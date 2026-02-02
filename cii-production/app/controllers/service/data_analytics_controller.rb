class Service::DataAnalyticsController < ApplicationController
    include FilterHelper
    include ApplicationHelper
    include ExcelAnalyticsCalculationHelper
    include AnalyticsReportHelper
    before_action :authenticate_user!
    before_action :user_role_check

    def index
    end

    def download_analytics_sector_specific_report
        sector_name = params[:sector_id]
        @sector_data = DataCollectionCompanyDetail.where(company_sector: sector_name, status: ApplicationRecord::WORK_SUBMITTED)
        @sector_analytics_data = DataCollectionCompanyDetail
                                .where(company_sector: sector_name, status: ApplicationRecord::WORK_SUBMITTED)
                                .joins("INNER JOIN data_collection_answers ON data_collection_company_details.id = data_collection_answers.company_id")
                                .where(data_collection_answers: { version: DataCollectionAnswer
                                .select('MAX(version)')
                                .group(:company_id)
                                .where('data_collection_answers.company_id = data_collection_company_details.id') })
                                .select("data_collection_answers.*")
        user_answers = @sector_analytics_data.map do |company_detail|
                        {
                            answers: company_detail.user_answers,
                            version: company_detail.version 
                        }
        end
         
        user_answers.each do |data|
            if data[:version] != current_year
                updated_data = interchange_table_data(data[:answers], [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
                updated_data = interchange_table_data(data[:answers], [16, 17, 18, 22, 23], same_row: false )
                data[:answers] = updated_data
            end
        end
        @sector_analytics_data.each_with_index do |company_detail, index|
            company_detail.user_answers = user_answers[index][:answers] # assuming user_answers is the field
        end    
        @questions = PeerBenchmarkingQuestionnaire.all.order(question_id: :asc)
        if @sector_data.present?
            download_sector_specific_excel_data(@sector_data, 'service/data_analytics/sector_specific_report', sector_name, @questions) 
        else
            redirect_to data_analytics_path, notice: "Chosen sector #{sector_name} does not have data"
        end
    end

    def download_analytics_general_specific_report
        @general_analytics_data = DataCollectionCompanyDetail
                                .where(status: ApplicationRecord::WORK_SUBMITTED)
                                .joins("INNER JOIN data_collection_answers ON data_collection_company_details.id = data_collection_answers.company_id")
                                .where(data_collection_answers: { version: DataCollectionAnswer
                                .select('MAX(version)')
                                .group(:company_id)
                                .where('data_collection_answers.company_id = data_collection_company_details.id') })
                                .select("data_collection_answers.*")

        user_answers = @general_analytics_data.map do |company_detail|
            {
                answers: company_detail.user_answers,
                version: company_detail.version 
            }
        end
        user_answers.each do |data|
            if data[:version] != current_year
                updated_data = interchange_table_data(data[:answers], [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
                updated_data = interchange_table_data(data[:answers], [16, 17, 18, 22, 23], same_row: false )
                data[:answers] = updated_data
            end
        end
        @general_analytics_data.each_with_index do |company_detail, index|
            company_detail.user_answers = user_answers[index][:answers] # assuming user_answers is the field
        end          
        
        @general_data = DataCollectionCompanyDetail.where(status: ApplicationRecord::WORK_SUBMITTED)
        @questions = PeerBenchmarkingQuestionnaire.all.order(question_id: :asc)
        if @general_data.present?
            download_general_specific_excel_data(@general_data, 'service/data_analytics/general_specific_report', '', @questions)
        else
            redirect_to data_analytics_path, notice: 'There is no data to download'
        end
    end

    def interchange_table_data(data, table_ids, same_row: true)
        table_ids.each do |table_id|
          table_key_prefix = "pb_#{format('%02d', table_id)}_table"
          table_rows = data.select { |key, _| key.start_with?(table_key_prefix) }
                            .sort_by { |key, _| key.match(/row(\d+)/)[1].to_i }
                            .to_h
      
          shifted_rows = table_rows.values.rotate(-1)
          shifted_rows[0] = ""
          table_rows.each_with_index do |(key, _), index|
            match_first_row = key.match(/row\d+_number1/)
            match_third_row = key.match(/row\d+_number3/)
            if match_first_row || ( !same_row && match_third_row )
             data[key] = ""
            else
             data[key] = shifted_rows[index]
            end
          end
        end
  
         data
    end

end
  