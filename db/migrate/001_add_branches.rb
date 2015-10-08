class AddBranches < ActiveRecord::Migration
  def self.up
    add_column :changesets, :branches, :text
  end
  
  def self.down
    remove_column :changesets, :branches
  end
end
