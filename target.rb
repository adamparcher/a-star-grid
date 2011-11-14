require 'gosu'
require_relative 'gridobject'

# Represents the Target the Agent is trying to find
# X and Y coordinates are grid coordinates, not actual pixel coords
# To find actual pixel coords for drawing, call GameWindow#grid_to_pixel_x/y

# TODO: Refactor so Agent only cares about Grid coordinates, and doesn't care about pixel coords
class Target < GridObject
  def initialize(image)
    super (image)
    
    @pos = Point.new(10, 10)
  end
end