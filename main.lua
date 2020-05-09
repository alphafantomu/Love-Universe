
--[[
    ‣ Concepts

    I think I have to be careful with my block physics, because there are different types of 2D games
    ‣ 2D Scroller (Left to Right vice versa)
    ‣ Top-down Dungeons
    ‣ UI-Dependent
    ‣ Psuedo-3D
        ‣ 2D Scroller
            ‣ Blocks can be anchored and solid, it doesn't really matter as the character will always collide with the block.
        
        ‣ Top-down Dungeons
            ‣ If blocks are in the right place, anchoring and soliding the blocks should not be an issue.

        ‣ UI-Dependent
            ‣ Blocks should work just fine

        ‣ Psuedo-3D
            ‣ Having psuedo-3d blocks is like me having the ability to create a quantum computer, aka it's beyond me.

    ‣ Physics
        ‣ First we need to calculate whether the object is touching another object. This can be intensely complicated.
        ‣ Circle, probably the easiest way to calculate if an object is interacting with it as it's easily described as a function.
        ‣ Square/Rectangle, a bit more difficult as it does not use a function
        ‣ Arc, potentially easier as you can use it to describe part of a function.
        ‣ Quadrilaterals, gonna have to use my big brain for this one.
        ‣ Ellipse, described as a formula
        ‣ Mesh, no clue.
        ‣ ArrayImage, no clue.
        ‣ Line, easy.
        ‣ Point, easy.
        ‣ Polygon, death.
        ‣ Stencils, no clue.
        ‣ Triangle, maybe? dunno.
]]

require('OEE_Import');

local CurrentWorld = Object.CurrentWorld;
local Http = CurrentWorld:GetUtility('Http');
local Space = CurrentWorld:GetUtility('Space');

local Block = Instance.new('Block', Space);
Block.Changed:connect(function(index, value)
    print('For object Block', index, 'was changed to', value);
end);
Block.Name = 'a';

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

