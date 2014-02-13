class RemoveNestingFromComments < ActiveRecord::Migration
  def up
    rename_column :comments, :commentable_id, :project_id
    remove_column :comments, :commentable_type
    remove_index :comments, name: "index_comments_on_commentable_id"
    add_index :comments, :project_id

    remove_column :comments, :lft
    remove_column :comments, :rgt
    remove_column :comments, :parent_id

    remove_column :comments, :title
    remove_column :comments, :subject
  end

  def down
    add_column :comments, :commentable_type, :string, default: 'Project'
    rename_column :comments, :project_id, :commentable_id
    add_index :comments, :commentable_id
    remove_index :comments, name: "index_comments_on_project_id"

    add_column :comments, :lft, :integer
    add_column :comments, :rgt, :integer
    add_column :comments, :parent_id, :integer

    add_column :comments, :title, :string
    add_column :comments, :subject, :string
  end
end
