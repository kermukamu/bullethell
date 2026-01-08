-- Instructions "class"
local Instructions = {}
Instructions.__index = Instructions

function Instructions.new(instructionTable, host)
	local self = setmetatable({}, Instructions)
	self.instructionList = instructionTable
	self.host = host
	self.ind = 1
	self.wait = 0
	self.mag = 1 -- For multiplying certain actions with a constant
	return self
end

function Instructions:printInstructions()
  print("---- INSTRUCTION TABLE ----")

  if not self.instructionTable or #self.instructionList == 0 then
    print("(empty)")
    print("---------------------------")
    return
  end

  for i, line in ipairs(self.instructionList) do
    print(string.format("%3d: %s", i, line))
  end

  print("---------------------------")
  io.stdout:flush()
end

function Instructions:readInstruction(instruction)
	-- Check if nil
	if not instruction then
    	self.ind = 1
    	return false
  	end

  -- Parse
	local parts = {}
	for part in instruction:gmatch("%S+") do
		table.insert(parts, part)
	end

	--- These actions will pass false to caller either due to end or wait
	if parts[1] == "end" then 
		self.ind = 1
		return false
	end

	if parts[1] == "wait" then
		self:commandIntegrity(tonumber(parts[2]))
		self.wait = tonumber(parts[2]) / 1000
		self.ind = self.ind + 1
		return false
	end

	--- These actions will pass true to caller
	if parts[1] == "goto" then
		self:commandIntegrity(tonumber(parts[2]))
		self.ind = tonumber(parts[2])
		return true
	end

	if parts[1] == "setXSpeed" then 
		self:commandIntegrity(tonumber(parts[2]))
		self.host.xSpeed = tonumber(parts[2]) * self.mag
		io.stdout:flush()
	end

	if parts[1] == "shoot" then
		self:commandIntegrity(tonumber(parts[2]))
		self:commandIntegrity(tonumber(parts[3]))
		self:commandIntegrity(tonumber(parts[4]))
		self.host:shoot(tonumber(parts[2]) * self.mag, tonumber(parts[3]), tonumber(parts[4]))
	end

	self.ind = self.ind + 1
	return true
end

function Instructions:commandIntegrity(n)
	if not n then error("Instruction error at instruction line " .. tostring(self.ind)) end
end

function Instructions:callInstructions(dt)
	self.wait = math.max(0, self.wait - dt)

	-- Call readInstruction() for every line until receiving false as return
	local keepReading = true
	while self.wait <= 0 and keepReading do
		keepReading = self:readInstruction(self.instructionList[self.ind])
	end
end


return { Instructions = Instructions}