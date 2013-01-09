class AddReasonToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :reason, :string
  end
end
