# Path representation 
# Cost is calculated assuming each hope in the array has a cost of 1
# TODO: implement A* heuristic
class PathHelper
  def initialize(image, grid)
    @image = image
    @grid = grid
  end
  
  # TODO: Refactor this so we don't have to do all the calculation here...
  def draw_path(p)
    if p && p.nodes
      p.nodes.each do |n|
        @image.draw(@grid.cellsize * n.x + @grid.pos.x, @grid.cellsize * n.y + @grid.pos.y, 1)
      end
    end
  end
  
end

class Path < GridObject
  attr_accessor :nodes
  
  def initialize
    @nodes = Array.new
    @current_index = 0
  end
  
  def copy
    p = Path.new
    @nodes.each do |n| p.add_node(n) end
  end
  
  def add_node (node)
    @nodes.push(node)
  end
  
  def <=> (other_path)
    self.cost_function <=> other_path.cost_function
  end
  
  def length
    if @nodes
      @nodes.length
    else
      0
    end
  end
  
  def to_s
    if @nodes
      @nodes.to_s
    end
  end
  
  def cost_function
    if @nodes 
      @nodes.length
    else
      0
    end
  end
  
  
  # helper method that returns a path from a single Point
  def self.path_from_point(p)
    path = Path.new
    path.add_node(p)
    path
  end
  
  # Returns the next node (Point) on the Path, and increments the counter
  def next!
    next_node = @nodes[@current_index]
    @current_index += 1
    next_node
  end
  
  def last_node
    @nodes.last
  end
end