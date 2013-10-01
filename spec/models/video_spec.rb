require 'spec_helper'

describe Video do
  # Abilities
  # create, save, activate, destroy, read, update, contribute
  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:video) { build:video }

    context 'when not signed in' do
      let(:user) { nil }

    end

    context 'when signed in' do
      let(:user) { create :user }

    end

    context 'when user owns project' do
      let(:user) { video.project.owner }

    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }

    end
  end

  # Validations
  it { should validate_presence_of :project }

  # Methods
  describe 'update' do
    it 'forwards request to yt_session' do
      video = build_stubbed :video
      Video.yt_session.should_receive(:video_update) do |video_id, attributes|
        video_id.should eq video.yt_video_id
        attributes[:title].should eq video.project.name
        attributes[:description].should include video.project.short_description
        attributes[:list].should eq 'denied'
      end
      video.update
    end
  end

  describe 'destroy' do
    it 'should delete youtube video' do
      video = build :video
      video.should_receive :delete_yt_video
      video.destroy
    end
  end
end

describe NullVideo do
  its(:nil?) { should be_true }
  its(:upload_video) { should be_nil }
  its(:update) { should be_nil }
  its(:delete_yt_video) { should be_nil }
  its(:destroy) { should be_nil }
  its(:complete?) { should be_false }
end
