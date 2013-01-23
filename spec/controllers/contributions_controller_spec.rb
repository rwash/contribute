require 'spec_helper'
require 'controller_helper'

describe ContributionsController do
  include Devise::TestHelpers

  describe 'permissions' do
    let!(:project) { Factory :project, state: :active }

    context 'when user is not signed in' do
      it "does not allow contributions" do
        expect {get :new, :project => project.id}.to_not change { Contribution.count }
        expect(response).to redirect_to(new_user_session_path)
      end	
    end

    context 'when user is signed in' do
      let(:user) { Factory :user }
      before(:each) { sign_in user }

      it "allows contributions" do
        get :new, :project => project.name
        expect(response).to be_success
      end

      it "does not allow contributions to projects the user owns" do
        project = Factory :project, state: :active, user: user
        expect {get :new, :project => project.name}.to_not change { Contribution.count }
        expect(response).to redirect_to(project)
        expect(flash[:alert]).to include "may not contribute"
      end		

      it "lets user edit their contributions" do
        contribution = FactoryGirl.create(:contribution, :user => user, :project => project)
        get :edit, :id => contribution.id
        expect(response).to be_success
      end

      it "does not let user edit someone else's contribution" do
        contribution = FactoryGirl.create(:contribution, :project => project)
        get :edit, :id => contribution.id
        expect(response).to redirect_to(project)
        expect(flash[:alert]).to include "may not edit this contribution"
      end

      it "does not allow contributions after project end date" do
        Timecop.freeze(project.end_date + 2) do
          expect {get :new, :project => project.name}.to_not change { Contribution.count }
          expect(response).to redirect_to(project)
          expect(flash[:alert]).to include "may not contribute"
        end
      end

      it "does not allow contributions one day after project end date" do
        Timecop.freeze(project.end_date + 1) do
          expect {get :new, :project => project.name}.to_not change { Contribution.count }
          expect(response).to redirect_to(project)
          expect(flash[:alert]).to include "may not contribute"
        end
      end

      it "allows contributions on project end date" do
        Timecop.freeze(project.end_date) do
          expect {get :new, :project => project.name}.to_not change { Contribution.count }
          expect(response).to be_success
        end
      end

      it "allows contributions before project end date" do
        Timecop.freeze(project.end_date - 1) do
          expect {get :new, :project => project.name}.to_not change { Contribution.count }
          expect(response).to be_success
        end
      end
    end
  end

  describe 'functional tests: ' do
    let(:user) { Factory :user }

    context 'save action' do
      before(:all) do
        project = FactoryGirl.create(:project)
        @contribution = FactoryGirl.create(:contribution, :user => user, :project => project)
      end

      before(:each) do
        sign_in user
        @params = {"signature"=>"Thvdd5kskNDHS27B33qHnI9M2Rdm3kYFhP0jU2LBd69i/COjNzAYDetOoudQMsFKuRvM1g5/TDDh\nRdKSWQvX9rz65BDgdruXIoxeFouMLyZgkXSCR8lEHUMosxJVYo5bn6qSeUCmFyJ42iy+05zqc6yf\ncEpTePp3mnGJ2do6LN8=", "expiry"=>"10/2017", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0o", "tokenID"=>"I6TRJVI1ARAHBNCZFJII35UPJXJCXMD5ID9RHMMIUJ6DAJAZDSDEKDAEVBDPQBB3", "status"=>"SC", "callerReference"=>"4d9cf6a3-59d7-4fda-8ddb-296e92c95b06", "controller"=>"contributions", "action"=>"save"}
        Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
      end

      it "succeeds for valid input" do
        session[:contribution_id] = @contribution.id

        get :save, @params
        expect(response).to redirect_to(@contribution.project)
        expect(flash[:alert]).to include "submitted"
      end

      it "displays an error for a nil contribution" do
        session[:contribution_id] = nil

        get :save, @params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include "error"
      end

      it "handles invalid parameters" do
        session[:contribution_id] = @contribution.id
        @params["tokenID"] = nil

        get :save, @params
        expect(response).to redirect_to(@contribution.project)
        expect(flash[:alert]).to include "error"
      end

      it "shows an error if contribution doesn't save" do
        Contribution.any_instance.stub(:save){false}

        session[:contribution_id] = @contribution.id

        get :save, @params
        expect(response).to redirect_to(@contribution.project)
        expect(flash[:alert]).to include "error"
      end
    end

    describe 'show action' do
      it "raises 404" do
        expect { get :show, :id => 1 }.to raise_error
      end
    end

    context 'update_save action' do
      before(:all) do
        project = FactoryGirl.create(:project)
        @editing_contribution = FactoryGirl.create(:contribution, :user => user, :project => project)
        @contribution = FactoryGirl.build(:contribution, :user => user, :project => project)
      end

      before(:each) do
        sign_in user
        @params = {"signature"=>"IPbBYiozVv4/HHI+hMQLbY1L9rq0x+jSvka0/p65gGqCKdqRhegLF/WURdIjB/9mMFLDxv0BinZw\nT29ij5uTJL1Vqm0mLTAGVeo2v/cpBFJF+egfDjTE1P3TkS23S+YKvzcCxGstGgXnCbSkXcGI0oGM\ntwlT7H5eMRX5Mp6F8eo=", "expiry"=>"10/2017", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0o", "tokenID"=>"I4TRCVA1ATAFBN1ZJJI634UP4XQCX9DDIDNR1MM7UF6DDJ6ZDDD7KD9E4BDVQIBF", "status"=>"SC", "callerReference"=>"b87070fe-a36f-4dee-80f4-3a8e76837096", "controller"=>"contributions", "action"=>"update_save"}
        Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
        Amazon::FPS::CancelTokenRequest.stub(:send)
      end

      it "succeeds with valid input" do
        session[:contribution] = @contribution #new contribution
        session[:editing_contribution_id] = @editing_contribution.id #old contribution	
        get :update_save, @params
        expect(response).to redirect_to(@contribution.project)
        expect(flash[:alert]).to include "successfully updated"
      end

      it "fails if there is no contribution in session" do
        session[:contribution] = nil
        session[:editing_contribution_id] = @editing_contribution.id

        get :update_save, @params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include "error"
      end

      it "fails when given invalid params" do
        session[:contribution] = @contribution
        session[:editing_contribution_id] = @editing_contribution.id
        @params["tokenID"] = nil

        get :update_save, @params
        expect(response).to redirect_to(@contribution.project)
        expect(flash[:alert]).to include "error"
      end

      it "displays error message if the contribution can't save" do
        Contribution.any_instance.stub(:save){false}

        session[:contribution] = @contribution
        session[:editing_contribution_id] = @editing_contribution.id

        get :update_save, @params
        expect(response).to redirect_to(@contribution.project)
        expect(flash[:alert]).to include "error"
      end

      it "displays error message if editing contribution can't cancel" do
        Contribution.any_instance.stub(:cancel){false}
        Contribution.any_instance.stub(:save){true} #if you remove this, you will get a stack overflow error at @contribution.save.  The previous test and this one will run in isolation, but not one after another *shrugs*

        session[:contribution] = @contribution
        session[:editing_contribution_id] = @editing_contribution.id

        get :update_save, @params
        expect(response).to redirect_to(@contribution.project)
        expect(flash[:alert]).to include "error"
      end
    end

    describe "method validate_project" do
      let(:project_1) { Factory :project, active: 0 }
      let(:project_2) { Factory :project, confirmed: 0 }

      before(:each) { sign_in user }

      it "handles invalid project" do
        get :new, :project => project_1.name
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include "error"
      end

      it "handles invalid project case: 2" do
        get :new, :project => project_2.name
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include "error"
      end
    end

    describe "method prepare_contribution" do
      it "handles invalid contribution" do
        sign_in user
        get :edit, {:id => 1 }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include "error"
      end
    end
  end
end
