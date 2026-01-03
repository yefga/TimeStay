# Dockerfile for TimeStay Rails API
# ==================================
# This is a simplified Dockerfile for development and learning.
# It builds a Docker image that can run our Rails API.

# Use the official Ruby image as base
# Alpine is a small Linux distribution, keeping the image size down
FROM ruby:4.0-alpine

# Set working directory inside the container
WORKDIR /app

# Install essential build dependencies
# - build-base: Compilers and build tools needed for native gems
# - libc-dev: C library development files
# - tzdata: Timezone data (important for our timezone service!)
RUN apk add --no-cache \
    build-base \
    libc-dev \
    yaml-dev \
    tzdata

# Copy Gemfile first (for better caching)
# Docker caches layers - if Gemfile doesn't change, gems won't be reinstalled
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose port 3000 (Rails default)
EXPOSE 3000

# Start the Rails server
# -b 0.0.0.0: Bind to all interfaces (required for Docker)
# -p 3000: Use port 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
