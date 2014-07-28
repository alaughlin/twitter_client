require 'launchy'
require 'oauth'
require 'yaml'
require 'addressable/uri'
require 'rest-client'

class TwitterSession
  TOKEN_FILE = "access_token.yml"
  CONSUMER_KEY = File.read(".api_key")
  CONSUMER_SECRET = File.read(".api_secret")
  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  def initialize
  end

  def self.access_token
    # Load from file or request from Twitter as necessary. Store token
    # in class instance variable so it is not repeatedly re-read from disk
    # unnecessarily.
    if File.exist? TOKEN_FILE
      if @access_token.nil?
        @access_token = YAML.load(File.read(TOKEN_FILE))
        p @access_token
      else
        @access_token
      end
    else
      @access_token = self.request_access_token
      p @access_token
      File.open(TOKEN_FILE, "w").write(YAML.dump(@access_token))

      @access_token
    end
  end

  def self.request_access_token
    # Put user through authorization flow; save access token to file
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url

    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )

    access_token
  end

  def self.path_to_url(path, query_values = nil)
    # All Twitter API calls are of the format
    # "https://api.twitter.com/1.1/#{path}.json". Use
    # `Addressable::URI` to build the full URL from just the
    # meaningful part of the path (`statuses/user_timeline`)
  end

  def self.get(path, query_values)
    url = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/#{path}.json",
      :query_values => {
        :user_id => query_values[:user_id]
      }
    ).to_s

    self.access_token.get(url).body
  end

  def self.post(path, req_params)
    url = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/#{path}.json",
      :query_values => {
        :status => req_params[:status]
      }
    ).to_s

    self.access_token.post(url).body
  end

end
