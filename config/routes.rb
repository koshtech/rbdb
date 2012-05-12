Rbdb::Application.routes.draw do
  resources :settings

  resources :environments

  resources :databs, :as => 'databases' do |datab|
    datab.resources :tables do |table|
      table.resources :rows
      table.resources :searches
      table.resources :graphs
    end
    datab.relations_graph '/relations/:table_id/graph.:format', :controller => 'relations',
      :action => 'graph'
    datab.resources :relations
    datab.resources :sqls
  end


  match ':controller/:action/:id'
  match ':controller/:action/:id.:format'

  root :to => 'databs#index'
end
