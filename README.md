# Love Universe
Love Universe is an pseudo-game/physics engine for the LÖVE framework.
Love Universe provides a tree system for object handling similarly to that of the tree system that Roblox has. Although there are differences, it was intended to be similar for ease of use for users used to Roblox's tree system, however there are some major differences.

### Why was this made?
Solely for fun.

### Status
Basic infrastructure of the engine is still a work in progress, such as the tree system and the physics + rendering. Not all necessary classes have been made
and not all neat events exist yet. Soo, you probably shouldn't use this yet.

## Features
* Tree System (Parenting, Properties, Callbacks, Functions, and Events etc)
* Rendering (Renders objects inside Space)
* Type System (Allows for custom implementation of types)

### Similarities and Differences between Love Universe and Roblox
Currently, Love Universe does not have enumerations implemented. 
Creating new objects are different Roblox and Love Universe, since one engine is three dimensional and
the other is two dimensional, the reference for vectors are different, and for colors too. To reduce memory usage,
in Love Universe you can modify individual values, such as x and y, instead of like in Roblox you would have to
create a new object entirely.

Roblox:
```lua
local Vector = Vector3.new(5, 2, 3);
```

Love Universe:
```lua
local psuedoObjects = require('psuedoObjects');
local Vector = Vector2.new(5, 2); --there's no z axis on a 2 dimensional vector.
local Vector2 = psuedoObjects:createType('Vector');
Vector2.x = 5;
Vector2.y = 2;
```

Love Universe does not have "services", instead we have objects called "utilities", however calling to get them is similar in both engines.
Roblox has places, however we have something called "worlds" which are similar, except worlds are essentially scenes, whereas scenes are usually inside a place.
However worlds can be used like places as well, for instance you can have your character transport from a lobby to a dungeon using places or worlds.

Roblox:
```lua
local Workspace = game:GetService('Workspace');
local SecondReference = game.Workspace;
print(Workspace == SecondReference); --prints true
```

Love Universe:
```lua
local OurWorld = World.new()
local Space = OurWorld:GetUtility('Space');
local SecondReference = OurWorld.Space;
print(Space == SecondReference); --this also prints true
```


