
require('Framework/Enumeration');
require('Framework/OptimizerRewrite2');
require('Framework/Object');
require('Framework/Type');
require('Framework/Ripple');
require('Framework/Physics');
require('Framework/Time');
require('Framework/Input');
require('Framework/Application');
require('Visuals/Drawing');
require('Visuals/Waterfall');
require('Visuals/Particle');

Placeholder = function() end;
--Object Classes--
Object:newClass('World', { --Container for the world, we can have multiple worlds
    {
        Name = 'Name';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 'World';
        EditMode = 3;
    };{
        Name = 'SetActive';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, bool)
            if (bool == true) then
                Drawing.RenderWorld = self;
            end;
        end;
        EditMode = 1;
    };{
        Name = 'GetUtility';
        Generator = false;
        Updater = false;
        IsCallback = false;
		Default = function(self, utilityClass)
            return Object.Worlds[self].Utilities[utilityClass];
        end;
        EditMode = 1;
    };{
        Name = 'StartContact';
        Generator = false;
        Updater = false;
        IsCallback = true;
		Default = function(self, ...)
            print('Contact Detected', ...);
        end;
        EditMode = 3;
    };{
        Name = 'EndContact';
        Generator = false;
        Updater = false;
        IsCallback = true;
		Default = function(self, ...)
            print('Contact Ended', ...);
        end;
        EditMode = 3;
    };{
        Name = 'PreCalculations';
        Generator = false;
        Updater = false;
        IsCallback = true;
		Default = function(self, ...)
            print('Precalculations started', ...);
        end;
        EditMode = 3;
    };{
        Name = 'PostCalculations';
        Generator = false;
        Updater = false;
        IsCallback = true;
		Default = function(self, ...)
            print('Postcalculations started', ...);
        end;
        EditMode = 3;
    };
}, true);
Object:newClass('Space', { --Physical objects can be shown here and physics are enabled in this object
    {
        Name = 'Name';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 'Space';
        EditMode = 3;
	};
}, true);
Object:newClass('Time', { --Manages the time for OBJECTS, not time in general, specifically objects that exist in space.
    {
        Name = 'Name';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 'Time';
        EditMode = 3;
    };
}, true);
Object:newClass('Players', { --What players and their information are created here, only displays players that currently in this world.
    {
        Name = 'Name';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 'Players';
        EditMode = 3;
    };
}, true);
Object:newClass('Audio', { --Manages audio for the current world.
    {
        Name = 'Name';
        Generator = false;
        Updater = false;
        IsCallback = false;
        EditMode = 3;
        Default = 'Audio';
    };
}, true);

--GLOBAL UTILITIES BELOW-- These are not meant to be replicated from world to world, but they can.

Object:newClass('Http', {
    {
        Name = 'Name';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 'Http';
        EditMode = 3;
    };
    {
        Name = 'Get';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, url)
            local res = {};
            local responseData,c,d = require('socket.http').request{
                url = url;
                method = 'GET';
                sink = ltn12.sink.table(res);
            };
            print(c, d);
            return table.concat(res, '');
        end;
        EditMode = 1;
    };
    {
        Name = 'Post';
        Generator = false;
        Updater = false;
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
        Updater = false;
        IsCallback = false;
        Default = 'Block';
        EditMode = 3;
    };
    {
        Name = 'Color';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local color = CustomTypes:createType('Color');
            color.r = 255;
            color.g = 255;
			color.b = 255;
			color('attachChange', self, 'Color');
            return color;
        end;
        EditMode = 3;
    };
    {
        Name = 'Size';
        Generator = true;
        Updater = false;
        IsCallback = false;
		Default = function(self)
            local vector = CustomTypes:createType('Vector');
            vector.x = 100;
			vector.y = 100;
			vector('attachChange', self, 'Size');
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Position';
        Generator = true;
        Updater = false;
        IsCallback = false;
		Default = function(self)
			local vector = CustomTypes:createType('Vector');
            vector.x = 0;
			vector.y = 0;
			vector('attachChange', self, 'Position');
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Touched';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Touched');
			return Ripple:AttachProcessor(self, 'Touched');
        end;
        EditMode = 1;
    };
    {
        Name = 'Velocity';
        Generator = true;
        Updater = false;
        IsCallback = false;
		Default = function(self) 
            local vector = CustomTypes:createType('Vector');
            vector.x = 0;
			vector.y = 0;
			vector('attachChange', self, 'Velocity');
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'CanCollide';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = true;
        EditMode = 3;
	};
	{
        Name = 'Massless';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = true;
        EditMode = 3;
	};
	{
        Name = 'Transparency';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 0;
        EditMode = 3;
	};
	{
        Name = 'Anchored';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = false;
        EditMode = 3;
    };
    { --Rotation is not a vector as it doesn't rotate in x or y, it only rotates in one direction.
        Name = 'Rotation';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 0;
        EditMode = 3;
    };
    {
        Name = 'DrawMode';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = 'line';
        EditMode = 3;
    };
    {
        Name = 'Changed';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self)
			local RippleObject = Ripple:TearRipple('Changed');
			return Ripple:AttachProcessor(self, 'Changed');
        end;
        EditMode = 1;
    };
}, false);

