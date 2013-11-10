require 'spec_helper'

describe "projects/show" do
  before do
    assign :project, project.decorate
    assign :rootComments, []
    assign :updates, []
    assign :comment, Comment.new
    assign :update, Update.new
  end
  subject { rendered }

  context 'user is not logged in' do
    before { render }

    it 'has the appropriate buttons' do
      should have_button 'Log in to contribute'
      should_not have_button 'Contribute to this project'
      should_not have_button 'Contribute more'
      should_not have_button "Connect an Amazon account"
      should_not have_button 'Cancel Project'
      should_not have_button 'Edit Project'
      should_not have_button 'Activate Project'
      should_not have_button 'Delete Project'
    end
  end

  context 'when signed in' do
    before { sign_in user }

    context 'user does not own project' do
      before do
        project.payment_account_id = "abc"
        project.state = :active
        project.save
      end
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should have_button 'Contribute to this project'
        should_not have_button 'Contribute more'
        should_not have_button "Connect an Amazon account"
        should_not have_button 'Cancel Project'
        should_not have_button 'Edit Project'
        should_not have_button 'Activate Project'
        should_not have_button 'Delete Project'
      end
    end

    context 'user has already contributed' do
      before { create :contribution, user: user, project: project }
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should_not have_button 'Contribute to this project'
        should have_button 'Contribute more'
        should_not have_button "Connect an Amazon account"
        should_not have_button 'Cancel Project'
        should_not have_button 'Edit Project'
        should_not have_button 'Activate Project'
        should_not have_button 'Delete Project'
      end
    end

    context 'project is expired and nonfunded' do
      before do
        project.end_date = 12.days.ago
        project.state = :nonfunded
        project.save
      end
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should_not have_button 'Contribute to this project'
        should_not have_button 'Contribute more'
        should_not have_button 'Connect an Amazon account'
        should_not have_button 'Cancel Project'
        should_not have_button 'Edit Project'
        should_not have_button 'Activate Project'
        should_not have_button 'Delete Project'
      end
    end
  end

  context 'user owns project' do
    before { sign_in project.owner }

    context 'project is active' do
      before do
        project.payment_account_id = "abc"
        project.state = :active
        project.save
      end
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should_not have_button 'Contribute to this project'
        should_not have_button 'Contribute more'
        should_not have_button "Connect an Amazon account"
        should have_button 'Cancel Project'
        should_not have_button 'Edit Project'
        should_not have_button 'Activate Project'
        should_not have_button 'Delete Project'
      end
    end

    context 'project is inactive' do
      before do
        project.payment_account_id = "abc"
        project.state = :inactive
        project.save
      end
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should_not have_button 'Contribute to this project'
        should_not have_button 'Contribute more'
        should_not have_button "Connect an Amazon account"
        should_not have_button 'Cancel Project'
        should have_button 'Edit Project'
        should have_button 'Activate Project'
        should have_button 'Delete Project'
      end
    end

    context 'project is unconfirmed' do
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should_not have_button 'Contribute to this project'
        should_not have_button 'Contribute more'
        should have_button "Connect an Amazon account"
        should_not have_button 'Cancel Project'
        should have_button 'Edit Project'
        should_not have_button 'Activate Project'
        should have_button 'Delete Project'
      end
    end
  end

  context 'user is an admin' do
    before { sign_in admin }

    context 'project is active' do
      before do
        project.payment_account_id = "abc"
        project.state = :active
        project.save
      end
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should have_button 'Contribute to this project'
        should_not have_button 'Contribute more'
        should_not have_button "Connect an Amazon account"
        should_not have_button 'Cancel Project'
        should_not have_button 'Edit Project'
        should_not have_button 'Activate Project'
        should_not have_button 'Delete Project'
        should have_button 'Block Project'
        should_not have_button 'Unblock Project'
      end
    end

    context 'project is blocked' do
      before do
        project.payment_account_id = "abc"
        project.state = :blocked
        project.save
      end
      before { render }

      it 'has the appropriate buttons' do
        should_not have_button 'Log in to contribute'
        should_not have_button 'Contribute to this project'
        should_not have_button 'Contribute more'
        should_not have_button "Connect an Amazon account"
        should_not have_button 'Cancel Project'
        should_not have_button 'Edit Project'
        should_not have_button 'Activate Project'
        should_not have_button 'Delete Project'
        should_not have_button 'Block Project'
        should have_button 'Unblock Project'
      end
    end

    private
    def admin
      @_admin ||= create :user, admin: true
    end
  end

  private
  def project
    @_project ||= create :project
  end

  def user
    @_user ||= create :user
  end
end
