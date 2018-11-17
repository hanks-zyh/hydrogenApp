local filehelper = {}

--
local function readfile(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

--------------------------------------------
-- 功能：写入文件
-- 输入：文件名, 内容
-- 输出：生成的文件里面包含内容
local function writefile(path, content)
    print('writefile:' .. path, content)
    local wfile = io.open(path, "w") --写入文件(w覆盖)
    assert(wfile) --打开时验证是否出错
    wfile:write(content) --写入传入的内容
    wfile:close() --调用结束后记得关闭
end

filehelper.readfile = readfile
filehelper.writefile = writefile
return filehelper
