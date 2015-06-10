json.extract! @paper, :title, :created_at, :updated_at, :history
json.stats JSON.parse(@paper.stats)
