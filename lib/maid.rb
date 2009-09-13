require "mp3info"
require 'ostruct'
require 'activesupport'
require 'music_file'

class Dir

  def self.select_leaf_dirs(dirname, &block_for_files)
    raise "Not a directory: '#{dirname}'" unless File.directory?(dirname)
    globdir = Regexp.escape(dirname)

    results = []
    Dir.glob(File.join(globdir, "*")).each do | file_or_dir |
      if File.directory?(file_or_dir)
        results << Dir.select_leaf_dirs(file_or_dir, &block_for_files)
      else
        if results.empty? and yield(file_or_dir) then
          results << dirname
        end
      end
    end

    results.flatten
  end

end
