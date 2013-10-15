require 'spec_helper'

describe UserAction do
  it 'can assign projects as a subject' do
    action.subject = project
    action.save.should be_true
    action.subject.should eq project
  end

  it 'can assign contributions as a subject' do
    action.subject = contribution
    action.save.should be_true
    action.subject.should eq contribution
  end

  private
  let(:action) { UserAction.new }
  let(:project) { create :project }
  let(:contribution) { create :contribution }
end
