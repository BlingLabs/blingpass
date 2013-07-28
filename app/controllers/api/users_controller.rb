require 'pp'

class Api::UsersController < ApplicationController

  def create
    u = User.new user_params
    u.count = 0
    u.save!

    render json: { user: u }
  end

  def login
    u = User.where(params[:user].slice :username).first
    render json: { success: authenticate(u, user_params) }
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def authenticate(u, u_candidate)
    ret = Verifier.verify(u, u_candidate[:holds], u_candidate[:flights])
    u.save!
    ret
  end

end
