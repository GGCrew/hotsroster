json.array!(@heros) do |hero|
  json.extract! hero, :id
  json.url hero_url(hero, format: :json)
end
