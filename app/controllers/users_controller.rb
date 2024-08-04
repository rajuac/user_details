
class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create update]
  before_action :check_user
  def create
    user = User.new(user_params)
    if user.save
      WebhookJobs::UserDetailsNotification.perform_later({ user_id: user.id, event_type: 'create' })
      render json: { message: 'User successfully created' }, status: 200

    else
      render json: { message: user.errors.full_messages }, status: :bad_request
    end
  end

  def update
    if update_user.update(user_params)
      WebhookJobs::UserDetailsNotification.perform_later({ user_id: update_user.id, event_type: 'update' })

      render json: { message: 'User successfully updated' }, status: 200
    else
      render json: { message: update_user.errors.full_messages }, status: :bad_request
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :mobile)
  end

  def check_user
    render json: { message: 'Uset not present for this id' }, status: :bad_request if update_user.nil?
  end

  def update_user
    @update_user ||= User.find_by(id: params[:id])
  end
end
