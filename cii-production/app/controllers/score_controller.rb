class ScoreController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_company_user, only: [:generate_score_card]
  skip_before_action :verify_authenticity_token, only: [:generate_score_card, :download_csv]
  def generate_score_card
    @company_user = User.find(params[:company_user_id])
    version_id = @company_user.questionnaire_version_id
    class_name = "Scores::GenerateScoreV#{version_id}"
    unless Object.const_defined?(class_name)
      folder_path = Rails.root.join('app', 'services', 'scores')
      search_name_pattern = "generate_score_v*.rb"
      class_name =  "Scores::#{last_created_file_before_date(folder_path, search_name_pattern, version_id)}"
    end
    Object.const_get(class_name).perform(params[:company_user_id])
    # UserMailer.send_score_card_generated_mail(@company_user).deliver_now

    rescue Exception => e
      Rollbar.error('Score Generation', e)
  end


  def last_created_file_before_date(folder_path, search_name_pattern, version)
    files = Dir.glob(File.join(folder_path, search_name_pattern))
    files.reject! do |file|
      File.directory?(file) || extract_version_number(file) > version
    end
    sorted_files = files.sort_by { |file| extract_version_number(file) }.reverse
    last_file = sorted_files.first
    file_name_without_extension = File.basename(last_file, '.*')
    class_name = file_name_without_extension.split('_').map(&:capitalize).join
  end

  def extract_version_number(file)
    file.match(/generate_score_v(\d+)\.rb/)[1].to_i
  end
  

end