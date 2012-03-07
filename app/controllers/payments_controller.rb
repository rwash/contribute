require 'amazon/fps/multi_token_request'
require 'amazon/fps/recipient_request'
require 'amazon/fps/pay_request'

class PaymentsController < ApplicationController
  def new
		redirect_to Amazon::FPS::RecipientRequest.url(self.request.host_with_port + '/payments/recipient_return')
  end

	def recipient_return
		puts params

		session['recipient_token'] = params['tokenID'] #need to put this in DB
		redirect_to Amazon::FPS::MultiTokenRequest.url(self.request.host_with_port + '/payments/multi_token_return',
			session['recipient_token'])
	end

	def multi_token_return
		puts params

		multi_use_token = params['tokenID']

		request = Amazon::FPS::PayRequest.new()
		response =  request.send(multi_use_token, 
			session['recipient_token'],
			50)


		puts 'response!', response
		#put stuff in here for error checking

		transaction_id = response['PayResponse']['PayResult']['TransactionId']
		puts 'transaction_id', transaction_id
		transaction_status = response['PayResponse']['PayResult']['TransactionStatus']
		puts 'transaction_status', transaction_status

		if transaction_status.nil?
			message = 'Something went wrong'
		else
			message = transaction_status
		end

		redirect_to root_url, :notice => 'Thank you for your contribution. Transaction status:' + message
	end
end
