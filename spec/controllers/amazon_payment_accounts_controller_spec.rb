require 'spec_helper'

describe AmazonPaymentAccountsController do

  def valid_attributes
    attributes_for :amazon_payment_account
  end

  def valid_session
    {}
  end

  describe "GET new" do
    before { get :new, {project_id: project_id}, valid_session }

    it { should respond_with :redirect }

    it 'sets the project_id session variable' do
      session[:project_id].to_i.should eq project_id
    end

    private
    def project_id
      2
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AmazonPaymentAccount" do
        expect {
          post :create, {:amazon_payment_account => creation_attributes}, valid_session
        }.to change(AmazonPaymentAccount, :count).by(1)
      end

      it "redirects to the associated project" do
        post :create, {:amazon_payment_account => creation_attributes}, {project_id: project.id}
        response.should redirect_to(AmazonPaymentAccount.last.project)
      end

      private
      def creation_attributes
        attributes_for(:amazon_payment_account, project_id: project.id)
      end

      def project
        @_project ||= create :project
      end
    end

    describe "with invalid params" do
      it "redirects to the project show page" do
        project = create :project
        AmazonPaymentAccount.any_instance.stub(:save).and_return(false)
        post :create, {:amazon_payment_account => {  }}, {project_id: project.id}
        response.should redirect_to project
      end

      it "sets the flash to an error message"
    end

    describe 'without a project in the session' do
      before do
        project = create :project
        AmazonPaymentAccount.any_instance.stub(:save).and_return(false)
        post :create, {:amazon_payment_account => {  }}, {}
      end
      it { should redirect_to :root }
      it { should set_the_flash.to(/Something went wrong/) }
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested amazon_payment_account" do
      amazon_payment_account = create :amazon_payment_account
      expect {
        delete :destroy, {:id => amazon_payment_account.to_param}, valid_session
      }.to change(AmazonPaymentAccount, :count).by(-1)
    end

    it 'somehow handles the contributions in progress'

    it "redirects to the associated project" do
      amazon_payment_account = create :amazon_payment_account, project_id: project.id
      delete :destroy, {:id => amazon_payment_account.to_param}, valid_session
      response.should redirect_to project
    end

    private
    def project
      @_project ||= create :project
    end
  end

end
