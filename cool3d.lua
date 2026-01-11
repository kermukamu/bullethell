-- cool3d "class"
local Cool3d = {}
Cool3d.__index = Cool3d

function Cool3d.new(debugmode, x2d, y2d, modelScale)
	local self = setmetatable({}, Cool3d)
	self.debugmode = debugmode

	self.points = {} -- AKA vertices
	self.lines = {}
	self.lineWidth = 1
	self.dz = 1
	self.angle = 0
    self.rotSpeed = 1
    self.timer = 0
    self.zSpeed = 0.2

    self.x2d = x2d or 0
    self.y2d = y2d or 0
    self.modelScale = modelScale or 1

	return self
end

function Cool3d:readFile(filename)
	local contents, err = love.filesystem.read(filename)
	if not contents then error("Table not read\n") end

	--Separate lines
	for line in contents:gmatch("[^\r\n]+") do
		-- Separate each value in a line, form should be x1 y1 z1 i1 i2 i3 i4...\n
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

function Cool3d:update(dt)
    self.timer = self.timer + 1 * dt
    self.dz = math.sin(self.zSpeed * self.timer) + 3
    self.angle = (self.angle + math.pi * self.rotSpeed * dt)
end

function Cool3d:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(self.lineWidth or 1)

    local w, h = love.graphics.getDimensions()
    local cx, cy = self.x2d, self.y2d
    local scale = self.modelScale

    local screen = {}
    local zvals  = {}

    for i = 1, #self.points do
        local p = self:rotate_xz(self.points[i], self.angle)
        p = self:translate_z(p, self.dz)

        local z = p[3]
        zvals[i] = z

        if z and z > 0.001 then
            local proj = self:project(p)
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

return { Cool3d = Cool3d}