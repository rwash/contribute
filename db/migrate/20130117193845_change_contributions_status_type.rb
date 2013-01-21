class ChangeContributionsStatusType < ActiveRecord::Migration

  @@status_names = ['none', 'success', 'pending', 'failure', 'cancelled', 'retry_pay', 'retry_cancel']

  def up
    change_column :contributions, :status, :string, default: 'none'
    (1..7).each do |i|
      Contribution.update_all("status = '#{@@status_names[i]}'", "status LIKE '#{i}'")
    end
  end

  def down
    (1..7).each do |i|
      Contribution.update_all("status = '#{i}'", "status LIKE '#{@@status_names[i]}'")
    end
    change_column :contributions, :status, :integer
  end
end
