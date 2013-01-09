require 'spec_helper'

describe List do

  describe 'listable' do
    it 'listable id is required' do
      list = FactoryGirl.build(:list, :listable_id => '')
      assert !list.save, 'Incorrectly saved list without listable id'
    end

    it 'listable type is required' do
      list = FactoryGirl.build(:list, :listable_type => '')
      assert !list.save, 'Incorrectly saved list without listable type'
    end
  end
end
