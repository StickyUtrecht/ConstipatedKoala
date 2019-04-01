#:nodoc:
class CreateAdvertisements < ActiveRecord::Migration[4.2]
  def change
    create_table :advertisements do |t|
      t.string :name
      t.boolean :visible
      t.timestamps
    end
  end
end
