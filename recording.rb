require 'dm-core'
require 'dm-timestamps'
require 'rss/2.0'
require 'rss/itunes'

DataMapper.setup(:default, ENV['DATABASE_URL'] || {:adapter => 'yaml', :path => "db"})

class Recording
  include DataMapper::Resource
  
  property :id, Serial
  property :title, Text
  property :description, Text
  property :mp3_url, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  property :size, Float

  def self.rss

    author = "Greg Borenstein"
   
    rss = RSS::Rss.new("2.0")
    channel = RSS::Rss::Channel.new
   
    category = RSS::ITunesChannelModel::ITunesCategory.new("Visual Arts")
    category.itunes_categories << RSS::ITunesChannelModel::ITunesCategory.new("Philosophy")
    channel.itunes_categories << category
   
    channel.title = "Podcustom"
    channel.description = "Custom podcast curated by Greg Borenstein for Greg Borenstein."
    channel.link = "http://podcustom.heroku.com/recordings"
    channel.language = "en-us"
    channel.copyright = "Copyright #{Date.today.year} I Own This"
    channel.lastBuildDate = Time.now
  
    # below is your "album art"
    channel.image = RSS::Rss::Channel::Image.new
    channel.image.url = "http://podcustom.heroku.com/ewn.jpg"
    channel.image.title = "Podcustom"
    channel.image.link = "http://podcustom.heroku.com/recordings"

    channel.itunes_author = author
    channel.itunes_owner = RSS::ITunesChannelModel::ITunesOwner.new
    channel.itunes_owner.itunes_name=author
    channel.itunes_owner.itunes_email='greg.borenstein@gmail.com'

    channel.itunes_keywords = %w(Technology Art Philosophy Computer Vision)

    channel.itunes_subtitle = "Custom podcast curated by Greg Borenstein for Greg Borenstein."             
    channel.itunes_summary = "Technology, art, computer vision, visual effects, object-oriented ontology."

     # below is what iTunes uses for your "album art", different from RSS standard
    channel.itunes_image = RSS::ITunesChannelModel::ITunesImage.new("http://podcustom.heroku.com/ewn.jpg")
    channel.itunes_explicit = "Yes"
    # above could also be "Yes" or "Clean"

    self.all.each do |recording|
      item = RSS::Rss::Channel::Item.new
      item.title = recording.title
      link = recording.mp3_url
      item.link = link
      item.itunes_keywords = channel.itunes_keywords
      item.guid = RSS::Rss::Channel::Item::Guid.new
      item.guid.content = link
      item.guid.isPermaLink = true
      item.pubDate = recording.updated_at.strftime("%a, %d %b %Y %H:%M:%S GMT")#Wed, 15 Jun 2005 19:00:00 GMT
     
      description = recording.description

      item.description = description
      item.itunes_summary = description
      item.itunes_subtitle = recording.title
      item.itunes_explicit = "No"
      item.itunes_author = author
     
      # TODO can add duration once we can compute that somehow
     
      item.enclosure = RSS::Rss::Channel::Item::Enclosure.new(item.link, recording.size, 'audio/mpeg')     
      channel.items << item
       
      end

    rss.channel = channel
    return rss.to_s
  end
end

DataMapper.finalize