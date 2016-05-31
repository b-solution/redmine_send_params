class AddIssueQueryToWebhookSetting < ActiveRecord::Migration
  def change
    add_column :webhook_settings, :issue_query_id, :integer
  end
end