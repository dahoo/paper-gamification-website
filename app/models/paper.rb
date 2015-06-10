class Paper < ActiveRecord::Base
  has_many :applause

  has_paper_trail skip: [:created_at, :updated_at]

  def history
    return [] unless stats
    history = [start]
    history += versions.reject {|v| v.reify.stats.nil? }.map do |version|
      {
        time: version.created_at,
        words: JSON.parse(version.reify.stats)['num_words'],
        pages: JSON.parse(version.reify.stats)['pages']
      }
    end
    history.append current
    history.append goal
  end

  def start
    {
      time: start_date,
      words: 0,
      pages: 0
    }
  end

  def current
    {
      time: updated_at,
      words: JSON.parse(stats)['num_words'],
      pages: JSON.parse(stats)['pages']
    }
  end

  def goal
    goal = {
      time: end_date,
      words: nil,
      pages: nil
    }
    if end_date && goal_value && %w(pages words).include?(goal_type)
      goal[goal_type.to_sym] = goal_value
    end
    goal
  end
end
