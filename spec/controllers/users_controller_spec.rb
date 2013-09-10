require 'spec_helper'
require 'controller_helper'

describe UsersController do
  include Devise::TestHelpers
  render_views

  let(:user) { create :user }

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  describe "GET 'show'" do
    context 'with permission' do
      before { @ability.stub!(:can?).with(:read, user).and_return(true) }
      before { get :show, id: user.id }

      it { should respond_with :success }
      it { should_not set_the_flash }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:read, user).and_return(false) }
      before { get :show, id: user.id }

      it { should redirect_to :root }
      it { should set_the_flash.to I18n.t('unauthorized.manage.all') }
    end
  end

  describe "GET 'edit'" do
    context 'with permission' do
      before { @ability.stub!(:can?).and_return(true) }
      before { @ability.stub!(:can?).with(:edit, user).and_return(true) }
      before { get :edit, id: user.id }

      it { should respond_with :success }
      it { should_not set_the_flash }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:edit, user).and_return(false) }
      before { get :edit, id: user.id }

      it { should redirect_to :root }
      it { should set_the_flash.to I18n.t('unauthorized.manage.all') }
    end
  end

  describe "GET 'index'" do
    context 'with permission' do
      before { @ability.stub!(:can?).with(:read, User).and_return(true) }
      before { get :index }

      it { should respond_with :success }
      it { should_not set_the_flash }
      it { should assign_to :users }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:read, User).and_return(false) }
      before { get :index }

      it { should redirect_to :root }
      it { should set_the_flash.to I18n.t('unauthorized.manage.all') }
    end
  end

  describe "POST 'block'" do
    before { @request.env['HTTP_REFERER'] = user_path(user) }

    context 'with permission' do
      before { @ability.stub!(:can?).with(:block, user).and_return(true) }

      context "with 'blocked': true" do
        before { post :block, id: user.id, blocked: true }

        it { should redirect_to user_path(user) }
        it { should set_the_flash.to I18n.t('users.block.success.flash', username: user.name) }
        it 'should set blocked to true' do
          expect(user.reload.blocked?).to be_true
        end
      end

      context "with 'blocked': false" do
        before { post :block, id: user.id, blocked: false }

        it { should redirect_to user_path(user) }
        it { should set_the_flash.to I18n.t('users.block.success.flash', username: user.name) }
        it 'should set blocked to false' do
          expect(user.reload.blocked?).to be_false
        end
      end
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:block, user).and_return(false) }
      before { post :block, id: user.id, blocked: true }

      it { should redirect_to :root }
      it { should set_the_flash.to I18n.t('unauthorized.manage.all') }
    end
  end

  describe "POST 'toggle_admin'" do
    before { @request.env['HTTP_REFERER'] = user_path(user) }

    context 'with permission' do
      before { @ability.stub!(:can?).with(:toggle_admin, user).and_return(true) }

      context "with 'admin': true" do
        before { post :toggle_admin, id: user.id, admin: true }

        it { should respond_with :redirect }
        it { should set_the_flash.to I18n.t('users.toggle_admin.success.flash', username: user.name) }
        it 'should toggle admin status' do
          expect(user.reload.admin?).to be_true
        end
      end

      context "with 'admin': false" do
        before { post :toggle_admin, id: user.id, admin: false }

        it { should respond_with :redirect }
        it { should set_the_flash.to I18n.t('users.toggle_admin.success.flash', username: user.name) }
        it 'should toggle admin status' do
          expect(user.reload.admin?).to be_false
        end
      end
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:toggle_admin, user).and_return(false) }
      before { post :toggle_admin, id: user.id, admin: true }

      it { should redirect_to :root }
      it { should set_the_flash.to I18n.t('unauthorized.manage.all') }
    end
  end
end
