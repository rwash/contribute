require 'spec_helper'

describe UserAction do
  it 'can assign projects as an object' do
    action.object = project
    action.save.should be_true
    action.object.should eq project
  end

  it 'can assign contributions as an object' do
    action.object = contribution
    action.save.should be_true
    action.object.should eq contribution
  end

  private
  let(:action) { UserAction.new }
  let(:project) { create :project }
  let(:contribution) { create :contribution }
end
