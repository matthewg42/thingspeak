# == Schema Information
#
# Table name: feeds
#
#  id         :integer          not null, primary key
#  channel_id :integer
#  field1     :string(255)
#  field2     :string(255)
#  field3     :string(255)
#  field4     :string(255)
#  field5     :string(255)
#  field6     :string(255)
#  field7     :string(255)
#  field8     :string(255)
#  created_at :datetime
#  updated_at :datetime
#  entry_id   :integer
#  status     :string(255)
#  latitude   :decimal(15, 10)
#  longitude  :decimal(15, 10)
#  elevation  :string(255)
#  location   :string(255)
#

class Feed < ActiveRecord::Base
  extend FeedHelper
  belongs_to :channel

  #after_commit :queue_react
  #delegate :queue_react, :to => :channel

  self.include_root_in_json = false

  attr_readonly :created_at

  # delete feeds in batches
  def self.delete_in_batches(channel_id)
    channel = Channel.find(channel_id)

    # while there are still feeds left
    while channel.feeds.count > 0
      # create the sql query to delete 1000 feeds from the channel
      sql = "DELETE FROM feeds WHERE channel_id=#{channel_id} LIMIT 1000"
      # execute the sql query
      ActiveRecord::Base.connection.execute(sql)
      # wait a bit before the next delete
      sleep 0.1
    end
  end

  # for to_xml, return only the public attributes
  def self.public_options
    {
      :except => [:id, :updated_at]
    }
  end

  # only output these fields for feed
  def self.select_options(channel, params)
    only = [:created_at]
    only += [:entry_id] unless timeparam_valid?(params[:timescale]) or timeparam_valid?(params[:average]) or timeparam_valid?(params[:median]) or timeparam_valid?(params[:sum])

    Channel.column_names_with_prefix('field').map {|c| c.to_sym}.each do |f| 
      only += [f] if !channel.send(f).blank?
    end

    # add geolocation data if necessary
    if params[:location] and params[:location].upcase == 'TRUE'
      only += [:latitude]
      only += [:longitude]
      only += [:elevation]
      only += [:location]
    end

    # add status if necessary
    only += [:status] if params[:status] and params[:status].upcase == 'TRUE'
    return only
  end

  # outputs feed info correctly, used by daily_feeds
  def self.normalize_feeds(daily_feeds)
    output = []
    hash = {}

    # for each daily feed
    daily_feeds.each do |daily_feed|
      # check if the feed already exists
      existing_feed = hash[daily_feed['date']]

      # skip blank feeds
      next if daily_feed['date'].blank?

      # if the feed exists
      if existing_feed.present?
        # add the new field
        existing_feed["field#{daily_feed['field']}"] = daily_feed['result']
      # else add a new feed
      else
        new_feed = Feed.new(:created_at => daily_feed['date'])
        # set the field attribute correctly
        new_feed["field#{daily_feed['field']}"] = daily_feed['result']
        # add the feed
        hash[daily_feed['date']] = new_feed
      end

    end

    # turn the hash into an array
    output = hash.values

    # sort by date
    return output
  end

  # custom json output
  def as_json(options = {})
    super(Feed.public_options.merge(options))
  end

  # check if a field value is a number
  # usage: Feed.numeric?(field_value)
  def self.numeric?(object)
    true if Float(object) rescue false
  end

  def field(number)
    self.attributes["field#{number.to_i}"]
  end

  # make sure any selected fields are greater than a minimum
  def greater_than?(minimum)
    output = true
    self.attributes.each do |attribute|
      # if this attribute is a numeric field with a value
      if attribute[0].to_s.index('field') == 0 && attribute[1].present? && Feed.numeric?(attribute[1])
        output = false if attribute[1].to_f < minimum.to_f
      end
    end
    return output
  end

  # make sure any selected fields are less than a minimum
  def less_than?(maximum)
    output = true
    self.attributes.each do |attribute|
      # if this attribute is a numeric field with a value
      if attribute[0].to_s.index('field') == 0 && attribute[1].present? && Feed.numeric?(attribute[1])
        output = false if attribute[1].to_f > maximum.to_f
      end
    end
    return output
  end

end

