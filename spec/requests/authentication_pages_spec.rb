require 'spec_helper'

describe "Authentication Pages" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign In') }
    it { should have_title(full_title('Sign In')) }
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

      before { valid_signin user }

      it { should have_title(user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign Out', href: signout_path) }
      it { should_not have_link('Sign In', href: signin_path) }

      describe "followed by signout" do
        before { click_link 'Sign Out' }

        it { should have_link("Sign In", href: signin_path) }
      end
    end
  end
end
