#!/usr/bin/env ruby
require 'twitter'
require 'sinatra'

class Tweet < ActiveRecord::base
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "Bi6HemnID5eof5xIDSjUMHUy8"
  config.consumer_secret     = "bbCfxQugTYFedcFvVSRcsODU3ScALNNRQmHzX3FJtSbhZMsJxf"
  config.access_token        = "2927794471-bJOLUAy6DgUz28EmvfczxEYIvTnFFXynZ734nH4"
  config.access_token_secret = "V2UclP5JSDL9TAsHI8yQORx5RsznedFoewejn6zkekyh3"
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

  newest_tweet = Tweet.find(:all, :order => "created_at desc", :limit => 1)

  if Time.new() <= newest_tweet.created_at + "15 mins" do
    client.get_all_tweets('kanyewest').each do |tweet|
      # existing twitter filter code
      
      @tweet = Tweet.new
      @tweet.text = tweet.text
      @tweet.save
    end
  end
    random_offset = rand(Tweet.count)
    display_tweet = Tweet.offset(random_offset).first

    client.get_all_tweets("kanyewest").sample(1).each do |tweet|
    @tweet = tweet.text

  end
  erb :index
end
