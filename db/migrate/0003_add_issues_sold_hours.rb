class AddIssuesSoldHours < ActiveRecord::Migration
  def self.up
    add_column :issues, :sold_hours, :float
  end

  def self.down
    remove_column :issues, :sold_hours
  end
end
