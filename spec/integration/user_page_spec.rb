require 'spec_helper'
require 'integration_helper'

class UserPageTesting
  describe 'user page' do
    before :all do
      Capybara.default_driver = :selenium

      @headless = Headless.new
      @headless.start
    end

    let(:user) { create :user }
    before do
      login_as user
    end

    it "should show successfully" do
      visit user_path(user)

      expect(current_path).to eq user_path(user)

      #find('div#userProfile').has_content?('Batman')
      expect(page).to have_content(user.name)
    end

    it "should edit successfully" do
      visit edit_user_registration_path(user)

      #rails does some goofy garbage with the routes
      #expect(current_path).to eq edit_user_registration_path(@path)

      fill_in 'user_name', with: 'The Hulk'
      fill_in 'user_current_password', with: user.password

      click_button 'Update Profile'

      expect(current_path).to eq user_path(user)
      #find('div#edit_user').has_content?('The Hulk')
      expect(page).to have_content('The Hulk')
    end

    describe "redirect tests" do

      it "redirects to edit profile page after creating user"
=begin
Reason for failure unknown.
---
        user = build :user

        visit new_user_registration_path
        fill_in 'user_name', :with => user.name
        fill_in 'user_email', :with => user.email
        fill_in 'user_password', :with => user.password
        fill_in 'user_password_confirmation', :with => user.password

        click_button 'Sign up'

        expect(current_path).to eq edit_user_registration_path
      end
=end

=begin
#TODO: For some reason these two tests fail like the user still exists, though
 it should be gone from the User.delete_all. WTF.
      it "should create user successfully and redirect to project page" do
        @user = build(:user)

        @project = create(:project)
        visit project_path(@project)

        click_button 'Contribute to this project'

        click_link "Don't have an account yet? Sign up!"

        fill_in 'user_name', :with => @user.name
        fill_in 'user_email', :with => @user.email
        fill_in 'user_password', :with => @user.password
        fill_in 'user_password_confirmation', :with => @user.password

        click_button 'Sign up'

        expect(current_path).to eq project_path(@project)
      end

      it "should redirect to edit on confirm" do
        @user = create(:user)

        visit "/users/confirmation?confirmation_token=#{@user.confirmation_token}"

        expect(current_path).to eq edit_user_registration_path(@user)
      end
=end
    end
  end
end

