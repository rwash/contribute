require 'spec_helper'

describe ProjectState do
  let(:project) { Factory :project, state: project_state }

  context "is unconfirmed" do
    let(:project_state) { 'unconfirmed' }

    it 'responds appropriately' do
      project.state.should eq 'unconfirmed'
      project.state.unconfirmed?.should be_true
      project.state.inactive?.should be_false
      project.state.active?.should be_false
      project.state.nonfunded?.should be_false
      project.state.funded?.should be_false
      project.state.cancelled?.should be_false
    end

    it 'can be edited' do
      project.can_edit?.should be_true
    end

    it "can't be viewed by the public" do
      project.public_can_view?.should be_false
    end

    it "can't be updated" do
      project.can_update?.should be_false
    end

    it "can't be commented on" do
      project.can_comment?.should be_false
    end
  end

  context "is inactive" do
    let(:project_state) { 'inactive' }

    it 'responds appropriately' do
      project.state = :inactive
      project.state.should eq 'inactive'
      project.state.unconfirmed?.should be_false
      project.state.inactive?.should be_true
      project.state.active?.should be_false
      project.state.nonfunded?.should be_false
      project.state.funded?.should be_false
      project.state.cancelled?.should be_false
    end

    it "can be edited" do
      project.can_edit?.should be_true
    end

    it "can't be viewed by the public" do
      project.public_can_view?.should be_false
    end

    it "can't be updated" do
      project.can_update?.should be_false
    end

    it "can't be commented on" do
      project.can_comment?.should be_false
    end
  end

  context "is active" do
    let(:project_state) { 'active' }

    it 'responds appropriately' do
      project.state = :active
      project.state.should eq 'active'
      project.state.unconfirmed?.should be_false
      project.state.inactive?.should be_false
      project.state.active?.should be_true
      project.state.nonfunded?.should be_false
      project.state.funded?.should be_false
      project.state.cancelled?.should be_false
    end

    it "can't be edited" do
      project.can_edit?.should be_false
    end

    it "can be viewed by the public" do
      project.public_can_view?.should be_true
    end

    it "can be updated" do
      project.can_update?.should be_true
    end

    it "can be commented on" do
      project.can_comment?.should be_true
    end
  end

  context "is nonfunded" do
    let(:project_state) { 'nonfunded' }

    it 'responds appropriately' do
      project.state = :nonfunded
      project.state.should eq 'nonfunded'
      project.state.unconfirmed?.should be_false
      project.state.inactive?.should be_false
      project.state.active?.should be_false
      project.state.nonfunded?.should be_true
      project.state.funded?.should be_false
      project.state.cancelled?.should be_false
    end

    it "can't be edited" do
      project.can_edit?.should be_false
    end

    it "can be viewed by the public" do
      project.public_can_view?.should be_true
    end

    it "can be updated" do
      project.can_update?.should be_true
    end

    it "can be commented on" do
      project.can_comment?.should be_true
    end
  end

  context "is funded" do
    let(:project_state) { 'funded' }

    it 'responds appropriately' do
      project.state = :funded
      project.state.should eq 'funded'
      project.state.unconfirmed?.should be_false
      project.state.inactive?.should be_false
      project.state.active?.should be_false
      project.state.nonfunded?.should be_false
      project.state.funded?.should be_true
      project.state.cancelled?.should be_false
    end

    it "can't be edited" do
      project.can_edit?.should be_false
    end

    it "can be viewed by the public" do
      project.public_can_view?.should be_true
    end

    it "can be updated" do
      project.can_update?.should be_true
    end

    it "can be commented on" do
      project.can_comment?.should be_true
    end
  end

  context "is cancelled" do
    let(:project_state) { 'cancelled' }

    it 'responds appropriately' do
      project.state = :cancelled
      project.state.should eq 'cancelled'
      project.state.unconfirmed?.should be_false
      project.state.inactive?.should be_false
      project.state.active?.should be_false
      project.state.nonfunded?.should be_false
      project.state.funded?.should be_false
      project.state.cancelled?.should be_true
    end

    it "can't be edited" do
      project.can_edit?.should be_false
    end

    it "can't be viewed by the public" do
      project.public_can_view?.should be_false
    end

    it "can't be updated" do
      project.can_update?.should be_false
    end

    it "can't be commented on" do
      project.can_comment?.should be_false
    end
  end

  it 'guards against invalid values' do
    project = Factory.build :project, state: 'invalid_state'
    project.valid?.should be_false
    project.save.should be_false
  end

  it 'guards against nil value' do
    project = Factory.build :project, state: nil
    project.valid?.should be_false
    project.save.should be_false
  end
end

