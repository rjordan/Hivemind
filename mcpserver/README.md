# Hivemind MCP Server (Ruby)

Sinatra app with Fast MCP mounted as Rack middleware. Exposes MCP over HTTP/SSE and a `/health` endpoint.

## Run locally
1. Install gems
   - `bundle install`
2. Configure env (optional)
   - DB via URL: `HIVEMIND_DB_URL=postgres://postgres:password@localhost:5432/hivemind_dev`
   - or pair:
     - `HIVEMIND_DB_HOST=localhost`
     - `HIVEMIND_DB_DATABASE=hivemind_dev`
     - `HIVEMIND_DB_USER=postgres`
     - `HIVEMIND_DB_PASSWORD=password`
3. Start
   - `bundle exec ruby app.rb -o 0.0.0.0 -p 5678`

## Endpoints
- Health: `GET /health`
- MCP SSE: `GET /mcp/sse`
- MCP Messages: `POST /mcp/messages`

## Tests
- `bundle exec rspec`
