include ApplicationHelper

def valid_signin(user)
  fill_in "email",    with: user.email
  fill_in "password", with: user.password
  click_button "SIGN IN"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-danger', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end
