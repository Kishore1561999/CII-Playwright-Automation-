Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }
  devise_scope :user do
    get 'users/show' => 'registrations#show', as: "profile"
    post '/checkisin', to: 'registrations#isincheck'
    get 'service/renew' => 'registrations#service_renew', as: "service_renew"
    post 'renew/upgrading', to: 'registrations#renew_upgrading' , as: "renew_upgrading"
    get 'service/upgradation' => 'registrations#service_upgrade', as: "service_upgrade"
    post '/upgrading', to: 'registrations#upgrading' , as: "upgrading"
    get '/email_validation/check' => 'registrations#email_validation', as: "email_validation"
  end
  get '/users/:id/edit', to: 'profile#edit', as: 'profile_password'
  patch '/users/:id/update', to: 'profile#update', as: 'update_profile_password'

  root to: 'dashboard#index', as: 'dashboard'

  get 'states/:country', to: 'application#states'
  get 'cities/:state', to: 'application#cities'

  get '/rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)', to: "active_storage/blobs/redirect#show"
  get '/rails/active_storage/disk/:encoded_key/*filename(.:format)', to: "active_storage/disk#show"

  get '/download/:company_user_id/pdf_assessment/:user_type', to: 'downloads#assessment_pdf', as: 'download_assessment_pdf'
  get '/download/pdf_assessment_file/:file_id', to: 'downloads#assessment_pdf_attachment', as: 'download_assessment_pdf_attachment'
  post '/download_attachments', to: "downloads#process_and_create_zip_file", as: 'download_documents'
  get '/download_excel/:user_type/:company_user_id', to: 'downloads#download_excel_score_report', as: 'download_excel_report'
  patch '/score/:company_user_id/generate_score_card', to: 'score#generate_score_card', as: 'generate_score_card'

  get '/upload_chart/:company_user_id', to: 'word_report#upload_chart', as: 'upload_chart'
  post '/upload_graph_image/:company_user_id', to: 'word_report#upload_graph_image', as: 'upload_graph_image'
  get '/word_document/:company_user_id', to: 'word_report#word_document', as: 'word_document'
  get '/download_word_document/:company_user_id', to: 'word_report#download_word_document', as: 'download_word_document'
  
  scope module: 'service', path: 'service' do
      get '/basic_subscription', to: 'basic_subscription#index', as: 'basic_subscription'
      patch '/basic_subscription/:id/update_status/:status', to: 'basic_subscription#update_status', as: 'admin_basic_subscription_update_status'
      get 'basic_subscription/export_excel', to: 'basic_subscription#export_excel', as: 'basic_export_excel'
      delete 'basic_subscription/:id', to: 'basic_subscription#destroy', as: 'delete_basic_company_user'
      get 'subscription_user_basic/:id/edit', to: 'basic_subscription#edit', as: 'edit_basic_user_details'
      get '/premium_subscription', to: 'premium_subscription#index', as: 'premium_subscription'
      patch '/premium_subscription/:id/update_status/:status', to: 'premium_subscription#update_status', as: 'premium_subscription_update_status'
      get 'premium_subscription/export_excel', to: 'premium_subscription#export_excel', as: 'premium_export_excel'
      delete 'premium_subscription/:id', to: 'premium_subscription#destroy', as: 'delete_premium_company_user'
      get 'subscription_user/:id/edit', to: 'premium_subscription#edit', as: 'edit_premium_user_details'
      put 'subscription_user/update_user', to: 'premium_subscription#update', as: 'premium_user_update_details'
      get '/peer_benchmark', to: 'peer_benchmarking#index', as: 'cii_peer_benchmarking'
      patch '/peer_benchmark/update_duplicate_company', to: 'peer_benchmarking#update_duplicate_company', as: 'peer_benchmarking_update_duplicate_company'
      patch '/peer_benchmark/:id/update_status/:status', to: 'peer_benchmarking#update_status', as: 'peer_benchmarking_update_status'
      get '/data_collection', to: 'data_collection#index', as: 'data_collection_dashboard'
      get '/data_collection/:company_id/provide_data', to: 'data_collection#data_collection_assessment', as: 'data_collection_assessment'
      post '/data_collection/:company_id/save_data', to: 'data_collection#save_data_collection_assessment', as: 'save_providedata'
      get '/data_collection/:company_id/fetch_provide_data', to: 'data_collection#fetch_data_collection_data', as: 'fetch_provide_data'
      post '/data_collection/:company_id/data_automation', to: 'data_collection#data_automation', as: 'data_automation'
      post '/data_collection/data_collection_company', to: 'data_collection#data_collection_company', as: 'data_collection_company_creation' 
      get '/data_collection/:company_id/view_providedata', to: 'data_collection#view_providedata', as: 'view_providedata'
      post '/data_collection/:company_id/submit_providedata', to: 'data_collection#submit_providedata', as: 'submit_providedata'
      get '/data_collection/fetch_companydata', to: 'data_collection#fetch_companydata', as: 'fetch_companydata'
      delete '/data_collection/destroy', to: 'data_collection#destroy', as: 'deletecompanydata'
      patch '/data_collection/:id/assign_analyst', to: 'data_collection#assign_analyst', as: 'assign_analyst'
      post '/data_collection/pushback', to: 'data_collection#pushback', as: 'pushback'
      post '/data_collection/:company_id/clear', to: 'data_collection#clear', as: 'clearAnswerdata'
      get '/data_collection/company_exists', to: 'data_collection#company_exists', as: 'data_collection_company_exists'
      get '/data_analytics', to: 'data_analytics#index', as: 'data_analytics'
      get 'data_analytics/download_analytics_sector_specific_report', to: 'data_analytics#download_analytics_sector_specific_report', as: 'download_analytics_sector_specific_report'
      get 'data_analytics/download_analytics_general_specific_report', to: 'data_analytics#download_analytics_general_specific_report', as: 'download_analytics_general_specific_report'
      get 'cii_publication/index', to: 'cii_publication#index', as: 'publication_admin_dashboard' 
      post '/cii_publication/publication_creation', to: 'cii_publication#publication_creation', as: 'publication_creation'
      delete '/cii_publication/destroy', to: 'cii_publication#destroy', as: 'delete_publication'
      get 'cii_elearning/index', to: 'cii_elearning#index', as: 'elearning_admin_dashboard' 
      post '/cii_elearning/elearning_creation', to: 'cii_elearning#elearning_creation', as: 'elearning_creation'
      get '/cii_elearning/fetch_elearning', to: 'cii_elearning#fetch_elearning', as: 'fetch_elearning_elearning'
      delete '/cii_elearning/destroy', to: 'cii_elearning#destroy', as: 'delete_elearning'
      get '/cii_elearning/fetch_details', to: 'cii_elearning#fetch_details', as: 'fetch_details_elearning'
      patch '/cii_elearning/update_status/:status', to: 'cii_elearning#update_status', as: 'admin_cii_elearning_update_status'
      get '/cii_elearning/no_of_downloads', to: 'cii_elearning#no_of_downloads', as: 'no_of_downloads_elearning'
  end
 
  scope module: 'admin', path: 'esgadmin' do
    authenticate :user, lambda { |u| u.is_admin? } do
      get '/dashboard', to: 'dashboard#index', as: 'admin_dashboard'

      resources :users, param: :id, controller: 'users', path: '/users'
      resources :users, param: :id, controller: 'company_users', path: '/company_users', as: :admin_company_users
      get '/filter_company_users', to: 'company_users#filter_company_users', as: 'admin_filter_company_users'
      patch '/company_users/:id/update_status/:status', to: 'company_users#update_status', as: 'admin_company_user_status'
      patch '/company_users/:id/assign_analyst', to: 'company_users#assign_analyst', as: 'admin_assign_analyst'
      resources :emails
      get '/assessment/:company_user_id/view_assessment/:user_type', to: 'assessment#view_assessment', as: 'admin_view_assessment'
      get '/assessment/:company_user_id/edit_assessment/:user_type', to: 'assessment#edit_assessment', as: 'admin_edit_assessment'
      get '/assessment/:company_user_id/fetch_assessment', to: 'assessment#fetch_assessment', as: 'admin_fetch_assessment'
      patch '/assessment/:company_user_id/update_assessment', to: 'assessment#update_assessment', as: 'admin_update_assessment'
      patch '/assessment/:company_user_id/submit_assessment', to: 'assessment#submit_assessment', as: 'admin_submit_assessment'
      post '/assessment/:company_user_id/add_attachments', to: 'assessment#add_attachments', as: 'admin_add_attachments'
      post '/assessment/:company_user_id/remove_attachment', to: 'assessment#remove_attachment', as: 'admin_remove_attachment'
            
    end
  end

  scope module: 'analyst', path: 'analyst' do
    authenticate :user, lambda { |u| u.is_analyst? } do
      get '/dashboard', to: 'dashboard#index', as: 'analyst_dashboard'

      get '/assessment/:company_user_id/view_assessment/:user_type', to: 'assessment#view_assessment', as: 'analyst_view_assessment'
      get '/assessment/:company_user_id/edit_assessment/:user_type', to: 'assessment#edit_assessment', as: 'analyst_edit_assessment'
      get '/assessment/:company_user_id/fetch_assessment', to: 'assessment#fetch_assessment', as: 'analyst_fetch_assessment'
      patch '/assessment/:company_user_id/update_assessment', to: 'assessment#update_assessment', as: 'analyst_update_assessment'
      patch '/assessment/:company_user_id/submit_assessment', to: 'assessment#submit_assessment', as: 'analyst_submit_assessment'
      post '/assessment/:company_user_id/add_attachments', to: 'assessment#add_attachments', as: 'analyst_add_attachments'
      post '/assessment/:company_user_id/remove_attachment', to: 'assessment#remove_attachment', as: 'analyst_remove_attachment'
      get '/data_collection', to: 'analyst_data_collection#index', as: 'analyst_data_collection'
      post '/data_collection/data_collection_company', to: 'analyst_data_collection#data_collection_company', as: 'analyst_data_collection_company_creation'
      get '/analyst_data_collection/fetch_companydata', to: 'analyst_data_collection#fetch_companydata', as: 'analyst_fetch_companydata'
      delete '/analyst_data_collection/destroy', to: 'analyst_data_collection#destroy', as: 'analyst_deletecompanydata'
      get '/analyst_data_collection/:company_id/view_providedata', to: 'analyst_data_collection#view_providedata', as: 'analyst_view_providedata'
      get '/analyst_data_collection/:company_id/provide_data', to: 'analyst_data_collection#data_collection_assessment', as: 'analyst_data_collection_assessment'
      post '/analyst_data_collection/:company_id/save_data', to: 'analyst_data_collection#save_data_collection_assessment', as: 'analyst_save_providedata'
      post '/analyst_data_collection/:company_id/submit_providedata', to: 'analyst_data_collection#submit_providedata', as: 'analyst_submit_providedata'
      get '/analyst_data_collection/:company_id/fetch_provide_data', to: 'analyst_data_collection#fetch_data_collection_data', as: 'analyst_fetch_provide_data'
      post '/analyst_data_collection/:company_id/data_automation', to: 'analyst_data_collection#data_automation', as: 'analyst_data_automation'
      post '/analyst_data_collection/:company_id/clear', to: 'analyst_data_collection#clear', as: 'analystclearAnswerdata'
      get '/analyst_data_collection/company_exists', to: 'analyst_data_collection#company_exists', as: 'analyst_data_collection_company_exists'
    end
  end

  scope module: 'company_user', path: 'company_user' do
    authenticate :user, lambda { |u| u.is_company_user? } do
      get '/dashboard', to: 'dashboard#index', as: 'company_user_dashboard'
      patch 'update_user_sector', to: 'peer_benchmark#update_user_sector', as: 'update_sector'

      get '/take_assessment', to: 'assessment#take_assessment', as: 'take_assessment'
      get '/fetch_assessment', to: 'assessment#fetch_assessment', as: 'fetch_assessment'
      post '/save_assessment', to: 'assessment#save_assessment', as: 'save_assessment'
      post '/submit_assessment', to: 'assessment#submit_assessment', as: 'submit_assessment'
      get '/view_assessment', to: 'assessment#view_assessment', as: 'view_assessment'
      post '/add_attachments', to: 'assessment#add_attachments', as: 'add_attachments'
      post '/remove_attachment', to: 'assessment#remove_attachment', as: 'remove_attachment'
      post '/send_inquiry_email', to: 'dashboard#send_inquiry_email'
      get '/fetch_peerbenchmark_data', to: 'peer_benchmark#fetch_peerbenchmark_data', as: 'fetch_peerbenchmark_data'
      get '/peer_benchmarking', to: 'peer_benchmark#peer_benchmarking', as: 'peer_benchmarking'
      post '/save_peerbenchmark_assessment', to: 'peer_benchmark#save_peerbenchmark_assessment'
      post '/set_cookie', to: 'peer_benchmark#set_cookie'
      get '/peer_benchmark_assessment', to: 'peer_benchmark#peer_benchmark_assessment', as: 'peer_benchmark_assessment'
      get '/esg_learnings', to: 'esg_learning#esg_learnings', as: 'esg_learnings'
      post '/esg_learning/approval', to: 'esg_learning#approval', as: 'esg_learning_approval'
      get '/publications', to: 'publication#publications', as: 'publications'
      get '/peer_benchmark_answer_exist', to: 'peer_benchmark#peer_benchmark_answer_exist'
      delete '/delete_peer_benchmark_answer', to: 'peer_benchmark#delete_peer_benchmark_answer'
      patch '/update_peer_benchmark_answer', to: 'peer_benchmark#update_peer_benchmark_answer'
      get '/analytics', to: 'peerbenchmark_analytics#analytics_dashboard', as: 'analytics'
      get '/analytics_calculation', to: 'peerbenchmark_analytics#analytics_calculation', as: 'analytics_calculation'
      get '/analytics_graph', to: 'peerbenchmark_analytics#analytics_graphs', as: 'analytics_graphs'
      get '/fetch_analytics_graphs_data', to: 'peerbenchmark_analytics#fetch_analytics_graphs_data', as: 'fetch_analytics_graphs_data'
      post '/peer_benchmark/upload_pdf', to: 'peer_benchmark#upload_pdf', as: 'upload_pdf_report'
      patch '/update_consent', to: 'peer_benchmark#update_consent', as: 'peer_benchmark_update_consent'
      post '/esg_learning/free_download', to: 'esg_learning#free_download', as: 'esg_learning_free_download'
    end
  end

  scope module: 'manager', path: 'manager' do
    authenticate :user, lambda { |u| u.is_manager? } do
      get '/dashboard', to: 'dashboard#index', as: 'manager_dashboard'

      resources :users, param: :id, controller: 'company_users', path: '/company_users', as: :manager_company_users
      get '/filter_company_users', to: 'company_users#filter_company_users', as: 'manager_filter_company_users'
      patch '/company_users/:id/update_status/:status', to: 'company_users#update_status', as: 'manager_company_user_status'
      patch '/company_users/:id/assign_analyst', to: 'company_users#assign_analyst', as: 'manager_assign_analyst'
      get '/assessment/:company_user_id/view_assessment/:user_type', to: 'assessment#view_assessment', as: 'manager_view_assessment'
      get '/assessment/:company_user_id/edit_assessment/:user_type', to: 'assessment#edit_assessment', as: 'manager_edit_assessment'
      get '/assessment/:company_user_id/fetch_assessment', to: 'assessment#fetch_assessment', as: 'manager_fetch_assessment'
      patch '/assessment/:company_user_id/update_assessment', to: 'assessment#update_assessment', as: 'manager_update_assessment'
      patch '/assessment/:company_user_id/submit_assessment', to: 'assessment#submit_assessment', as: 'manager_submit_assessment'
      post '/assessment/:company_user_id/add_attachments', to: 'assessment#add_attachments', as: 'manager_add_attachments'
      post '/assessment/:company_user_id/remove_attachment', to: 'assessment#remove_attachment', as: 'manager_remove_attachment'
    end
  end

  get '/privacy_policy.pdf', to: redirect('/privacy_policy.pdf')
  post '/report/report_details_analyst', to: 'report#report_details_analyst'
  post '/comments/create', to: 'comments#create'
  post '/comments/show', to: 'comments#show'

  match '*unmatched_route', to: 'errors#not_found', via: [:get, :post, :patch, :delete]
end
