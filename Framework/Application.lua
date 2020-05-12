
local API = {
    LoveVersion = love.getVersion();
};
local ImageCache = {};
--I'm not sure if Love2D automatically caches objects, but assuming that the wiki said loading an image continously can cause fps drops, I guess not.

API.loadImage = function(self, path)
    if (ImageCache[path] == nil) then
        local Image = love.graphics.newImage(path);
        ImageCache[path] = Image;
        return Image;
    end;
end;

API.getCacheImage = function(self, path)
    return ImageCache[path];
end;

Application = API;