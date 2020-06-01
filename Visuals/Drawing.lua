
local API = {
    MouseIcon = nil;
    RenderWorld = nil;
};

API.IsPartOfRenderWorld = function(self, UniverseObject)
    local World = Object:getFirstAncestor(UniverseObject);
    if (World ~= nil and self.RenderWorld ~= nil) then
        return self.RenderWorld:GetUtility('Space') == World:GetUtility('Space');
    end;
    return false;
end;

API.RenderObject = function(self, UniverseObject, RenderWorldCheck)
    local Reference = Physics:GetPhysicsObjectReference(UniverseObject);
    local ClassName = UniverseObject.ClassName;
    if (Reference ~= nil) then
        if ((RenderWorldCheck == nil or RenderWorldCheck == false) or (RenderWorldCheck == true and self:IsPartOfRenderWorld(UniverseObject) == true)) then
            if (ClassName == 'Block' and Reference.Body ~= nil and Reference.Shape ~= nil and Reference.Fixture ~= nil) then
                love.graphics.polygon('line', Reference.Body:getWorldPoints(Reference.Shape:getPoints()));
            end;
        end;
	end;
end;

API.StopRenderWorld = function(self) 
    if (self.RenderWorld ~= nil) then
        self.RenderWorld = nil;
    end;
end;

API.RenderRenderWorld = function(self)
	local RenderWorld = self.RenderWorld;
    if (RenderWorld ~= nil) then
        local Space = RenderWorld:GetUtility('Space');
        if (Space ~= nil) then
            local Descendants = Space:GetDescendants();
            for i = 1, #Descendants do
                local Descendant = Descendants[i];
                self:RenderObject(Descendant);
            end;
        end;
	end;
end;

love.draw = function()
    if (API.RenderWorld ~= nil) then
        API:RenderRenderWorld();
    end;
    if (API.MouseIcon ~= nil) then
        love.graphics.draw(API.MouseIcon, love.mouse.getPosition());
    end;
    love.graphics.print(love.timer.getFPS(), 20, 50);
end;

Drawing = API;