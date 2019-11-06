
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
local psuedoRenderer = require('psuedoRenderer');
local roblox2D = require('roblox2D')

local CurrentWorld = psuedoLife.CurrentWorld;
local Http = CurrentWorld:GetUtility('Http');
local Space = CurrentWorld:GetUtility('Space');

local Block = psuedoLife:newObject('Block', Space);
local Event = Block.Touched;
local Signal = Event:connect(function(a, b)
    print("Signal works!", a, b);
end);

local EventData = psuedoEvents:getEvent(Event);
local Remote = EventData.Remote;
Remote:FireAll(5, 'a');
Signal:disconnect();
Remote:FireAll(7, 'b');
print'success';

local CountedFPS = 0;
local currentTime = 0;
--[[
local str = 'bbbbb';
local loveEventExists = function(s)
    local ran, result = pcall(function()
        return love.handlers[s] ~= nil;
    end);
    return ran;
end;
love.handlers[str] = function()
    print'found';
end;
print(loveEventExists(str))
love.handlers[str] = nil;
print(loveEventExists(str))]]
function love.load(args) --although this is called exactly at the beginning of the game, the rest of the game code outside runs first.
    --table.foreach(args, print);
end;
--dt is the change in time, basically.
function love.update(dt) --seems to be a loop, this is equivalent to runtime except it's more of a 2d runtime env rather than a 3d runtime env
    currentTime = currentTime + dt;
    if (currentTime >= 1) then
        print(CountedFPS * (1/1), love.timer.getFPS());
        CountedFPS = 0;
        currentTime = 0;
    end;
    CountedFPS = CountedFPS + 1;
   -- print(dt);
   
   -- Block.Position.x = Block.Position.x + .01;
	--[[Block2.Position.y = Block2.Position.y + 1;
	Block3.Position.x = Block3.Position.x + 1;
	Block3.Position.y = Block3.Position.y + 1;]]
	--love.timer.sleep(60);
	--Block.Rotation = Block.Rotation + .001;
	--print(Block.Rotation);
	--print(Block.Rotation);
	--print(Block.Position == Block2.Position);
	--print(Block.Position.x, Block2.Position.x, Block.Position.x == Block2.Position.x)
	--Block2.Position.y = Block2.Position.y + 1;
	--[[Block.Type = 'fill'
	Block.Position.x = Block.Position.x + 1;
	Block2.Position.x = Block2.Position.x + 5;]]
end
-- Draw a coloured rectangle.
