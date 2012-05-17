Rbdb::Application.routes.draw do
  resources :settings
  resources :environments

  resources :databases do
    resources :tables do |table|
      resources :rows
      resources :searches
      resources :graphs
    end

    resources :relations
    resources :sqls
  end

  match "login" => "accounts#login"

  root :to => 'databases#index'
end
