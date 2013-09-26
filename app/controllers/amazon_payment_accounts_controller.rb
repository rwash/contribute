class AmazonPaymentAccountsController < ApplicationController
  # TODO get rid of this
  skip_authorization_check

  # GET /amazon_payment_accounts
  # GET /amazon_payment_accounts.json
  def index
    @amazon_payment_accounts = AmazonPaymentAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @amazon_payment_accounts }
    end
  end

  # GET /amazon_payment_accounts/1
  # GET /amazon_payment_accounts/1.json
  def show
    @amazon_payment_account = AmazonPaymentAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @amazon_payment_account }
    end
  end

  # GET /amazon_payment_accounts/new
  # GET /amazon_payment_accounts/new.json
  def new
    @amazon_payment_account = AmazonPaymentAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @amazon_payment_account }
    end
  end

  # GET /amazon_payment_accounts/1/edit
  def edit
    @amazon_payment_account = AmazonPaymentAccount.find(params[:id])
  end

  # POST /amazon_payment_accounts
  # POST /amazon_payment_accounts.json
  def create
    @amazon_payment_account = AmazonPaymentAccount.new(params[:amazon_payment_account])

    respond_to do |format|
      if @amazon_payment_account.save
        format.html { redirect_to @amazon_payment_account, notice: 'Amazon payment account was successfully created.' }
        format.json { render json: @amazon_payment_account, status: :created, location: @amazon_payment_account }
      else
        format.html { render action: "new" }
        format.json { render json: @amazon_payment_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /amazon_payment_accounts/1
  # PUT /amazon_payment_accounts/1.json
  def update
    @amazon_payment_account = AmazonPaymentAccount.find(params[:id])

    respond_to do |format|
      if @amazon_payment_account.update_attributes(params[:amazon_payment_account])
        format.html { redirect_to @amazon_payment_account, notice: 'Amazon payment account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @amazon_payment_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /amazon_payment_accounts/1
  # DELETE /amazon_payment_accounts/1.json
  def destroy
    @amazon_payment_account = AmazonPaymentAccount.find(params[:id])
    @amazon_payment_account.destroy

    respond_to do |format|
      format.html { redirect_to amazon_payment_accounts_url }
      format.json { head :no_content }
    end
  end
end
