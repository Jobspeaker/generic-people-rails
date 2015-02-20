module GenericPeopleRails
  class CredentialsController < ApplicationController
    layout GenericPeopleRails::Config.layout
    before_filter :check_logged_in
    
    # for changing password
    def resend_confirmation
      @params = params
      email = @params[:email]
      if email.present?
        get_valid_cred(email)
        if @cred
          @cred.update(uid: SecureRandom.uuid)
          GprMailer.resend_confirmation(@cred.member, @cred).deliver if defined?(ActionMailer)     
          flash[:notice] = "Your confirmation email has been resent." 
        end
      end
    end
    
    def confirm_account
      email = params[:email]
      token = params[:token]     
      uid = params[:uid]
      if email.present? && token.present?
        useremail = Email.where(address: email).first
        cred = Credential.find_by(email_id: useremail.id, uid: token) if useremail
        if useremail && cred
          @member = cred.member
          if @member.id == uid.to_i
            @member.update(status: 'confirmed')
            useremail.update(confirmed: true)
            GprMailer.confirmed(@member).deliver        
            flash[:notice] = "Thank you, your account has been confirmed!"
          else
            flash[:alert] = "Valid account not found"
          end
        else
          flash[:alert] = "Valid account not found"
        end
      else
        flash[:alert] = "Valid account not found"
      end
      redirect_to main_app.root_url
    end    
  
    def forgot_password
      @params = params
      email = @params[:email]
      
      if email.present?
        get_valid_cred(email)
        if @cred
          #if cred.member.deleted_at.nil?
            @cred.update(uid: SecureRandom.uuid)
            GprMailer.reset_password(@cred.member, @cred).deliver if defined?(ActionMailer)        
            flash[:notice] = "An email has been sent to you with instructions on resetting your password."
          #else
            #flash.now[:error] = "Your account has been cancelled. Please contact an administrator"
          #end
        else
          flash[:error] = "Valid account not found"
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
        flash[:alert] = "Invalid User Account."
      else
        #form submit - process
        if params[:password] && params[:password_confirm] 
          id_mem = Member.find(params[:id])
          if id_mem != @member
            flash[:alert] = "Invalid User Account."
          else
            if params[:password] == params[:password_confirm]
              # set creds all with same password, make sure member field is populated (side effect of oauth).
              @cred.email.credentials.each do |c|
                c.member_id = @cred.email.member.id
                c.password = params[:password]
                c.save
              end
              #@cred.update(password: params[:password])
              GprMailer.password_was_reset(@member).deliver if defined?(ActionMailer)        
              flash[:notice] = "Congratulations You reset your password."
            else
              flash[:alert] = "Your passwords do not match!"
            end
          end
        end
      end
    end
    
    private
      def check_logged_in
        if authenticated? 
          redirect_to main_app.root_url
        end
      end
      
      def get_valid_cred(email)
        @email = Email.where(address: email).first
        if @email
          creds = Credential.where(email_id: @email.id)
          if creds.empty?
            @msg = "Valid account not found."
          else
            @cred = creds.first
            if GenericPeopleRails::Config.acts_paranoid && @cred.member.is_cancelled?
              @msg = "Your account has been closed. Please contact the site's administrator"
              @cred = nil
            end
          end
        else  
          @msg = "Valid account not found."
        end
      end
  end
end