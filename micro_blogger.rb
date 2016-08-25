require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Error, message is over 140 characters."
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You can only DM people who follow you."
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each { |follower| screen_names << @client.user(follower).screen_name }
    screen_names
  end

  def spam_my_followers(message)
    followers = followers_list
    followers.each { |follower| dm(follower, message) }
  end

  # This method does not work
  # Its suspected that twitter changed their API
  # I do believe that this code would have worked in the past but can not confirm this
  def everyones_last_tweet
    friends = @client.friends
    friends.sort_by { |friend| friend.screen_name.downcase }
    friends.each do |friend|
      last_tweet = friend.status.text
      timestamp = friend.status.created_at
      puts "#{friend.screen_name} said this on #{timestamp.strftime("%A, %b %d")}..."
      puts last_tweet
      puts ""
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    short_url = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{original_url}"
    return short_url.shorten(original_url).short_url
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when "q" then puts "Goodbye!"
        when "t" then tweet(parts[1..-1].join(" "))
        when "dm" then dm(parts[1], parts[2..-1].join(" "))
        when "spam" then spam_my_followers(parts[1..-1].join(" "))
        when "elt" then everyones_last_tweet
        when "s" then shorten(parts[1])
        when "turl" then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        else
          puts "Sorry, I dont know how to #{command}"
      end
    end
  end

end

blogger = MicroBlogger.new
blogger.run
