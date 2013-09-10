require 'spec_helper'
require 'controller_helper'

describe ContributionsController do
  include Devise::TestHelpers
  render_views

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  let(:user) { create :user }
  let!(:project) { create :active_project }

  describe 'GET new' do
    context 'when user is not signed in' do
      before { get :new, project: project.id }

      it { should redirect_to(new_user_session_path) }
      it { should set_the_flash.to I18n.t('devise.failure.unauthenticated') }
    end

    context 'when user is signed in' do
      before { sign_in user }

      context 'without permission' do
        before { @ability.stub!(:can?).and_return(false) }
        before { get :new, project: project.name }

        it { should redirect_to project_path(project) }
        it { should set_the_flash.to I18n.t('unauthorized.create.contribution') }
      end

      context 'with permission' do
        before { @ability.stub!(:can?).and_return(true) }
        before { get :new, project: project.name }

        it { should respond_with :success }
        it { should_not set_the_flash }
      end
    end
  end

  describe 'POST create' do
    before { post :create, contribution: attributes_for(:contribution) }

    it { should respond_with :redirect }
  end

  describe 'POST save' do
    let(:contribution) { create :contribution, user: user }
    let(:params) { {"tokenID"=>"I6TRJVI1ARAHBNCZFJII35UPJXJCXMD5ID9RHMMIUJ6DAJAZDSDEKDAEVBDPQBB3",
                    "status"=>"SC" } }

    before(:each) do
      sign_in user
      Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
    end

    it "succeeds for valid input" do
      session[:contribution_id] = contribution.id

      get :save, params
      expect(response).to redirect_to(contribution.project)
      expect(flash[:alert]).to include "submitted"
    end

    it "displays an error for a nil contribution" do
      session[:contribution_id] = nil

      get :save, params
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include "error"
    end

    it "handles invalid parameters" do
      session[:contribution_id] = contribution.id
      params["tokenID"] = nil

      get :save, params
      expect(response).to redirect_to(contribution.project)
      expect(flash[:alert]).to include "error"
    end

    it "shows an error if contribution doesn't save" do
      Contribution.any_instance.stub(:save){false}

      session[:contribution_id] = contribution.id

      get :save, params
      expect(response).to redirect_to(contribution.project)
      expect(flash[:alert]).to include "error"
    end
  end

  # Keep this test in, because the error is being raised in the
  # ContributionsController, instead of by the Rails Routing system
  describe 'GET show' do
    it 'is not a valid route' do
      expect { get :show, id: create(:contribution) }.to raise_error
    end
  end

  describe 'GET edit' do
    context 'with permission' do
      let(:contribution) { create :contribution, project: project, user: user }

      before { sign_in user }
      before { @ability.stub!(:can?).and_return(true) }
      before { get :edit, id: contribution.id }

      it { should respond_with :success }
    end

    context "without permission" do
      let(:contribution) { create :contribution, project: project, user: user }

      before { sign_in user }
      before { @ability.stub!(:can?).and_return(false) }
      before { get :edit, id: contribution.id }

      it { should redirect_to project_path(project) }
      it { should set_the_flash.to I18n.t('unauthorized.update.contribution') }
    end

    it "handles invalid contribution" do
      sign_in user
      get :edit, { id: 0 }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include "error"
    end
  end

  describe 'POST update' do
    let(:contribution) { create :contribution }
    before { @ability.stub!(:can?).and_return(true) }
    before { post :update, id: contribution.id, contribution: contribution.attributes.symbolize_keys }

    it { should respond_with :redirect }
  end

  describe 'POST update_save' do
    let(:contribution) { create :contribution, user: user }
    let(:editing_contribution) { create :contribution, user: user, project: contribution.project }
    let(:params) { {"tokenID"=>"I4TRCVA1ATAFBN1ZJJI634UP4XQCX9DDIDNR1MM7UF6DDJ6ZDDD7KD9E4BDVQIBF",
                    "status"=>"SC"} }

    before(:each) do
      sign_in user
      Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
      Amazon::FPS::CancelTokenRequest.stub(:send)
    end

    it "succeeds with valid input" do
      session[:contribution] = contribution #new contribution
      session[:editing_contribution_id] = editing_contribution.id #old contribution
      get :update_save, params
      expect(response).to redirect_to(contribution.project)
      expect(flash[:alert]).to include "successfully updated"
    end

    it "fails if there is no contribution in session" do
      session[:contribution] = nil
      session[:editing_contribution_id] = editing_contribution.id

      get :update_save, params
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include "error"
    end

    it "fails when given invalid params" do
      session[:contribution] = contribution
      session[:editing_contribution_id] = editing_contribution.id
      params["tokenID"] = nil

      get :update_save, params
      expect(response).to redirect_to(contribution.project)
      expect(flash[:alert]).to include "error"
    end

    it "displays error message if the contribution can't save" do
      Contribution.any_instance.stub(:save){false}

      session[:contribution] = contribution
      session[:editing_contribution_id] = editing_contribution.id

      get :update_save, params
      expect(response).to redirect_to(contribution.project)
      expect(flash[:alert]).to include "error"
    end

    it "displays error message if editing contribution can't cancel" do
      Contribution.any_instance.stub(:cancel){false}
      Contribution.any_instance.stub(:save){true} #if you remove this, you will get a stack overflow error at contribution.save.  The previous test and this one will run in isolation, but not one after another *shrugs*

      session[:contribution] = contribution
      session[:editing_contribution_id] = editing_contribution.id

      get :update_save, params
      expect(response).to redirect_to(contribution.project)
      expect(flash[:alert]).to include "error"
    end
  end

  describe "method validate_project" do
    let(:project_1) { create :project, active: 0 }
    let(:project_2) { create :project, confirmed: 0 }

    before { @ability.stub!(:can?).and_return(true) }
    before { @ability.stub!(:can?).and_return(true) }

    before(:each) { sign_in user }

    it "handles invalid project" do
      get :new, project: project_1.name
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include "error"
    end

    it "handles invalid project case: 2" do
      get :new, project: project_2.name
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include "error"
    end
  end
end
