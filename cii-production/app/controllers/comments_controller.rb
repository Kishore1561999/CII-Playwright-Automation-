class CommentsController < ApplicationController
   before_action :authenticate_user!
   skip_before_action :verify_authenticity_token, only: [:create, :show]

   def create
      role_id = User.find(params[:comments][:resource_id].to_i)&.role_id
      role_name = Role.find(role_id)&.role_name

      Comment.create(resource_id: params[:comments][:resource_id], user_id: params[:comments][:user_id].to_i, user_type: role_name, comments: params[:comments][:comment])
   end

   def show
      @comments = Comment.where(user_id: params[:comments][:user_id].to_i)
      render json: { company: @comments}
   end



   private
      def comment_user_params
        params.require(:comment).permit(:resource_id, :user_id, :user_type, :comments)
      end
end