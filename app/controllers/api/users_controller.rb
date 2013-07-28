require 'pp'

TRAINING_PERIOD = 10

class Api::UsersController < ApplicationController

  def create
    unless User.where(username: get_combined_username).blank?
      render json: { status: { code: -1, message: "User already exists" } } and return
    end

    u = User.new
    u.username = get_combined_username
    u.password = user_params[:password]
    u.holds = to_int_array user_params[:holds]
    u.flights = to_int_array user_params[:flights]

    ret = u.save!

    render json: { status: (ret ? { code: 0, message: "Successfully created user" } : { code: -1, message: "Failed to create user" }) }
  end

  def login
    all_users = User.where(username: get_combined_username)
    if all_users.blank?
      render json: { status: { code: -1, message: "User does not exist" } } and return
    end

    u = all_users.first

    if !u.password_digest.blank? and u.authenticate(user_params[:password]).blank?
      render json: { status: { code: -1, message: "Failed to verify user" } } and return
    end

    if u.count < TRAINING_PERIOD
      Verifier.update_average(u, to_int_array(user_params[:holds]), to_int_array(user_params[:flights]))
      u.count = u.count + 1
      u.save!
      render json: { status: { code: 0, message: "Need more logins" } } and return
    end

    ret = authenticate u, user_params

    render json: { status: (ret ? { code: 0, message: "Successfully verified user" } : { code: -1, message: "Failed to verify user" }) }
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
    (params[:service] || 'none') + ':' + user_params[:username]
  end

  def to_int_array(arr)
    return [] if arr.blank?
    arr.map { |i| i.to_s.to_i }
  end

end
