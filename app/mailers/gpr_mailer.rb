if defined?(ActionMailer)
  class GprMailer < ActionMailer::Base
    def setup(member=nil, cred=nil)
      @member = member
      @cred = cred
      @host = @gpr_frontend_host
      GprMailer.default_url_options[:host] ||= @host
    end
    
    def welcome(member, cred)
      setup(member, cred)
      mail(to: @member.email.address, subject: 'Welcome, please confirm your email!')
    end
    
    def resend_confirmation(member, cred)
      setup(member, cred)
      mail(to: @member.email.address, subject: 'Welcome, please confirm your email!')
    end
      
    def confirmed(member)
      setup(member)
      mail(to: @member.email.address, subject: 'Your account has been confirmed.')
    end
  
    #def account_cancelled(member)
    #  setup(member)
    #  
    #  mail(to: @member.email.address, subject: 'Your OurDesign subscription has been cancelled')
    #end

    def reset_password(member, cred)
      setup(member, cred)
      mail(to: @member.email.address, subject: 'Reset your password.')
    end
    
    def password_was_reset(member, cred)
      setup(member, cred)
      mail(to: @member.email.address, subject: 'Your password has been reset.')
    end    
    
  end
end
