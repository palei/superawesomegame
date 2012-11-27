Zombo = {}
Zombo.new = function(v)
  local self = {}
  local v = v or 1
  local image = zombo_img
  local pos_x = math.random(love.graphics.getWidth()-64)
  local pos_y = -64
  local direction = 1
  self.draw = function() 
    love.graphics.draw(image, pos_x, pos_y)    
  end
  self.move = function()
    if pos_y > love.graphics.getHeight() + 64 then
      direction = -1
    elseif pos_y < -64 then
      direction = 1
    end
    pos_y = pos_y + direction
  end
  self.x = function() return pos_x end
  self.y = function() return pos_y end
  return self
end
