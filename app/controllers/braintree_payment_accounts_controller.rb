class BraintreePaymentAccountsController < ApplicationController
  skip_authorization_check

  def new
    unless current_user == project.owner
      unauthorized
    end
  end

  def create
    unless current_user == project.owner
      return unauthorized
    end
    project.state = :inactive
    project.save
    application = params[:braintree_payment_account]
    result = Braintree::MerchantAccount.create(
      :applicant_details => {
        :first_name => application[:first_name],
        :last_name => application[:last_name],
        :email => application[:email],
        :address => {
          :street_address => application[:street_address],
          :postal_code => application[:postal_code],
          :locality => application[:locality],
          :region => application[:region],
        },
        :date_of_birth => application[:date_of_birth],
        :routing_number => application[:routing_number],
        :account_number => application[:account_number],
      },
      :tos_accepted => application[:tos_accepted],
      :master_merchant_account_id => merchant_account_id,
    )

    BraintreePaymentAccount.create token: result.merchant_account.id, project: project
    redirect_to project
  end

  def save
  end

  def destroy
  end

  private
  def project
    @_project ||= Project.find_by_slug! params[:project_id]
  end

  def unauthorized
    redirect_to :root, alert: "You are not authorized to access that page."
  end

  def merchant_account_id
    Contribute::Application.config.braintree_merchant_account_id
  end
end
