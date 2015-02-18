GenericPeopleRails::Engine.routes.draw do
  match "generic_people_rails/forgot_password" => "credentials#forgot_password" , as: :forgot_password, via: [:get , :post]
  match "generic_people_rails/reset_password" => "credentials#reset_password" , as: :reset_password, via: [:get , :post]  
  match "generic_people_rails/resend_confirmation" => "credentials#resend_confirmation" , as: :resend_confirmation, via: [:get, :post]   
  match "generic_people_rails/confirm_account" => "credentials#confirm_account" , as: :confirm_account, via: :get
end

Rails.application.routes.draw do
  match "forgot_password" => "generic_people_rails/credentials#forgot_password" , as: :forgot_password, via: [:get , :post]
  match "reset_password" => "generic_people_rails/credentials#reset_password" , as: :reset_password, via: [:get , :post]
  match "resend_confirmation" => "generic_people_rails/credentials#resend_confirmation" , as: :resend_confirmation, via: [:get, :post]  
  match "confirm_account" => "generic_people_rails/credentials#confirm_account" , as: :confirm_account, via: :get   
end