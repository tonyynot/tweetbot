#!/usr/bin/env ruby
require 'twitter'
require 'sinatra'

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
    @timeline.reject! { |item| item.text =~ /http/ }
  end
end

get '/' do
  client.get_all_tweets("kanyewest").sample(1).each do |tweet|
    @tweet = tweet.text
  end
  erb :index
end
