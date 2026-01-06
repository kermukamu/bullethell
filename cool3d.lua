-- cool3d "class"
local Cool3d = {}
Cool3d.__index = Cool3d

function Cool3d.new(debugmode)
	local self = setmetatable({}, Cool3d)
	self.debugmode = debugmode

	self.points = {} -- AKA vertices
	self.lines = {}
	self.lineWidth = 1
	self.dz = 1
	self.dt = 0 -- Used for synchronizing drawing, gets updated in update()
	self.angle = 0
    self.rotSpeed = 0.5 -- Speed of rotation
    self.timer = 0
    self.zSpeed = 1 -- Speed of z variation

	return self
end

function Cool3d:readFile(filename)
	local contents, err = love.filesystem.read(filename)
	if not contents then error("Table not read\n") end

	--Separate lines
	for line in contents:gmatch("[^\r\n]+") do
		-- Separate each value in a line, form should be x1 y1 z1 i1 i2 i3 i4...\n (connected to 4 other points)
		local pointParts = {}
		local lineParts = {}
		local i = 1
		for part in line:gmatch("%S+") do
			if i > 3 then table.insert(lineParts, tonumber(part))
			else table.insert(pointParts, tonumber(part)) end
			i = i + 1
		end
		table.insert(self.points, pointParts)
		table.insert(self.lines, lineParts)
	end
	self:printData()
end

function Cool3d:project(xyz)
	local x = xyz[1]
	local y = xyz[2]
	local z = xyz[3]
	if z == 0 then return {0,0} end
    return {x / z, y / z}
end

function Cool3d:translate_z(xyz, dz)
	local x = xyz[1]
	local y = xyz[2]
	local z = xyz[3]
	return {x, y, z + dz}
end

function Cool3d:rotate_xz(xyz, angle)
	local x = xyz[1]
	local y = xyz[2]
	local z = xyz[3]
    local c = math.cos(angle);
    local s = math.sin(angle);
    return {x*c - z*s, y, x*s + z*c}
end

function Cool3d:draw()
    self.timer = self.timer + 1 * self.dt
    self.dz = math.sin(self.zSpeed * self.timer) + 3

    -- animate rotation
    self.angle = (self.angle + math.pi * self.rotSpeed * self.dt)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(self.lineWidth or 1)

    local w, h = love.graphics.getDimensions()
    local cx, cy = w * 0.5, h * 0.5
    local scale = 500

    -- Project all points once
    local screen = {}   -- screen[i] = {x, y} or nil if not drawable
    local zvals  = {}   -- keep z so we can cull points behind camera

    for i = 1, #self.points do
        local p = self:rotate_xz(self.points[i], self.angle)
        p = self:translate_z(p, self.dz)

        local z = p[3]
        zvals[i] = z

        if z and z > 0.001 then
            local proj = self:project(p) -- {x/z, y/z}
            screen[i] = { cx + proj[1] * scale, cy + proj[2] * scale }
        else
            screen[i] = nil
        end
    end

    -- Draw lines by connection indices
    local drawn = {}

    for i = 1, #self.lines do
        local a = screen[i]
        local links = self.lines[i]

        if a and links then
            for _, k in ipairs(links) do
                local b = screen[k]
                if b then
                    local key1 = i .. "-" .. k
                    local key2 = k .. "-" .. i
                    if not drawn[key1] and not drawn[key2] then
                        love.graphics.line(a[1], a[2], b[1], b[2])
                        drawn[key1] = true
                    end
                end
            end
        end
    end
end

function Cool3d:printData()
    print("=== Cool3d Data ===")
    print("Total points:", #self.points)

    for i, p in ipairs(self.points) do
        local x, y, z = p[1], p[2], p[3]

        io.write(string.format(
            "Point %d: x=%.3f y=%.3f z=%.3f",
            i, x or 0, y or 0, z or 0
        ))

        local links = self.lines[i]
        if links and #links > 0 then
            io.write(" | connects to: ")
            for j, idx in ipairs(links) do
                io.write(idx)
                if j < #links then io.write(", ") end
            end
        else
            io.write(" | connects to: (none)")
        end

        io.write("\n")
    end

    print("=====================")
end


return { Cool3d = Cool3d}