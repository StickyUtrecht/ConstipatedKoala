#:nodoc:
class Users::RegistrationsController < ActionController::Base
  protect_from_forgery with: :exception
  layout 'doorkeeper'

  def new
    @user = User.new
    render 'devise/registrations/new'
  end

  def create
    if User.find_by_email sign_up_params[:email]
      User.send_reset_password_instructions(sign_up_params.slice(:email))
      flash[:alert] = I18n.t :signed_up_but_unconfirmed, scope: 'devise.registrations'

      redirect_to :new_user_session
      return
    end

    @user = User.new sign_up_params
    @user.credentials = Member.find_by_email sign_up_params[:email]

    flash[:alert] = nil

    if @user.credentials.nil?
      flash[:alert] = I18n.t :not_found_in_database, scope: 'devise.registrations'
      render 'devise/registrations/new'
      return
    end

    if @user.save
      flash[:notice] = I18n.t :signed_up_but_unconfirmed, scope: 'devise.registrations'
      redirect_to :new_user_session
    else
      render 'devise/registrations/new'
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
