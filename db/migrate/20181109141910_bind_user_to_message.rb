class BindUserToMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :user, foreign_key: true
    remove_column :messages, :author, :string
  end
end
