GenericPeopleRails.config do |config|
  # uncomment these to change them
  # by changing the default status to 'active', 
  # you allow a user to use the site before they
  # confirm their email address.
  # a pending status requires the user to confirm 
  # their email before gaining access to the app
  # note - fb sign up users default to active_status as email confirmation is not required
  #config.default_member_status = 'pending'
  
  #config.active_status = 'active'
  #config.confirmed_status = 'confirmed'
  #config.cancelled_status = 'cancelled'
  
  # add a layout to the views
  #config.layout = 'signup'
  
  # allows member data to be kept in the database when destroyed
  # default = true
  # uncomment to turn off
  #config.acts_paranoid = false
  
  # sends welcome email when member created
  # default = true
  # uncomment to turn off
  #config.send_welcome = false  
  
end
