class Users::RegistrationsController < Devise::RegistrationsController
  include Devise::Controllers::UrlHelpers
  
#  layout 'default'
#  layout 'application', only: [:edit, :update]
  before_action :configure_permitted_parameters

  # add member to user credentials
  def create
    build_resource(sign_up_params)
       
    resource.credentials = Member.find_by_email(sign_up_params[:email])
    
    if resource.credentials.nil?
      set_flash_message :error, :'Ongeldige e-mailadres.'
      
      clean_up_passwords resource
      set_minimum_password_length
      render 'new'
    end
    
    resource_saved = resource.save
    
    yield resource if block_given?
    
    if resource_saved
      set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
      expire_data_after_sign_in!
      redirect_to new_user_session_path
    else    
      clean_up_passwords resource
      set_minimum_password_length
      render 'new'
    end
  end

  # override for adding layout to this view
  def edit
    render :edit, :layout => 'application'
  end
  
  # make sure the admin is also updated seperatly
  def update
    params = account_update_params
    credentials = params.delete(:credentials)
    
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, params)
    
    yield resource if block_given?
    
    if resource_updated
      flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
      set_flash_message :notice, flash_key
      
      if resource.admin?
        Admin.find(credentials[:id]).update_attributes(credentials)
      end
      
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: :edit_registration
    else
      clean_up_passwords resource
      respond_with(resource, :layout => 'application')
    end
  end

  protected

  # don't allow automatic sign_in for members
  def sign_up(resource_name, resource)
    if resource.admin?
      sign_in(resource_name, resource)
    end
  end
  
  # allow admin attributes on update user
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit({:credentials => [:id, :type, :first_name, :infix, :last_name, :signature]}, :email, :password, :password_confirmation, :current_password) }
  end
  
  # Sets minimum password length to show to user
  def set_minimum_password_length
    @validatable = devise_mapping.validatable?
    if @validatable
      @minimum_password_length = resource_class.password_length.min
    end
  end

end