require 'gosu'


# Wall contains a 2-d array of points that make up the wall
# Stored in 2d array where first index is 'x', second index is 'y'
class Wall
  def initialize(image, grid)
    @grid = grid
    @image = image
    @points = Array.new
  end
  
  def add_point(p)
    # Point is added at x, y coordinates, plus one more in each direction, 
    # so wall has some substance more than just one pixel
    if @points[p.x].nil?
      @points[p.x] = Array.new
    end
    @points[p.x][p.y] = true
  end
  
  def clear
    # Clear out the entire wall
    @points = Array.new
  end
  
  # Returns true if there is a wall at the specified location
  def blocked?(p)
    return (p && @points && @points[p.x] && @points[p.x][p.y])
  end
  
  def draw
    if @points.nil? then return end
    for i in (0..@points.length)
      if !@points[i].nil?
        for j in (0..@points[i].length)
          if @points[i][j]
            pos = @grid.grid_point_to_absolute(Point.new(i, j))
            @image.draw(pos.x, pos.y, 1)
          end
        end
      end
    end
  end
end