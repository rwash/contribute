require 'spec_helper'

describe User do
  # Validations
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
  it { should_not allow_value('invalid_email').for :email }
  it { should allow_value('valid@example.com').for :email }
end
