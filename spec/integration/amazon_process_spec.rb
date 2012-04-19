require 'spec_helper'

headless = Headless.new

describe 'amazon process' do
	fixtures :users

	before :each do
		login()
	end

	before :all do
		headless.start
	end

	after :all do
		headless.destroy
	end


	def login()
		visit(root_path)
		click_link 'Sign In'

		fill_in 'Email', :with => 'mthelen2@gmail.com'
		fill_in 'Password', :with => 'aaaaaa'
		click_button 'Sign in'

		print page.html
		page.should have_content('Signed in successfully')
	end

	it "created a project successfully" do
		visit(new_project_path)
		print page.html
		project = FactoryGirl.create(:project)
		fill_in 'project_name' , :with => project.name
		#fill_in(:project_categroy_id, :with => project.category_id)
		fill_in 'project_funding_goal', :with => project.funding_goal
		fill_in 'DatePickerEndDate', :with => project.end_date.strftime('%m/%d/%Y')
		fill_in 'project_short_description', :with => project.short_description
		fill_in 'project_long_description', :with => project.long_description
	
		click_button 'Create Project'

		#Now we're in amazon's sign in
		fill_in 'ap_email', :with => 'email'
		fill_in 'ap_password', :with => 'pass'
		click_on 'signInSubmit'
		print page.html	
	end
end

