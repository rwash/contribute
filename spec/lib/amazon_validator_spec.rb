require "spec_helper"

describe Amazon::FPS::AmazonValidator do
  describe "valid_multi_token_response?" do
    it "should succeed with valid input" do
      valid = Amazon::FPS::AmazonValidator.valid_multi_token_response?(url, session, parameters)
      valid.should be_true
    end

    it "should fail without tokenID" do
      params = parameters.delete("tokenID")
      valid = Amazon::FPS::AmazonValidator.valid_multi_token_response?(url, session, params)
      valid.should be_false
    end

    it "should fail with invalid status" do
      params = parameters
      params["status"] = "NP"
      valid = Amazon::FPS::AmazonValidator.valid_multi_token_response?(url, session, params)
      valid.should be_false
    end

    it "should fail with an invalid signature" do
      params = parameters
      params["signature"] = "invalid signature"
      valid = Amazon::FPS::AmazonValidator.valid_multi_token_response?(url, session, params)
      valid.should be_false
    end

    def url
      'http://127.0.0.1:3999/contributions/save'
    end

    def session
      {}
    end

    def parameters
      {
        "signature"=>"oqf/HV3gxQpVi1nwDGdYaSzNO5XvikEypZi82M5/Z0mQaj5KNH7v6XB3XtNatXEZYdYiTbjCjZu2\n4X8W6BZ6mEvQXEgAsgr/q6vpm+kfdk1wFiV4Ho2lAkAzF93tBbLg12GIVQpETuQ8h6aTWUIy9Y01\n1P+fPYDznVrapsdmy8s=",
        "expiry"=>"10/2017",
        "signatureVersion"=>"2",
        "signatureMethod"=>"RSA-SHA1",
        "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0j",
        "tokenID"=>"I7TRIVD1A1ABBN6Z5JIP3MUP6XLCXADCIDER9MMKUM6DTJ4ZD2DUKDSEHBDFQNBH",
        "status"=>"SC",
        "callerReference"=>"c5b2c519-2b55-4fdd-83e1-2fff1238f51a",
        "controller"=>"contributions",
        "action"=>"save"
      }
    end
  end

  describe "valid_recipient_response? and get_transaction_status" do
    before :each do
      @url = 'http://127.0.0.1:3999/projects/save'
      @params = {"signature"=>"fOaFts6c+RA6ZsgSZd8/b80kIx9JaKOuKj/NJGqgyGrrVUG6ALi1p2U0DkmIQli+2cZcI40xD7vq\nePieOgGIk2CvJW5luYWLneJQXXkjvl14BU4fmE339nfuguUbROcCtdyzSYuyQ9T44iaNG0S6sjIk\n+5qfQdclXo4HZoOzFf8=",
                 "refundTokenID"=>"C5Q3D454UL4X183AGIEQ2ZXS7DGGCAB91AP6M5TQ48XFSQ8DJDZ8JD8RMQWUC8WV",
                 "signatureVersion"=>"2",
                 "signatureMethod"=>"RSA-SHA1",
                 "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0j",
                 "tokenID"=>"C3Q3N4K4UZ4918CAMIEU2FXS8D8GCBB91AB6L5TE4VXF4QTDJCZ4JDGRTQWSCGW6",
                 "status"=>"SR",
                 :project_id => 1,
                 "callerReference"=>"03e8637b-4979-46b3-9314-d178379a284f",
                 "controller"=>"amazon_payment_accounts",
                 "action"=>"create"}
    end

    it "succeeds with valid input" do
      recipient_response.should be_true
    end

    it "fails without a project" do
      @params["project_id"] = nil
      recipient_response.should be_false
    end

    it "should fail without a tokenID" do
      @params["tokenID"] = nil
      recipient_response.should be_false
    end

    it "should fail without a valid transaction status" do
      @params["status"] = "NP"
      recipient_response.should be_false
    end

    it "should fail with an invalid signature" do
      @params["signature"] = "invalid signature"
      recipient_response.should be_false
    end

    private
    def recipient_response
      Amazon::FPS::AmazonValidator.valid_recipient_response?(@url, @session, @params)
    end
  end

  describe "get_error" do
    it "returns the correct error on valid input" do
      response = {"Errors"=>{"Error"=>{"Code"=>"TokenNotActive_Sender", "Message"=>"Sender token not active."}}, "RequestID"=>"0eb3bc4f-63dc-4d11-9f48-c34cd921f164"}

      pending "spec relies on a 'TokenNotActive_Sender' AmazonError to be present in the DB"
      expected = AmazonError.find_by_error("TokenNotActive_Sender")
      expected.should_not be_nil

      errors(response).should eq expected
    end

    it "returns an unknown error on given input" do
      response = {"Errors"=>{"Error"=>{"Code"=>"TokenNotActive_Sender", "Message"=>"Sender token not active."}}, "RequestID"=>"0eb3bc4f-63dc-4d11-9f48-c34cd921f164"}

      expected = AmazonError.unknown_error("New_Error")
      expected.should_not be_nil

      response["Errors"]["Error"]["Code"] = "New_Error"
      errors(response).should eq expected
    end

    it "should raise exception if errors is nill" do
      response = { "unexpected" => "I don't do what you expect" }

      expect(lambda { Amazon::FPS::AmazonValidator.get_error(response) }).to raise_error
    end

    private
    def errors(response)
      Amazon::FPS::AmazonValidator.get_error(response)
    end
  end
end
