require 'spec_helper'

describe Amazon::FPS::OutboundSignatureV2 do
  describe '.validate' do

    context 'with empty parameters' do
      it 'is invalid' do
        signature = Amazon::FPS::OutboundSignatureV2.new({}, nil, nil)
        #signature.valid?.should be_false
        expect { signature.validate }.to raise_exception
      end
    end

  end
end
