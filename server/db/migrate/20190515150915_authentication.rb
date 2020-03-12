# frozen_string_literal: true

class Authentication < ActiveRecord::Migration[5.2]

  def change

    create_table :accounts do |t|
      t.references :email, type: :citext, index: true, foreign_key: {to_table: :users, primary_key: :email}, null: false
      t.string :password_hash, null: false
      t.string :jit, null: true, limit: 24
    end

  end

end
