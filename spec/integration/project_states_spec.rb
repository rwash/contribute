require 'spec_helper'
require 'integration_helper'

class AmazonProcessTesting
	describe 'amazon process' do
		fixtures :users

		before :all do
			Capybara.default_driver = :selenium

			@headless = Headless.new
			@headless.start
		end

		after :all do
			Project.delete_all
			Contribution.delete_all			
		end

	
		describe 'project' do
			it "create successfully" do
				project = FactoryGirl.build(:project)

				#login with our project creator
				login('mthelen2@gmail.com', 'aaaaaa')

				#create a project
				visit(new_project_path)
				current_path.should == new_project_path

				#fill in form
				fill_in 'project_name' , :with => project.name
				fill_in 'project_funding_goal', :with => project.funding_goal
				fill_in 'DatePickerEndDate', :with => project.end_date.strftime('%m/%d/%Y')
				fill_in 'project_short_description', :with => project.short_description
				fill_in 'project_long_description', :with => project.long_description
			
				click_button 'Create Project'

				visit(project_path(project))
				get_and_assert_project(project.name)
				#project is now unconfirmed
				
				click_button('Edit Project')
				page.should have_content('Amazon Payments')
				
				click_button('Update Project')
				page.should have_content('Sign in with your Amazon account')
				login_amazon('spartanfan10@hotmail.com', 'testing')
				click_amazon_continue
				find('a').click
				page.should have_content('Project saved successfully')
				#project is no inactive
				
				click_button('Activate')
				page.driver.browser.switch_to.alert.accept
				page.should have_content('Successfully activated project.')
				#project is now active
				
			end

		end
	end
end