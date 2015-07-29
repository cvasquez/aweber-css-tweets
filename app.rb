require 'sinatra'
require 'twitter'
require 'date'

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
  d = DateTime.parse("#{tweet.created_at}")
  tweetext = Rack::Utils.escape_html("#{tweet.text}")
    <<-CSS
      #tweet-#{i + 1} .copy:before {
        content: "#{tweetext}";
      }
      #tweet-#{i + 1} .name:before {
        content: "#{tweet.user.name}";
      }
      #tweet-#{i + 1} .handle:after {
        content: "#{tweet.user.screen_name}";
      }
      #tweet-#{i + 1} .avatar {
        background: url("#{tweet.user.profile_image_url}");
      }
      #tweet-#{i + 1} .timestamp:after {
        content: "#{d.strftime('%m/%d')}";
      }
    CSS
  end
end
