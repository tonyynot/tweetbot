
require 'twitter'
require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"

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
  config.consumer_key        = "rI1Zmi5vARGQU23a65EDy2x4S"
  config.consumer_secret     = "7pK6YSWXukDPLNYjw2hxsLd4Ir4BR310aLRI0vKJPSqQZtqDK5"
  config.access_token        = "2927794471-CoI0DBDuFzIRLlVk5eZZsdtSB1ZiHKVmh9au1S7"
  config.access_token_secret = "xnvCskYrDCfuwiRdDRQcunfsUHCv1c81fPjkhoD9vObLY"
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: false, include_url: false}
    options[:max_id] = max_id unless max_id.nil?
    @timeline = user_timeline(user, options)
    @timeline.reject! { |item| item.text =~ /http/ }
  end
end

get '/' do

  newest_tweet = StoredTweet.last()

  if newest_tweet.nil? || newest_tweet.created_at < DateTime.now - ((1/24.0) / 4.0) #check created_at
    client.get_all_tweets('realDonaldTrump').each do |tweet|
    #   # existing twitter filter code
      
      @tweet = StoredTweet.new
      @tweet.tweet = tweet.text
      # @tweet.tweet = "Test Tweet"
      @tweet.save

      puts 'API CALL'
    end
  end
    
    @display_tweet = StoredTweet.first(:offset => rand(StoredTweet.count)) #offset might break

    # # client.get_all_tweets("realDonaldTrump").sample(1).each do |tweet|
    # # @tweet = tweet.text

    # end

  erb :index
  end
