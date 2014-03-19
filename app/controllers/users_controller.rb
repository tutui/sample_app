class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]	# サインイン要求用。インデックス、編集、更新、削除の時だけ。
  before_filter :correct_user,   only: [:edit, :update]	# 編集中ユーザ用。編集と更新の時だけ。
  before_filter :admin_user,     only: :destroy

	# 探す
  def show
    @user = User.find(params[:id])
  end

	# 新規ユーザ
  def new
    @user = User.new
  end

	# 作成
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"	#成功したときのメッセージ
      # Handle a successful save.
      redirect_to @user
    else
      render 'new'
    end
  end

	# 編集
  def edit
#    @user = User.find(params[:id])	# correct_userで見つけたから削除
  end

	# 更新
  def update
#    @user = User.find(params[:id])	# correct_userで見つけたから削除
    if @user.update_attributes(params[:user])
      # 更新に成功した場合を扱う。
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
	end

	# ユーザ一覧のインデックス
  def index
    @users = User.paginate(page: params[:page])
  end

	# 削除
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end


  private

		# サインインの要求
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."		# notice内は表示するメッセージ
      end
    end

		# 処理中のユーザ
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

		# 削除できるのは管理者のみ
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
