FROM ruby:3.2

# Install system packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl

# Set the working directory in the container
WORKDIR /app

# Copy only the Gemfile first, then install gems (layer cache)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Now copy the entire app
COPY . .

CMD ["ruby", "bin/bitcoin_ruby_cli.rb"]
