require 'spec_helper'
require 'integration_helper'

class UserPageTesting
	describe 'user page' do
		fixtures :users

		before :all do
			Capybara.default_driver = :selenium

			@headless = Headless.new
			@headless.start
		end

		it "should show successfully" do
			#login with our project creator
			login('mthelen2@gmail.com', 'aaaaaa')

			@user = User.find_by_email('mthelen2@gmail.com')
			visit user_path(@user)

			current_path.should == user_path(@user)

			find('div#userProfile').has_content?('Batman')
		end

		it "should edit successfully" do
			login('mthelen2@gmail.com', 'aaaaaa')

			@user = User.find_by_email('mthelen2@gmail.com')
			visit edit_user_registration_path(@user)

			#rails does some goofy garbage with the routes
			#current_path.should == edit_user_registration_path(@path)

			fill_in 'user_name', :with => 'The Hulk'
			fill_in 'user_current_password', :with => 'aaaaaa'

			click_button 'Update Profile'

			current_path.should == user_path(@user)	
			find('div#userProfile').has_content?('The Hulk')
		end
	end
end

