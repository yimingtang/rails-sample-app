require 'spec_helper'

describe "Authentication Pages" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign In') }
    it { should have_title(full_title('Sign In')) }
    it { should_not have_link('Profile') }
    it { should_not have_link('Settings') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "SIGN IN" }

      it { should have_title(full_title('Sign In')) }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_error_message }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        fill_in "email",    with: user.email
        fill_in "password", with: user.password
        click_button "SIGN IN"
      end

      it { should have_title(user.name) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign Out', href: signout_path) }
      it { should_not have_link('Sign In', href: signin_path) }

      describe "followed by signout" do
        before { click_link 'Sign Out' }

        it { should have_link("Sign In", href: signin_path) }
      end
    end
  end

  describe "authorization" do
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit protected pages" do
        before do
          visit edit_user_path(user)

          fill_in "email", with: user.email
          fill_in "password", with: user.password
          click_button "SIGN IN"
        end

        describe "after signing in" do
          describe "should render the desired protected page" do
            it { should have_title('Edit User') }
          end
        end

        describe "when signing in again" do
          before do
            click_link "Sign Out"
            sign_in user
          end

          it "should render the default (profile) page" do
            expect(page).to have_title(user.name)
          end
        end
      end

      describe "in the users controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }

          it { should have_title('Sign In') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }

          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }

          it { should have_title('Sign In') }
        end
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end

    describe "for signed users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:new_user) { FactoryGirl.create(:user, name: "New User", email: "new@example.com")}
      before { sign_in user, no_capybara: true }

      describe "attempting to visit signup page" do
        before { get signup_path }

        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a POST request to the Users#create action" do
        before { post users_path(new_user)}

        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end
