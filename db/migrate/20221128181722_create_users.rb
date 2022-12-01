# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.text :description
      t.string :email, index: { unique: true }
      t.integer :status
      t.decimal :total_transaction_sum, precision: 8, scale: 2
      t.string :type

      t.timestamps
    end
  end
end
