class Service::CiiElearningController < ApplicationController
    before_action :authenticate_user!

    def index
        @company_name = params[:companyName].present? ? params[:companyName] : ""
        @company_users = CiiElearning.order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
        @company_users = @company_users.order(created_at: :desc).where(params[:sector_ids].present? ? { company_sector: sector_names } : {})
        @company_users = @company_users.search_by(params[:companyName]) if params[:companyName].present?
        @company_users = @company_users.by_creation_date(params[:year]) if params[:year].present?
        @company_users = @company_users.paginate(page: params[:page], per_page: 10)
    end

    def elearning_creation
      if params[:company_id].present?
        elearning = find_elearning(params[:company_id])
        update_elearning = {
          title: params[:company_name] ? params[:company_name] : elearning.title,
          user_id: current_user.id,
          price: params[:price] ? params[:price] : elearning.price,
          service: params[:service] ? params[:service] : elearning.service,
        }.compact
        elearning.update(update_elearning) 
        if params[:videofile].present?
          elearning.videofile.attach(params[:videofile])
        end
        if params[:thumbnail].present?
          elearning.thumbnail.attach(params[:thumbnail])
        else
          VideoThumbnailService.new(elearning.videofile, elearning).generate_thumbnail
        end
        msg = 'E-Learning has been updated successfully.'
      else
        @elearning_creation = CiiElearning.create(
          title: params[:company_name],
          user_id: current_user.id,
          price: params[:price],
          service: params[:service]
        )
        if @elearning_creation.persisted?
          if params[:videofile].present?
            @elearning_creation.videofile.attach(params[:videofile])
          end
    
          if params[:thumbnail].present?
            @elearning_creation.thumbnail.attach(params[:thumbnail])
          else
            VideoThumbnailService.new(@elearning_creation.videofile, @elearning_creation).generate_thumbnail
          end
          msg = 'E-Learning file has been created successfully.'
        else
          msg = 'Failed to create E-Learning. Please check your input.'
        end
      end
      redirect_to elearning_admin_dashboard_path, notice: msg
    end
      

    def fetch_details
        learning_id = params[:learning_id].to_i
        elearnings = EsgLearning.where(learning_id: learning_id)
                                 .order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
        
        details = elearnings.map do |elearning|
          user = User.find(elearning.company_user_id)
          { company_name: user.company_name, user_id: user.id, elearning_id: elearning.id, status: elearning.status }
        end
        
        render json: details
    end

    def update_status
        user_id = params[:company_id]
        elearning = EsgLearning.find(params[:elearning_id])
        if params[:status] == "rejected"
            update_params = {
              approver_user_id: current_user.id,
              reason_for_rejection: params[:reason],
              rejected_at: Time.now,
              status: 'rejected'
            }
        else
            update_params={
                approver_user_id: current_user.id,
                status: "approved",
                approved_at: Time.now
            }
        end
        if elearning.update(update_params)
          begin
            UserMailer.elearning_approval_success(user_id, elearning.learning_id, elearning.id).deliver_later
          rescue StandardError => e
             Rails.logger.error "Failed to send email: #{e.message}"
          end
            redirect_to elearning_admin_dashboard_path, notice: 'E-learning Download approval was updated successfully'
        end
    end

    def destroy
        @elearning = find_elearning(params[:user_id])
        if @elearning
            @elearning.destroy
            redirect_to elearning_admin_dashboard_path, notice: 'E-learning file was successfully deleted.'
        end
    end

    def fetch_elearning
        @company = find_elearning(params[:company_id])
        @filename = @company.videofile.filename.to_s if @company.videofile.attached?
        @thumbnail = @company.thumbnail.filename.to_s if @company.thumbnail.attached?
        @price = @company.price.present? ? @company.price : ""
        @service = @company.service.present? ? @company.service : ""
        render json: { company_data: @company, filename: @filename, price: @price, thumbnail: @thumbnail, service: @service }
    end

    def no_of_downloads
      @cii_elearning = find_elearning(params[:format])
      @cii_elearning.increment!(:no_of_downloads)
      redirect_to rails_blob_path(@cii_elearning.videofile, disposition: "attachment")
    end

    private

    def find_elearning(id)
        CiiElearning.find_by(id: id)
    end

end