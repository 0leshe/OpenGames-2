local projectName = "Main"
local beep = require('computer').beep
local System = require('System')
local path = string.gsub(System.getCurrentScript(),'CrushHandler', projectName)
beep(50,0.05)
local programmHandle, why = loadfile(path)
if type(programmHandle) ~= 'function' and why then
	require('component').gpu.setActiveBuffer(0)
	prnt('ERR: '..why)
	beep(450,0.1)
	beep(450,0.1)
	return
end
local suc, _, _, traceback = System.call(programmHandle)
if suc == false then
	require('component').gpu.setActiveBuffer(0)
	print("ERR: "..traceback)
	beep(450,0.1)
	beep(450,0.1)
	return
end
beep(20,0.05)