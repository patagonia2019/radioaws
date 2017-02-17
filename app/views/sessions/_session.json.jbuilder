json.extract! session, :id, :api_key, :session_id, :token_id, :beacon_id, :created_at, :updated_at
json.url session_url(session, format: :json)
