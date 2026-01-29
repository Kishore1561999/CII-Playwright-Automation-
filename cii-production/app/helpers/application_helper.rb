module ApplicationHelper
  def current_user_dashboard
    if current_user.is_admin?
      admin_company_users_path
    elsif current_user.is_analyst?
      analyst_dashboard_path
    elsif current_user.is_company_user?
      current_user.subscription_esg_diagnostic? && current_user.approved? ? company_user_dashboard_path : peer_benchmarking_path
    elsif current_user.is_manager?
      manager_company_users_path
    end
  end

  def current_company_user
    if current_user.is_admin?
      admin_company_users_path
    elsif current_user.is_manager?
      manager_company_users_path
    end
  end

  def getTimeString(test_time)
    current_time = Time.now
    seconds_diff = (test_time - current_time).to_i.abs

    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60

    seconds = seconds_diff

    return (hours == 1 ? "#{hours} hr ago" : (hours > 1 ? "#{hours} hrs ago" : (minutes == 1 ? "#{minutes} min ago" : minutes > 1 ? "#{minutes} mins ago": (seconds > 10 ? "#{seconds} secs ago" : "just now"))))
  end

  def getDateString(date_string)
    date_string&.strftime("%d %b %Y")
  end

  def assigned_analyst(user_id)
    analyst_name_user_id = AssignAnalyst.find_by(company_user_id: user_id)&.analyst_user_id
    analyst_user = User.find(analyst_name_user_id) if analyst_name_user_id != nil
    return analyst_user != nil ? "#{analyst_user&.first_name} #{analyst_user&.last_name}" : "NA"
  end

  def table_custom_td_tag(column_data)
    attributes = {
      class: column_data['class'],
      colspan: column_data['colspan'],
      rowspan: column_data['rowspan']
    }.compact
    td_tag = "<td #{attributes.map { |attr, value| "#{attr}=\"#{value}\"" }.join(' ')}>".html_safe
  end
  
  def services_amount(amount)
    "₹ #{amount}"
  end

  def current_year
    Time.now.year
  end

  def subscription_status(company_user)
    if company_user.subscription_approved == "rejected"
      status = "Rejected"
      css_class = "premium-status-inactive"
    elsif company_user.subscription_approved.nil?
      status = "Due for approval"
      css_class = "premium-status-inactive"
    else
      subscription_active = company_user.subscription_approved_at.present? && (company_user.subscription_approved_at + 1.year > DateTime.now)
      status, css_class = subscription_active ? ["Active", "premium-status-active"] : ["Inactive", "premium-status-inactive"]
    end
    { status: status, class: css_class }
  end

  def check_company_existence(entered_company_name, entered_sector, option, company_id)
    word_count = entered_company_name.split(' ').size
    entered_company_name = entered_company_name.sub(/^cii[_-]/i, '').strip
    entered_company_name = entered_company_name.split(' ').first([word_count, 2].min).join(' ').downcase   
    entered_company_name = entered_company_name.gsub(/\s+/, '').downcase 
    entered_company_name = entered_company_name.singularize
    if option == "Submit"
      matching_companies = DataCollectionCompanyDetail
                      .where("regexp_replace(regexp_replace(company_name, '\\s+', '', 'g'), '^cii[_-]', '', 'i') ILIKE ? AND company_sector ILIKE ?", "#{entered_company_name}%", "#{entered_sector}%")
    else
      matching_companies = DataCollectionCompanyDetail
                      .where("regexp_replace(regexp_replace(company_name, '\\s+', '', 'g'), '^cii[_-]', '', 'i') ILIKE ? AND company_sector ILIKE ? AND id != ?", "#{entered_company_name}%", "#{entered_sector}%", company_id)
    end
    count = matching_companies.count
  
    if count > 1
      { multiple: true, count: count }
    else
      company_detail = matching_companies.select(:id).limit(1).take
      { exists: company_detail.present?, id: company_detail&.id, count: count }
    end
  end

  def peer_benchmark_check_company_existence(entered_company_name, entered_sector)
    word_count = entered_company_name.split(' ').size
    entered_company_name = entered_company_name.split(' ').first([word_count, 2].min).join(' ').downcase    
    entered_sector = entered_sector.downcase
    matching_companies = DataCollectionCompanyDetail.where("company_name ILIKE ? AND company_sector ILIKE ?", "#{entered_company_name}%", "#{entered_sector}%")
    count = matching_companies.count
  
    if count > 1
      { multiple: true, count: count }
    else
      company_detail = matching_companies.select(:id).limit(1).take
      { exists: company_detail.present?, id: company_detail&.id }
    end
  end

end
