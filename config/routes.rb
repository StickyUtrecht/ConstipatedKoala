ConstipatedKoala::Application.routes.draw do
  constraints :subdomain => 'intro' do
    get  '/', to: 'public#index', as: 'public'
    post '/', to: 'public#create'

    get 'confirm', to: 'public#confirm'
  end

  constraints :subdomain => 'koala' do
    # You can have the root of your site routed with "root"
    root 'home#index'

    # Home controller
    get 'home', to: 'home#index'

    # Devise routes
    devise_for :admins, controllers:
    {
      registrations: "admin_devise/registrations",
      unlocks: "admin_devise/unlocks",
      passwords: "admin_devise/passwords"
    }

    # Resource pages
    resources :members, :activities

    # Participants routes for JSON calls
    get    'participants/list', to: 'participants#list'
    get    'participants',      to: 'participants#find'
    post   'participants',      to: 'participants#create'
    patch  'participants',      to: 'participants#update'
    delete 'participants',      to: 'participants#destroy'
  end

  get '/', to: redirect('/404')
end
