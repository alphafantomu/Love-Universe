
require('Framework/Object');
require('Framework/Type');
require('Framework/Ripple');
require('Framework/Time');
require('Visuals/Drawing');
require('Visuals/Waterfall');

--Object Classes--
Object:newClass('World', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'World';
        EditMode = 3;
    };
    {
        Name = 'GetUtility';
        Generator = false;
        IsCallback = false;
		Default = function(self, utilityClass)
            return Object.Worlds[self].Utilities[utilityClass];
        end;
        EditMode = 1;
    };
}, true);
Object:newClass('Space', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Space';
        EditMode = 3;
    };
}, true);
Object:newClass('Time', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Time';
        EditMode = 3;
    };
}, true);
Object:newClass('Players', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Players';
        EditMode = 3;
    };
}, true);
Object:newClass('Storage', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Storage';
        EditMode = 3;
    };
}, true);
Object:newClass('Database', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Database';
        EditMode = 3;
    };
}, true);
Object:newClass('Audio', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        EditMode = 3;
        Default = 'Audio';
    };
}, true);
Object:newClass('Window', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Window';
        EditMode = 3;
    };
    {
        Name = 'Close';
        Generator = false;
        Default = function(self)
            return love.window.close();
        end;
    };
}, true);
Object:newClass('Http', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Http';
        EditMode = 3;
    };
    {
        Name = 'Get';
        Generator = false;
        IsCallback = false;
        Default = function(self, url)
            local res = {};
            local responseData = http.request{
                url = url;
                method = 'GET';
                sink = ltn12.sink.table(res);
            };
            return table.concat(res, '');
        end;
        EditMode = 1;
    };
    {
        Name = 'Post';
        Generator = false;
        IsCallback = false;
        Default = function(self, url, body)
            local res = {};
            local responseData = http.request{
                url = url;
                method = 'POST';
                source = ltn12.source.string(body);
                sink = ltn12.sink.table(res);
            };
            return table.concat(res, '');
        end;
        EditMode = 1;
    };
}, true);

--------------------------------------Objects-----------------------------------------

Object:newClass('Block', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Block';
        EditMode = 3;
    };
    {
        Name = 'Color';
        Generator = true;
        IsCallback = false;
        Default = function() 
            local color = CustomTypes:createType('Color');
            color.r = 255;
            color.g = 255;
            color.b = 255;
            return color;
        end;
        EditMode = 3;
    };
    {
        Name = 'Size';
        Generator = true;
        IsCallback = false;
		Default = function()
            local vector = CustomTypes:createType('Vector');
            vector.x = 100;
            vector.y = 100;
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Position';
        Generator = true;
        IsCallback = false;
		Default = function()
			local vector = CustomTypes:createType('Vector');
            vector.x = 0;
            vector.y = 0;
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Touched';
        Generator = true;
        IsCallback = false;
        Default = function() 
            return CustomTypes:createType('Event');
        end;
        EditMode = 1;
    };
    {
        Name = 'Velocity';
        Generator = true;
        IsCallback = false;
		Default = function() 
            local vector = CustomTypes:createType('Vector');
            vector.x = 0;
            vector.y = 0;
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Collidable';
        Generator = true;
        IsCallback = false;
        Default = true;
        EditMode = 3;
     };
    {
        Name = 'Rotation';
        Generator = false;
        IsCallback = false;
        Default = 0;
        EditMode = 3;
    };
    {
        Name = 'Type';
        Generator = false;
        IsCallback = false;
        Default = 'line';
        EditMode = 3;
    };
    {
        Name = 'Moved';
        Generator = false; --generates a new value by firing Default() every time if default is a function
        IsCallback = false;
        Default = function(self)
            return Ripple:TearRipple('Moved');
        end;
        EditMode = 1;
    };
}, false);

--Custom Types--

CustomTypes:newType('Vector', {
    {
        index = 'x';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'y';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'Magnitude';
        function_dependent = true;
        is_callback = false;
        default = function(self)
            return math.sqrt(self.x^2 + self.y^2);
        end;
        edit_mode = 1;
    };
}, {
    __add = function(vector1, vector2)
        if (type(vector1):lower() == 'vector' and type(vector2):lower() == type(vector1):lower()) then
            return Vector.new(vector1.x + vector2.x, vector1.y + vector2.y);
        end;
    end;
    __sub = function(vector1, vector2)
        if (type(vector1):lower() == 'vector' and type(vector2):lower() == type(vector1):lower()) then
            return Vector.new(vector1.x - vector2.x, vector1.y - vector2.y);
        end;
    end;
    --[[__mul = function(vector1, vector2) this is some complicated shit, we would have to define the existence of a vector

    end;
    __div = function(vector1, vector2)

    end;]]
});

