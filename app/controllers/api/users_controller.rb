require 'pp'

class Api::UsersController < ApplicationController

  def create
    unless User.where(username: get_combined_username).blank?
      render json: { status: :user_already_exists } and return
    end

    u = User.new
    u.username = get_combined_username
    u.password = params[:user][:username]
    u.holds = params[:user][:holds].map { |i| i.to_s.to_i }
    u.flights = params[:user][:flights].map { |i| i.to_s.to_i }

    ret = u.save!

    render json: { status: (ret ? :create_user_success : :create_user_failure) }
  end

  def login
    all_users = User.where(username: get_combined_username)
    if all_users.blank?
      render json: { status: :user_does_not_exist } and return
    end

    u = all_users.first
    ret = authenticate u, user_params

    if u.count < 5
      render json: { status: :need_more_logins.to_s + u.count.to_s } and return
    end

    render json: { status: (ret ? :sucessful_verification : :failed_verification) }
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def authenticate(u, u_candidate)
    ret = Verifier.verify(u, u_candidate[:holds].map { |i| i.to_s.to_i }, u_candidate[:flights].map { |i| i.to_s.to_i })
    u.save!
    ret
  end

  def get_combined_username
    (params[:service] ? params[:service] : 'none') + ':' + params[:user][:username]
  end

end
