require 'sinatra'
require 'twitter'

helpers do
  def twitter
    @twitter ||= Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV.fetch("TWITTER_CONSUMER_KEY")
      config.consumer_secret = ENV.fetch("TWITTER_CONSUMER_SECRET")
    end
  end
end

get "/tweets.css" do
  content_type "text/css"
  tweets = twitter.search(ENV.fetch("TWITTER_SEARCH_STRING"))
  tweets.take(15).map.with_index do |tweet, i|
    <<-CSS
      #tweet-#{i + 1} .copy:before {
        content: "#{tweet.text}";
      }
      #tweet-#{i + 1} .name:before {
        content: "#{tweet.user.name}";
      }
      #tweet-#{i + 1} .handle:after {
        content: "#{tweet.user.screen_name}";
      }
      #tweet-#{i + 1} .avatar {
        content: "#{tweet.user.profile_image_url}";
      }
    CSS
  end
end
