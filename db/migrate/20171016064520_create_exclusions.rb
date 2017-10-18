class CreateExclusions < ActiveRecord::Migration[5.1]
  def change
    create_table :exclusions do |t|
      t.string :host, null: false
      t.datetime :excluded_since
      t.datetime :excluded_till

      t.timestamps
    end
  end
end
