require 'spec_helper'

describe Amazon::FPS::OutboundSignatureV1 do
  describe '.validate' do
    context 'with a signature keyname' do
      it 'does not raise exception' do
        signature = Amazon::FPS::OutboundSignatureV1.new({parameters: {"signature" => "foo"}})
        expect {signature.send(:signature)}.to_not raise_exception "Signature is missing from parameters"
      end
    end

    context 'without a signature keyname' do
      it 'raises exception' do
        signature = Amazon::FPS::OutboundSignatureV1.new({parameters: {}})
        expect {signature.validate}.to raise_exception
      end
    end
  end
end
