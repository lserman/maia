# This migration comes from maia (originally 20150302191320)
class CreateMaiaDevices < ActiveRecord::Migration
  def change
    create_table :maia_devices do |t|
      t.references :pushable, polymorphic: true, index: true
      t.string :token
      t.string :platform
      t.datetime :token_expires_at

      t.timestamps null: false
    end
  end
end
