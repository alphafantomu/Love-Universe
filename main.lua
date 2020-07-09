
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
CurrentWorld:SetActive(true);
local Space = CurrentWorld:GetUtility('Space');

local Input = Object:newObject('Mouse'); --Input:SetIcon('Assets/Ishtar Avenger 4.png');
local Keyboard = Object:newObject('Keyboard');

local Part = Instance.new('Block', Space);

local Object = {};
local Container = {};

for i = 1, 100 do
    if (i ~= 53) then
    Container[i] = Object;
    end;
end;
Optimizer:Optimize(Container);
local Data = Optimizer:ReceiveData(Container);
for i = 1, #Data do
    local Section = Data[i];
    print('__________'..tostring(Section)..'_____________');
    table.foreach(Section, print);
    print'_______________________';
end;
Container[9.5] = Object;
--[[
local timer = os.clock();
print(table.maxn(Container));
print(os.clock() - timer)

local timer1 = os.clock();
print(Optimizer:maxn(Container));
print(os.clock() - timer1);
]]
Input.Moved:connect(function(x, y, dx, dy)
    Part.Position.x = x;
    Part.Position.y = y;
    Part.Size.x = math.random(5, 250);
    
end)

Waterfall.TimeChanged:connect(function(dt)
    if (Part.Parent == Space) then Part.Parent = nil; elseif (Part.Parent == nil) then Part.Parent = Space; end;
end);
--Part.Parent = nil;
Part.Position.x = 250;

function love.load(args) --although this is called exactly at the beginning of the game, the rest of the game code outside runs first.
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
end;

