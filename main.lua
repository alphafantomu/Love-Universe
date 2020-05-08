
require('OEE_Import');

local CurrentWorld = Object.CurrentWorld;
local Http = CurrentWorld:GetUtility('Http');
local Space = CurrentWorld:GetUtility('Space');

local V = Vector.new(5, 2);
local V1 = Vector.new(1, 2);

local A, B = V.Changed, V1.Changed;
local C = A:connect(function()
    print'hi';
end);
C:Disconnect();
local F = B:connect(function() print'hi2'; end);

local M = Ripple:ManageRipple('Changed');
M:FireProcessorConnections('Vector');
--[[
BlockA.Name = 'Lmao';
BlockB.Name = 'A';
print(BlockA.Name, BlockB.Name);]]

--[[
BlockA.Size = Vector.new(20, 20);
BlockA.Position = Vector.new(500, 300);

local V1 = Vector.new(5, 10);

function love.mousemoved(x, y, dx, dy, istouch)
    BlockB.Position.x = x;
    BlockB.Position.y = y;
    --print(x, y);
    --analyzeBlock(BlockB);
end;

--dt is the change in time, basically.
function love.update(dt) --seems to be a loop, this is equivalent to runtime except it's more of a 2d runtime env rather than a 3d runtime env
    print(love.timer.getFPS());
end;]]
function love.load(args) --although this is called exactly at the beginning of the game, the rest of the game code outside runs first.
    --table.foreach(args, print);
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
end;

function love.draw()
    love.graphics.rectangle("fill", 20, 50, 60, 120 )
end
