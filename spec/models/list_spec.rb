require 'spec_helper'

describe List do
  # Validations
  it { should validate_presence_of :listable_id }
  it { should validate_presence_of :listable_type }

  it { should ensure_inclusion_of(:kind).in_array %w[default
                                             manual
                                             created_at_descending
                                             created_at_ascending
                                             end_date_descending
                                             end_date_ascending
                                             funding_goal_descending
                                             funding_goal_ascending
                                             amount_left_to_goal_in_dollars_descending
                                             amount_left_to_goal_in_dollars_ascending
                                             amount_left_to_goal_as_percent_descending
                                             amount_left_to_goal_as_percent_ascending
                                             amount_donated_in_dollars_descending
                                             amount_donated_in_dollars_ascending
                                             amount_donated_as_percent_of_goal_descending
                                             amount_donated_as_percent_of_goal_ascending
                                             random_descending
                                             random_ascending] }
end
