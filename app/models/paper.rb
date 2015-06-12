class Paper < ActiveRecord::Base
  has_many :applause

  has_paper_trail skip: [:created_at, :updated_at]

  def history
    return [] unless stats
    history = [start]
    history += versions.reject { |v| v.reify.nil? || v.reify.stats.nil? }.map do |version|
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

  def get_non_nil_values_with_date(key)
    versions.reject do|v|
      v.reify.nil? ||
      v.reify.stats.nil? ||
      JSON.parse(v.reify.stats)[key].nil?
    end.each_with_object({}) do |v, o|
      o[v.created_at.to_f] = stats_as_json(v.reify.stats)[key].to_f
    end.tap do |h|
      h[updated_at.to_f] = stats_as_json[key]
    end
  end

  def achieved
    %w(num_words pages).each_with_object({}) do |key, o|
      inter = Interpolate::Points.new get_non_nil_values_with_date(key)
      result = {
        hour: stats_as_json[key] - inter.at(1.hour.ago.to_f),
        day: stats_as_json[key] - inter.at(1.day.ago.to_f),
        week: stats_as_json[key] - inter.at(1.week.ago.to_f)
      }
      o[key] = result
    end
  end

  def stats_as_json(the_stats = nil)
    the_stats ||= stats
    JSON.parse the_stats
  end
end
