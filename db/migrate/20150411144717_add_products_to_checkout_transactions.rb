class AddProductsToCheckoutTransactions < ActiveRecord::Migration
  def change
    create_table :checkout_products do |t|
      t.string :name
      t.string :category
      t.boolean :active, :default => true
      
      t.decimal :price, :scale => 2, :precision => 6

      t.attachment :image
      t.timestamps
    end
    
    remove_column :advertisements, :visible, :boolean
    
    add_column :checkout_transactions, :items, :string
  end
end