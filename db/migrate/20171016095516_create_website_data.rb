class CreateWebsiteData < ActiveRecord::Migration[5.1]
  def change
    create_table :website_data do |t|
      t.datetime :date, null: false
      t.string :host, null: false
      t.integer :count, null: false

      t.timestamps
    end

    add_index(:website_data, [:date, :host], unique: true)
  end
end
