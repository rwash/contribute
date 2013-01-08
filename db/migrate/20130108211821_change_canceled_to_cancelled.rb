class ChangeCanceledToCancelled < ActiveRecord::Migration
  def up
    # From now on, 'cancelled' in the database will be spelled with two 'l's
    Project.update_all( "state = 'cancelled'", "state = 'canceled'" )
  end

  def down
    # Previously, it was only spelled with one
    Project.update_all( "state = 'canceled'", "state = 'cancelled'" )
  end
end
