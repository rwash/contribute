class PaymentsController < ApplicationController
  def new
		redirect_to Amazon::FPS::AuthorizationRequest.url(self.request.host_with_port)
  end

end
