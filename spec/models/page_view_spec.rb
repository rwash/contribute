require 'spec_helper'

describe PageView do
  it 'has a user attribute' do
    pv = PageView.new
    pv.user = user
    pv.save
    pv.user.should eq user
  end

  private
  def user
    @_user ||= create :user
  end
end
