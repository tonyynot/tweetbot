
require 'twitter'
require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db")

class StoredTweet
    include DataMapper::Resource
    property :id        , Serial
    property :tweet     , String
    property :created_at, DateTime
end

configure :development do
    # DataMapper.auto_upgrade!
    StoredTweet.auto_migrate! unless StoredTweet.storage_exists?
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "___"
  config.consumer_secret     = "___"
  config.access_token        = "___"
  config.access_token_secret = "___"
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: false, include_url: false}
    options[:max_id] = max_id unless max_id.nil?
    @timeline = user_timeline(user, options)
    @timeline.reject! { |item| item.text =~ /(http|#|@)/ }
  end
end

get '/' do

  newest_tweet = StoredTweet.last()

  if newest_tweet.nil? || newest_tweet.created_at < DateTime.now - ((1/24.0) / 4.0) #check created_at
    client.get_all_tweets('KanyeWest').each do |tweet|
      
      @tweet = StoredTweet.new
      @tweet.tweet = tweet.text
      @tweet.save

      puts 'API CALL'
    end
  end
    
    @display_tweet = StoredTweet.first(:offset => rand(StoredTweet.count)) #offset might break

  erb :index
  end
