# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Userクラスは、ActiveRecord::Baseクラスを継承
class User < ActiveRecord::Base
	# ()に指定された属性を持つ。メンバ変数みたいなもの
  attr_accessible(:name, :email, :password, :password_confirmation)
  has_secure_password

	# emailの内容をすべて小文字にする
	#アドレスは大文字・小文字区別しないので、一意性の確認のために、小文字で全部登録する。
	before_save { |user| user.email = email.downcase }
	before_save :create_remember_token

	########### 制限をつけるメソッド ##############

	##### nameに関するメソッド #####

	#50文字以上の文字は使え内容にする制限。自作メソッド。
  validates( # メソッドは()で囲む。囲まなくてもいい。
		:name, # 名前に関する処理
	  presence: true, # 受け入れる
		length: { maximum: 50 }) #　最大長さ50文字

	##### emailに関するメソッド #####

	#アドレスに使えない文字を定義する制限。正規表現。自作メソッド
	# 正規表現でメルアドに使えるものを定義
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(
		:email,
		presence: true,
		format: { with: VALID_EMAIL_REGEX }) # 定義を使って、フォーマットのチェック

	# アドレスは一意じゃないとダメにする制限。自作メソッド
  validates(
		:email,
		presence: true,
		format: { with: VALID_EMAIL_REGEX },
		uniqueness: true)		# 一意の場合OK

	# アドレスは大文字小文字関係なく一意に制限。自作メソッド
  validates(
		:email,
		presence: true,
		format: { with: VALID_EMAIL_REGEX },
   uniqueness: { case_sensitive: false }) # 大文字・小文字関係なく、一意性をチェック

	##### passwordに関するメソッド #####

	# 認証をセキュアにする魔法の言葉
  has_secure_password

	# パスワードは6文字以上
	validates(
		:password,
		presence: true,
		length: { minimum: 6 })

	# パスワードの存在チェック
  validates(
		:password_confirmation,
		presence: true)

	###### トークンを覚えておく ######

	private
	  def create_remember_token
	    self.remember_token = SecureRandom.urlsafe_base64
	  end

end
