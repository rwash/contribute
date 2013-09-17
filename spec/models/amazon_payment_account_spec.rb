require 'spec_helper'

describe AmazonPaymentAccount do
  it { should validate_presence_of :project }
  it { should validate_presence_of :token }
  it { should validate_uniqueness_of :project_id }
end
