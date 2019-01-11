Spree::Core::Engine.routes.draw do
  if (
    SolidusSupport.frontend_available? &&
    Spree::Auth::Config.draw_frontend_routes
  )

    devise_for(:spree_user, {
      class_name: 'Spree::User',
      controllers: {
        sessions: 'spree/user_sessions',          # eredita da devise
        registrations: 'spree/user_registrations',# eredita da devise
        passwords: 'spree/user_passwords',        # eredita da devise
        confirmations: 'spree/user_confirmations' # eredita da devise
      },
      skip: [:unlocks, :omniauth_callbacks],
      path_names: { sign_out: 'logout' },
      path_prefix: :user
    })

    resources :users, only: [:edit, :update]

    devise_scope :spree_user do
      get '/login', to: 'user_sessions#new', as: :login
      post '/login', to: 'user_sessions#create', as: :create_new_session
      match '/logout', to: 'user_sessions#destroy', as: :logout, via: Devise.sign_out_via
      get '/signup', to: 'user_registrations#new', as: :signup
      post '/signup', to: 'user_registrations#create', as: :registration
      get '/password/recover', to: 'user_passwords#new', as: :recover_password
      post '/password/recover', to: 'user_passwords#create', as: :reset_password
      get '/password/change', to: 'user_passwords#edit', as: :edit_password
      put '/password/change', to: 'user_passwords#update', as: :update_password
      get '/confirm', to: 'user_confirmations#show', as: :confirmation if Spree::Auth::Config[:confirmable]
    end

    get '/checkout/registration', to: 'checkout#registration', as: :checkout_registration # pagina del checkout per fare login/newaccount/forget password o farte checkout as guest (post su update_registration)
    put '/checkout/registration', to: 'checkout#update_registration', as: :update_checkout_registration # vedi sora

    resource :account, controller: 'users' # già in via di spostamento, nessun problema con questo
  end

  if (
    SolidusSupport.backend_available? &&
    Spree::Auth::Config.draw_backend_routes
  )

    namespace :admin do
      devise_for(:spree_user, {
        class_name: 'Spree::User',
        # singular: :spree_user,
        skip: :all,
        path_names: { sign_out: 'logout' },
        # controllers: {
        #   sessions: 'spree/admin/user_sessions',
        #   passwords: 'spree/admin/user_passwords'
        # },
      })

      devise_scope :spree_user do
        get '/authorization_failure', to: 'user_sessions#authorization_failure', as: :unauthorized
        get '/login', to: 'user_sessions#new', as: :login
        post '/login', to: 'user_sessions#create', as: :create_new_session
        get '/logout', to: 'user_sessions#destroy', as: :logout

        get '/password/recover', to: 'user_passwords#new', as: :recover_password
        post '/password/recover', to: 'user_passwords#create', as: :reset_password
        get '/password/change', to: 'user_passwords#edit', as: :edit_password
        put '/password/change', to: 'user_passwords#update', as: :update_password
      end
    end
  end
end

# il codice commentato apparentemente non serve

# la parte admin di queste rotte sembra non usare nulla di devise, perché non genera nessuna url coi controller di devise (skip :all)

