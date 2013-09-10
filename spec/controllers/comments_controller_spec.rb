require 'spec_helper'

describe CommentsController do
  render_views

  include Devise::TestHelpers
  let(:user) { create :user }
  let(:project) { create :project }

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  describe 'POST create' do
    context 'when user is signed in' do
      before { sign_in user }

      before { @ability.stub!(:can?).and_return(true) }
      before { post :create, comment: attributes_for(:comment), projectid: project.id }

      it 'creates a comment' do
        expect {
          post :create, comment: attributes_for(:comment), projectid: project.id
        }.to change{Comment.count}.by 1
      end

      it { should redirect_to project_path(project) }
      it { should_not set_the_flash }
    end

    context 'when user is not signed in' do
      before { post :create, comment: attributes_for(:comment), projectid: project.id }

      it { should redirect_to new_user_session_path }
      it { should set_the_flash.to I18n.t('devise.failure.unauthenticated') }
    end
  end

  describe 'DELETE destroy' do
    context 'with permission' do
      before { sign_in user }
      let(:comment) { create :comment, user: user }

      before { @ability.stub!(:can?).with(:destroy, comment).and_return(true) }
      before { delete :destroy, id: comment.id }
      it { should set_the_flash.to I18n.t('comments.destroy.success.flash') }
    end

    context 'when user is not signed in' do
      let(:comment) { create :comment }

      before { delete :destroy, id: comment.id }
      it { should set_the_flash.to I18n.t('devise.failure.unauthenticated') }
      it { should redirect_to new_user_session_path }
    end

    context 'without permission' do
      before { sign_in user }
      let(:comment) { create :comment }

      before { @ability.stub!(:can?).with(:destroy, comment).and_return(false) }
      before { delete :destroy, id: comment.id }
      it { should set_the_flash.to I18n.t('unauthorized.destroy.comment') }
      it { should redirect_to :root }
    end
  end
end
