
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

local Input = Object:newObject('Mouse');
local Keyboard = Object:newObject('Keyboard');
Keyboard.InputDown:connect(function(...) print(...) end);
--print(love.keyboard.setKeyRepeat(true))

function love.load(args) --although this is called exactly at the beginning of the game, the rest of the game code outside runs first.
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
end;

