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

    author = "Tim Morton"
   
    rss = RSS::Rss.new("2.0")
    channel = RSS::Rss::Channel.new
   
    category = RSS::ITunesChannelModel::ITunesCategory.new("Philosophy")
    category.itunes_categories << RSS::ITunesChannelModel::ITunesCategory.new("Literature")
    channel.itunes_categories << category
   
    channel.title = "Ecology Without Nature"
    channel.description = "Class and lecture audio recordings from Professor Tim Morton on Object-Oriented Ontology, Romanticism, Hyperobjects"
    channel.link = "http://ecologywithoutnature.blogspot.com"
    channel.language = "en-us"
    channel.copyright = "Copyright #{Date.today.year} I Own This"
    channel.lastBuildDate = Time.now
  
    # below is your "album art"
    channel.image = RSS::Rss::Channel::Image.new
    channel.image.url = "http://morton-podcast.heroku.com/ewn.jpg"
    channel.image.title = "Ecology Without Nature"
    channel.image.link = "http://ecologywithoutnature.blogspot.com"

    channel.itunes_author = author
    channel.itunes_owner = RSS::ITunesChannelModel::ITunesOwner.new
    channel.itunes_owner.itunes_name=author
    channel.itunes_owner.itunes_email='timothymorton303@gmail.com'

    channel.itunes_keywords = %w(OOO Object-Oriented Ontology Philosophy Ecology)

    channel.itunes_subtitle = "Tim Morton on Object-Oriented Ontology, Romanticism, Hyperobjects."             
    channel.itunes_summary = "Class and lecture audio recordings from Professor Tim Morton on Object-Oriented Ontology, Romanticism, Hyperobjects."

     # below is what iTunes uses for your "album art", different from RSS standard
    channel.itunes_image = RSS::ITunesChannelModel::ITunesImage.new("http://morton-podcast.heroku.com/ewn.jpg")
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