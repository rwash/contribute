require 'spec_helper'

describe ProjectsController do
  include Devise::TestHelpers
  render_views

  [:index, :show].each do |page|
    context "GET #{page}" do
      let(:user) { create :user }
      let(:project) { create :project }
      before { sign_in user }

      it "records page views" do
        get page, test_params
        should log_page_view user, :projects, page, test_params
      end

      private
      def test_params
        {a: :b, "string_key" => 10, id: project.to_param}
      end
    end
  end

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  let(:user) { create :user }
  let!(:project) { create :project }

  context "GET index" do
    before { @ability.stub!(:can?).with(:index, Project).and_return(true) }
    before { get :index }

    it { should respond_with :success }
    it { should render_template :index }
    it { should assign_to :projects }

    context 'with a search parameter' do
      it 'returns an empty array if there are no matching projects' do
        3.times { create :searchable_project }
        search_results.should eq []
      end

      it 'returns projects with matching names' do
        projects = [create(:searchable_project, name: 'unicorn'),
                    create(:searchable_project)]
        search_results.should eq [projects.first]
      end

      it 'returns projects with matching short descriptions' do
        projects = [create(:searchable_project, short_description: 'unicorn'),
                    create(:searchable_project)]
        search_results.should eq [projects.first]
      end

      it 'searches the name and short description at the same time' do
        projects = [create(:searchable_project, short_description: 'unicorn'),
                    create(:searchable_project),
                    create(:searchable_project, name: 'unicorn')]
        search_results.sort_by(&:id).should eq [projects.first, projects.last].sort_by(&:id)
      end

      it 'favors name matching over short description matching' do
        projects = [create(:searchable_project, short_description: 'unicorn'),
                    create(:searchable_project),
                    create(:searchable_project, name: 'unicorn')]
        search_results.should eq [projects.last, projects.first]
      end

      it "returns projects with similar names" do
        projects = [create(:searchable_project, name: 'Unicorn cookies'),
                    create(:searchable_project),
                    create(:searchable_project, name: 'Awesome unicorn joke book')]
        search_results.should eq [projects.first, projects.last]
      end

      it "returns projects with similar short descriptions" do
        projects = [create(:searchable_project, short_description: 'Unicorn cookies'),
                    create(:searchable_project),
                    create(:searchable_project, short_description: 'Awesome unicorn joke book')]
        search_results.should eq [projects.first, projects.last]
      end

      it 'only returns active projects' do
        projects = [create(:project, short_description: 'Unicorn cookies'),
                    create(:active_project, short_description: 'Unicorn cookies')]
        Sunspot.index! projects
        search_results.should eq [projects.last]
      end

      private
      def search_results
        get :index, search_parameters
        assigns :projects
      end

      def search_parameters
        { search: 'unicorn' }
      end
    end
  end

  describe 'POST update' do
    context 'with permission' do
      let(:project) { create :project }
      before { sign_in user }
      before { @ability.stub!(:can?).with(:update, project).and_return(true) }
      before { post :update, id: project.to_param, project: attributes }
      let(:attributes) { attributes_for :project }

      it { should set_the_flash.to(/Successfully updated project/) }
      it { should log_user_action(user, :update, project) }

      it 'logs the params' do
        attributes.keys.each do |attr|
          UserAction.last.message.should match attributes[attr].to_s
        end
      end
    end
  end

  describe 'PUT activate' do
    context 'with permission' do
      let(:project) { create :project }
      before { @ability.stub!(:can?).with(:activate, project).and_return(true) }
      let(:user) { project.owner }
      before { sign_in user }

      context 'when not signed in' do
        pending 'does not activate project'
      end

      it 'sets project state to active if project has payment_account_id' do
        # TODO extract this into a fake Amazon API
        project.payment_account_id = 'ABCD'
        project.save
        put :activate, id: project.to_param
        expect(project.reload.state).to eq :active
      end

      it 'logs the activate event' do
        project.payment_account_id = 'ABCD'
        project.save
        put :activate, id: project.to_param
        should log_user_action user, :activate, project
      end

      it "doesn't activate project without a payment_account_id" do
        expect { put :activate, id: project.to_param }.to raise_error
        expect(project.reload.state).to_not eq :active
      end
    end

    context 'without permission' do
      let(:project) { create :project }
      before { @ability.stub!(:can?).with(:activate, project).and_return(false) }
      before { put :activate, id: project.to_param }

      it 'sets project state to active' do
        expect(project.reload.state).to_not eq :active
      end
    end
  end

  describe 'GET new' do
    context 'when not signed in' do
      it "can't create a project" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when signed in' do
      before { sign_in user }

      context 'with permission' do
        before do
          @ability.should_receive(:can?) { |arg1, arg2|
            arg1.should eq :new
            arg2.should be_instance_of Project
            true
          }
        end

        it 'can create a project' do
          get :new
          expect(response).to be_success
        end
      end
    end
  end

  describe 'GET show' do
    context 'with permission' do
      before { @ability.stub!(:can?).and_return(true) }
      before { @ability.stub!(:can?).with(:show, project).and_return(true) }

      it 'CAN view project' do
        get :show, id: project.to_param
        expect(response).to be_success
      end
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:show, project).and_return(false) }

      it 'can NOT view project' do
        get :show, id: project.to_param
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET edit' do
    context 'without permission' do
      before { @ability.stub!(:can?).with(:edit, project).and_return(false) }

      it "can't edit a project" do
        get :edit, id: project.to_param
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with permission' do
      before { sign_in user }
      before { @ability.stub!(:can?).with(:edit, project).and_return(true) }

      it "CAN edit the project" do
        get :edit, id: project.to_param
        expect(response).to be_success
      end
    end
  end

  describe 'POST create' do
    render_views

    context 'user is signed in' do
      before { sign_in user }

      before { UUIDTools::UUID.stub(:random_create){} }
      before do
        @ability.stub!(:can?) { |arg1, arg2|
          arg1.should eq :create
          arg2.should be_instance_of Project
          true
        }
      end

      it "succeeds for valid attributes" do
        attributes = attributes_for :project
        expect{ post :create, project: attributes }.to change(Project, :count).by 1

        expect(response).to redirect_to(Project.last)
      end

      it "handles errors for invalid attributes" do
        invalid_attributes = attributes_for(:project, funding_goal: -5)
        expect{post :create, project: invalid_attributes}.to_not change{ Project.count }

        expect(response).to be_success
        expect(response.body.inspect).to include("error")
        expect(Project.find_by_name(invalid_attributes[:name])).to be_nil
      end

      it 'logs the create action' do
        attributes = attributes_for(:project)
        post :create, {project: attributes}
        should log_user_action user, :create, Project.last
      end

      it 'logs the params' do
        attributes = attributes_for(:project)
        post :create, {project: attributes}
        attributes.keys.each do |attr|
          UserAction.last.message.should match attributes[attr].to_s
        end
      end
    end
  end

  describe 'DELETE destroy' do
    context 'with permission' do
      before { sign_in user }
      before { @ability.stub!(:can?).with(:destroy, project).and_return(true) }

      it "CAN destroy a project" do
        expect { get :destroy, id: project.to_param }.to change { Project.count }.by(-1)
        expect(flash[:notice]).to include "successfully deleted"
        expect(response).to redirect_to(root_path)
      end

      pending 'logs the user action' do
        should log_user_action user, :destroy, Project.last
      end

      it "should succeed destroy" do
        expect{ delete :destroy, id: project.to_param }.to change{ Project.count }.by(-1)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include "successfully deleted"
      end

      it "should handle failure" do
        Project.any_instance.stub(:destroy) {false}

        expect{ delete :destroy, id: project.to_param }.to_not change{ Project.count }

        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to include "could not be deleted"
      end
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:destroy, project).and_return(false) }

      it "can't destroy a project" do
        expect {get :destroy, id: project.to_param}.to_not change{ Project.count }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
