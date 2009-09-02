#!/usr/bin/env ruby
require 'rubygems'
require "mp3info"
require 'ostruct'
require 'activesupport'

class Info
  def self.diff(left, right, *attrs)
    results = {}
    
    attrs.each do | attribute |
      left_val = left.send(attribute.to_sym)
      right_val = right.send(attribute.to_sym)
      results[attribute.to_sym] = { :left => left_val, :right => right_val } unless (left_val.eql?(right_val))
    end
    
    return results
  end
  
  def self.print_diff(what, left, right, *attrs)
    diffs = Info.diff(left, right, attrs)

    if (diffs.length > 0) 
      puts "#{what}"

      diffs.each_pair do | k, v |
        puts "#{k.to_s.center(20)}|#{v[:left].to_s.center(100)}|#{v[:right].to_s.center(100)}"
      end

    end
  end
  
end

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


# Load a tag from a file
#dir = ("/Users/redbeard/Music/iTunes/iTunes Music/")
#dir = ("/Volumes/NAS/Media/Music to import/")
dir = ("/Volumes/NAS/Music/")
#dir = ("/Users/redbeard/Music/iTunes/iTunes Music/Blur/Blur/**")

def select_directories_that_match_in(dirname, &block_for_files)
  raise "Not a directory: '#{dirname}'" unless File.directory?(dirname)
  globdir = Regexp.escape(dirname)
  
  puts "Scanning...\t#{dirname}"
  results = []
  files = Dir.glob(File.join(globdir, "*"))
  files.each do | file_or_dir |
    if File.directory?(file_or_dir)
      results << select_directories_that_match_in(file_or_dir, &block_for_files)
    else
      if results.empty? and yield(file_or_dir) then
        results << dirname
        puts "Added:\t#{dirname}"
      end
    end
  end
  
  results
end

select_directories_that_match_in(dir) do | music_file | 
  MusicFile.new(music_file).is_high_quality?
end.each do | x |
  puts x 
end

