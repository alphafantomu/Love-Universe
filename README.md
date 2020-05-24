# Love Universe
Love Universe is an object environment engine for the LÖVE framework. What is an object environment engine? An object-oriented system is used to handle game object's individual ancestry, properties, information and data. Very similarly roblox's framework works like this, the engine is intentionally designed to mimick roblox's own framework and libraries with some differences.

### Why was this made?
Solely for fun. Also the game engine I'm writing it for is a bit new and odd to me, so as a learning experience I thought it would be enjoyable to do this in-order to learn about it.

### Status
The skeleton of the engine is complete, the skeleton being object management, custom types, and events (called Ripples). The old-skeleton of the engine can be found at /OldCode, but the more recent version outside of it is more optimized, stable and takes less space. Although things like physics, rendering, camera systems, and all their events will take awhile to program.

The repository is usable, but you would have to finish writing the objects and their properties yourself, `OEE_Import.lua` contains the registration of custom objects and types, along with their properties.

You can see updates [here](https://github.com/alphafantomu/Love-Universe/projects/1)
***When a version is suitable for usage, there will be a new release on the releases page.***

## Features
* Object Environment System (Easier understood as a tree system)
* Custom Typing System (Allows for custom implementation of types)
* Rippling (Roblox implementation/interpretation of event handling)

### Will it be exactly the same as Roblox's framework?
Intentionally, no, it will not. Love2D has different ways of how the engine works compared to Roblox's engine. For instance, Love2D does not have a thread yielding `wait()` function similar to Roblox's `wait()` function, I have actually tried a bit to replicate it into Love2D but yielding actually freezes the entire program/game, unlike Roblox's where `wait()` only yields the thread of the script. It's not impossible however to program one that yields the script, but it would not be the same way as you would write the syntax in Roblox. 

### Similarities and Differences between Love Universe and Roblox
* Data types in Roblox that would be in three dimensions do not have the same syntax in Love Universe, such as `Vector3.new()` in Roblox would be `Vector.new()` in Love Universe instead.
* You're able to modify individual properties of data types instead of recreating them to reindex an object. For instance, to change the x value of a vector you're able to just `Vector.x = 5`, instead of calling `Vector.new(5, 0)` just to change the x value. This is intentional for memory purposes.
* In Roblox you're able to have universes and within those universes, individual places and games. When you play into one of those places and games, the entire engine is being used for that one place/game on your computer. However, Love2D is different and having something like that just isn't really acceptable and is very difficult to replicate in a similar fashion without reopening and closing the program/game. So instead you're able to create any number of Worlds, which is also comparable to places/games in Roblox.
* Roblox's services would be Love Universe's utilities. Referencing to utilities are very similar however, as for something like `game:GetService('HttpService')` you could do `World:GetUtility('Http')`.
