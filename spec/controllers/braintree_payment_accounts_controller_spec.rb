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
      context 'with valid params' do
        it 'should succeed with valid input'
        it 'creates a new payment account'
        it 'redirects to the associated project'
        it 'sets the associated project to inactive'
        it 'sets the token appropriately'
      end

      context 'with invalid params' do
        it 're-renders the form'
        it 'sets the flash to an error message'
      end
    end

    context 'as non-project owner' do
      before { sign_in create :user }
      before { post_create }

      pending { should redirect_to :root }
      pending { should set_the_flash.to(/not authorized/) }
    end

    context 'when not signed in' do
      before { post_create }

      pending { should redirect_to :root }
      pending { should set_the_flash.to(/not authorized/) }
    end
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
