class FileNode

  # A very simple class for managing files.  Can have a parent and multiple
  # children.  Children can be a directory or a file.
  
  attr_accessor :parent, :children, :name, :dir
  
  def initialize(name, params)
    @name = name
    @parent = params[:parent]
    @children = params[:children]
    @dir = params[:dir]
  end
  
  def is_dir?
    @dir
  end
end
