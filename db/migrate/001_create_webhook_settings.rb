class CreateWebhookSettings < ActiveRecord::Migration
  def change
    create_table :webhook_settings do |t|
      t.integer :project_id
      t.string :url
      t.text :description
      t.boolean :post
    end

    # add_foreign_key :webhook_settings, :projects
  end
end
