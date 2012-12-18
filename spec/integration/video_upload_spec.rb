require 'spec_helper'
require 'integration_helper'

class VideoUploadTesting
	describe 'upload video' do
				fixtures :users

		before :all do
			Capybara.default_driver = :selenium
			
			@headless = Headless.new
			@headless.start
		end
		
		after :all do
				Project.last.destroy
				Project.delete_all
		end
		
		it "can upload video" do
				project = FactoryGirl.build(:project)

				#login with our project creator
				login('mthelen2@gmail.com', 'aaaaaa')

				#create a project
				visit(new_project_path)
				current_path.should == new_project_path

				#fill in form
				attach_file 'video', "#{Rails.root}/test/test.mov"
				fill_in 'name' , :with => project.name
				fill_in 'project_funding_goal', :with => project.funding_goal
				fill_in 'DatePickerEndDate', :with => project.end_date.strftime('%m/%d/%Y')
				fill_in 'project_short_description', :with => project.short_description
				fill_in_ckeditor 'project_long_description', :with => 'This is my message!'
			
				click_button 'Create Project'
				
				wait_until() do
					page.should have_content('Sign in with your Amazon account')
				end
				
				visit(project_path(project))
				get_and_assert_project(project.name)
				
				@project = Project.find_by_name(project.name)
				assert !@project.nil?, "Project is nil"
				
				@video = Video.find_by_id(@project.video_id)
				assert !@video.nil?, "Video is nil"
				
				assert !@video.yt_video_id.nil?, "Video yt id is nil"
				
				@client = Video.yt_session
				@response = @client.video_by(@video.yt_video_id)
				
				assert !@response.listed?, "Video should be unlisted on YouTube"
				
				visit(project_path(@project))
				click_button('Edit Project')
				page.should have_content('Amazon Payments')
				
				click_button('Update Project')
				page.should have_content('Sign in with your Amazon account')
				login_amazon('spartanfan10@hotmail.com', 'testing')
				click_amazon_continue
				find('a').click
				page.should have_content('Project saved successfully')
				#project is no inactive
				
				visit(project_path(@project))
				page.should have_content(@project.name)
				
				click_button('Activate Project')
				page.driver.browser.switch_to.alert.accept
				page.should have_content('Successfully activated project.')
				
				@response = @client.video_by(@video.yt_video_id)
				assert @response.listed?, "Video should be listed/public on YouTube"
		end
	end
end
