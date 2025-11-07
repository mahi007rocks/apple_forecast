Rails.application.config.action_controller.forgery_protection_origin_check = false

# Allow requests from GitHub Codespaces domain
Rails.application.config.hosts << ".app.github.dev"