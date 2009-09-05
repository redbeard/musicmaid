require "mp3info"
require 'ostruct'
require 'activesupport'

class MusicFile
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def type
    match = /\.(\w*)$/.match(file_path)

    match.blank? ? nil : match[1].to_sym
  end

  def size
    File.size(file_path)
  end

  def size_in_kb
    size / 1024.0
  end

  def size_in_mb
    size_in_kb / 1024.0
  end

  def is_protected?()
    return true if type == :m4p
  end

  def is_high_quality?()
#    puts attributes.to_yaml
    return true if type == :flac
    return true if type == :m4a and size > 20.megabytes
    return true if type == :mp3 and size > 20.megabytes and bitrate.to_i > 320

    return false
  end

  def attributes
    return @attributes unless @attributes.nil?

    @attributes = {}

    mp3 = nil
    begin
      mp3 = Mp3Info.new(file_path)
      @attributes =
        safe_attributes(mp3, :bitrate, :samplerate, :length, :vbr, :layer).
        merge(safe_attributes(mp3.tag, :album, :artist, :title)).
        merge(safe_attributes(self, :size_in_mb, :type, :is_high_quality?))
    rescue => e
      @attributes[:error] = e
    ensure
      mp3.close unless mp3.nil?
    end

    @attributes
  end

  def method_missing(symbol, *args)
    super(symbol, args) unless (args.blank?)
    attributes[symbol]
  end

private

  def safe_attribute(obj, attribute)
    value = obj.send(attribute.to_sym)
    value.blank? ? nil : value
  end

  def safe_attributes(obj, *attributes)
    result = {}
    attributes.each do | attribute |
      value = safe_attribute(obj, attribute)
      result[attribute.to_sym] = value
    end

    result
  end

end
