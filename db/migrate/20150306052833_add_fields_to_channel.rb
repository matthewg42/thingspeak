class AddFieldsToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :field9, :string
    add_column :channels, :field10, :string
    add_column :channels, :field11, :string
    add_column :channels, :field12, :string
    add_column :channels, :field13, :string
    add_column :channels, :field14, :string
    add_column :channels, :field15, :string
    add_column :channels, :field16, :string
    add_column :feeds, :field9, :string
    add_column :feeds, :field10, :string
    add_column :feeds, :field11, :string
    add_column :feeds, :field12, :string
    add_column :feeds, :field13, :string
    add_column :feeds, :field14, :string
    add_column :feeds, :field15, :string
    add_column :feeds, :field16, :string
  end
end
