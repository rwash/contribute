require 'spec_helper'
require 'integration_helper'

feature 'upload video', :js do

  scenario "can upload video" do
        project = build(:project)

        #login with our project creator
        login_as project.user

        #create a project
        visit(new_project_path)
        current_path.should eq new_project_path

        #fill in form
        attach_file 'video', "#{Rails.root}/test/test.mov"
        fill_in 'name' , :with => project.name
        fill_in 'project_funding_goal', :with => project.funding_goal
        fill_in 'DatePickerEndDate', :with => project.end_date.strftime('%m/%d/%Y')
        fill_in 'project_short_description', :with => project.short_description
        fill_in_ckeditor 'project_long_description', :with => 'This is my message!'

        pending "amazon sends a strange response"
        click_button 'Create Project'

        expect(page).to have_content('Sign in with your Amazon account')

        visit(project_path(project))
        project = get_and_assert_project(project.name)

        video = project.video
        expect(video).to be_nil

        # Because we're delaying video uploading, the yt_video_id should be nil (for now)
        # We'll need a way to test the rest of this process after a delay...
        expect(video.yt_video_id).to be_nil

        # When the video is uploaded, it should not be listed on youtube until the project has
        # amazon payments set up
        client = Video.yt_session
        response = client.video_by(video.yt_video_id)

        expect(response.listed?).to be_false

        visit(project_path(project))
        click_button('Edit Project')
        expect(page).to have_content('Amazon Payments')

        click_button('Update Project')
        expect(page).to have_content('Sign in with your Amazon account')
        login_amazon('spartanfan10@hotmail.com', 'testing')
        click_amazon_continue
        find('a').click
        expect(page).to have_content('Project saved successfully')
        #project is no inactive

        visit(project_path(project))
        expect(page).to have_content(project.name)

        click_button('Activate Project')
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content('Successfully activated project.')

        response = client.video_by(video.yt_video_id)
        expect(response.listed?).to be_true
  end
end
