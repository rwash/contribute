require 'spec_helper'

describe ApplicationHelper do
  it 'formats date correctly' do
    date = Date.new(2012, 04, 26)

    formatted = format_date(date)

    expect(formatted).to eq '04/26/2012'
  end
end
