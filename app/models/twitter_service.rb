module TwitterService
  class << self

    def config
      raise "No Twitter credentials" if !ENV['TWITTER_CONSUMER_KEY'] || !ENV['TWITTER_CONSUMER_SECRET'] || !ENV['TWITTER_ACCESS_TOKEN'] || !ENV['TWITTER_ACCESS_SECRET']
      Twitter.configure do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.oauth_token_secret = ENV['TWITTER_ACCESS_SECRET']
      end
    end

    def update(tweet)
      config
      Twitter.update(tweet)
    end

  end
end
