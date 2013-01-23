require 'spec_helper'

describe Update do
  # Validations
  
  it { should validate_presence_of :title }
  it { should validate_presence_of :content }
  it { should validate_presence_of :user }
  it { should validate_presence_of :project }
end
