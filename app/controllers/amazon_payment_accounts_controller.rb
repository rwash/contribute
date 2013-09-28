class AmazonPaymentAccountsController < ApplicationController
  # TODO get rid of this
  skip_authorization_check

  def new
    amazon_service = Amazon::FPS::RecipientRequest.new return_url
    redirect_to amazon_service.url
  end

  def create
    @amazon_payment_account = AmazonPaymentAccount.new
    @amazon_payment_account.token = params["tokenID"]
    @amazon_payment_account.project = project

    if valid_response? && @amazon_payment_account.save
      project.state = :inactive
      project.save

      redirect_to project, notice: "Project saved successfully"
    else
      return redirect_to project, alert: error_message
    end
  end

  def save
    Amazon::FPS::AmazonLogger::log_recipient_token_response(params)
    authorize! :save, project
  end

  def destroy
    @amazon_payment_account = AmazonPaymentAccount.find(params[:id])
    @amazon_payment_account.destroy

    redirect_to @amazon_payment_account.project
  end

  private
  def project
    @_project ||= Project.find_by_slug! params[:project_id]
  end

  def error_message
    "Something went wrong, and we couldn't save your changes."
  end

  def valid_response?
    Amazon::FPS::AmazonValidator::valid_recipient_response?(
      return_url,
      session,
      params)
  end

  def return_url
    project_amazon_payment_accounts_url(project)
  end
end
