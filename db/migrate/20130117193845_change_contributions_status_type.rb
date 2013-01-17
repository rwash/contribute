class ChangeContributionsStatusType < ActiveRecord::Migration
  def up
    change_column :contributions, :status, :string
    (1..7).each do |i|
      Contribution.update_all("status = '#{ContributionStatus.parameterize(i)}'", "status LIKE '#{i}'")
    end
  end

  def down
    (1..7).each do |i|
      Contribution.update_all("status = '#{i}'", "status LIKE '#{ContributionStatus.parameterize(i)}'")
    end
    change_column :contributions, :status, :integer
  end
end
