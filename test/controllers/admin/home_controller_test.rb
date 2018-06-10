require 'test_helper'

# Easy test script calling pages and testing if no error page is shown
class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    host! 'koala.rails.local'
  end

  test 'should load admin_home' do
    sign_in users(:martijn)

    get root_url
    assert_response :success
  end

  test 'should redirect to sign_in without session' do
    # goto any url without session
    get members_url
    assert_response :redirect
    assert_redirected_to new_user_session_url

    # gets redirected to login page
    follow_redirect!
    assert_response :success
  end

  test 'should logout and redirect to sign_in' do
    sign_in users(:martijn)
    get root_url

    # mimic sign_out button
    delete destroy_user_session_url

    # follow root to sign_in
    follow_redirect!
    assert_redirected_to new_user_session_url
  end
end
