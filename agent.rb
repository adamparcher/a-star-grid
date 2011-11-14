require 'gosu'
require_relative 'gridobject'
require_relative 'path'

# Represents the Agent that is trying to find the Target
# X and Y coordinates are grid coordinates, not actual pixel coords
# To find actual pixel coords for drawing, call GameWindow#grid_to_pixel_x/y

# TODO: Refactor so Agent only cares about Grid coordinates, and doesn't care about pixel coords
class Agent < GridObject
  STRATEGY_DIRECT   = 0x01 # also the default
  STRATEGY_GREEDY   = 0x02
  STRATEGY_ASTAR    = 0x03
  

  attr_accessor :move, :move_interval
  attr_reader :path

  def initialize(image, target, wall)
    super (image)
    @target = target
    @wall = wall
    
    @pos = Point.new(0, 0)
    @move = false
    @move_amount = 1 # The number of spaces we move each time
    @move_interval = 0.1 # The min number of seconds we'll wait between moves
    @last_update_time = Time.now
    @strategy = STRATEGY_DIRECT
    
    @path = nil
    @path_calculated = false
    
  end

  # Clear out the existing path and force it to be recalculated
  def invalidate_path
    @path_calculated = false
    @path = nil
    @path_index = 0
  end
  
  def chase_target
    # puts <<-eol 
    #   Now:  #{Time.now.to_f.to_s}
    #   Last: #{@last_update_time.to_f.to_s}
    #   Diff: #{(Time.now.to_f - @last_update_time.to_f).to_s}
    #   eol
    if (Time.now.to_f - @last_update_time.to_f) > @move_interval 
      if @move 
        next_move
      end
      @last_update_time = Time.now
    end
  end
  
  
  def next_move
    if !@path_calculated
      calculate_path
    end
    if !at_goal? && @path && @path.length > 0
      case @strategy
      when STRATEGY_GREEDY
        ;
      when STRATEGY_ASTAR
        ;
      else # default is STRATEGY_DIRECT
        @pos = @path.next!
        # in this strategy, we make only one move, then force the path to recalculate
        calculate_path
      end
    end
  end
  
  def calculate_path
    case @strategy
    when STRATEGY_GREEDY
      @path = calculate_greedy_path
    when STRATEGY_ASTAR
      ;
    else # default is STRATEGY_DIRECT
      @path = Path.new
      @path.add_node(get_new_pos_direct)
    end
    @path_calculated = true
  end
  
  def at_goal?
    (@target.pos.x-@pos.x).abs <= 1 && (@target.pos.y-@pos.y).abs <= 1
  end
  
  
  private
  
  
  # this strategy moves directly toward the target and stops if there's an obstacle
  # (so it's not really pathfinding)
  def get_new_pos_direct
    # We assume in this method that we're not at the target yet, since we check for the goal state elsewhere
    # Determine if we need to move sideways or up-down
    new_pos = Point.new(@pos.x, @pos.y)
    if (@target.pos.x-@pos.x).abs >= (@target.pos.y-@pos.y).abs
      # move sideways
      if @target.pos.x > @pos.x
        new_pos.x += @move_amount
      else
        new_pos.x -= @move_amount
      end
    else
      # move up-down
      if @target.pos.y > @pos.y
        new_pos.y += @move_amount
      else
        new_pos.y -= @move_amount
      end
    end
    
    if @wall.blocked? (new_pos)
      @pos
    else
      new_pos
    end
  end
  
  
  
  # This strategy picks a path by doing a greedy algorithm. As long as the Agent is not completely blocked off
  # by the Wall from the Target, this will find at least one path (although not the optimal in certain cases)
  # 
  # Pseudocode
  #   PATHS = {}
  #   add all adjacent paths to PATHS
  #   P = member of PATHS with least f(p)
  #     if P.last_node is goal, then return P
  #     for each adjacent node N to P
  #       if N is not already "visited"
  #         new path P' = P << N
  #         add P' to PATHS
  #         mark N "visited"
  def calculate_greedy_path
    goal = @target.pos
    paths = Array.new # will be an array of Path objects
    p = Path::path_from_point(@pos) # The first path we start with is the current Agent position
    while !(p == goal) do
      # PICK UP HERE
    end
  end
  
end
