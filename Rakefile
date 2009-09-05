$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
require 'maid'
require 'pathname'

task :default do

  origin_pathname = Pathname.new('/media/raid-one/nas/Music')
  
  directories_with_high_quality_files = Dir.select_leaf_dirs(origin_pathname.to_s) do | music_file |
    MusicFile.new(music_file).is_high_quality?
  end

  directories_with_high_quality_files.each do | dir |
    puts dir
#    dir_pathname = Pathname.new(dir)
#    puts dir_pathname.relative_path_from(origin_pathname)
  end

end