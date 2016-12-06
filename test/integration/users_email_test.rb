require 'test_helper'

class UsersEmailTest < ActionDispatch::IntegrationTest

  def setup
    @email_setting = settings(:four)
    @email_setting.update_attributes(value: 'test@test.com')
    @email_setting.reload
  end

  test 'test account_activation with non-standard email' do
    user = users(:one)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation",    mail.subject
    assert_equal [user.email],            mail.to
    assert_equal ["test@test.com"],       mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "new_user_activated" do
    new_user = users(:one)
    admin_user = users(:two)
    mail = UserMailer.new_user_activated(new_user, admin_user)
    assert_equal "New user activated",   mail.subject
    assert_equal [admin_user.email],     mail.to
    assert_equal ["test@test.com"],      mail.from
    assert_match new_user.name,          mail.body.encoded
    assert_match new_user.email,         mail.body.encoded
  end

  test "password_reset" do
    user = users(:one)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["test@test.com"],       mail.from
    assert_match user.reset_token,        mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end
end
