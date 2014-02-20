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

require 'spec_helper'

# ユーザのテストをしますよ、って宣言。
# do ～ end は、rubyの｛｝みたいなもの。
describe User do

	# テストに使うユーザの初期化
  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

	# userのテストをするから、@userの記載は省きますよー、って宣言。
  subject { @user }

	# 名前・Eメール・パスワードの応答。
	# should ：user.shouldの略。userは↑で宣言したから省略可。
  # respond_to :
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

	# 不正な値が入ってないか。クラス内のメソッドでテスト
  it { should be_valid }

#############　ここからがテストコード本番　###############

	#####  name　に関するテスト　#####

	# 名前がはいってるかどうかのテストをしますよ、ってタイトル
  describe "when name is not present" do
		#　名前に空を設定
    before { @user.name = " " }
		#　カピバラの仕組みを使って、エラーになることをテスト
    it { should_not be_valid }
  end

	# 名前が50文字以上でエラーになるかどうかテストをしますよ、ってタイトル
  describe "when name is too long" do
		# 名前にaを51文字設定
    before { @user.name = "a" * 51 }
		#　カピバラの仕組みを使って、エラーになることをテスト
    it { should_not be_valid }
  end

	#####  email　に関するテスト　#####

	# emailに空がはいってるかどうかのテストをしますよ、ってタイトル
  describe "when email is not present" do
		# emailに空を設定
    before { @user.email = " " }
		#　カピバラの仕組みを使って、エラーになることをテスト
    it { should_not be_valid }
  end

	# emailのフォーマットが正しいかどうかテストをしますよ、ってタイトル
  describe "when email format is invalid" do
		# 不正なことをチェックしますよ、って説明
    it "should be invalid" do
			# addressのテスト用のリストを作成。%Wはリストを作る
			# ,は使えない、＠マークがない、 . 終わりはない、ドメインに _ + は使えない
     addresses = %w[user@foo,com user_at_foo.org example.user@foo.  
                     foo@bar_baz.com foo@bar+baz.com]
			# リストの中身を回す。invalid_addressに順番に格納。
     addresses.each do |invalid_address|
				# userに格納
        @user.email = invalid_address
				#　カピバラの仕組みを使って、エラーになることをテスト
        @user.should_not be_valid
      end      
    end
  end

	# emailのフォーマットが正しいかどうかテストをしますよ、ってタイトル
  describe "when email format is valid" do
		# 正しいことをチェックしますよ、って説明
    it "should be valid" do
			# addressのテスト用のリストを作成。%Wはリストを作る。全部正しいアドレスのリスト。
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
			# リストの中身を回す。invalid_addressに順番に格納。
      addresses.each do |valid_address|
				# userに格納
        @user.email = valid_address
				#　カピバラの仕組みを使って、エラーにならないことをテスト
        @user.should be_valid
      end      
    end
  end

	# アドレスが一意かどうかテストしますよ、ってタイトル
  describe "when email address is already taken" do
		# 前準備として、@user.dup　で同じユーザを作る
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase #大文字小文字を意識させない
      user_with_same_email.save
    end

		#　カピバラの仕組みを使って、エラーになることをテスト
    it { should_not be_valid }
  end

	#####  password　に関するテスト　#####

	# パスワードの存在確認のテストしますよ、ってタイトル
	describe "when password is not present" do
		# user（本パスワードと、確認用パスワードの両方）に空のパスワードを入れる
		before { @user.password = @user.password_confirmation = " " }
		#　カピバラの仕組みを使って、エラーになることをテスト
		it { should_not be_valid }
	end

	# 本パスワードと確認用パスワードが一致するか手すとしますよ、ってタイトル
	describe "when password doesn't match confirmation" do
		# 確認用パスワードだけ変更。本パスワードは一番最初に指定した奴
		before { @user.password_confirmation = "mismatch" }
		it { should_not be_valid }
	end

	# nilが指定された場合にエラーになるテストですよ、ってタイトル
	describe "when password confirmation is nil" do
		before { @user.password_confirmation = nil }
		it { should_not be_valid }
	end

	#####  ユーザ認証　に関するテスト　#####

	# authenticate（認証)に応答してもらう
	it { should respond_to(:authenticate) }

	# パスワードが一致するかどうかのテストですよ、ってタイトル
	describe "return value of authenticate method" do
		# user情報を保存しておく
		before { @user.save }
		# emailが一致するuserを見つける
		# letを使うと、（）内の引数に、｛｝の戻り値が入る。（emaliが一致したユーザが、found_userにはいる。）
		let(:found_user) { User.find_by_email(@user.email) }

		# パスワードが正しいかチェック
		describe "with valid password" do
		  it { should == found_user.authenticate(@user.password) }
		end

		# パスワードが間違っていることのチェック
		describe "with invalid password" do
		  let(:user_for_invalid_password) { found_user.authenticate("invalid") }

		  it { should_not == user_for_invalid_password }
			# specify = it と同じ。英文としてどっちが適切かで決める。
		  specify { user_for_invalid_password.should be_false }
		end
	end

	# パスワードが短すぎる場合はエラーですよ、ってタイトル
	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it { should be_invalid }
	end

end
