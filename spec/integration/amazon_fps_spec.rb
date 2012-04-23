require 'spec_helper'
require 'integration_helper'

class AmazonFpsTesting
	describe "fps requests should" do
		fixtures :users

		before :all do
			@project = FactoryGirl.create(:project)

			Capybara.default_driver = :selenium

			@headless = Headless.new
			@headless.start
		end

		after :all do
			Project.delete_all
			Contribution.delete_all
		end

		it "succeed on pay request" do
			@contribution = generate_contribution(
				'thelen56@msu.edu', #contribution login
				'aaaaaa',
				'contribute_testing@hotmail.com', #amazon login
				'testing',
				@project, #the project to contribute to
				100) #the amount
		end

		it "succeed on cancel token request" do
		end

		it "succeed on get transaction request" do
		end
	end
end

