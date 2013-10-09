require 'spec_helper'

describe Amazon::FPS::SignatureVerificationRequest do
  describe '.validate' do

    context 'with empty parameters' do
      it 'is invalid' do
        signature = Amazon::FPS::SignatureVerificationRequest.new({}, nil, nil)
        #signature.valid?.should be_false
        expect { signature.validate }.to raise_exception
      end
    end

  end
end
