require 'spec_helper'
require 'amazon/response'

describe Amazon::Response do
  describe '#new' do
    it 'accepts a list of parameters' do
      expect {
        Amazon::Response.new params
      }.to_not raise_error
    end

    private
    def params
      {first: 1, second: 2}
    end
  end

  describe '#valid?' do
    it 'returns true for a valid response' do
      response = Amazon::Response.new valid_response_params
      response.valid?.should be_true
    end

    private
    def valid_response_params
      {}
    end
  end
end
