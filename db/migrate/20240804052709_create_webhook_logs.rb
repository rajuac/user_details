class CreateWebhookLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :webhook_logs do |t|
      t.references :user, foreign_key: true
      t.string :event_type
      t.integer :retry_count, default: 0
      t.string :status
      t.timestamps
    end
  end
end
