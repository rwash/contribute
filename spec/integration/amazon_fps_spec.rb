require 'spec_helper'
require 'integration_helper'

class AmazonFpsTesting
	describe "fps requests should" do
		fixtures :users

		before :all do
			Capybara.default_driver = :selenium

			@test1_project = FactoryGirl.create(:project)
			@test2_project = FactoryGirl.create(:project2)

			@headless = Headless.new
			@headless.start
		end

		after :all do
			Project.delete_all
			Contribution.delete_all
		end

		it "succeed on pay request and check transaction status" do
			@contribution = generate_contribution(
				'thelen56@msu.edu', #contribution login
				'aaaaaa',
				'contribute_testing@hotmail.com', #amazon login
				'testing',
				@test1_project, #the project to contribute to
				100) #the amount

			request = Amazon::FPS::PayRequest.new(@contribution.payment_key, @contribution.project.payment_account_id, @contribution.amount)
			response = request.send()

			response['Errors'].should be_nil
			response['PayResult']['TransactionStatus'].should_not be_nil
	
			transaction_id = response['PayResult']['TransactionId']
			transaction_id.should_not be_nil

			request = Amazon::FPS::GetTransactionStatusRequest.new(transaction_id)
			response = request.send()

			response['Errors'].should be_nil
			response['GetTransactionStatusResult']['TransactionStatus'].should_not be_nil
		end

		it "succeed on cancel token request" do
			@contribution = generate_contribution(
				'thelen56@msu.edu', #contribution login
				'aaaaaa',
				'contribute_testing@hotmail.com', #amazon login
				'testing',
				@test2_project, #the project to contribute to
				100) #the amount

			request = Amazon::FPS::CancelTokenRequest.new(@contribution.payment_key)
			response = request.send()

			response['Errors'].should be_nil
		end
	end
end

