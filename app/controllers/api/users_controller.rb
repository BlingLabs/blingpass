require 'pp'

class Api::UsersController < ApplicationController

  def create
    u = User.new user_params
    u.save!

    render json: { user: u }
  end

  private

  def user_params
    params.require(:user).permit!
  end

end
