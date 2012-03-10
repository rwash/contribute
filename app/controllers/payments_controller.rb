require 'amazon/fps/multi_token_request'
require 'amazon/fps/recipient_request'
require 'amazon/fps/pay_request'

class PaymentsController < ApplicationController
  def new
		request = Amazon::FPS::RecipientRequest.new()
		redirect_to request.url("#{self.request.host_with_port}/payments/recipient_return", rand(9999999)) #TODO: guid
  end

	def recipient_return
		session['recipient_token'] = params['tokenID'] #need to put this in DB

		request = Amazon::FPS::MultiTokenRequest.new()
		redirect_to request.url("#{self.request.host_with_port}/payments/multi_token_return", rand(9999999), session['recipient_token'], 50, "Paying for contribution project")

	end

	def multi_token_return
		multi_use_token = params['tokenID']

		request = Amazon::FPS::PayRequest.new()
		response =  request.send(rand(999999), 
			multi_use_token, 
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
