require 'open-uri'

class User < ActiveRecord::Base
  validates :screen_name, :twitter_user_id, presence: true, uniqueness: true

  def self.fetch_by_screen_name!(screen_name)
    path = "users/show"
    query_values = {:screen_name => screen_name}
    user = TwitterSession.get(path, query_values)
    user_obj = self.parse_twitter_user(JSON.parse(user))

    user_obj.save
  end

  def self.parse_twitter_user(user)
    User.new(
      :screen_name => "#{user[screen_name]}",
      :twitter_user_id => "#{user[id]}"
    )
  end

  def self.get_by_screen_name(screen_name)
    if self.internet_connection?
      self.fetch_by_screen_name!(screen_name)
    else
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