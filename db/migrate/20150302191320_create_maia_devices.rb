class CreateMaiaDevices < ActiveRecord::Migration
  def change
    create_table :maia_devices do |t|
      t.references :pushable, polymorphic: true, index: true
      t.string :token
      t.datetime :token_expires_at

      t.timestamps null: false
    end
  end
end
