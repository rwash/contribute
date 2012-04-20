require 'spec_helper'
require 'integration_helper'

class AmazonProcessTesting
	describe 'amazon process' do
		fixtures :users

		before :all do
			Project.delete_all
			Contribution.delete_all
			@project = FactoryGirl.build(:project)
			@contribution = nil

			@headless = Headless.new
			@headless.start
		end

		after :all do
			Project.delete_all
			Contribution.delete_all			

			@headless.destroy
		end

		it "created a project successfully" do
			#login with our project creator
			login('mthelen2@gmail.com', 'aaaaaa')

			#create a project
			visit(new_project_path)
			current_path.should == new_project_path

			#fill in form
			fill_in 'project_name' , :with => @project.name
			#fill_in(:project_categroy_iid, :with => project.category_id)
			fill_in 'project_funding_goal', :with => @project.funding_goal
			fill_in 'DatePickerEndDate', :with => @project.end_date.strftime('%m/%d/%Y')
			fill_in 'project_short_description', :with => @project.short_description
			fill_in 'project_long_description', :with => @project.long_description
		
			click_button 'Create Project'

			login_amazon('spartanfan10@hotmail.com', 'testing')

			#Saying 'yes, we'll take your money'
			click_amazon_continue

			#Confirm, yes thank you for letting me take people's money
			find('a').click

			#Now we should be back at contribute
			current_path.should == root_path
			page.should have_content('Project saved successfully')

			get_and_assert_project(@project.name)
		end

		it "should contribute successfully" do
			@project = get_and_assert_project(@project.name)
			#login with our contributor
			login('thelen56@msu.edu', 'aaaaaa')

			#visit the project page we've just created with a different user
			visit project_path(@project.name)

			#contribute!
			click_button 'Contribute to this project'
			current_path.should == new_contribution_path(@project.name)

			fill_in 'contribution_amount', :with => 100
			click_button 'Make Contribution'

			make_amazon_payment('thelen56@msu.edu', 'fartoofrail')

			#Calling find first, so capybara will wait until it appears
			page.should have_content('Contribution entered successfully')
			current_path.should == project_path(@project.name)
		end

		it "should edit contribution successfully" do
			login('thelen56@msu.edu', 'aaaaaa')
			@project = get_and_assert_project(@project.name)
			@contribution = get_and_assert_contribution(@project.id)

			visit edit_contribution_path(@contribution)

			fill_in 'contribution_amount', :with => @contribution.amount + 5
			click_button 'Update Contribution'

			make_amazon_payment('contribute_testing@hotmail.com', 'testing')

			page.should have_content('Contribution successfully updated')

			cancelled_contribution = Contribution.where(:status => ContributionStatus::CANCELLED, :project_id => @project.id)

			new_contribution = Contribution.where(:status => ContributionStatus::NONE, :project_id => @project.id)

			cancelled_contribution.should_not be_nil
			new_contribution.should_not be_nil
		end
	end
end

