require 'pp'

class Api::UsersController < ApplicationController

  def create
    u = User.new user_params
    u.save!

    render json: { user: u }
  end

  def login
    u = User.where(params[:user].slice :username).first
    render json: { success: authenticate(u, User.new(user_params)) }
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def authenticate(u, u_candidate)
    return rand < 0.5
  end

end
