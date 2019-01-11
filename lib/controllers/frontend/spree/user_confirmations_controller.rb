class Spree::UserConfirmationsController < Devise::ConfirmationsController
  helper 'spree/base', 'spree/store'

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Store


  def show # FIXME implicita definto in devise
    super
    # self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    # yield resource if block_given?

    # if resource.errors.empty?
    #   set_flash_message!(:notice, :confirmed)
    #   respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    # else
    #   respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    # end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    signed_in?(resource_name) ? spree.signed_in_root_path(resource) : spree.login_path
  end
end
