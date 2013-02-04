require 'spec_helper'

describe ApplicationHelper do
  it 'formats date correctly' do
    expect(format_date Date.new(2012, 04, 26)).to eq '04/26/2012'
  end
end
