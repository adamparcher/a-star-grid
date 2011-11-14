require 'gosu'

# General class to provide helper methods for loading 
class MediaLoader
  AGENT  = 0x01
  TARGET = 0x02
  WALL   = 0x03
  PATH   = 0x04
  
  def initialize(window)
    @window = window
  end
  
  def load_image(reference)
    case reference
    when AGENT
      Gosu::Image.new(@window, "media/agent.png", false)
    when TARGET
      Gosu::Image.new(@window, "media/target.png", false)
    when WALL
      Gosu::Image.new(@window, "media/wall.png", false)
    when PATH
      Gosu::Image.new(@window, "media/path.png", false)
    else
      puts "Image could not be loaded for reference: #{reference}"
      nil
    end 
  end
end