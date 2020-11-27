# frozen_string_literal: true

module Spree
  module UsersControllerDecorator
    def self.prepended(base)
      puts "** prepending #{base} in solidus_auth_devise"
      base.prepend_before_action :authorize_actions, only: :new
      base.prepend_before_action :load_object, only: [:show, :edit, :update]
    end

    def create
      @user = Spree::User.new(user_params)
      if @user.save

        if current_order
          session[:guest_token] = nil
        end

        redirect_back_or_default(root_url)
      else
        render :new
      end
    end

    def update
      if @user.update(user_params)
        spree_current_user.reload

        if params[:user][:password].present?
          # this logic needed b/c devise wants to log us out after password changes
          unless Spree::Auth::Config[:signout_after_password_change]
            bypass_sign_in(@user)
          end
        end
        redirect_to spree.account_url, notice: I18n.t('spree.account_updated')
      else
        render :edit
      end
    end

    private

    def user_params
      params.require(:user).permit(Spree::PermittedAttributes.user_attributes | [:email])
    end

    def authorize_actions
      authorize! params[:action].to_sym, Spree::User.new
    end

    Spree::UsersController.prepend(self)
  end
end
