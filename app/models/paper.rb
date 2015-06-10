class Paper < ActiveRecord::Base
  has_many :applause

  has_paper_trail skip: [:created_at, :updated_at]

  def history
    return [] unless stats
    versions.reject {|v| v.reify.nil? || v.reify.stats.nil? }.map do |version|
      {
        time: version.created_at,
        words: JSON.parse(version.reify.stats)['num_words'],
        pages: JSON.parse(version.reify.stats)['pages']
      }
    end +
      [{
        time: updated_at,
        words: JSON.parse(stats)['num_words'],
        pages: JSON.parse(stats)['pages']
      }]
  end
end
