require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All Users') }
    it { should have_content('All Users') }

    describe "pagination" do
      before(:all) do
        30.times { FactoryGirl.create(:user) }
      end
      after(:all) { User.delete_all }

      it { should have_selector('ul.pagination') }

      it "should list each user" do
        User.page(1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }

        before do
          # Since signed in user can't access sign in page, sign out first
          click_link('Sign Out')
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it { should_not have_link('delete', href: user_path(admin)) }

        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end

        describe "attempting delete himself" do
          before do
            click_link ('Sign Out')
            sign_in admin, no_capybara: true
          end

          specify do
            expect { delete user_path(admin) }.not_to change(User, :count)
          end
        end
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up')}
    it { should have_title(full_title('Sign Up')) }
  end

   describe "signup" do
    before { visit signup_path }
    let(:submit) { "SIGN UP" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title(full_title('Sign Up')) }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "user_name",                  with: "Example User"
        fill_in "user_email",                 with: "user@example.com"
        fill_in "user_password",              with: "foobar"
        fill_in "user_password_confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_title(user.name) }
        it { should have_link('Sign Out', signout_path) }
        it { should have_success_message('Welcome') }
      end
    end
  end

  describe "profile page" do
    let (:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_title('Edit User') }
      it { should have_content('Update your profile') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe 'with invalid information' do
      before { click_button 'Save' }

      it { should have_content('error') }
    end

    describe 'with valid information' do
      let(:new_name) { 'New Name' }
      let(:new_email) { 'new@example.com' }

      before do
        fill_in 'user_name',                  with: new_name
        fill_in 'user_email',                 with: new_email
        fill_in 'user_password',              with: user.password
        fill_in 'user_password_confirmation', with: user.password
        click_button 'Save'
      end

      it { should have_title(new_name) }
      it { should have_success_message }
      it { should have_link('Sign Out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end

      specify { expect(user.reload).not_to be_admin }
    end
  end
end
