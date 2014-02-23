require 'spec_helper'

describe ProjectState do
  # TODO change to build_stubbed
  let(:project) { create :project, state: project_state }

  context "is unconfirmed" do
    let(:project_state) { :unconfirmed }

    it 'responds appropriately' do
      expect(project.state).to eq 'unconfirmed'
      expect(project.state.unconfirmed?).to be_true
    end

    it 'can be edited' do
      expect(project.can_edit?).to be_true
    end

    it "can't be viewed by the public" do
      expect(project.public_can_view?).to be_false
    end

    it "can't be updated" do
      expect(project.can_update?).to be_false
    end

    it "can't be commented on" do
      expect(project.can_comment?).to be_false
    end
  end

  context "is inactive" do
    let(:project_state) { :inactive }

    it 'responds appropriately' do
      project.state = :inactive
      expect(project.state).to eq 'inactive'
      expect(project.state.inactive?).to be_true
    end

    it "can be edited" do
      expect(project.can_edit?).to be_true
    end

    it "can't be viewed by the public" do
      expect(project.public_can_view?).to be_false
    end

    it "can't be updated" do
      expect(project.can_update?).to be_false
    end

    it "can't be commented on" do
      expect(project.can_comment?).to be_false
    end
  end

  context "is active" do
    let(:project) { create :active_project }

    it 'responds appropriately' do
      project.state = :active
      expect(project.state).to eq 'active'
      expect(project.state.active?).to be_true
    end

    it "can't be edited" do
      expect(project.can_edit?).to be_false
    end

    it "can be viewed by the public" do
      expect(project.public_can_view?).to be_true
    end

    it "can be updated" do
      expect(project.can_update?).to be_true
    end

    it "can be commented on" do
      expect(project.can_comment?).to be_true
    end
  end

  context "is nonfunded" do
    let(:project_state) { :nonfunded }

    it 'responds appropriately' do
      project.state = :nonfunded
      expect(project.state).to eq 'nonfunded'
      expect(project.state.nonfunded?).to be_true
    end

    it "can't be edited" do
      expect(project.can_edit?).to be_false
    end

    it "can be viewed by the public" do
      expect(project.public_can_view?).to be_true
    end

    it "can be updated" do
      expect(project.can_update?).to be_true
    end

    it "can be commented on" do
      expect(project.can_comment?).to be_true
    end
  end

  context "is funded" do
    let(:project_state) { :funded }

    it 'responds appropriately' do
      project.state = :funded
      expect(project.state).to eq 'funded'
      expect(project.state.funded?).to be_true
    end

    it "can't be edited" do
      expect(project.can_edit?).to be_false
    end

    it "can be viewed by the public" do
      expect(project.public_can_view?).to be_true
    end

    it "can be updated" do
      expect(project.can_update?).to be_true
    end

    it "can be commented on" do
      expect(project.can_comment?).to be_true
    end
  end

  context "is cancelled" do
    let(:project_state) { :cancelled }

    it 'responds appropriately' do
      project.state = :cancelled
      expect(project.state).to eq 'cancelled'
      expect(project.state.cancelled?).to be_true
    end

    it "can't be edited" do
      expect(project.can_edit?).to be_false
    end

    it "can't be viewed by the public" do
      expect(project.public_can_view?).to be_false
    end

    it "can't be updated" do
      expect(project.can_update?).to be_false
    end

    it "can't be commented on" do
      expect(project.can_comment?).to be_false
    end
  end

  it 'guards against invalid values' do
    project = build :project, state: 'invalid_state'
    expect(project.valid?).to be_false
    expect(project.save).to be_false
  end

  it 'guards against nil value' do
    project = build :project, state: nil
    expect(project.valid?).to be_false
    expect(project.save).to be_false
  end

end

