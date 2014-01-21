module RsErrors
  extend ActiveSupport::Concern
  included do
    if Rails.env.production? || Rails.env.staging?
      rescue_from Exception, with: :render_500
      rescue_from ActionController::RoutingError, with: :render_404
      rescue_from ActionController::UnknownController, with: :render_404
      rescue_from AbstractController::ActionNotFound, with: :render_404
      rescue_from Mongoid::Errors::DocumentNotFound, with: :render_404
      rescue_from Mongoid::Errors::InvalidFind, with: :render_404
    end
  end
  
  protected
  def render_404(exception = nil)
    unless exception.nil?
      capture_exception(exception) if respond_to?(:capture_exception)
    end
    render_error(404)
  end

  def render_500(exception)
    Rails.logger.error exception.message
    Rails.logger.error exception.backtrace.join("\n")

    capture_exception(exception) if respond_to?(:capture_exception)
    
    begin
      if rails_admin_controller?
        return render text: 'Внутренняя ошибка'
      end
    rescue
    end
    render_error(500)
  end

  def render_error(code = 500)
    render template: "errors/error_#{code}", formats: [:html], handlers: [:haml, :slim], layout: RocketCMS.configuration.error_layout, status: code
  end

end