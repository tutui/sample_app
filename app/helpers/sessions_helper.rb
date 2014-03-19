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

	# 処理中のユーザ
  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end
  def current_user?(user)
    user == current_user
  end

	# フレンドリーフォワーディング（サインイン -> サインインしたユーザの編集画面、とかに正しく遷移すること）
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end
  def store_location
    session[:return_to] = request.url
  end

end
