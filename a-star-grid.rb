# a-star-grid
# 
# This program has an Agent trying to find a Target. The user can draw a Wall between the two
# and the Agent will not go through the wall.
#
# Some guidelines:
# - The Agent can only move up, down, left, or right. Not diagonal.
# - The Agent, Target, and Wall, must stay on the Grid.
# - There are a few different algorithms the Agent can choose from
#
# TODO LIST:
# - Greedy pathfinding 
# - A* search pathfinding
# - dynamic switching of path algorithm
# - tighter control on Agent speed
# - "explain"/show the path the Agent will choose
# - implementation of Wall seems a big cludgy, maybe I can improve it?
#
# Future ideas:
# - Currently Agent has knowledge of the entire scene including where the Target is, and where the Wall is and
#   all possible moves. Make it so the Agent only has partial knowledge, or line-of-sight
# - Agent, Wall, and Target pre-sets to illustrate different interesting scenarios
require 'gosu'
require_relative 'target'
require_relative 'agent'
require_relative 'wall'
require_relative 'gamegrid'
require_relative 'media_loader'


class KeyHandler
  def initialize(window)
    @window = window
  end
    
  def button_down(id)
    # Keys:
    # Return - single-step Agent move
    # ESC - close
    # C - clear wall
    # A - move Agent to mouse coordinates
    # T - move Target to mouse coordinates
    # B - toggle showing border of Grid
    # Space - toggle moving of Agent
    # P - toggle showing planned Path of Agent
    # X - force recalculation of Agent's Path
    # D - print debug info
    if id == Gosu::KbEnter || id == Gosu::KbReturn 
      @window.agent.next_move # Force the agent to chase the target once
    end
    if id == Gosu::KbP
      @window.show_path = !@window.show_path
    end
    if id == Gosu::KbD
      puts <<-eol
DEBUG-----
  Agent Pos: #{@window.agent.pos}
  Target Pos: #{@window.target.pos}
  Path: #{@window.agent.path}

      eol
    end
    if id == Gosu::KbX
      @window.agent.calculate_path
    end
    if id == Gosu::KbEscape
      @window.close
    end
    if id == Gosu::KbC
      @window.wall.clear
    end
    if id == Gosu::KbA
      new_pos = @window.grid.absolute_point_to_grid(Point.new(@window.mouse_x, @window.mouse_y))
      if new_pos
        @window.agent.pos = new_pos
        @window.agent.invalidate_path
      end
    end
    if id == Gosu::KbT
      new_pos = @window.grid.absolute_point_to_grid(Point.new(@window.mouse_x, @window.mouse_y))
      if new_pos
        @window.target.pos = new_pos
        @window.agent.invalidate_path
      end      
    end
    if id == Gosu::KbB
      @window.grid.draw_border = !@window.grid.draw_border
    end
    if id == Gosu::KbSpace
      @window.agent.move = !@window.agent.move
    end
  end
  
  # Handle keys where we want to check status on every update call
  def update_key_status
    if @window.button_down? Gosu::MsLeft
      new_pos = @window.grid.absolute_point_to_grid(Point.new(@window.mouse_x, @window.mouse_y))
      @window.wall.add_point(new_pos)
    end
    if @window.button_down? Gosu::KbNumpadAdd
      @window.agent.move_interval = (@window.agent.move_interval + 0.01).round(2)
    end
    if @window.button_down? Gosu::KbNumpadSubtract
      @window.agent.move_interval = (@window.agent.move_interval - 0.01).round(2) < 0 ? 0 : 
        (@window.agent.move_interval - 0.01).round(2)
    end
  end
end



class GameWindow < Gosu::Window
  attr_reader :agent, :target, :wall, :grid
  attr_accessor :show_path
  
  WIDTH = 800
  HEIGHT = 600
  CELLSIZE = 20 # the size of each cell in the grid TODO: To change this from 20px I would need to resize the images or something
  
  def initialize
    super WIDTH, HEIGHT, false
    self.caption = "A* Grid"
    
    ml = MediaLoader.new(self)
    
    # Create the grid where all the game objects will go.
    @grid = GameGrid.new(self, 150, 10, 32, 29, 20)
    
    
    # Wall is special, because it represents a bunch of things that need to be drawn. 
    # Probably should figure out a better way to do this
    @wall = Wall.new(ml.load_image(MediaLoader::WALL), @grid)
    
    
    # create the game objects
    @target = Target.new(ml.load_image(MediaLoader::TARGET))
    @grid.add_object(@target)
    @agent = Agent.new(ml.load_image(MediaLoader::AGENT), @target, @wall)
    @grid.add_object(@agent)
    
    
    @keyhandler = KeyHandler.new(self)
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 16) # Create font with height for displaying debug junk
    
    # Some stuff to draw the Path that I probably need to refactor
    @show_path = true
    @path_helper = PathHelper.new(ml.load_image(MediaLoader::PATH), @grid)
  end
 
  
  def update
    @keyhandler.update_key_status
    @agent.chase_target
  end
  
  def draw
    @grid.draw
    @wall.draw
    if show_path
      @path_helper.draw_path(@agent.path)
    end
    draw_crosshairs(mouse_x, mouse_y)
    draw_info
  end
  
  def draw_crosshairs(x, y)
    draw_line(x+1, y, Gosu::Color::GREEN, x+5, y, Gosu::Color::GREEN)
    draw_line(x-6, y, Gosu::Color::GREEN, x-2, y, Gosu::Color::GREEN)
    draw_line(x, y+1, Gosu::Color::GREEN, x, y+5, Gosu::Color::GREEN)
    draw_line(x, y-6, Gosu::Color::GREEN, x, y-2, Gosu::Color::GREEN)
  end
  
  def draw_info
    color = Gosu::Color::WHITE
    debug_text = "AgentMoveInt: #{@agent.move_interval}"
    @font.draw(debug_text, 5, HEIGHT-@font.height-5, 0, 1, 1, color)
  end
  
  
  def button_down(id)
    @keyhandler.button_down(id)
  end
  
  
  # HELPER METHODS for CALCULATING GRID STUFF
  def grid_width
    # Returns 0 if divide-by-zero
    if CELLSIZE != 0 then WIDTH / CELLSIZE else 0 end
  end
  
  def grid_height
    # Returns 0 if divide-by-zero
    if CELLSIZE != 0 then HEIGHT / CELLSIZE else 0 end
  end
  
  def grid_to_pixel_x(x)
    x * CELLSIZE
  end
  
  def grid_to_pixel_y(y)
    y * CELLSIZE
  end
  
  def pixel_to_grid_x(x)
    # Returns 0 if divide-by-zero
    if CELLSIZE != 0 then x / CELLSIZE else 0 end
  end
  
  def pixel_to_grid_y(y)
    # Returns 0 if divide-by-zero
    if CELLSIZE != 0 then y / CELLSIZE else 0 end
  end
  
  
end

window = GameWindow.new
window.show