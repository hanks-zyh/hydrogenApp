local path,outPath = ...

-- print(path, outPath)

if path==nil or outPath == nil then
  return
end

local str,err = loadfile(path)
if err then
  return
end
local success, code= pcall(string.dump,str,true)
if success then
  f=io.open(outPath,'wb')
  f:write(code)
  f:close()
  return
end
