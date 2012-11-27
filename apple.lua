Apple = {}
Apple.new = function ()
  local self = {}
  local image = apple_img
  local pos_x = math.random(love.graphics.getWidth() - 32)
  local pos_y = math.random(love.graphics.getHeight() - 32)
  self.draw = function() 
    love.graphics.draw(image, pos_x, pos_y)    
  end
  self.x = function() return pos_x end
  self.y = function() return pos_y end
  return self
end
