
--[[
	We're going to use Love2D's default physics handler to utilize with our objects, but have to break down how we're going to do it first.
	
	RenderWorld - Current active world that will be rendered in-game

	Let's establish the roles of each script to Physics.

	Waterfall.lua updates the RenderWorld
	Drawing.lua renders objects and RenderWorld, does calculations for how far to see within the world
	Physics.lua manages the gateway between Universe Objects and Love Objects

	Issue I'm trying to figure out is: 
	‣ I need to somehow implement descendants so I can just render whole Space utilities
    ‣ Figure out the makings of body, fixture and shape into a PhysicsObjectReference
    
    Definitely something weird with Body, Fixtures and Shape.
    https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks
    https://love2d.org/wiki/love.physics
    https://love2d.org/forums/viewtopic.php?t=76193
    https://love2d.org/wiki/Tutorial:Drawing_Order
]]
local API = {};
local Data = {};
local ReverseLoveLookup = {};

API.GetPhysicsObjectReference = function(self, UniverseObject)
	return Data[UniverseObject];
end;

API.GetLoveObjectReference = function(self, LoveObject)
    return ReverseLoveLookup[LoveObject];
end;

API.UpdateUniverseObject = function(self, UniverseObject, index, value)
    local ClassName = UniverseObject.ClassName;
    local Reference = self:GetPhysicsObjectReference(UniverseObject);
    if (Reference ~= nil) then
        if (ClassName == 'Block') then
            if (index == 'Position') then
                local Body = Reference.Body;
                if (Body ~= nil) then
                    Body:setX(value.x);
                    Body:setY(value.y);
                else print('Attempt to move position with no body');
                end;
            elseif (index == 'Size') then --something about size is not being optimized
                local Body, Shape, Fixture = Reference.Body, Reference.Shape, Reference.Fixture;
                if (Body ~= nil) then
                    if (Fixture ~= nil and Shape ~= nil) then --releasing causes unbearable lag for Love, use destroy if possible
                        Fixture:destroy();
                        Shape:release();
                        Reference.Shape = love.physics.newRectangleShape(value.x, value.y);
                        Reference.Fixture = love.physics.newFixture(Body, Reference.Shape);
                    end;
                else print('Attempt to change size with no body');
                end;
            elseif (index == 'Parent') then
                if (Reference.Body == nil and Reference.Shape == nil and Reference.Fixture == nil and value ~= nil) then --part has not been set up yet
                    local LocalWorld, TargetWorld = Object:getFirstAncestor(UniverseObject), Object:getFirstAncestor(value);
                    if (LocalWorld == TargetWorld) then
                        local BlendWorld = LocalWorld or TargetWorld;
                        local BlendPhysicsData = self:GetPhysicsObjectReference(BlendWorld);
                        if (BlendPhysicsData ~= nil and BlendPhysicsData.LoveObject ~= nil) then
                            local LoveObject = BlendPhysicsData.LoveObject;
                            local Position, Size = UniverseObject.Position, UniverseObject.Size;
                            local Body = love.physics.newBody(LoveObject, Position.x, Position.y, 'static');
                            local Shape = love.physics.newRectangleShape(Size.x, Size.y);
                            local Fixture = love.physics.newFixture(Body, Shape);
                            Reference.Body, Reference.Shape, Reference.Fixture = Body, Shape, Fixture;
                        else print('Physics data for world not found?');
                        end;
                    else print('Weird, local and target worlds are different?')
                    end;
                end;
                
            end;
        elseif (ClassName == 'World') then
            local LoveObject = Reference.LoveObject;
            assert(LoveObject ~= nil, 'World Love Object not found');
            local beginContact, endContact, preSolve, postSolve = LoveObject:getCallbacks();
            if (UniverseObject.StartContact ~= beginContact or
                UniverseObject.EndContact ~= endContact or
                UniverseObject.PreCalculations ~= preSolve or
                UniverseObject.PostCalculations ~= postSolve) then
            LoveObject:setCallbacks(
                UniverseObject.StartContact or Placeholder, 
                UniverseObject.EndContact or Placeholder, 
                UniverseObject.PreCalculations or Placeholder, 
                UniverseObject.PostCalculations or Placeholder);
            end;
        end;
    end;
end;

--[[
    A block is connected to a body, shape and fixture
    When the block position updates, body will be updated with it's new position, shape and fixture will be the same
    When the block size updates, fixture and shape will have to be recreated and destroyed, body still exists in the world
    When the block changes parent of a different world, body and fixture will be destroyed and recreated, shape does not change

    local Size = UniverseObject.Size;
            local Body = love.physics.newBody();

            local Shape = love.physics.newRectangleShape(Size.x, Size.y);
            local Fixture = love.physics.newFixture(Shape);
]]

API.RegisterUniverseObject = function(self, UniverseObject)
	local ClassName = UniverseObject.ClassName;
	if (ClassName == 'World') then
		local LoveObject = love.physics.newWorld(0, 9.8 * love.physics.getMeter(), true);
		LoveObject:setCallbacks(
			UniverseObject.StartContact or Placeholder, 
			UniverseObject.EndContact or Placeholder, 
			UniverseObject.PreCalculations or Placeholder, 
            UniverseObject.PostCalculations or Placeholder);
        ReverseLoveLookup[LoveObject] = UniverseObject;
		Data[UniverseObject] = {
			LoveObject = LoveObject;
		};
    elseif (ClassName == 'Block') then
        if (UniverseObject.Parent ~= nil) then
            local Parent = UniverseObject.Parent;

        end;
        Data[UniverseObject] = {};
	end;
end;

API.UpdateRenderWorld = function(self, dt) --only physics calculations for the world should be active
	local RenderWorld = Drawing.RenderWorld;
	local PhysicsData = self:GetPhysicsObjectReference(RenderWorld);
	if (PhysicsData ~= nil) then
		local LoveObject = PhysicsData.LoveObject;
		LoveObject:update(dt);
	end;
end;

Physics = API;