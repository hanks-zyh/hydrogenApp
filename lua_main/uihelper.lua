local uihelper = {}

local function runOnUiThread(activity, f)
    activity.runOnUiThread(luajava.createProxy('java.lang.Runnable', {
        run = f
    }))
end

local density
local screenWidth

local function dp2px(dp)
    if density == nil then
        import "androlua.LuaUtil"
        density = LuaUtil.getDensity()
        screenWidth = LuaUtil.getScreenWidth()
    end
    return 0.5 + dp * density
end

local function getScreenWidth()
    if screenWidth == nil then
        dp2px(0)
    end
    return screenWidth
end

uihelper.runOnUiThread = runOnUiThread
uihelper.dp2px = dp2px
uihelper.getScreenWidth = getScreenWidth

return uihelper

