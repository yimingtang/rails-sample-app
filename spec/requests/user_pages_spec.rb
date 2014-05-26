require 'spec_helper'

describe "User Pages" do
  subject { page }

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
    end
  end

  describe "profile page" do
    let (:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end
end
