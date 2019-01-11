Spree::CheckoutController.class_eval do
  prepend_before_action :check_registration,
    except: [:registration, :update_registration]
  prepend_before_action :check_authorization

  # This action builds some associations on the order, ex. addresses, which we
  # don't to build or save here.
  skip_before_action :setup_for_current_state, only: [:registration, :update_registration]

  def registration
    @user = Spree::User.new
  end

  def update_registration
    if params[:order][:email] =~ Devise.email_regexp && current_order.update_attributes(email: params[:order][:email]) # FIXME Devise.email_regexp
      redirect_to spree.checkout_path
    else
      flash[:registration_error] = t(:email_is_invalid, scope: [:errors, :messages])
      @user = Spree::User.new
      render 'registration'
    end
  end

  private
    def order_params
      params.
        fetch(:order, {}).
        permit(:email)
    end

    def skip_state_validation?
      %w(registration update_registration).include?(params[:action])
    end

    def check_authorization
      authorize!(:edit, current_order, cookies.signed[:guest_token])
    end

    # Introduces a registration step whenever the +registration_step+ preference is true.
    def check_registration
      return unless registration_required?
      store_location
      redirect_to spree.checkout_registration_path
    end

    def registration_required?
      Spree::Auth::Config[:registration_step] && # spostare anche il setting
        !already_registered?
    end

    def already_registered?
      spree_current_user || guest_authenticated? # usare try_spree_current_user
    end

    def guest_authenticated?
      current_order.try!(:email).present? &&
        Spree::Config[:allow_guest_checkout] # spostare il setting
    end

    # Overrides the equivalent method defined in Spree::Core.  This variation of the method will ensure that users
    # are redirected to the tokenized order url unless authenticated as a registered user.
    def completion_route
      return spree.order_path(@order) if spree_current_user
      spree.token_order_path(@order, @order.guest_token)
    end

    # dentro solidus c'è:
    # def completion_route
    #   spree.order_path(@order)
    # end
    # magari così può funzionare dentro solidus:
    def completion_route
      return spree.order_path(@order) if try_spree_current_user || !@order.guest_token
      spree.token_order_path(@order, @order.guest_token) if @order.guest_token
    end
end
