-- SUPER-AWESOME-GAME
local GS = require "hump.gamestate"
require "apple"
require "creep"
require "zombo"

-- SETTINGS
apple_popup_interval = 1  -- seconds
creep_popup_interval = 15 -- seconds 
zombo_popup_interval = 10 -- seconds

creep_speed = 1
creep_speed_increment = 1

points_per_apple = 1

lives = 3

game_name = "Super Awesome Game"

-- GLOBALS
lives_left = lives
points = 0
creeps = {}
apples = {}
zombos = {}

-- hump stuff; declare different game states
menu = GS.new()
game = GS.new()
dead = GS.new()
over = GS.new()
paus = GS.new()

-- MENU STATE
function menu:enter()
  love.graphics.setCaption(game_name .. " - Menu")
  love.graphics.setBackgroundColor(0, 0, 0)
  love.audio.pause()
end

function menu:draw()
  love.graphics.draw(steve_img, 100, 100)
  love.graphics.print("This is you and you need these apples ->", 200, 120)
  love.graphics.draw(apple_img, 630, 120)
  love.graphics.draw(zombo_img, 100, 190)
  love.graphics.print("These guys are BAD!", 200, 200)
  love.graphics.draw(creep_img, 440, 195)
  love.graphics.print("Use the mouse to move! \"P\" pauses the game!", 100, 300)
  love.graphics.print("Press any key to start!", 100, 370)
end

function menu:keypressed(k)
  if k == "q" or k == "escape" then 
    os.exit()
  end
  GS.switch(game)
end

-- GAME STATE
function game:enter()
  love.graphics.setCaption(game_name .. " - Playing")

  start_time = love.timer.getTime()
  
  last_apple_time = start_time
  last_creep_time = start_time
  last_zombo_time = start_time
  
  love.audio.play(music)
  love.mouse.setVisible(false)
end

function game:draw()
  draw_grass_background()
  draw_info()
  creeps_move_and_draw()
  zombos_move_and_draw()
  apples_draw()
  
  -- draw the mouse cursor
  love.graphics.draw(steve_img, mx, my)
end

function game:update()
  mx = love.mouse.getX()
  my = love.mouse.getY()
  
  time = love.timer.getTime()

  -- Add apple
  if time - last_apple_time > apple_popup_interval then
    last_apple_time = time
    table.insert(apples, Apple.new())
  end

  -- Add creep
  if time - last_creep_time > creep_popup_interval then
    last_creep_time = time
    table.insert(creeps, Creep.new(creep_speed))
    creep_speed = creep_speed + creep_speed_increment
  end

  -- Add zombo
  if time - last_zombo_time > zombo_popup_interval then
    last_zombo_time = time
    table.insert(zombos, Zombo.new())
  end
  
  if touching_apple() then
    love.audio.stop(food)
    love.audio.play(food)
    points = points + points_per_apple
  end
  
  if touching_creep() or touching_zombo() then
    love.audio.stop(music)
    GS.switch(dead) -- switch to death screen
  end

  love.timer.sleep(10) -- sleep 10ms
end

function game:keypressed(k)
  if k == "q" or k == "escape" then GS.switch(menu) end
  if k == "p" then GS.switch(paus) end
end

-- PAUSE STATE
function paus:enter()
  love.audio.setVolume(0.3)
  love.graphics.setBackgroundColor(45, 45, 240)
end

function paus:draw()
  love.graphics.setCaption("Super Awesome Game - Paused")
  love.graphics.print("The Game is paused", 300, 270)
end

function paus:keypressed(k)
  if k == "q" then GS.switch(menu) 
    love.audio.setVolume(1.0)
  end
  if k == "p" then GS.switch(game) 
    love.audio.setVolume(1.0)
  end
end


function dead:enter()
  love.audio.stop(pain)
  love.audio.play(pain)
  
  lives_left = lives_left - 1 
  if lives_left < 1 then 
    GS.switch(over) 
  end

  -- clear the field
  creeps = {}
  apples = {}
  zombos = {}

  love.graphics.setBackgroundColor(240, 23, 23)
end

function dead:draw()
  love.graphics.print("YOU WERE EATEN ALIVE!.", 230, 200)
  love.graphics.print("Good thing you have " .. lives_left .. 
    " more lives left.", 230, 250)
  love.graphics.print("Press any key to continue.", 230, 300)
end

function dead:keypressed(key)
  GS.switch(game)
end

function over:enter()
  love.graphics.setCaption(game_name .. " - Game over")
  lives_left = lives
  love.graphics.setBackgroundColor(0,0,0)
end

function over:draw()
  love.graphics.print("GAME OVER!", 300, 300)
  love.graphics.print("Score: " .. points, 300, 350)
end

function over:keypressed(key)
  lives_left = lives
  points = 0
  creep_speed = 1
  GS.switch(menu)
end

function love.load()
  -- load background grass tile 
  bg = love.graphics.newImage("img/grass.png")
  
  -- load images
  steve_img = love.graphics.newImage("img/steve.png")
  creep_img = love.graphics.newImage("img/creep.jpg")
  zombo_img = love.graphics.newImage("img/zombo.png") 
  apple_img = love.graphics.newImage("img/apple.png")
  
  -- load audio sources
  pain = love.audio.newSource("audio/death.mp3", "static")
  food = love.audio.newSource("audio/crunch.wav", "static") 
  music = love.audio.newSource("audio/bummer.mp3")
  music:setLooping(true)
  
  w = love.graphics.getWidth()
  h = love.graphics.getHeight()
  
  love.mouse.setPosition(math.floor(w/2)-32, math.floor(h/2)-32)
  
  local f = love.graphics.newFont("font/font.ttf", 32)
  love.graphics.setFont(f)
  
  GS.registerEvents()
  GS.switch(menu) -- go into "menu" first
end

-- HELPER FUNCTIONS

function draw_grass_background()
  love.graphics.draw(bg, 0, 0)
  love.graphics.draw(bg, 600, 0)
  love.graphics.draw(bg, 0, 427)
  love.graphics.draw(bg, 600, 427)
end

function draw_info()
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
  love.graphics.print("Lives: " .. lives_left, 350, 10)
  love.graphics.print("Points: " .. points, 650, 10)
end

function touching_apple()
  for i,v in ipairs(apples) do
    if (math.abs(v.x()-(mx+32)) < 32) and (math.abs(v.y()-(my+32)) < 32) then
      table.remove(apples, i)
      return true
    end
  end
  return false
end

function touching_creep()
  for i,c in ipairs(creeps) do
    if math.abs(c.x()-mx) < 25 and math.abs(c.y()-my) < 25 then
      return true
    end 
  end
  return false
end

function touching_zombo()
  for i,z in ipairs(zombos) do
    if math.abs(z.x()-mx) < 32 and math.abs(z.y()-my) < 32 then
      return true
    end 
  end
  return false
end

function zombos_move_and_draw()
  for i, z in ipairs(zombos) do
    z.draw()
    z.move()
  end
end

function creeps_move_and_draw()
  for i,c in ipairs(creeps) do
    c.draw()
    c.move()
  end
end

function apples_draw() 
  for i,a in ipairs(apples) do
    a.draw()
  end
end
