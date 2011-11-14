require_relative 'gamegrid'

# A game object that lives on the grid. Intended to be extended into the 
# actual game object classes. Those objects only need to care about the 'pos' (position)
# relative to the grid. They do not need to worry about actual pixel coordinates when it 
# comes to drawing their proper location
class GridObject
  attr_reader :grid, :image
  
  # coordinates for GridObject are grid coords, so not actual pixel coordinates
  attr_accessor :pos
  
  def initialize(image)
    @image = image
  end
      
  def draw(x_offset, y_offset, grid_cell_size)
    if @image
      @image.draw(grid_cell_size * @pos.x + x_offset, grid_cell_size * @pos.y + y_offset, 1)
    end
  end
end