Object:newClass('Mouse', {
    {
        Name = 'Hit';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self)
            local X, Y = love.mouse.getPosition();
            local vector = CustomTypes:createType('Vector');
            vector.x = X;
			vector.y = Y;
			vector('lock', 'x', 'y');
            return vector;
        end;
        EditMode = 1;
    };{
        Name = 'Confined';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = love.mouse.isGrabbed();
        EditMode = 3;
    };{
        Name = 'Visible';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = love.mouse.isVisible();
        EditMode = 3;
    };{
        Name = 'RelativeMode';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = love.mouse.getRelativeMode();
        EditMode = 3;
    };{
        Name = 'Move';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, x, y) 
            assert(tonumber(x) ~= nil and tonumber(y) ~= nil, 'Cannot move cursor to a value other than a number')
            love.mouse.setPosition(x, y);
            local Hit = self.Hit;
            CustomTypes:forceNewIndex(Hit, 'x', x);
            CustomTypes:forceNewIndex(Hit, 'y', y);
        end;
        EditMode = 1;
    };{
        Name = 'IsDown';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, ...) 
            return love.mouse.isDown(...);
        end;
        EditMode = 1;
    };{
        Name = 'SetIcon';
        Generator = false;
        Updater = false;
        IsCallback = false;
		Default = function(self, imagePath)
			Drawing.MouseIcon = Application:loadImage(imagePath);
        end;
        EditMode = 1;
    };{
        Name = 'Target'; --wip
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = false;
        EditMode = 1;
    };{
        Name = 'Moved';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Moved');
			return Ripple:AttachProcessor(self, 'Moved');
        end;
        EditMode = 1;
    };{
        Name = 'ButtonDown';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('ButtonDown');
			return Ripple:AttachProcessor(self, 'ButtonDown');
        end;
        EditMode = 1;
    };{
        Name = 'ButtonUp';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('ButtonUp');
			return Ripple:AttachProcessor(self, 'ButtonUp');
        end;
        EditMode = 1;
    };{
        Name = 'Idle';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Idle');
			return Ripple:AttachProcessor(self, 'Idle');
        end;
        EditMode = 1;
    };{
        Name = 'WheelMoved';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('WheelMoved');
			return Ripple:AttachProcessor(self, 'WheelMoved');
        end;
        EditMode = 1;
    };
}, false);

