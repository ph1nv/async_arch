Rails.application.config.middleware.use OmniAuth::Builder do
  provider :keepa, Rails.application.credentials[:auth_key], Rails.application.credentials[:auth_secret]
end
