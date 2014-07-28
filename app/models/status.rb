require 'open-uri'

class Status < ActiveRecord::Base
  validates :twitter_user_id, :twitter_status_id, :body, presence: true

  def self.post(body)
    path = "statuses/update"
    req_params = {:status => body}
    tweet = TwitterSession.post(path, req_params)

    status = self.parse_json(JSON.parse(tweet))

    self.save_records([status], status.twitter_user_id)

    nil
  end

  def self.fetch_by_twitter_user_id!(twitter_user_id)
    path = "statuses/user_timeline"
    query_values = {:user_id => twitter_user_id}

    status_arr = []
    JSON.parse(TwitterSession.get(path, query_values)).each do |tweet|
       status_arr << self.parse_json(tweet)
    end

    status_arr.each do |status|
      puts "#{status.body}"
    end

    self.save_records(status_arr, twitter_user_id)

    nil
  end

  def self.parse_json(tweet)
    Status.new(
      :twitter_user_id => "#{tweet["user"]["id"]}",
      :twitter_status_id => "#{tweet["id"]}",
      :body => "#{tweet["text"]}"
    )
  end

  def self.save_records(statuses, twitter_user_id)
    puts twitter_user_id
    prev_statuses = self.where(twitter_user_id: twitter_user_id)
      .pluck(:twitter_status_id)

    statuses.select! { |status| !prev_statuses.include?(status.twitter_status_id)}

    statuses.each do |status|
      status.save!
    end

    nil
  end

  def self.get_by_twitter_user_id(twitter_user_id)
    if self.internet_connection?
      self.fetch_by_twitter_user_id!(twitter_user_id)
    else
      self.where(twitter_user_id: twitter_user_id).each do |status|
        puts "#{status.body}"
      end
    end

    nil
  end

  def self.internet_connection?
    begin
      true if open("http://www.google.com/")
    rescue
      false
    end
  end
end