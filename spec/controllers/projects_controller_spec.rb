require 'spec_helper'
require 'controller_helper'

describe ProjectsController do
  include Devise::TestHelpers

  describe 'permissions' do
    context 'user is not signed in' do
      it "can't create a project" do
        get :new
        #new_user_session_path is the login page
        expect(response).to redirect_to(new_user_session_path)	
      end

      # Start State Tests (These tests are added after those above. Some of the ones below may cover the same thing as one above.)
      context 'project is unconfirmed,' do
        let!(:project) { Factory :project, state: :unconfirmed }

        it 'can NOT view project' do
          get :show, :id => project.name
          expect(response).to redirect_to(root_path)
        end

        it "can't destroy a project" do
          expect {get :destroy, :id => project.name}.to_not change{ Project.count }
          expect(response).to redirect_to(new_user_session_path)
        end

        it "can't edit a project" do
          get :edit, :id => project.name
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'project is inactive,' do
        let!(:project) { Factory :project, state: :inactive }

        it 'can NOT view project' do
          get :show, :id => project.name
          expect(response).to redirect_to(root_path)
        end

        it "can't destroy a project" do
          expect{ get :destroy, :id => project.name }.to_not change { Project.count }
          expect(response).to redirect_to(new_user_session_path)
        end

        it "can't edit a project" do
          get :edit, :id => project.name
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'project is active,' do
        let!(:project) { Factory :project, state: :active }

        it 'CAN view project' do
          get :show, :id => project.name
          expect(response).to be_success
        end

        it "can't destroy a project" do
          expect{ get :destroy, :id => project.name }.to_not change { Project.count }
          expect(response).to redirect_to(new_user_session_path)
        end

        it "can't edit a project" do
          get :edit, :id => project.name
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'project is funded,' do
        let!(:project) { Factory :project, state: :funded }

        it 'CAN view project' do
          get :show, :id => project.name
          expect(response).to be_success
        end

        it "can't destroy a project" do
          expect{ get :destroy, :id => project.name }.to_not change { Project.count }
          expect(response).to redirect_to(new_user_session_path)
        end

        it "can't edit a project" do
          get :edit, :id => project.name
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'project is nonfunded,' do
        let!(:project) { Factory :project, state: :nonfunded }

        it 'CAN view project' do
          get :show, :id => project.name
          expect(response).to be_success
        end

        it "can't destroy a project" do
          expect{ get :destroy, :id => project.name }.to_not change { Project.count }
          expect(response).to redirect_to(new_user_session_path)
        end

        it "can't edit a project" do
          get :edit, :id => project.name
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'project is cancelled,' do
        let!(:project) { Factory :project, state: :cancelled }

        it 'can NOT view project' do
          get :show, :id => project.name
          expect(response).to redirect_to(root_path)
        end

        it "can't destroy a project" do
          expect{ get :destroy, :id => project.name }.to_not change { Project.count }
          expect(response).to redirect_to(new_user_session_path)
        end

        it "can't edit a project" do
          get :edit, :id => project.name
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    context 'user is signed in' do
      let(:user) { Factory :user }
      before(:each) { sign_in user }

      it 'can create a project' do
        get :new
        expect(response).to be_success
      end

      #Again the tests below were added after those above and may test some of the same thing.
      context "user is project owner" do

        context 'project is unconfirmed,' do
          let!(:project) { Factory :project, user: user, state: :unconfirmed }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "CAN destroy a project" do
            expect { get :destroy, :id => project.name }.to change { Project.count }.by(-1)
            expect(flash[:alert]).to include "successfully deleted"
            expect(response).to redirect_to(root_path)
          end

          it "CAN edit the project" do
            get :edit, :id => project.name
            expect(response).to be_success
          end
        end

        context 'project is inactive,' do
          let!(:project) { Factory :project, user: user, state: :inactive }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "CAN destroy a project" do
            expect { get :destroy, :id => project.name }.to change { Project.count }.by(-1)
            expect(flash[:alert]).to include "successfully deleted"
            expect(response).to redirect_to(root_path)
          end

          it "CAN edit the project" do
            get :edit, :id => project.name
            expect(response).to be_success
          end
        end

        context 'project is active,' do
          let(:project) { Factory :project, user: user, state: :active }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "CAN cancel a project" do
            get :destroy, :id => project.name
            expect(flash[:alert]).to include "Project successfully cancelled."
            expect(response).to redirect_to(root_path)
          end

          it "can't edit the project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end

        context 'project is funded,' do
          let!(:project) { Factory :project, user: user, state: :funded }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "can NOT cancel or delete a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(flash[:alert]).to include "You can not cancel or delete this project."
            expect(response).to redirect_to(root_path)
          end

          it "can't edit the project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end

        context 'project is nonfunded,' do
          let!(:project) { Factory :project, user: user, state: :nonfunded }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "can NOT cancel or delete a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(flash[:alert]).to include "You can not cancel or delete this project."
            expect(response).to redirect_to(root_path)
          end

          it "can't edit the project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end

        context 'project is cancelled,' do
          let!(:project) { Factory :project, user: user, state: :cancelled }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "can NOT cancel or delete a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(flash[:alert]).to include "You can not cancel or delete this project."
            expect(response).to redirect_to(root_path)
          end

          it "can't edit the project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end

        end
      end

      context "user is not project owner" do
        context 'project is unconfirmed,' do
          let!(:project) { Factory :project, state: :unconfirmed }

          it 'can NOT view project' do
            get :show, :id => project.name
            expect(response).to redirect_to(root_path)
          end

          it "can't destroy a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(Project.find(project.id)).to_not be_nil
            expect(response).to redirect_to(root_path)
          end

          it "can't edit a project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end

        context 'project is inactive,' do
          let!(:project) { Factory :project, state: :inactive }

          it 'can NOT view project' do
            get :show, :id => project.name
            expect(response).to redirect_to(root_path)
          end

          it "can't destroy a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(Project.find(project.id)).to_not be_nil
            expect(response).to redirect_to(root_path)
          end

          it "can't edit a project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end

        end

        context 'project is active,' do
          let!(:project) { Factory :project, state: :active }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "can't destroy a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(Project.find(project.id)).to_not be_nil
            expect(response).to redirect_to(root_path)
          end

          it "can't edit a project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end

        context 'project is funded,' do
          let!(:project) { Factory :project, state: :funded }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "can't destroy the project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(Project.find(project.id)).to_not be_nil
            expect(response).to redirect_to(root_path)
          end

          it "can't edit the project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end

        context 'project is nonfunded,' do
          let!(:project) { Factory :project, state: :nonfunded }

          it 'CAN view project' do
            get :show, :id => project.name
            expect(response).to be_success
          end

          it "can't destroy a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(Project.find(project.id)).to_not be_nil
            expect(response).to redirect_to(root_path)
          end

          it "can't edit the project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end

        context 'project is cancelled,' do
          let!(:project) { Factory :project, state: :cancelled }

          it 'can NOT view project' do
            get :show, :id => project.name
            expect(response).to redirect_to(root_path)
          end

          it "can't destroy a project" do
            expect { get :destroy, :id => project.name }.to_not change { Project.count }
            expect(Project.find(project.id)).to_not be_nil
            expect(response).to redirect_to(root_path)
          end

          it "can't edit the project" do
            get :edit, :id => project.name
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end
  end

  describe "functional tests:" do
    context "index action" do
      it "should succeed" do
        get "index"
        expect(response).to be_success
      end
    end

    context "user is signed in" do
      let(:user) { Factory :user }
      before(:each) { sign_in user }

      context "create action" do
        render_views

        before(:all) do
          UUIDTools::UUID.stub(:random_create){}
        end

        it "succeeds for valid attributes" do
          expect{ post 'create', project: Factory.attributes_for(:project) }.to change{ Project.count }.by 1

          request = Amazon::FPS::RecipientRequest.new(save_project_url)
          expect(response).to redirect_to(request.url)
        end

        it "handles errors for invalid attributes" do
          invalid_attributes = Factory.attributes_for(:project, funding_goal: -5)
          expect{post 'create', project: invalid_attributes}.to_not change{ Project.count }

          expect(response).to be_success
          expect(response.body.inspect).to include("error")
          expect(Project.find_by_name(invalid_attributes[:name])).to be_nil
        end
      end

      context "destroy action" do
        let!(:project) { Factory.create(:project, state: :inactive, user: user) }

        it "should succeed destroy" do
          expect{ delete :destroy, :id => project.name }.to change{ Project.count }.by(-1)

          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include "successfully deleted"
        end

        it "should handle failure" do
          Project.any_instance.stub(:destroy) {false}

          expect{ delete :destroy, :id => project.name }.to_not change{ Project.count }

          expect(response).to redirect_to(project_path(project))
          expect(flash[:alert]).to include "could not be deleted"
        end
      end

      context "save action" do
        let(:project) { Factory.create(:project, user: user, state: 'unconfirmed') }
        let(:params) { {"signature"=>"Vttw5Q909REPbf2YwvVn9DGAmz/rWQdKWSOj3tLxxYXBmCi7XvHSPgZGVAnNEo1O5SkSJavDod5j\n8XlUkZ99qn7CgqfAtOq0jnWEdmk4uYScfaHZNK6Xhw+KFCuTGBDn9tQoLVIpcXqRjds+aJ237Goh\n1J0btKmw1R363dFTLXA=", "refundTokenID"=>"C7Q3D4C4UP42186ADIE428XSRD3GCNBT1AN6E5TA43XF4QMDJSZNJD7RDQWGC5WV", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0o", "tokenID"=>"C5Q3L4H4UL4U18BA1IE12MXSDDAGCEBV1A56A5T243XF8QTDJQZ1JD9RFQW5CCWG", "status"=>"SR", "callerReference"=>"8cc8eb48-7ed8-4fb4-81f2-fe83389d58f5", "controller"=>"projects", "action"=>"save"} }

        before(:each) do
          Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
        end

        it "should succeed with valid input" do
          session[:project_id] = project.id
          get :save, params
          expect(response).to redirect_to(project)
          expect(flash[:alert]).to include "saved successfully"
        end

        it "should handle unsuccessful input" do
          session[:project_id] = project.id
          params["status"] = "NP"

          get :save, params
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include "error"
        end

        it "should handle unsuccessful input case: 2" do
          Project.any_instance.stub(:save){false}
          session[:project_id] = project.id

          get :save, params
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include "error"
        end
      end
    end
  end
end
