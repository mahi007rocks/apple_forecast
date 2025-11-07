# Disable CSRF origin check for Codespaces
unless Rails.env.test?
  Rails.application.config.action_controller.forgery_protection_origin_check = false
end

# Allow requests from GitHub Codespaces domain
Rails.application.config.hosts << ".app.github.dev"