Object:newClass('Keyboard', { --enable or disable text inputs, and key to scancode vice versa
    {
        Name = 'ScancodeToKey';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, scancode) 
            return love.keyboard.getKeyFromScancode(scancode);
        end;
        EditMode = 1;
    };{
        Name = 'KeyToScancode';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, key) 
            return love.keyboard.getScancodeFromKey(key);
        end;
        EditMode = 1;
    };{
        Name = 'HoldToRepeat';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = love.keyboard.hasKeyRepeat();
        EditMode = 3;
    };{
        Name = 'TextInputEnabled';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = love.keyboard.hasTextInput();
        EditMode = 3;
    };{
        Name = 'ScreenKeyboardEnabled';
        Generator = false;
        Updater = true;
        IsCallback = false;
        Default = function(self) return love.keyboard.hasScreenKeyboard(); end;
        EditMode = 1;
    };{
        Name = 'IsKeyDown';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, key) 
            return love.keyboard.isDown(key);
        end;
        EditMode = 1;
    };{
        Name = 'IsScancodeDown';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, ...) 
            return love.keyboard.isScancodeDown(...);
        end;
        EditMode = 1;
    };{
        Name = 'InputDown';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('InputDown');
			return Ripple:AttachProcessor(self, 'InputDown');
        end;
        EditMode = 1;
    };{
        Name = 'InputUp';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('InputUp');
			return Ripple:AttachProcessor(self, 'InputUp');
        end;
        EditMode = 1;
    };{
        Name = 'InputTyped';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('InputTyped');
			return Ripple:AttachProcessor(self, 'InputTyped');
        end;
        EditMode = 1;
    };
}, false);

Object:newClass('Touchscreen', {
    {
        Name = 'GetActiveTouchPresses';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            return love.touch.getTouches();
        end;
        EditMode = 1;
    };{
        Name = 'GetPressureById';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, id) 
            return love.touch.getPressure(id);
        end;
        EditMode = 1;
    };{
        Name = 'GetPositionById';
        Generator = false;
        Updater = false;
        IsCallback = false;
        Default = function(self, id) 
            return love.touch.getPosition(id);
        end;
        EditMode = 1;
    };{
        Name = 'Moved';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Moved');
			return Ripple:AttachProcessor(self, 'Moved');
        end;
        EditMode = 1;
    };{
        Name = 'InputDown';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('InputDown');
			return Ripple:AttachProcessor(self, 'InputDown');
        end;
        EditMode = 1;
    };{
        Name = 'InputUp';
        Generator = true;
        Updater = false;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('InputUp');
			return Ripple:AttachProcessor(self, 'InputUp');
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
			local RippleData = Ripple.Ripples[self.Name];
			assert(RippleData ~= nil, 'Ripple data not found');
            local Connection = CustomTypes:createType('Connection');
            local Manager = Ripple:ManageConnection(Connection);
            if (Ripple.Mode == 1) then
                CustomTypes:forceNewIndex(Connection, 'LoveId', Object:generateUnique(25));
			end;
			Manager:SetCallback(callback); --manages the love handler too
			CustomTypes:forceNewIndex(Connection, 'Connected', true);
			table.insert(RippleData.Connections, Connection);
            return Connection;
        end;
    };
    {index = 'wait';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = function(self, callback)
            
        end;
    };
}, {});

