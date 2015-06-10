class AddDatesAndGoalToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :start_date, :datetime
    add_column :papers, :end_date, :datetime
    add_column :papers, :goal_value, :integer
    add_column :papers, :goal_type, :string
  end
end
