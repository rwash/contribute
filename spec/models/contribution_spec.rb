require 'spec_helper'

describe Contribution do
	describe 'payment key' do
		it 'is required' do
			contribution = FactoryGirl.build(:contribution, :payment_key => '')
			assert !contribution.save, 'Incorrectly saved contribution without payment key'
		end
	end
end
