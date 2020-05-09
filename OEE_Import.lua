
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

--Object Classes--
Object:newClass('World', { --Container for the world, we can have multiple worlds
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'World';
        EditMode = 3;
    };{
        Name = 'GetUtility';
        Generator = false;
        IsCallback = false;
		Default = function(self, utilityClass)
            return Object.Worlds[self].Utilities[utilityClass];
        end;
        EditMode = 1;
    };
}, true);
Object:newClass('Space', { --Physical objects can be shown here and physics are enabled in this object
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Space';
        EditMode = 3;
	};
}, true);
Object:newClass('Time', { --Manages the time for OBJECTS, not time in general, specifically objects that exist in space.
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Time';
        EditMode = 3;
    };
}, true);
Object:newClass('Players', { --What players and their information are created here, only displays players that currently in this world.
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Players';
        EditMode = 3;
    };
}, true);
Object:newClass('Audio', { --Manages audio for the current world.
    {
        Name = 'Name';
        Generator = false;
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
            local RippleObject = Ripple:TearRipple('Touched');
			return Ripple:AttachProcessor(self, 'Touched');
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
        Name = 'CanCollide';
        Generator = false;
        IsCallback = false;
        Default = true;
        EditMode = 3;
	};
	{
        Name = 'Massless';
        Generator = false;
        IsCallback = false;
        Default = true;
        EditMode = 3;
	};
	{
        Name = 'Transparency';
        Generator = false;
        IsCallback = false;
        Default = 0;
        EditMode = 3;
	};
	{
        Name = 'Anchored';
        Generator = true;
        IsCallback = false;
        Default = false;
        EditMode = 3;
    };
    { --Rotation is not a vector as it doesn't rotate in x or y, it only rotates in one direction.
        Name = 'Rotation';
        Generator = false;
        IsCallback = false;
        Default = 0;
        EditMode = 3;
    };
    {
        Name = 'DrawMode';
        Generator = false;
        IsCallback = false;
        Default = 'line';
        EditMode = 3;
    };
    {
        Name = 'Changed';
        Generator = true;
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
        Name = 'Moved';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Moved');
			return Ripple:AttachProcessor(self, 'Moved');
        end;
        EditMode = 1;
    };{
        Name = 'Button1Down';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Button1Down');
            return Ripple:AttachProcessor(self, 'Button1Down');
        end;
        EditMode = 1;
    };{
        Name = 'Button1Up';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Button1Up');
			return Ripple:AttachProcessor(self, 'Button1Up');
        end;
        EditMode = 1;
    };{
        Name = 'Button2Down';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Button2Down');
			return Ripple:AttachProcessor(self, 'Button2Down');
        end;
        EditMode = 1;
    };{
        Name = 'Button2Up';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Button2Up');
			return Ripple:AttachProcessor(self, 'Button2Up');
        end;
        EditMode = 1;
    };{
        Name = 'ButtonDown';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('ButtonDown');
			return Ripple:AttachProcessor(self, 'ButtonDown');
        end;
        EditMode = 1;
    };{
        Name = 'ButtonUp';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('ButtonUp');
			return Ripple:AttachProcessor(self, 'ButtonUp');
        end;
        EditMode = 1;
    };{
        Name = 'Idle';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('Idle');
			return Ripple:AttachProcessor(self, 'Idle');
        end;
        EditMode = 1;
    };{
        Name = 'WheelBackward';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('WheelBackward');
			return Ripple:AttachProcessor(self, 'WheelBackward');
        end;
        EditMode = 1;
    };{
        Name = 'WheelForward';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('WheelForward');
			return Ripple:AttachProcessor(self, 'WheelForward');
        end;
        EditMode = 1;
    };{
        Name = 'WheelLeft';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('WheelLeft');
			return Ripple:AttachProcessor(self, 'WheelLeft');
        end;
        EditMode = 1;
    };{
        Name = 'WheelRight';
        Generator = true;
        IsCallback = false;
        Default = function(self) 
            local RippleObject = Ripple:TearRipple('WheelRight');
			return Ripple:AttachProcessor(self, 'WheelRight');
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
    {
        index = 'Changed';
        function_dependent = true;
        is_callback = false;
        default = function(self)
            local RippleObject = Ripple:TearRipple('Changed');
			return Ripple:AttachProcessor(self, 'Changed');
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
				table.remove(Record, Index);
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

Object.ObjectCreated = Ripple:TearRipple('ObjectCreated');
Object.PropertyChanged = Ripple:TearRipple('PropertyChanged');
Waterfall.TimeChanged = Ripple:TearRipple('TimeChanged');

--We can use Object.PropertyChanged to reverse time.
--Just realized another issue with the connection ugh.
Object.PropertyChanged:connect(function(self, index, value)
    local Changed = self.Changed;
    if (Changed ~= nil and type(Changed):lower() == 'processor') then
        local ClassName = self.ClassName;
        local ManageRipple = Ripple:ManageRipple('Changed');
        ManageRipple:FireRippleProcessorConnections(self, index, value);
    end;
end);

Object.ObjectCreated:connect(function(self)
    local Class = self.ClassName;
    if (Class == 'World' and Object.Worlds[self] == nil) then
        Object.Worlds[self] = {
            Utilities = {};
        };
        --Physics:
    elseif (Class == 'Block') then
        table.insert(Object.Blocks, self);
    end;
end);

Object.CurrentWorld = Object:newObject('World');
for i, v in next, {'Space', 'Time', 'Players', 'Audio'} do
	Object:newObject(v, Object.CurrentWorld);
end;
