require 'spec_helper'

describe CommentsController do
  include Devise::TestHelpers
  let(:user) { Factory :user }
  let(:project) { Factory :project }

  describe 'POST create' do
    context 'when user is signed in' do
      before { sign_in user }
      before { post :create, comment: Factory.attributes_for(:comment), projectid: project.id }

      it { should redirect_to project_path(project) }
      it { should_not set_the_flash }
    end

    context 'when user is not signed in' do
      before { post :create, comment: Factory.attributes_for(:comment), projectid: project.id }

      it { should redirect_to new_user_session_path }
      it { should set_the_flash.to(/sign in/) }
    end
  end

  describe 'DELETE delete' do
    context 'when user is signed in' do
      before { sign_in user }
      let(:comment) { Factory :comment, user: user }

      before { delete :delete, id: comment.id }
      it { should set_the_flash.to(/successfully deleted/) }
    end

    context 'when user is not signed in' do
      let(:comment) { Factory :comment }

      before { delete :delete, id: comment.id }
      it { should set_the_flash.to(/sign in/) }
      it { should redirect_to new_user_session_path }
    end

    context 'when user does not own project' do
      before { sign_in user }

      before { delete :delete, id: Factory(:comment).id }
      it { should set_the_flash.to(/cannot delete comments you don't own/) }
      it { should redirect_to :root }
    end
  end
end
