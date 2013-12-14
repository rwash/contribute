require 'spec_helper'

describe AmazonPaymentAccountsController do
  include Devise::TestHelpers
  def valid_attributes
    attributes_for :amazon_payment_account
  end

  describe "GET new" do
    context 'while signed in as a project owner' do
      before { sign_in project.owner }
      before { get :new, {project_id: project.to_param} }

      it { should respond_with :redirect }
    end

    context 'when the user does not own the project' do
      before { sign_in create :user }
      before { get :new, {project_id: project.to_param} }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    context 'when not signed in' do
      before { get :new, {project_id: project.to_param} }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    private
    def project
      @_project ||= create :project
    end
  end

  describe "POST create" do
    context 'when signed in as project owner' do
      before { sign_in project.owner }

      describe "with valid params" do
        before { AmazonFlexPay.stub(:verify_signature) {true} }

        let(:user) { create :user }
        let(:project) { create :project }
        let(:params) do
          {project_id: project.to_param,
           'tokenID' => token,
           status: "SR",
          }
        end

        it "should succeed with valid input" do
          get :create, params
          expect(response).to redirect_to(project)
          expect(flash[:notice]).to include "saved successfully"
        end

        it "should handle unsuccessful input" do
          p = params
          p["status"] = "NP"

          get :create, p
          expect(response).to redirect_to(project)
          expect(flash[:alert]).to include "Something went wrong"
        end

        it "should handle unsuccessful input case: 2" do
          AmazonPaymentAccount.any_instance.stub(:create){false}

          get :create, params
          expect(response).to redirect_to(project)
          expect(flash[:alert]).to include "Something went wrong"
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
      end

      describe "with invalid params" do
        before do
          AmazonPaymentAccount.any_instance.stub(:save).and_return(false)
          post :create, {project_id: project.to_param, :amazon_payment_account => {  }}
        end

        it { should redirect_to project }
        it { should set_the_flash.to(/something went wrong/i) }
      end

      describe "with an invalid signature response from Amazon" do
        it "displays appropriate error message" do
          pending
          expect(response).to redirect_to(project)
          expect(flash[:alert]).to include "Something went wrong"
        end
      end
    end

    context 'when user does not own the project' do
      before { sign_in create :user }
      before { post_create }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    context 'when the user is not logged in' do
      before { post_create }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    private
    def post_create
      post :create, {project_id: project.to_param, "tokenID" => token, status: "SR"}
    end

    def token
      "C5Q3L4H4UL4U18BA1IE12MXSDDAGCEBV1A56A5T243XF8QTDJQZ1JD9RFQW5CCWG"
    end

    def project
      @_project ||= create :project
    end
  end

  describe "DELETE destroy" do
    context 'while signed in as a project owner' do
      before { sign_in project.owner }

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
    end

    context 'when the user does not own the project' do
      before { sign_in create :user }
      let!(:amazon_payment_account) { create :amazon_payment_account }
      before { delete :destroy, {project_id: project.to_param, :id => amazon_payment_account.to_param} }

      it 'does not destroy the payment account' do
        AmazonPaymentAccount.find_by_id(amazon_payment_account.id).should_not be_nil
      end

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    context 'when the user is not signed in' do
      let!(:amazon_payment_account) { create :amazon_payment_account }
      before { delete :destroy, {project_id: project.to_param, :id => amazon_payment_account.to_param} }

      it 'does not destroy the payment account' do
        AmazonPaymentAccount.find_by_id(amazon_payment_account.id).should_not be_nil
      end

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    private
    def project
      @_project ||= create :project
    end
  end
end
