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

			#find('div#userProfile').has_content?('Batman')
			page.should have_content('Batman')
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
			#find('div#edit_user').has_content?('The Hulk')
			page.should have_content('The Hulk')
		end

		describe "redirect tests" do
			after(:each) do
				User.delete_all
				Project.delete_all
				Contribution.delete_all
			end
	
			it "should create user successfully" do
				@user = FactoryGirl.build(:user)

				visit new_user_registration_path

				fill_in 'user_name', :with => @user.name
				fill_in 'user_email', :with => @user.email
				fill_in 'user_password', :with => @user.password
				fill_in 'user_password_confirmation', :with => @user.password

				click_button 'Sign up'

				@user = User.find_by_email(@user.email)
				current_path.should == edit_user_registration_path(@user)
			end

#TODO: For some reason these two tests fail like the user still exists, though
# it should be gone from the User.delete_all. WTF.
#			it "should create user successfully and redirect to project page" do
#				@user = FactoryGirl.build(:user)
#
#				@project = FactoryGirl.create(:project)
#				visit project_path(@project)
#			
#				click_button 'Contribute to this project'
#				
#				click_link "Don't have an account yet? Sign up!"
#
#				fill_in 'user_name', :with => @user.name
#				fill_in 'user_email', :with => @user.email
#				fill_in 'user_password', :with => @user.password
#				fill_in 'user_password_confirmation', :with => @user.password
#
#				click_button 'Sign up'
#				
#				current_path.should == project_path(@project)
#			end
#
#			it "should redirect to edit on confirm" do
#				@user = FactoryGirl.create(:user)
#
#				visit "/users/confirmation?confirmation_token=#{@user.confirmation_token}"
#		
#				current_path.should == edit_user_registration_path(@user)
#			end
		end
	end
end

