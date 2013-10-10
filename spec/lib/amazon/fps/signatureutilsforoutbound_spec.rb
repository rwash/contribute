require "spec_helper"

describe Amazon::FPS::SignatureUtilsForOutbound do
  describe ".validate_request" do
    it "should send a signature verification request" do
      utils = Amazon::FPS::SignatureUtilsForOutbound.new

      Amazon::FPS::SignatureVerificationRequest.any_instance.should_receive(:validate)

      utils.validate_request({})
    end
  end
end
