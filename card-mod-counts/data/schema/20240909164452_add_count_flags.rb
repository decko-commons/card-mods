# -*- encoding : utf-8 -*-

class AddCountFlags < Cardio::Migration::Schema
  def up
    rename_table :counts, :card_counts
    add_column :card_counts, :flag, :boolean, default: false
  end
end
