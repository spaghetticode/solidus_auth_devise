class Spree::Admin::UserSessionsController < Devise::SessionsController
  helper 'spree/base'

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Store

  helper 'spree/admin/navigation'
  layout 'spree/layouts/admin'

  def create # FIXME da rivedere un po'
    authenticate_spree_user! # da scrivere dentro a solidus

    if spree_user_signed_in? # helper di devise
      respond_to do |format|
        format.html {
          flash[:success] = I18n.t('spree.logged_in_succesfully')
          redirect_back_or_default(after_sign_in_path_for(spree_current_user)) #helper di devise, e poi usare try_spree_current_user
        }
        format.js {
          user = resource.record
          render json: {ship_address: user.ship_address, bill_address: user.bill_address}.to_json
        }
      end
    else
      flash.now[:error] = t('devise.failure.invalid')
      render :new
    end
  end

  def authorization_failure
  end

  private
    def accurate_title
      I18n.t('spree.login')
    end

    # FIXME mmm... queste chiavi mi sembrano tutte roba di devise
    def redirect_back_or_default(default)
      redirect_to(session["spree_user_return_to"] || default)
      session["spree_user_return_to"] = nil
    end
end
