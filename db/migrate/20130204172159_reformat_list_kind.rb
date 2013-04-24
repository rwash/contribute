class ReformatListKind < ActiveRecord::Migration
  class List < ActiveRecord::Base
  end

  def up
    List.all.each do |list|
      list.kind = list.kind.to_s.gsub('-','_')
      list.save
    end
  end

  def down
    List.all.each do |list|
      list.kind = list.kind.to_s.gsub('_','-')
      list.save
    end
  end
end
