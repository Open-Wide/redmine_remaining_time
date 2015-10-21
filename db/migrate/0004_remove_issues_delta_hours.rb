class RemoveIssuesDeltaHours < ActiveRecord::Migration
  def self.up
    remove_column :issues, :delta_hours
  end

  def self.down
    add_column :issues, :delta_hours, :float
  end
end
