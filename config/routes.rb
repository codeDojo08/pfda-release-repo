Rails.application.routes.draw do
  #
  # Remove the ability to switch formats (i.e. /foo vs /foo.json or /foo.xml)
  # by wrapping everything into a scope
  #
  scope(format: false) do

    # Main controller
    get 'login' => 'main#login'
    delete 'logout' => 'main#destroy'
    get 'return_from_login' => 'main#return_from_login'
    post 'publish' => 'main#publish'
    get 'track' => 'main#track'
    get 'request_access' => 'main#request_access'
    post 'request_access' => 'main#request_access'
    get 'browse_access' => 'main#browse_access'
    post 'browse_access' => 'main#browse_access'
    get 'about' => 'main#about'
    get 'about/:section' => 'main#about'
    get 'terms' => 'main#terms'
    post 'tokify' => 'main#tokify'
    post 'set_tags' => 'main#set_tags'
    get 'guidelines' => 'main#guidelines'
    get 'exception_test' => "main#exception_test"
    get 'presskit' => 'main#presskit'
    get 'news' => 'main#news'

    # API
    post '/api/publish', to: 'api#publish'
    post '/api/create_file', to: 'api#create_file'
    post '/api/create_image_file', to: 'api#create_image_file'
    post '/api/get_upload_url', to: 'api#get_upload_url'
    post '/api/get_file_link', to: 'api#get_file_link'
    post '/api/list_related', to: 'api#list_related'
    post '/api/close_file', to: 'api#close_file'
    post '/api/describe', to: 'api#describe'
    post '/api/list_files', to: 'api#list_files'
    post '/api/list_notes', to: 'api#list_notes'
    post '/api/list_comparisons', to: 'api#list_comparisons'
    post '/api/list_apps', to: 'api#list_apps'
    post '/api/list_assets', to: 'api#list_assets'
    post '/api/list_jobs', to: 'api#list_jobs'
    post '/api/describe_license', to: 'api#describe_license'
    post '/api/accept_licenses', to: 'api#accept_licenses'
    post '/api/run_app', to: 'api#run_app'
    post '/api/get_app_spec', to: 'api#get_app_spec'
    post '/api/get_app_script', to: 'api#get_app_script'
    post '/api/export_app', to: 'api#export_app'
    post '/api/search_assets', to: 'api#search_assets'
    post '/api/create_asset', to: 'api#create_asset'
    post '/api/close_asset', to: 'api#close_asset'
    post '/api/create_app', to: 'api#create_app'
    post '/api/attach_to_notes', to: 'api#attach_to_notes'
    post '/api/update_note', to: 'api#update_note'
    post '/api/upvote', to: 'api#upvote'
    post '/api/remove_upvote', to: 'api#remove_upvote'
    post '/api/follow', to: 'api#follow'
    post '/api/unfollow', to: 'api#unfollow'
    post '/api/update_submission', to: 'api#update_submission'

    # FHIR
    scope '/fhir' do
      get 'Sequence', to: 'comparisons#fhir_index'
      get 'metadata', to: 'comparisons#fhir_cap'
      get 'Sequence/:id', to: 'comparisons#fhir_export', id: /comparison-\d+/
    end

    # Profile
    get 'profile', to: 'profile#index'
    post 'profile/provision_user', to: 'profile#provision_user', as: 'provision_user'
    post 'profile/provision_org', to: 'profile#provision_org', as: 'provision_org'
    post 'profile/run_report', to: 'profile#run_report', as: 'run_report'

    resources :apps do
      resources :jobs, only: [:new, :create]
      get 'jobs', on: :member, to: 'apps#index'
      member do
        get 'fork'
        post 'export'
      end
      get 'featured', on: :collection, as: 'featured'
      get 'explore', on: :collection, as: 'explore'
      resources :comments
    end

    resources :jobs, except: :index do
      member do
        get 'log'
      end
      resources :comments
    end

    resources :comparisons do
      post 'rename', on: :member
      get 'visualize', on: :member
      get 'featured', on: :collection, as: 'featured'
      get 'explore', on: :collection, as: 'explore'
      resources :comments
    end

    resources :files do
      post 'download', on: :member
      post 'link', on: :member
      post 'rename', on: :member
      get 'featured', on: :collection, as: 'featured'
      get 'explore', on: :collection, as: 'explore'
      resources :comments
    end

    resources :notes do
      post 'rename', on: :member
      get 'featured', on: :collection, as: 'featured'
      get 'explore', on: :collection, as: 'explore'
      resources :comments
    end

    resources :assets, path: '/app_assets' do
      post 'rename', on: :member
      get 'featured', on: :collection, as: 'featured'
      get 'explore', on: :collection, as: 'explore'
      resources :comments
    end

    get "challenges/#{ACTIVE_META_APPATHON}" => "meta_appathons#show", as: 'active_meta_appathon'
    get "challenges/#{APPATHON_IN_A_BOX_HANDLE}", as: 'appathon_in_a_box'
    resources :challenges do
      get 'consistency(/:tab)', on: :collection, action: :consistency, as: 'consistency'
      get 'truth(/:tab)', on: :collection, action: :truth, as: 'truth'
      get 'join', on: :member
      get 'view(/:tab)', on: :member, action: :show, as: 'show'
      resources :submissions, only: [:new, :create, :edit] do
        post 'publish', on: :collection, action: :publish
        get 'log', on: :member
      end
      post 'assign_app', on: :member
    end

    resources :discussions, constraints: {answer_id: /[^\/]+/ } do
      get 'followers', on: :member
      post 'rename', on: :member
      resources :answers, constraints: {id: /[^\/]+/} do
        resources :comments
      end
      resources :comments
    end

    resources :licenses do
      post 'accept(/:redirect_to_uid)', on: :member, action: :accept, as: 'accept'
      match 'request_approval', on: :member, action: :request_approval, as: 'request_approval', via: [:get, :post]
      post 'license_item/:item_uid', on: :member, action: :license_item, as: 'license_item'
      post 'remove_item/:item_uid(/:redirect_to_uid)', on: :member, action: :remove_item, as: 'remove_item'
      post 'remove_user/:user_uid(/:redirect_to_uid)', on: :member, action: :remove_user, as: 'remove_user'
      post 'approve_user/:user_uid(/:redirect_to_uid)', on: :member, action: :approve_user, as: 'approve_user'
      post 'remove_items', on: :member
      post 'remove_users', on: :member
      post 'approve_users', on: :member
      post 'rename', on: :member
      get 'users', on: :member
      get 'items', on: :member
    end

    resources :experts do
      post 'ask_question', on: :member
      post 'open', on: :member
      post 'close', on: :member
      get 'dashboard', on: :member
      get 'blog', on: :member
      nested do
        scope '/dashboard' do
          resources :expert_questions, as: 'edit_question'
        end
      end
      resources :expert_questions, only: [:create, :destroy] do
          get '', on: :member, to: 'expert_questions#show_question', as: 'show_question'
          resources :comments
      end
    end

    resources :spaces do
      get 'members', on: :member
      get 'content', on: :member
      get 'discuss', on: :member
      post 'accept', on: :member
      post 'rename', on: :member
      post 'invite', on: :member
      resources :comments
    end

    resources :meta_appathons, constraints: {appathon_id: /[^\/]+/ }  do
      post 'rename', on: :member
      resources :appathons, constraints: {id: /[^\/]+/}
    end

    resources :appathons, constraints: {id: /[^\/]+/} do
      post 'rename', on: :member
      post 'join', on: :member
      resources :comments
    end

    resources :queries do
    end

    resources :docs do
      get ":section", on: :collection, action: :show, as: 'show'
    end

    user_constraints = { username: /[^\/]*/ }
    get "/users/:username(/:tab)", to: 'users#show', constraints: user_constraints, as: 'user'

    # You can have the root of your site routed with "root"
    root 'main#index'
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
