class AmazonPaymentAccountsController < ApplicationController
  # TODO get rid of this
  skip_authorization_check

  def new
    session[:project_id] = params[:project_id]

    request = Amazon::FPS::RecipientRequest.new(save_project_url)
    redirect_to request.url
  end

  def create
    @amazon_payment_account = AmazonPaymentAccount.new(params[:amazon_payment_account])
    project = Project.find_by_slug! params[:project_id]

    @amazon_payment_account.project = project

    error_message = "Something went wrong, and we couldn't save your changes."

    url = project_amazon_payment_accounts_url(project, method: :post)
    unless Amazon::FPS::AmazonValidator::valid_recipient_response?(url, session, params[:amazon_payment_account])
      return redirect_to project, alert: error_message
    end
    if @amazon_payment_account.save
      project.state = :inactive
      project.save

      redirect_to project, notice: "Project saved successfully"
    else
      redirect_to project, alert: error_message
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
end
