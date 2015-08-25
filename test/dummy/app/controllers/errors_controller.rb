class ErrorsController < ApplicationController

  def show
    @err_code = status_code
    @err_msg  = Rack::Utils::HTTP_STATUS_CODES[status_code.to_i].parameterize.underscore

    render status_code.to_s, :status => status_code, :layout => (!['500'].include? status_code)
  end

  protected

  def status_code
    params[:code] || 500
  end

end
