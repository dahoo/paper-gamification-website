json.extract! @paper, :title, :created_at, :updated_at, :history, :achieved
if @paper.stats.nil?
  json.stats []
else
  json.stats JSON.parse(@paper.stats)
end
