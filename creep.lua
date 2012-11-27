Creep = {}
Creep.new = function(v)
  local self = {}
  local v = v or 1
  local image = creep_img
  local pos_x = 0
  local pos_y = 0
  if math.random(2) == 2 then
    pos_x = 0
  else
    pos_x = love.graphics.getWidth()
  end
  local pos_y = math.random(love.graphics.getHeight() - 32)
  self.draw = function() 
    love.graphics.draw(image, pos_x, pos_y)    
  end
  self.move = function()
    if pos_x > mx then dx = -1 else dx = 1 end
    if pos_y > my then dy = -1 else dy = 1 end
    pos_x = pos_x + (dx * v)
    pos_y = pos_y + (dy * v)
  end
  self.x = function() return pos_x end
  self.y = function() return pos_y end
  return self
end
