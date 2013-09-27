class AmazonPaymentAccountsController < ApplicationController
  # TODO get rid of this
  skip_authorization_check

  # GET /amazon_payment_accounts/new
  # GET /amazon_payment_accounts/new.json
  def new
    session[:project_id] = params[:project_id]

    request = Amazon::FPS::RecipientRequest.new(save_project_url)
    redirect_to request.url
  end

  # POST /amazon_payment_accounts
  # POST /amazon_payment_accounts.json
  def create
    @amazon_payment_account = AmazonPaymentAccount.new(params[:amazon_payment_account])

    @amazon_payment_account.save
    redirect_to Project.find session[:project_id]
  rescue
    redirect_to :root, alert: "Something went wrong, and we couldn't save your changes. Please try again, or get in touch if the problem continues."
  end

  # DELETE /amazon_payment_accounts/1
  # DELETE /amazon_payment_accounts/1.json
  def destroy
    @amazon_payment_account = AmazonPaymentAccount.find(params[:id])
    @amazon_payment_account.destroy

    respond_to do |format|
      format.html { redirect_to @amazon_payment_account.project }
      format.json { head :no_content }
    end
  end
end
