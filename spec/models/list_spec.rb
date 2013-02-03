require 'spec_helper'

describe List do
  # Validations
  it { should validate_presence_of :listable_id }
  it { should validate_presence_of :listable_type }

  it { should ensure_inclusion_of(:kind).in_array %w[default
                                             manual
                                             created-at-descending
                                             created-at-ascending
                                             end-date-descending
                                             end-date-ascending
                                             funding-goal-descending
                                             funding-goal-ascending
                                             amount-left-to-goal-in-dollars-descending
                                             amount-left-to-goal-in-dollars-ascending
                                             amount-left-to-goal-as-percent-descending
                                             amount-left-to-goal-as-percent-ascending
                                             amount-donated-in-dollars-descending
                                             amount-donated-in-dollars-ascending
                                             amount-donated-as-percent-of-goal-descending
                                             amount-donated-as-percent-of-goal-ascending
                                             random-descending
                                             random-ascending] }
end
