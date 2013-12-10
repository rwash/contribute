require 'spec_helper'

describe BraintreePaymentAccountsController do
  include Devise::TestHelpers

  describe "GET new" do
    context 'as project owner' do
      before { sign_in project.owner }
      before { get :new, {project_id: project.to_param} }

      it { should respond_with :success }
    end

    context 'as non-project owner' do
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
    context 'as project owner' do
      before { sign_in project.owner }

      context 'with valid params' do
        it 'creates a new payment account' do
          expect { post_create }.to change(BraintreePaymentAccount, :count).by(1)
        end

        it 'redirects to the associated project' do
          post_create
          response.should redirect_to project
        end

        it 'sets the project to inactive' do
          post_create
          project.reload.state.should eq :inactive
        end

        it 'stores a pending braintree merchant account id' do
          post_create
          account = BraintreePaymentAccount.last
          account.token.should_not be_nil
        end
      end

      context 'with invalid params' do
        it 're-renders the form'
        it 'sets the flash to an error message'
      end
    end

    context 'as non-project owner' do
      before { sign_in create :user }
      before { post_create }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    context 'when not signed in' do
      before { post_create }

      it { should redirect_to :root }
      it { should set_the_flash.to(/not authorized/) }
    end

    private
    def post_create
      post :create, { project_id: project.to_param, braintree_payment_account: braintree_params }
    end

    def braintree_params
      {
        :first_name => Braintree::Test::MerchantAccount::Approve,
        :last_name => "Bloggs",
        :email => "joe@14ladders.com",
        :street_address => "123 Credibility St.",
        :postal_code => "60606",
        :locality => "Chicago",
        :region => "IL",
        :date_of_birth => "1980-10-09",
        :routing_number => "021000021",
        :account_number => "43759348798",
        :tos_accepted => true,
      }
    end

    let(:project) { create :project }
  end

  describe "DELETE destroy" do
    context 'as project owner' do
      it 'destroys the payment account'
      pending 'somehow handles the contributions in progress'
      it 'redirects to the associated project'
    end

    context 'as non-project owner' do
      it 'does not destroy the payment account'
      pending { should redirect_to :root }
      pending { should set_the_flash.to(/not authorized/) }
    end

    context 'when not signed in' do
      it 'does not destroy the payment account'
      pending { should redirect_to :root }
      pending { should set_the_flash.to(/not authorized/) }
    end
  end
end
