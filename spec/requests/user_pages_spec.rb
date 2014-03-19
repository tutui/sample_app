require 'spec_helper'

describe "User pages" do

  subject { page }

	# サインインページ
  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end

	# プロファイルページ
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end

	###### ユーザ登録に関するテスト　#####
	describe "signup page" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
				 it { should have_link('Sign out') }
      end
    end

  end

	###### ユーザ編集に関するテスト #########
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user	# 編集をするには事前にサインインが必要
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

		# エラーになること
    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end

		# 情報が正しいこと
    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

	######### ユーザ一覧のインデックス画面のテスト ###########
  describe "index" do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    it "should list each user" do
      User.all.each do |user|
        page.should have_selector('li', text: user.name)
      end
    end


		# ページネーションのテスト（1頁ごとに表示する件数を指定するテスト）
    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }		# 事前準備として30ユーザ作る
      after(:all)  { User.delete_all }		# 後始末で作ったユーザは消す

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

		# ユーザ削除に関するテスト
    describe "delete links" do

			# 一般ユーザには削除のリンクが表示されないこと
      it { should_not have_link('delete') }

			# 管理者のテスト
      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

					# 削除のリンクが見えていること
        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)	#　削除リンク押下後はユーザ数が減ること
        end
					# 自分自身の削除はリンクがみえないこと（ログイン中の管理者は消せない）
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end

  end


end
