class User < ActiveRecord::Base
  validates :screen_name, :twitter_user_id, presence: true, uniqueness: true

  def self.fetch_by_screen_name!(screen_name)

  end

  def self.get_by_screen_name(screen_name)

  end

end