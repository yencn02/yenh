class UserMailer < ActionMailer::Base

  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
       @url  = "http://yenh.enqu.it:3000/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @url  = "http://yenh.enqu.it:3000/"
  end
  
  protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "notifications@yenh.com"
    @subject     = "yenh - "
    @sent_on     = Time.now
    @user = user
  end

end
