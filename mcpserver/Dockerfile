# syntax=docker/dockerfile:1
FROM ruby:3.4.5-slim

ENV APP_HOME=/app \
  RUNTIME_PACKAGES="build-essential git libpq-dev"

WORKDIR $APP_HOME

# Install packages
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends $RUNTIME_PACKAGES \
  && rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock* ./
RUN bundle config set without 'development test' \
  && bundle install --jobs 4 --retry 3

# App
# Copy mcpserver files
COPY mcpserver/ ./
# Copy Rails models into the image so MCP can reuse them
COPY app/models ./app/models

EXPOSE 5678
ENV PORT=5678 BIND=0.0.0.0
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "5678"]
