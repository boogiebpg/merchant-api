# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.uuid :uuid, null: false
      t.decimal :amount, precision: 8, scale: 2
      t.integer :status
      t.string :customer_email
      t.string :customer_phone
      t.string :type
      t.references :user

      t.timestamps
    end
  end
end
