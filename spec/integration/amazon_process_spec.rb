require 'spec_helper'

describe 'amazon process' do
	fixtures :users

	before :each do
		login()
	end

	def login()
		visit(root_url)
		click_link 'Sign In'

		fill_in 'Email', :with => 'mthelen2@gmail.com'
		fill_in 'Password', :with => 'aaaaaa'
		click_button 'Sign in'

		print page.html
		page.should have_content('Signed in successfully')
	end

	it "created a project successfully", :js => true do
		visit(new_project_url)
		print page.html
	end
end

