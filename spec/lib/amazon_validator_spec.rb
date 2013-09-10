require "spec_helper"
require "lib_helper"

describe Amazon::FPS::AmazonValidator do
#Begin Properties
  describe "valid_multi_token_response?" do
    before :each do
      @url = 'http://127.0.0.1:3999/contributions/save'
      @session = {}
      @params = {"signature"=>"oqf/HV3gxQpVi1nwDGdYaSzNO5XvikEypZi82M5/Z0mQaj5KNH7v6XB3XtNatXEZYdYiTbjCjZu2\n4X8W6BZ6mEvQXEgAsgr/q6vpm+kfdk1wFiV4Ho2lAkAzF93tBbLg12GIVQpETuQ8h6aTWUIy9Y01\n1P+fPYDznVrapsdmy8s=", "expiry"=>"10/2017", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0j", "tokenID"=>"I7TRIVD1A1ABBN6Z5JIP3MUP6XLCXADCIDER9MMKUM6DTJ4ZD2DUKDSEHBDFQNBH", "status"=>"SC", "callerReference"=>"c5b2c519-2b55-4fdd-83e1-2fff1238f51a", "controller"=>"contributions", "action"=>"save"}
    end

    it "should succeed with valid input" do
      pending 'getting an SSLError from Amazon.'
      run_valid_multi_token_test(true)
    end

    it "should fail without tokenID" do
      @params.delete("tokenID")
      run_valid_multi_token_test(false)
    end

    it "should fail with invalid status" do
      @params["status"] = "NP"
      run_valid_multi_token_test(false)
    end

    it "should fail with an invalid signature" do
      pending 'getting an SSLError from Amazon.'
      @params["signature"] = "invalid signature"
      run_valid_multi_token_test(false)
    end
  end

  describe "valid_recipient_response? and get_transaction_status" do
    before :each do
      @url = 'http://127.0.0.1:3999/projects/save'
      @session = {}
      @session["project_id"] = 1
      @params = {"signature"=>"fOaFts6c+RA6ZsgSZd8/b80kIx9JaKOuKj/NJGqgyGrrVUG6ALi1p2U0DkmIQli+2cZcI40xD7vq\nePieOgGIk2CvJW5luYWLneJQXXkjvl14BU4fmE339nfuguUbROcCtdyzSYuyQ9T44iaNG0S6sjIk\n+5qfQdclXo4HZoOzFf8=", "refundTokenID"=>"C5Q3D454UL4X183AGIEQ2ZXS7DGGCAB91AP6M5TQ48XFSQ8DJDZ8JD8RMQWUC8WV", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0j", "tokenID"=>"C3Q3N4K4UZ4918CAMIEU2FXS8D8GCBB91AB6L5TE4VXF4QTDJCZ4JDGRTQWSCGW6", "status"=>"SR", "callerReference"=>"03e8637b-4979-46b3-9314-d178379a284f", "controller"=>"projects", "action"=>"save"}
    end

    it "should succeed with valid input" do
      pending 'getting an SSLError from Amazon.'
      run_valid_recipient_test(true)
    end

    it "should failed without a project" do
      pending 'getting an SSLError from Amazon.'
      @params["project_id"] = nil
      run_valid_recipient_test(false)
    end

    it "should fail without a tokenID" do
      @params["tokenID"] = nil
      run_valid_recipient_test(false)
    end

    it "should fail without a valid transaction status" do
      @params["status"] = "NP"
      run_valid_recipient_test(false)
    end

    it "should fail with an invalid signature" do
      pending 'getting an SSLError from Amazon.'
      @params["signature"] = "invalid signature"
      run_valid_recipient_test(false)
    end
  end

  describe "valid_transaction status_response?" do
    before :each do
      @response = {"GetTransactionStatusResult"=>{"TransactionId"=>"16RH6PUK26RN2K2UK3TG5R84R4U5H231PAV", "TransactionStatus"=>"Success", "CallerReference"=>"d312d0d5-c034-4f6a-81bf-11d30c149e83", "StatusCode"=>"Success", "StatusMessage"=>"The transaction was successful and the payment instrument was charged."}, "ResponseMetadata"=>{"RequestId"=>"bbe69f8c-b55f-4ab9-9c08-f830b1b23181:0"}}
    end

    it "should succeed with a valid repsonse" do
      run_valid_transaction_status_test(true)
    end

    it  "should fail with an error" do
      @response["Errors"] = "omg I'm an error"
      run_valid_transaction_status_test(false)
    end

    it "should fail when amazon changes their schema, case 1" do
      @response["newSchema"] = @response["GetTransactionStatusResult"]
      @response.delete("GetTransactionStatusResult")

      run_valid_transaction_status_test(false)
    end

    it "should fail when amazon changes their schema case 2" do
      @response["GetTransactionStatusResult"]["newSchema"] = @response["GetTransactionStatusResult"]["TransactionStatus"]
      @response["GetTransactionStatusResult"].delete("TransactionStatus")

      run_valid_transaction_status_test(false)
    end

    it "should succeed with valid parameters (for get_transaction_status)" do
      expect(Amazon::FPS::AmazonValidator.get_transaction_status(@response)).to eq :success
    end
  end

  describe "get_cancel_status" do
    before :each do
      @response = {"ResponseMetadata"=>{"RequestId"=>"7f51e809-190b-45a9-95fe-4a2c7bd2e319:0"}}
    end

    it "should succeed with valid parameters" do
      run_valid_cancel_status_test(:success)
    end

    it "should fail with an error" do
      @response["Errors"] = "omg an error"
      run_valid_cancel_status_test(:failure)
    end
  end

  describe "get_pay_status" do
    before :each do
      @failed_response = {"Errors"=>{"Error"=>{"Code"=>"TokenNotActive_Sender", "Message"=>"Sender token not active."}}, "RequestID"=>"0eb3bc4f-63dc-4d11-9f48-c34cd921f164"}
      @successful_response = {"PayResult"=>{"TransactionId"=>"16RHAKMLO3MUTK8Q5PFG3FLFN5UULKVZ2H1", "TransactionStatus"=>"Pending"}, "ResponseMetadata"=>{"RequestId"=>"7e14f1f0-c2f9-4c56-8316-6b06cea3973a:0"}}
    end

    it "should succeed on valid input" do
      run_get_pay_status_test(@successful_response, :pending)
    end

    it "should fail on invalid input" do
      run_get_pay_status_test(@failed_response, :failure)
    end
  end

  describe "get_error" do
    it "should return the correct error on valid input" do
      @response = {"Errors"=>{"Error"=>{"Code"=>"TokenNotActive_Sender", "Message"=>"Sender token not active."}}, "RequestID"=>"0eb3bc4f-63dc-4d11-9f48-c34cd921f164"}

      pending "spec relies on a 'TokenNotActive_Sender' AmazonError to be present in the DB"
      expected = AmazonError.find_by_error("TokenNotActive_Sender")
      expect(expected).to_not be_nil

      run_get_error_test(expected)
    end

    it "should return an unknown error on given input" do
      @response = {"Errors"=>{"Error"=>{"Code"=>"TokenNotActive_Sender", "Message"=>"Sender token not active."}}, "RequestID"=>"0eb3bc4f-63dc-4d11-9f48-c34cd921f164"}

      expected = AmazonError.unknown_error("New_Error")
      expect(expected).to_not be_nil

      @response["Errors"]["Error"]["Code"] = "New_Error"
      run_get_error_test(expected)
    end

    it "should raise exception if errors is nill" do
      response = { "unexpected" => "I don't do what you expect" }

      expect(lambda { Amazon::FPS::AmazonValidator.get_error(response) }).to raise_error
    end
  end

end
