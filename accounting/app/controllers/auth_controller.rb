class AuthController < ApplicationController
  def index
  end

  def create
    session[:account] = request.env['omniauth.auth']
    redirect_to '/'
  end
end
