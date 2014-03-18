module SessionsHelper

	# サインイン
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
  end
  def signed_in?
    !current_user.nil?
  end

	# 要素代入の定義
  def current_user=(user)
    @current_user = user
  end
  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

	# サインアウト
  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end
end
