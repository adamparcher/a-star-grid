# Handles the game pieces on a grid. Provides helper methods for convertin
# back and forth between grid coordinates and pixel coordinates (for drawing and mouse input)\

class Point
  attr_accessor :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  def to_s
    "{#{x}/#{y}}"
  end
  
  def ==(other_point)
    @x == other_point.x && @y == other_point.y
  end
end

class GameGrid
  attr_reader :pos, :w, :h, :cellsize, :objects
  attr_accessor :draw_border, :draw_grid
  
  COLOR = Gosu::Color::WHITE
  
  def initialize(window, x, y, w, h, cellsize)
    @window = window
    @pos = Point.new(x, y)
    @w = w
    @h = h
    @cellsize = cellsize
    @objects = Array.new
    @draw_border = true
    @draw_grid = false
  end
  
  def add_object(grid_object)
    objects.push grid_object
  end
  
  def draw
    objects.each do |grid_object| 
      grid_object.draw(@pos.x, @pos.y, @cellsize)
    end
    if @draw_border
      @window.draw_line(min_x, min_y, COLOR, max_x, min_y, COLOR) 
      @window.draw_line(max_x, min_y, COLOR, max_x, max_y, COLOR)
      @window.draw_line(max_x, max_y, COLOR, min_x, max_y, COLOR)
      @window.draw_line(min_x, max_y, COLOR, min_x, min_y, COLOR)
    end
  end
  
  # Takes a point as argument that has x and y as coordinates on the grid
  # returns a new point with the absolute coordinates (i.e. pixels)
  # Unlike the corresponding reverse method below, this does NOT check if the coords are actually on the grid
  def grid_point_to_absolute(point)
    Point.new((@pos.x + point.x * @cellsize).to_i, (@pos.y + point.y * @cellsize).to_i)
  end
  
  # Takes a point as an argument that uses absolute coordinates and returns a new point corresponding
  # to the grid coordinates. 
  # Returns nil if the point parameter is not on the grid.
  def absolute_point_to_grid(point)
    if point.x < min_x || point.x >= max_x || point.y < min_y || point.y >= max_y
      return nil
    end
    Point.new(((point.x - @pos.x) / @cellsize).to_i, ((point.y - @pos.y) / @cellsize).to_i)
  end
  
  
  # Helper functions to return the absolute coordinate boundaries (i.e. in pixels)
  def min_x
    @pos.x
  end
  def max_x
    @pos.x + @w * @cellsize
  end
  def min_y
    @pos.y
  end
  def max_y
    @pos.y + @h * @cellsize
  end
end