class SetDefaultContributionValues < ActiveRecord::Migration
  def up
    change_column_default :contributions, :retry_count, 0
  end

  def down
    change_column_default :contributions, :retry_count, nil
  end
end
