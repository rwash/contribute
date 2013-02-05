require 'spec_helper'

describe List do

  # Validations
  it { should validate_presence_of :listable_id }
  it { should validate_presence_of :listable_type }
end