CustomTypes:newType('Color', {
    {
        index = 'r';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'g';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'b';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
}, {});


--Rippling--

CustomTypes:newType('Ripple', {
    {index = 'Name';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = 'Ripple';
    };
    {index = 'connect';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = function(self, callback)
            assert(Ripple.Ripples[self.Name] ~= nil, 'Ripple data not found');
            local Connection = CustomTypes:createType('Connection');
            local Manager = Ripple:ManageConnection(Connection);
            table.insert(Ripple.Ripples[self.Name].Connections, Connection);
            if (Ripple.Mode == 1) then
                CustomTypes:forceNewIndex(Connection, 'LoveId', Object:generateUnique(25));
			end;
			Manager:SetCallback(callback); --manages the love handler too
			CustomTypes:forceNewIndex(Connection, 'Connected', true);
            return Connection;
        end;
    };
    {index = 'wait';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = function(self)
            
        end;
    };
}, {});

CustomTypes:newType('Connection', {
    {index = 'Connected';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = false;
    };
    {index = 'LoveId';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = false;
    };
    {index = 'Disconnect';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = function(self)
            local Manager = Ripple:ManageConnection(self);
            Manager:SetCallback(nil);
			CustomTypes:forceNewIndex(self, 'Connected', false);
			if (Ripple.Mode == 1) then
				love.handlers[self.LoveId] = nil;
			end;
        end;
    };
}, {});


--Time Handlers--

CustomTypes:newType('Timer', {
	{index = 'Started';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = false;
	};
	{index = 'TimePassed';
		function_dependent = false;
		is_callback = false;
        edit_mode = 3;
        default = 0;
    };
    {index = 'Start';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = function(self, s, callback, ...)
			local Event = Waterfall.TimeChanged;
			local Passed, Connection = false, nil;
			local Args = {...};
			CustomTypes:forceNewIndex(self, 'Started', true);
			Connection = Event:connect(function(dt)
				self.TimePassed = self.TimePassed + dt;
				if (self.Started == false) then
					self.Timepassed = 0;
					Passed = true;
					Connection:Disconnect();
				end;
				if (self.TimePassed >= s and Passed == false) then
					Passed = true;
					callback(unpack(Args));
					Connection:Disconnect();
					CustomTypes:forceNewIndex(self, 'Started', false);
					Passed = false;
				end;
			end);
        end;
    };
    {index = 'Restart';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
		default = function(self, s, callback, ...)
			self:Stop();
            self:Start(s, callback, ...);
        end;
	};
	{index = 'Stop';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
		default = function(self)
			CustomTypes:forceNewIndex(self, 'Started', false);
			self.TimePassed = 0;
        end;
    };
}, {});

--Custom Environment Handlers--

Instance = setmetatable({
    new = function(className, parent)
        return Object:newObject(className, parent);
    end;
}, {
    __newindex = function(self, index, value)
        return nil;
    end;
    __metatable = 'Locked';
});

Vector = setmetatable({
    new = function(x, y)
        local obj = CustomTypes:createType('Vector');
        obj.x = x;
        obj.y = y;
        return obj;
    end;
}, {
    __newindex = function(self, index, value)
        return nil;
    end;
    __metatable = 'Locked';
});

Color = setmetatable({
    new = function(r, g, b)
        local obj = CustomTypes:createType('Color');
        obj.r = r;
        obj.g = g;
        obj.b = b;
        return obj;
    end;
}, {
    __newindex = function(self, index, value)
        return nil;
    end;
    __metatable = 'Locked';
});

--Inits--
Object.CurrentWorld = Object:newObject('World');
for i, v in next, {'Space', 'Time', 'Players', 'Storage', 'Database', 'Http'} do
	Object:newObject(v, Object.CurrentWorld);
end;

Waterfall.TimeChanged = Ripple:TearRipple('TimeChanged');