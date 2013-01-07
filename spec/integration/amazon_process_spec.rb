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
				fill_in 'name' , :with => project.name
				#fill_in(:project_categroy_iid, :with => project.category_id)
				fill_in 'project_funding_goal', :with => project.funding_goal
				fill_in 'DatePickerEndDate', :with => project.end_date.strftime('%m/%d/%Y')
				fill_in 'project_short_description', :with => project.short_description				
				fill_in_ckeditor 'project_long_description', :with => 'This is my message!'  

				click_button 'Create Project'
				get_and_assert_project(project.name)
				
				login_amazon('spartanfan10@hotmail.com', 'testing')

				#Saying 'yes, we'll take your money'
				click_amazon_continue

				#Confirm, yes thank you for letting me take people's money
				find('a').click

				#Now we should be back at contribute
				# current_path.should == project_path(project)
				page.should have_content('Project saved successfully')
				
				get_and_assert_project(project.name)

				last_email.to.should eq(['mthelen2@gmail.com'])
				last_email.subject.should match(project.name)
				last_email.subject.should match('has been created')
			end
		end

		describe 'contribution' do
			before :all do
				@project = FactoryGirl.create(:project, :state => 'active')
			end

			it "with invalid amount should fail" do
				login('thelen56@msu.edu', 'aaaaaa')
				
				#go to project page
				visit project_path(@project)

				#contribute!
				click_button 'Contribute to this project'
				current_path.should == new_contribution_path(@project)

				fill_in 'contribution_amount', :with => 'you_fail_me' 
				click_button 'Make Contribution'

				page.should have_content('Contribute to')
				page.should have_content('prevented this contribution from being saved')
			end

			it "should contribute successfully" do
				generate_contribution(
					'thelen56@msu.edu', #contribution login
					'aaaaaa',
					'contribute_testing@hotmail.com', #amazon login
					'testing',
					@project, #the project to contribute to
					100) #the amount
				
				last_email.to.should eq(['thelen56@msu.edu'])
				last_email.subject.should match(@project.name)
				last_email.subject.should match('Your contribution to')
			end

			it "with smaller contribution amount should fail" do
				login('thelen56@msu.edu', 'aaaaaa')
				contribution = get_and_assert_contribution(@project.id)

				visit edit_contribution_path(contribution)

				fill_in 'contribution_amount', :with => contribution.amount - 5
				click_button 'Update Contribution'

				page.should have_content('Edit contribution to')
				page.should have_content('prevented this contribution from being saved')
			end

			it "with invalid contribution amount should fail" do
				login('thelen56@msu.edu', 'aaaaaa')
				contribution = get_and_assert_contribution(@project.id)

				visit edit_contribution_path(contribution)

				fill_in 'contribution_amount', :with => 'you_fail_me'
				click_button 'Update Contribution'

				page.should have_content('Edit contribution to')
				page.should have_content('prevented this contribution from being saved')
			end

			it "should edit contribution successfully" do
				login('thelen56@msu.edu', 'aaaaaa')
				contribution = get_and_assert_contribution(@project.id)

				visit edit_contribution_path(contribution)

				fill_in 'contribution_amount', :with => contribution.amount + 5
				click_button 'Update Contribution'

				make_amazon_payment('contribute_testing@hotmail.com', 'testing')

        page.should have_content('Contribution successfully updated.')

				cancelled_contribution = Contribution.where(:status => ContributionStatus::CANCELLED, :project_id => @project.id)
				new_contribution = Contribution.where(:status => ContributionStatus::NONE, :project_id => @project.id)

				cancelled_contribution.should_not be_nil
				new_contribution.should_not be_nil

				last_email.to.should eq(['thelen56@msu.edu'])
				last_email.subject.should match(@project.name)
				last_email.subject.should match('Your edited contribution to')
			end
		end
	end
end

