class ChangeTypeOfApprovalApproved < ActiveRecord::Migration
  def up
    add_column :approvals, :status, :string, null: false, default: 'pending'
    Approval.update_all({status: 'pending'}, {approved: nil})
    Approval.update_all({status: 'approved'}, {approved: true})
    Approval.update_all({status: 'rejected'}, {approved: false})
    remove_column :approvals, :approved
  end

  def down
    add_column :approvals, :approved, :boolean
    Approval.update_all({approved: nil}, {status: 'pending'})
    Approval.update_all({approved: true}, {status: 'approved'})
    Approval.update_all({approved: false}, {status: 'rejected'})
    remove_column :approvals, :status
  end
end
