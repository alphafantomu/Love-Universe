
--[[
	Notes:

	Love Engine does not support colored outputs in dev console

	Need to improve vectors, colors, etc, add magnitude to vectors
	Add the ability of matrices AFTER YOU LEARN LINEAR ALGEBRA

	wait() and love.timer.sleep() are basically the same, they both freeze the game. We need to develop a method of
	wait() that doesn't involve the game freezing, "fake yielding" should be made
	
	We can identify two kinds of yielding:
	- Passive Yielding > Game still operates, but the rest of the function that the yield occurs doesn't run
	- Aggressive Yielding > Game literally "pauses", everything doesn't really run

	We need passive yielding as that's what wait() in roblox is.

    To-dos:
    - As close to threading while being able to reference anything as close as possible
    - Physics Engine, like collisions, improved vectors etc.
]]

local psuedoOutput = require('psuedoOutput');
local psuedoObjects = require('psuedoObjects');
local psuedoThreading = require('psuedoThreading');
local psuedoEvents = require('psuedoEvents');
local psuedoPhysics = require('psuedoPhysics');
local psuedoLife = require('psuedoWorkspace');
local psuedoMatrixSpace = require('psuedoMatrixSpace');
local psuedoRenderer = require('psuedoRenderer');
local roblox2D = require('roblox2D');

local angle = 0

local CurrentWorld = psuedoLife.CurrentWorld;
local Http = CurrentWorld:GetUtility('Http');
local Space = CurrentWorld:GetUtility('Space');

thread = nil;

BlockA = Instance.new('Block', Space);
	BlockA.Name = "blocka"
	BlockA.Size = Vector.new(20, 20);
	BlockA.Position = Vector.new(500, 300);

BlockB = Instance.new('Block', Space);
	BlockB.Name = "blockb"
	BlockB.Position = Vector.new(10, 10)


PolygonA = Instance.new("Polygon", Space)
	PolygonA.Name = "polygona"
	PolygonA.Position = Vector.new(500, 200)
	PolygonA.Verticies = {{50, 0}, {50, 50}, {0, 50}, {30, 40}}

function love.mousemoved(x, y, dx, dy, istouch)
    BlockA.Position.x = x;
	BlockA.Position.y = y;
    --print(x, y);
    --analyzeBlock(BlockB);
end;

function love.load(args) --although this is called exactly at the beginning of the game, the rest of the game code outside runs first.
    --table.foreach(args, print);
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
end;
--dt is the change in time, basically.
function love.update(dt) --seems to be a loop, this is equivalent to runtime except it's more of a 2d runtime env rather than a 3d runtime env
	psuedoPhysics:update(dt)
end