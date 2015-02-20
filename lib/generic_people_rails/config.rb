module GenericPeopleRails
  module Config
    
    class << self

      def default_member_status=(status)
        @default_member_status = status
      end
      def default_member_status
        @default_member_status || 'pending'
      end
      
      def active_status=(status)
        @active_status = status
      end
      def active_status
        @active_status || 'active'
      end

      def confirmed_status=(status)
        @confirmed_status = status
      end
      def confirmed_status
        @confirmed_status || 'confirmed'
      end
      
      def cancelled_status=(status)
        @cancelled_status = status
      end
      def cancelled_status
        @cancelled_status || 'cancelled'
      end
      
      # layout to use in controller actions
      def layout=(layout)
        @layout = layout
      end
      def layout
        @layout || 'application'
      end
      
      # true/false if you want the member model to be saved when deleted
      def acts_paranoid=(acts_paranoid)
        @acts_paranoid = acts_paranoid
      end
      def acts_paranoid
        @acts_paranoid || true
      end
      
      # true/false if you want the welcome email to be sent after member creation
      def send_welcome=(send_welcome)
        @send_welcome = send_welcome
      end
      def send_welcome
        @send_welcome || true
      end      
            
    end
  end
end
