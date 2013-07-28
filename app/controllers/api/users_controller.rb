require 'pp'

class Api::UsersController < ApplicationController

  def create
    unless User.where(username: get_combined_username).blank?
      render json: { status: :user_already_exists } and return
    end

    u = User.new
    u.username = get_combined_username
    u.password = params[:user][:password]
    u.holds = to_int_array params[:user][:holds]
    u.flights = to_int_array params[:user][:flights]

    ret = u.save!

    render json: { status: (ret ? :create_user_success : :create_user_failure) }
  end

  def login
    all_users = User.where(username: get_combined_username)
    if all_users.blank?
      render json: { status: :user_does_not_exist } and return
    end

    u = all_users.first

    if user_params[:password] and (u.password_digest.blank? || u.authenticate(user_params[:password]).blank?)
      render json: { status: :failed_verification } and return
    end

    if u.count < 5
      Verifier.update_average(u, to_int_array(user_params[:holds]), to_int_array(user_params[:flights]))
      u.count = u.count + 1
      u.save!
      render json: { status: :need_more_logins } and return
    end

    ret = authenticate u, user_params

    render json: { status: (ret ? :successful_verification : :failed_verification) }
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def authenticate(u, u_candidate)
    ret = Verifier.verify(u, to_int_array(u_candidate[:holds]), to_int_array(u_candidate[:flights]))
    u.save!
    ret
  end

  def get_combined_username
    (params[:service] ? params[:service] : 'none') + ':' + params[:user][:username]
  end

  def to_int_array(arr)
    arr.map { |i| i.to_s.to_i }
  end

end
