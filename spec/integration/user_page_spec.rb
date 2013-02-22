require 'spec_helper'
require 'integration_helper'

class UserPageTesting
  describe 'user page' do
    before :all do
      Capybara.default_driver = :selenium

      @headless = Headless.new
      @headless.start
    end

    context "when signed in" do
      let(:user) { create :user }
      before { login_as user }

      it "should show successfully" do
        visit user_path(user)

        expect(current_path).to eq user_path(user)

        expect(page).to have_content(user.name)
      end

      it "should show inactive projects" do
        project = create :project, state: :inactive, user: user

        visit user_path(user)
        expect(page).to have_content(project.name)
      end

      it "should show unconfirmed projects" do
        project = create :project, state: :unconfirmed, user: user

        visit user_path(user)
        expect(page).to have_content(project.name)
      end

      it "should edit successfully" do
        visit edit_user_registration_path(user)

        fill_in 'user_name', with: 'The Hulk'
        fill_in 'user_current_password', with: user.password

        click_button 'Update Profile'

        expect(current_path).to eq user_path(user)
        expect(page).to have_content('The Hulk')
      end
    end

    describe "redirect tests" do

      it "redirects to edit profile page after creating user" do
        user = build :user

        visit new_user_registration_path
        fill_in 'user_name', :with => user.name
        fill_in 'user_email', :with => user.email
        fill_in 'user_password', :with => user.password
        fill_in 'user_password_confirmation', :with => user.password

        click_button 'Sign up'

        expect(current_path).to eq edit_user_registration_path
      end

      it "should create user successfully and redirect to project page" do
        user = build(:user)

        project = create(:project, state: :active)
        visit project_path(project)

        click_button 'Contribute to this project'

        click_link "Don't have an account yet? Sign up!"

        fill_in 'user_name', :with => user.name
        fill_in 'user_email', :with => user.email
        fill_in 'user_password', :with => user.password
        fill_in 'user_password_confirmation', :with => user.password

        click_button 'Sign up'

        expect(current_path).to eq new_contribution_path(project)
      end

      it "should redirect to edit on confirm" do
        user = create(:unconfirmed_user)

        visit "/users/confirmation?confirmation_token=#{user.confirmation_token}"

        expect(current_path).to eq edit_user_registration_path(user)
      end
    end
  end
end
