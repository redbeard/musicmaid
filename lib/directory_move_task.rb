class DirectoryMoveTask < Rake::Task
  attr_accessor :src_root
  attr_accessor :dst_root
  attr_accessor :src_dir

  def src_root_pathname
    @src_root_pathname ||= Pathname.new(@src_root)
  end

  def dst_root_pathname
    @dst_root_pathname ||= Pathname.new(@dst_root)
  end

  def src_dir_pathname
    @src_dir_pathname ||= Pathname.new(@src_dir)
  end

  def relative_path_pathname()
    @relative_path_pathname ||= src_dir_pathname.relative_path_from(src_root_pathname)
  end

  def relative_path
    @relative_path ||= relative_path_pathname.to_s
  end

  def dst_dir_pathname()
    @dst_dir_pathname ||= dst_root_pathname + relative_path
  end

  def dst_dir()
    dst_dir_pathname.to_s
  end

  def dst_dir_parent_pathname()
    dst_dir_pathname.parent
  end

  def dst_dir_parent
    dst_dir_parent_pathname.to_s
  end

  def define_dependencies
    directory(dst_dir_parent)

    file(dst_dir => dst_dir_parent) do
      FileUtils.mv(src_dir, dst_dir, :verbose => true)
    end

    self.enhance([ dst_dir ])
  end

end

def mv(src_root, dst_root, src_dir, &block)
  mv_task = DirectoryMoveTask.define_task("Moving of '#{src_dir}' to under '#{dst_root}'", &block)
  mv_task.src_root = src_root
  mv_task.dst_root = dst_root
  mv_task.src_dir = src_dir
  mv_task.define_dependencies
end
