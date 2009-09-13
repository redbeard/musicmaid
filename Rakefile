$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
require 'maid'
require 'pathname'

require 'lib/directory_move_task'

task :scan do

  puts "Setting up path..."
  src_root = File.expand_path('spec/integration/origin')
  hq_root = File.expand_path('spec/integration/music.hq.src')
  normal_root = File.expand_path('spec/integration/music.src')
    
  puts "Scanning directories..."

  directories_with_high_quality_files = Dir.select_leaf_dirs(src_root.to_s) do | music_file |
    MusicFile.new(music_file).high_quality?
  end

  directories_with_high_quality_files.each do | dir |
    task(:move_high_quality).enhance [ mv(src_root, hq_root, dir) ]
  end

end


task(:move_high_quality)
task(:move_normal_quality)

task(:move => [ :move_high_quality, :move_normal_quality ])

task(:default => [:scan, :move ])
