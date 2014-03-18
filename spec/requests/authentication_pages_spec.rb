require 'spec_helper'

describe "Authentication" do

  subject { page }

	# ページのテスト
  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',    text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }
  end

	# サインインのテスト
  describe "signin" do
    before { visit signin_path }

		# サインインに失敗した場合
    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('title', text: 'Sign in') }		# タイトルがサインインのままのこと（サインイン画面のままなこと）
      it { should have_selector('div.alert.alert-error', text: 'Invalid') } #エラーが表示されること

			 # メッセージがずっと表示される既知のバグのテスト
			 describe "after visiting another page" do
				 before { click_link "Home" }
				 it { should_not have_selector('div.alert.alert-error') }
			 end

    end

		# サインインに成功した場合
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
					before { valid_signin(user) }
#        fill_in "Email",    with: user.email.upcase
#        fill_in "Password", with: user.password
#        click_button "Sign in"
      end

      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', href: user_path(user)) }	# <a herf> 引数がリンクになる
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
			 # サインインできたら、サインアウトする
     	 describe "followed by signout" do
     	   before { click_link "Sign out" }
     	   it { should have_link('Sign in') }
    	 end

    end


  end


end
