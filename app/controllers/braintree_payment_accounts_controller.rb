class BraintreePaymentAccountsController < ApplicationController
  skip_authorization_check

  def new
    authorize project.owner
  end

  def create
    authorize project.owner do
      braintree_params = params[:braintree_payment_account]
      result = register_braintree_merchant braintree_params
      begin
        BraintreePaymentAccount.create token: result.merchant_account.id, project: project
        project.state = :inactive
        project.save
        redirect_to project
      rescue
        flash[:alert] = "There was a problem with the information you entered. Please try again."
        render :new
      end
    end
  end

  def destroy
    authorize project.owner
  end

  private
  def project
    @_project ||= Project.find_by_slug! params[:project_id]
  end

  def authorize user
    if current_user == user
      yield if block_given?
    else
      redirect_to :root, alert: "You are not authorized to access that page."
    end
  end

  def merchant_account_id
    Contribute::Application.config.braintree_merchant_account_id
  end

  def register_braintree_merchant params
    Braintree::MerchantAccount.create(
      :applicant_details => {
        :first_name => params[:first_name],
        :last_name => params[:last_name],
        :email => params[:email],
        :address => {
          :street_address => params[:street_address],
          :postal_code => params[:postal_code],
          :locality => params[:locality],
          :region => params[:region],
        },
        :date_of_birth => params[:date_of_birth],
        :routing_number => params[:routing_number],
        :account_number => params[:account_number],
      },
      :tos_accepted => params[:tos_accepted],
      :master_merchant_account_id => merchant_account_id,
    )
  end
end
