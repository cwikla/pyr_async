class CreateAsyncQueues < ActiveRecord::Migration
  def change
    create_table :async_queues do |t|
      t.timestamps
      t.timestamp :deleted_at
      t.timestamp :queued_at
      t.timestamp :started_at
      t.timestamp :completed_at
      t.timestamp :failed_at
      t.string :status
      t.string :clazz_name
      t.integer :obj_id
      t.string :method_name
      t.text :args
      t.text :message
    end

    add_index :async_queues, [:clazz_name, :obj_id, :status]
    add_index :async_queues, [:queued_at, :status]
    add_index :async_queues, [:started_at, :status]
    add_index :async_queues, [:completed_at, :status]
    add_index :async_queues, [:failed_at, :status]

  end
end
