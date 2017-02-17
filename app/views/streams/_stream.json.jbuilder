json.extract! stream, :id, :name, :url_type, :station_id, :created_at, :updated_at, :head_is_working, :listen_is_working, :use_web, :source_type
json.url stream_url(stream, format: :json)
