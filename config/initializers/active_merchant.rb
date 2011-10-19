if Rails.env.production?
  PAYPAL_ACCOUNT = 'yencn02@live.com'
else
  PAYPAL_ACCOUNT = 'yencn02@gmail.com'
  ActiveMerchant::Billing::Base.mode = :test
end