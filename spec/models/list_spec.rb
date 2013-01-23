require 'spec_helper'

describe List do

  describe 'listable' do
    it 'listable id is required' do
      list = FactoryGirl.build(:list, :listable_id => '')
      expect(list.save).to be_false
    end

    it 'listable type is required' do
      list = FactoryGirl.build(:list, :listable_type => '')
      expect(list.save).to be_false
    end
  end
end
