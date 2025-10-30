class UpdateEmailUniquenessForSoftDelete < ActiveRecord::Migration[8.0]
  def up
    # Remove the old unique index on email
    remove_index :users, :email

    # Add a partial unique index that only applies to non-deleted users
    # This allows multiple soft-deleted users with the same email
    add_index :users, :email, unique: true, where: "deleted_at IS NULL", name: "index_users_on_email_active"
  end

  def down
    # Restore the original unique index
    remove_index :users, name: "index_users_on_email_active"
    add_index :users, :email, unique: true
  end
end
