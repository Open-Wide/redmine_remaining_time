class AddIssuesDeltaHours < ActiveRecord::Migration
  def self.up
    add_column :issues, :delta_hours, :float
  end

  def self.down
    remove_column :issues, :delta_hours
  end
end
