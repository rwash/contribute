require "spec_helper"

describe Amazon::FPS::SignatureUtilsForOutbound do
  describe ".validate_request" do
    context "with version 1 signature" do
      it "should use v1 validator" do
        utils = Amazon::FPS::SignatureUtilsForOutbound.new('access_key', 'secret_key')

        Amazon::FPS::OutboundSignatureV1.any_instance.should_receive(:validate)

        utils.validate_request({parameters: {'signatureVersion' => '1'}})
      end
    end

    context "with version 2 signature" do
      it "should use v2 validator" do
        utils = Amazon::FPS::SignatureUtilsForOutbound.new('access_key', 'secret_key')

        Amazon::FPS::OutboundSignatureV2.any_instance.should_receive(:validate)

        utils.validate_request({parameters: {'signatureVersion' => '2'}})
      end
    end
  end
end
