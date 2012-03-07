require 'amazon/fps/authorization_request'
require 'amazon/fps/recipient_request'

class PaymentsController < ApplicationController
  def new
		redirect_to Amazon::FPS::RecipientRequest.url(self.request.host_with_port + '/payments/recipient_return')
		#redirect_to Amazon::FPS::AuthorizationRequest.url(self.request.host_with_port)
  end

	def recipient_return
		puts params

		recipient_token = params['tokenID']
		redirect_to Amazon::FPS::MultiTokenRequest.url(self.request.host_with_port + '/payments/authorization_return',
			recipient_token)
	end

	def authorization_return
		puts params
	end
end
