require 'spec_helper'
require 'controller_helper'

describe UsersController do
  include Devise::TestHelpers
  let(:user) { Factory :user }

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
      it { should set_the_flash.to(/not authorized/) }
    end
  end

  describe "GET 'index'" do
    context 'with permission' do
      before { @ability.stub!(:can?).with(:read, User).and_return(true) }
      before { get :index }

      it { should respond_with :success }
      it { should_not set_the_flash }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:read, User).and_return(false) }
      before { get :index }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end
  end

  describe "POST 'block'" do
    context 'with permission' do
      before { @ability.stub!(:can?).with(:block, user).and_return(true) }
      before { post :block, id: user.id }

      it { should respond_with :success }
      it { should_not set_the_flash }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:block, user).and_return(false) }
      before { post :block, id: user.id }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end
  end

  describe "POST 'toggle_admin'" do
    context 'with permission' do
      before { @ability.stub!(:can?).with(:toggle_admin, user).and_return(true) }
      before { post :toggle_admin, id: user.id }

      it { should respond_with :success }
      it { should_not set_the_flash }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:toggle_admin, user).and_return(false) }
      before { post :toggle_admin, id: user.id }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end
  end
end
