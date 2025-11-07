class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception unless Rails.env.test?

  before_action :debug_403

  private
  def debug_403
    if Rails.env.test?
      Rails.logger.info "[DEBUG] Request: #{request.method} #{request.fullpath} Host: #{request.host}"
      Rails.logger.info "[DEBUG] Headers: #{request.headers.env.select { |k, _| k.start_with?("HTTP_") }}"
      Rails.logger.info "[DEBUG] Params: #{params.inspect}"
    end
  end
end
