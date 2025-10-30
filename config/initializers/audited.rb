# Configure Audited gem
Audited.config do |config|
  # Set the current user method (Devise provides current_user)
  config.current_user_method = :current_user
end

# Configure JSON serialization for audited_changes after Rails loads
Rails.application.config.after_initialize do
  Audited::Audit.serialize :audited_changes, coder: JSON
end
