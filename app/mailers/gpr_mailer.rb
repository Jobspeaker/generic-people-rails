if defined?(ActionMailer)
  class GprMailer < ActionMailer::Base
  
    def welcome(member, cred)
      @member = member
      @cred = cred
      mail(to: @member.email.address, subject: 'Welcome, please confirm your email!')
    end
    
    def resend_confirmation(member, cred)
      @member = member
      @cred = cred
      mail(to: @member.email_address, subject: 'Welcome, please confirm your email!')
    end
      
    def confirmed(member)
      @member = member
      mail(to: @member.email_address, subject: 'Your account has been confirmed.')
    end
  
    #def account_cancelled(member)
    #  @member = member
    #  
    #  mail(to: @member.email_address, subject: 'Your OurDesign subscription has been cancelled')
    #end

    def reset_password(member, cred)
      @member = member
      @cred = cred  
      mail(to: @member.email_address, subject: 'Reset your password.')
    end
    
    def password_was_reset(member)
      @member = member
      mail(to: @member.email_address, subject: 'Your password has been reset.')
    end    
    
  end
end