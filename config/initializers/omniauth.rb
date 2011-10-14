Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK_KEY, FACEBOOK_SECRET, :scope => 'email,offline_access,publish_stream,user_events,friends_events,user_groups,user_interests,user_likes,user_location,user_work_history,user_checkins,user_activities'
  provider :twitter, TWITTER_KEY, TWITTER_SECRET
end