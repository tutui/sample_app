class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーをサインインさせ、ユーザーのshowページにリダイレクトする
      sign_in user
      redirect_to user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

	# セッションを削除する（ユーザのサインアウト）
  def destroy
    sign_out
    redirect_to root_url
  end
end
