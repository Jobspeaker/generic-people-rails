GenericPeopleRails.config do |config|
  # uncomment these to change them
  # by changing the default status to 'active', 
  # you allow a user to use the site before they
  # confirm their email address.
  # a pending status requires the user to confirm 
  # their email before gaining access to the app
  #config.default_member_status = 'pending'

  #config.active_status = 'active'
  #config.confirmed_status = 'confirmed'
  
  # add a layout to the views
  #config.layout = 'signup'
  
  # keep this here so root_path and other main_app urls in your layouts work.
  GenericPeopleRails::ApplicationController.send(:include, Rails.application.routes.url_helpers)
  
end
