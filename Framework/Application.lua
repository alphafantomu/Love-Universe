
local API = {
    LoveVersion = love.getVersion();
};
local ImageCache = {};
--I'm not sure if Love2D automatically caches objects, but assuming that the wiki said loading an image continously can cause fps drops, I guess not.

API.loadImage = function(self, path) --if the image changes then it will not return the same image
    if (ImageCache[path] == nil) then
        local Image = love.graphics.newImage(path);
        ImageCache[path] = Image;
        return Image;
    end;
    return ImageCache[path];
end;

API.reloadImage = function(self, path)
    local Image = love.graphics.newImage(path);
    ImageCache[path] = Image;
    return Image;
end;

API.getCacheImage = function(self, path)
    return ImageCache[path];
end;

Application = API;