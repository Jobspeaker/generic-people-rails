module GenericPeopleRails
  class CredentialsController < ApplicationController
    layout GenericPeopleRails::Config.layout
    before_filter :check_logged_in
    
    # for changing password
    def resend_confirmation
        Rails.logger.debug "sending confirmation"
    end
  
    def forgot_password
      @params = params
      email = @params[:email]
      
      if email.present?
        useremail = Email.where(address: Email.canonicalize_address(email)).first
        if useremail
          creds = Credential.where(email_id: useremail.id)
          if creds.empty?
            @msg = "Valid account not found."
          else
            cred = creds.first
            #if cred.member.deleted_at.nil?
              cred.update(uid: SecureRandom.uuid)
              GprMailer.reset_password(cred.member, cred).deliver if defined?(ActionMailer)        
              flash.now[:notice] = "An email has been sent to you with instructions on resetting your password."
            #else
              #flash.now[:error] = "Your account has been cancelled. Please contact an administrator"
            #end
          end
        else
          flash.now[:error] = "Valid account not found"
        end
      end
    end
    
    def reset_password
      @params = params
      
      #check for credentials in forgot password email
      @member = Member.find(params[:uid])
      @cred = @member.credentials.find_by(uid: params[:token]) if @member
      if !(@member && @cred)
        #not the right guy
        flash.now[:alert] = "Invalid User Account."
      else
        #form submit - process
        if params[:password] && params[:password_confirm] 
          id_mem = Member.find(params[:id])
          if id_mem != @member
            flash.now[:alert] = "Invalid User Account."
          else
            if params[:password] == params[:password_confirm]
              @cred.update(password: params[:password])
              GprMailer.password_was_reset(@member).deliver if defined?(ActionMailer)        
              flash.now[:notice] = "Congratulations You reset your password. Click Sign In!"
            else
              flash.now[:alert] = "Your passwords do not match!"
            end
          end
        end
      end
    end
    
    private
      def check_logged_in
        logged_in_helper = GenericPeopleRails.config.logged_in_helper
        is_logged_in = true
        if logged_in_helper
          is_logged_in = send(logged_in_helper)
        end
        #for these actions, the user can't be logged in
        if is_logged_in
          redirect_to main_app.root_url
        end
      end
  end
end