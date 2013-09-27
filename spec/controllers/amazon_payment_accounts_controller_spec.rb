require 'spec_helper'

describe AmazonPaymentAccountsController do

  def valid_attributes
    attributes_for :amazon_payment_account
  end

  describe "GET new" do
    before { get :new, {project_id: project_id} }

    it { should respond_with :redirect }

    private
    def project_id
      2
    end
  end

  describe "POST create" do
    describe "with valid params" do
      before do
        Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
      end

      it "should succeed with valid input" do
        get :create, params
        expect(response).to redirect_to(project)
        expect(flash[:notice]).to include "saved successfully"
      end

      it "should handle unsuccessful input" do
        params["status"] = "NP"

        get :create, params
        expect(response).to redirect_to(project)
        expect(flash[:alert]).to include "Something went wrong"
      end

      it "should handle unsuccessful input case: 2" do
        AmazonPaymentAccount.any_instance.stub(:create){false}

        get :create, params
        expect(response).to redirect_to(project)
        expect(flash[:alert]).to include "Something went wrong"
      end

      let(:user) { create :user }
      let(:project) { create :project }
      let(:params) do
        {project_id: project.to_param,
         amazon_payment_account: {"token" => token}
        }
      end

      def token
        "C5Q3L4H4UL4U18BA1IE12MXSDDAGCEBV1A56A5T243XF8QTDJQZ1JD9RFQW5CCWG"
      end

      it "creates a new AmazonPaymentAccount" do
        expect {
          post_create
        }.to change(AmazonPaymentAccount, :count).by(1)
      end

      it "redirects to the associated project" do
        post_create
        response.should redirect_to(AmazonPaymentAccount.last.project)
      end

      it 'sets the associated project to inactive' do
        post_create
        project.reload.state.should eq :inactive
      end

      it 'sets the token appropriately' do
        post_create
        AmazonPaymentAccount.last.token.should eq token
      end

      private
      def post_create
        post :create, {project_id: project.to_param, :amazon_payment_account => creation_attributes}
      end

      def creation_attributes
        attributes_for(:amazon_payment_account, project_id: project.to_param, token: token)
      end

      def project
        @_project ||= create :project
      end

      describe "with invalid params" do
        it "redirects to the project show page" do
          project = create :project
          AmazonPaymentAccount.any_instance.stub(:save).and_return(false)
          post :create, {project_id: project.to_param, :amazon_payment_account => {  }}
          response.should redirect_to project
        end

        it "sets the flash to an error message"
      end

      describe 'without a project in the session' do
        before do
          project = create :project
          AmazonPaymentAccount.any_instance.stub(:save).and_return(false)
          post :create, {project_id: project.to_param, :amazon_payment_account => {  }}, {}
        end
        pending { should redirect_to :root }
        pending { should set_the_flash.to(/Something went wrong/) }
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested amazon_payment_account" do
      amazon_payment_account = create :amazon_payment_account
      expect {
        delete :destroy, {project_id: project.to_param, :id => amazon_payment_account.to_param}
      }.to change(AmazonPaymentAccount, :count).by(-1)
    end

    it 'somehow handles the contributions in progress'

    it "redirects to the associated project" do
      amazon_payment_account = create :amazon_payment_account
      delete :destroy, {project_id: project.to_param, :id => amazon_payment_account.to_param}
      response.should redirect_to amazon_payment_account.project
    end

    private
    def project
      @_project ||= create :project
    end
  end

end