CustomTypes:newType('Processor', {
    {index = 'Ripple';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = false;
	};
	{index = 'Object';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = false;
    };
    {index = 'connect';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
		default = function(self, callback)
            local RippleData = Ripple.Ripples[self.Ripple.Name];
			local ClassObject = self.Object;
			if (RippleData ~= false and ClassObject ~= false) then
				local Processors = RippleData.Processors;
				local ClassProcessor = Processors[ClassObject.ClassName];
				if (ClassProcessor ~= nil) then
					local Connection = CustomTypes:createType('Connection');
					local Manager = Ripple:ManageConnection(Connection);
					if (Ripple.Mode == 1) then
						CustomTypes:forceNewIndex(Connection, 'LoveId', Object:generateUnique(25));
					end;
                    Manager:SetCallback(callback);
                    local ProcessorObject = Ripple:GetProcessorObject(ClassObject);
					local ClassProcessorIndex, RippleConnectionIndex = #ClassProcessor + 1, #RippleData.Connections + 1;
					table.insert(Manager.Records, {ClassProcessor, ClassProcessorIndex});
                    table.insert(Manager.Records, {RippleData.Connections, RippleConnectionIndex});
                    if (ProcessorObject ~= nil) then
                        local ProcessorRipple = ProcessorObject[self.Ripple.Name];
                        if (ProcessorRipple ~= nil) then
                            local ProcessorRippleIndex = #ProcessorRipple + 1;
                            table.insert(Manager.Records, {ProcessorRipple, ProcessorRippleIndex});
                            table.insert(ProcessorRipple, Connection);
                            if (ProcessorRipple[ProcessorRippleIndex] ~= Connection) then
                                print('There was an error calculating the processor ripple index');
                            end;
                        end;
                    end;
					table.insert(ClassProcessor, Connection);
					if (ClassProcessor[ClassProcessorIndex] ~= Connection) then
						print('There was an error calculating the class connection index');
					end;
					table.insert(RippleData.Connections, Connection);
					if (RippleData.Connections[RippleConnectionIndex] ~= Connection) then
						print('There was an error calculating the ripple connection index');
					end;
					CustomTypes:forceNewIndex(Connection, 'Connected', true);
					return Connection;
				end;
			end;
        end;
    };
    {index = 'wait';
		function_dependent = false;
		is_callback = false;
        edit_mode = 1;
        default = function(self, callback)
            
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
			local Records = Manager.Records;
			for i = 1, #Records do
				local RecordData = Records[i];
                local Record, Index = unpack(RecordData);
                Record[Index] = nil; --applying table.remove will shift the indexes down, we don't want that as it makes our calculations wrong.
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

local OnChanged = {
    Mouse = function(self, index, value)
        if (type(index):lower() == 'string') then
            if (index == 'Confined') then
                love.mouse.setGrab(value);
            elseif (index == 'Visible') then
                love.mouse.setVisible(value);
            elseif (index == 'RelativeMode') then
                love.mouse.setVisible(value);
            elseif (index == 'HoldToRepeat') then
                love.keyboard.setKeyRepeat(value);
            end;
        end;
    end;
    Keyboard = function(self, index, value)
        if (type(index):lower() == 'string') then
            if (index == 'HoldToRepeat') then
                love.keyboard.setKeyRepeat(value);
            elseif (index == 'TextInputEnabled') then
                love.keyboard.setTextInput(value);
            end;
        end;
	end;
	World = function(self, index, value)
		if (type(index):lower() == 'string') then
            if (index == 'StartContact' or index == 'EndContact' or index == 'PreCalculations' or index == 'PostCalculations') then
                Physics:UpdateUniverseObject(self, index, value);
            end;
        end;
    end;
	Block = function(self, index, value)
        Physics:UpdateUniverseObject(self, index, value);
    end;
};

Object.ObjectCreated = Ripple:TearRipple('ObjectCreated');
Object.ObjectDestroyed = Ripple:TearRipple('ObjectDestroyed');
Object.PropertyChanged = Ripple:TearRipple('PropertyChanged');
Waterfall.TimeChanged = Ripple:TearRipple('TimeChanged');

--We can use Object.PropertyChanged to reverse time.
--Just realized another issue with the connection ugh.
Object.PropertyChanged:connect(function(self, index, value) --this occurs after it has been changed
    local Changed = self.Changed;
    if (Changed ~= nil and type(Changed):lower() == 'processor') then
        local ClassName = self.ClassName;
        local ManageRipple = Ripple:ManageRipple('Changed');
        ManageRipple:FireRippleProcessorConnections(self, index, value);
	end;
    if (OnChanged[self.ClassName] ~= nil) then
        OnChanged[self.ClassName](self, index, value);
    end;
end);

Object.ObjectCreated:connect(function(self)
    local Class = self.ClassName;
    Physics:RegisterUniverseObject(self);
    if (Class == 'World' and Object.Worlds[self] == nil) then
        Object.Worlds[self] = {
            Utilities = {};
        };
    end;
end);

Object.ObjectDestroyed:connect(function(self)

end);

Object.CurrentWorld = Object:newObject('World');
for i, v in next, {'Space', 'Time', 'Players', 'Audio'} do
	Object:newObject(v, Object.CurrentWorld);
end;
