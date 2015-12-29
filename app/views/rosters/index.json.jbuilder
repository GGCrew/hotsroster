json.array!(@rosters) do |roster|
  json.extract! roster, :id
  json.url roster_url(roster, format: :json)
end
