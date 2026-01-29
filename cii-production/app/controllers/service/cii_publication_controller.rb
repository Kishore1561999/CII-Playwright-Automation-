class Service::CiiPublicationController < ApplicationController
    before_action :authenticate_user!

    def index
        @company_name = params[:companyName].present? ? params[:companyName] : ""
        @company_users = CiiPublication.order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
        @company_users = @company_users.order(created_at: :desc).where(params[:sector_ids].present? ? { company_sector: sector_names } : {})
        @company_users = @company_users.search_by(params[:companyName]) if params[:companyName].present?
        @company_users = @company_users.by_creation_date(params[:year]) if params[:year].present?
        @company_users = @company_users.paginate(page: params[:page], per_page: 10)
    end

    def publication_creation
        @publication_creation = CiiPublication.create(
            title: params[:company_name],
            user_id: current_user.id
            )
            if params[:pdffile].present? 
                @publication_creation.pdffile.attach(params[:pdffile])
            end  
            msg = 'Publication has been created successfully.'

        redirect_to publication_admin_dashboard_path, notice: msg
    end

    def destroy
        @publication = find_publication(params[:user_id])
        if @publication
            @publication.destroy
            redirect_to publication_admin_dashboard_path, notice: 'Publication was successfully deleted.'
        end
    end

    private

    def find_publication(id)
        CiiPublication.find_by(id: id)
    end

end