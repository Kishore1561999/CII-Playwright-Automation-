module NavbarHelper
  def is_dashboard_controller?
    controller.controller_name == 'dashboard'
  end

  def is_company_controller?
    controller.controller_name == 'company_users'
  end

  def is_user_controller?
    controller.controller_name == 'users'
  end

  def is_email_controller?
    controller.controller_name == 'emails'
  end

  def is_assessment_controller?
    controller.controller_name == 'assessment'
  end

  def is_peer_benchmark_controller?
    controller.controller_name == 'peer_benchmark'
  end

  def is_esg_learning_controller?
    controller.controller_name == 'esg_learning'
  end

  def is_publication_controller?
    controller.controller_name == 'publication'
  end

  def is_premium_controller?
    controller.controller_name == 'premium_subscription'
  end

  def is_basic_controller?
    controller.controller_name == 'basic_subscription'
  end

  def is_admin_peer_benchmark_controller?
    controller_name == 'peer_benchmarking'
  end

  def is_data_collection_controller?
    controller_name == 'data_collection'  
  end

  def is_analyst_dashboard_controller?
    controller.controller_path == 'analyst/dashboard'
  end

  def is_analyst_data_collection_controller?
    controller.controller_path == 'analyst/analyst_data_collection'
  end

  def is_data_analytics_controller?
    controller_name == 'data_analytics'  
  end

  def is_admin_publication_controller?
    controller_name == 'cii_publication'  
  end

  def is_admin_elearning_controller?
    controller_name == 'cii_elearning'  
  end
end
