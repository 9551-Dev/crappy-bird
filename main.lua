local gravity = 1

local w,h = love.graphics.getDimensions()

local bird_pos_x = w/2
local bird_pos_y = h/4
local dead = false

local acceleration = 0
local deceleration = 0.1

local barier_distance_range = {300,400}
local dist_range = {100,200}
local min_dist = 100
local barier_width = 100
local move_speed = 1

math.randomseed(love.timer.getTime())


local i = 0
local bariers = {}
local rev_pos = {}

for i=1,300 do
    local d = math.random(barier_distance_range[1],barier_distance_range[2])
    local xpd = min_dist+math.random(dist_range[1],dist_range[2])+i*w
    table.insert(bariers,{
        x=xpd,
        bdr=d,
        offset = math.random(500,h-500)-d
    })
    rev_pos[math.floor((w/barier_width)-i)] = xpd
end

for i=1,#rev_pos do
    bariers[i].stddst = rev_pos[i]
end

local bird
local bg
local bw,bh

local function check_box_intersection(aa,ab,ac,ad,ba,bb,bc,bd)
    return (
        aa < bc 
        and ac > ba 
        and ab < bd 
        and ad > bb
    )
end

function love.load()
    bird = love.graphics.newImage("bird.png")
    bg = love.graphics.newImage("background.png")
    bw,bh = bird:getDimensions()
end

function love.update()
    bird_pos_y = math.max(0,bird_pos_y + gravity - acceleration)

    if acceleration > 0 then
        acceleration = math.max(0,acceleration - deceleration)
    end

    if bird_pos_y+bird:getHeight() > h then dead = true end

    for k,v in pairs(bariers) do
        bariers[k].x = bariers[k].x - move_speed
        if bariers[k].x + barier_width < 0 then
            bariers[k] = nil
            local exp = min_dist+math.random(dist_range[1],dist_range[2])+i*w
            local d = math.random(barier_distance_range[1],barier_distance_range[2])
            table.insert(bariers,{
                x=exp,
                bdr=d,
                offset = math.random(500,h-500)-d,
                stddst=v.stddst
            })
        end
    end

    if dead then error("You died mf",0) end
end

function love.keypressed(key)
    if key == "w" and acceleration < 1 then
        acceleration = 4
    end
end

function love.draw()
    love.graphics.draw(bg,0,0)
    love.graphics.draw(bird,bird_pos_x,bird_pos_y)

    for k,v in pairs(bariers) do
        local part2 = v.offset+v.bdr

        if check_box_intersection(
            bird_pos_x,
            bird_pos_y,
            bird_pos_x+bw-1,
            bird_pos_y+bh-1,
            v.x,
            1,
            v.x+barier_width-1,
            v.offset+1) or check_box_intersection(
            bird_pos_x,
            bird_pos_y,
            bird_pos_x+bw-1,
            bird_pos_y+bh-1,
            v.x,part2,
            barier_width+v.x-1,
            part2+h) then
            dead = true
        end

        love.graphics.setColor(math.random(),math.random(),math.random())
        love.graphics.rectangle("fill",v.x,1,barier_width,v.offset)
        love.graphics.setColor(math.random(),math.random(),math.random())
        love.graphics.rectangle("fill",v.x,part2,barier_width,h)
        love.graphics.setColor(1,1,1)
    end
end