--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- qiqu
--
require "import"
import "android.widget.*"
import "android.content.*"
import "androlua.LuaWebView"
import "android.os.Build"
import "android.view.View"
import "android.support.v7.widget.AppCompatSeekBar"
import "android.support.design.widget.FloatingActionButton"
import "android.graphics.drawable.GradientDrawable"
import "android.animation.ValueAnimator"
import "java.lang.String"
import "java.io.File"
import "java.io.FileOutputStream"
import "android.graphics.Canvas"
import "android.graphics.Bitmap"
import "android.graphics.Paint"
import "android.graphics.Rect"
local CompressFormat = import "android.graphics.Bitmap$CompressFormat"
local Config = import "android.graphics.Bitmap$Config"

local JSON = require "cjson"
local Orientation = import "android.graphics.drawable.GradientDrawable$Orientation"
local colors = luajava.createArray("int", { 0xFF72A3FF, 0xFF607dff })
local gd = GradientDrawable(Orientation.TOP_BOTTOM, colors)
math.randomseed(os.time())

local colors = {
    0xFF131313, 0xFFD90C17, 0xFF33BB68, 0xFF3EA6FC, 0xFFE96138, 0xFFFDA236, 0xFF1E89E9, 0xFFF13525,
    0xFF3EC0D5, 0xFF1EBBA5, 0xFF3273EC, 0xFF22D926, 0xFFA630BF
}

local luaTemp = [[
require "import"
import "android.widget.*"
import "android.content.*"
import "androlua.LuaWebView"
local layout = {
    LinearLayout, orientation = "vertical", layout_width = "fill", layout_height = "fill", statusBarColor = "{ssColor}",
    { LuaWebView, id = "webview", layout_width = "fill",layout_height = "fill", }
}

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    webview.loadUrl("{url}")
end

function onBackPressed()
    if webview.canGoBack() then webview.goBack() return true end
    return false
end

function onDestroy()
    pcall(function() webview.release() end)
end
]]


local function write(filePath, txt)
    pcall(function()
        local file = File(filePath)
        file.getParentFile().mkdirs()
        local f = io.open(filePath, 'wb')
        f:write(txt)
        f:close()
    end)
end

local function drawLogo(txt, filePath, bgColor)
    local c = '氢'
    if txt then
        c = String(txt).substring(0, 1)
    end
    if bgColor == 0x33000000 then bgColor = colors[math.random(#colors)] end

    local file = File(filePath)
    file.getParentFile().mkdirs()
    local bm = Bitmap.createBitmap(100, 100, Config.RGB_565)
    local canvas = Canvas(bm)
    canvas.drawColor(bgColor)
    local mPaint = Paint(1)
    mPaint.setTextSize(40)
    mPaint.setColor(0xFFFFFFFF)
    local bounds = Rect()
    mPaint.getTextBounds(c, 0, 1, bounds)
    canvas.drawText(c, 47 - bounds.width() / 2, 47 + bounds.height() / 2, mPaint)
    local stream = FileOutputStream(file)
    bm.compress(CompressFormat.PNG, 100, stream)
    stream.close()
end

local function pack(params)
    if params == nil or params.url == nil or params.name == nil then
        return
    end

    local dirName = tostring(os.time())
    local pluginId = 'pub.hydrogen' .. dirName

    local infoPath = string.format('%s/%s/info.json', luajava.luaextdir, dirName)
    local luaPath = string.format('%s/%s/main.lua', luajava.luaextdir, dirName)
    local logoPath = string.format('%s/%s/logo.png', luajava.luaextdir, dirName)
    local info = {
        id = pluginId,
        name = params.name,
        icon = "logo.png",
        main = "main.lua",
        versionCode = 1,
        versionName = "1.0.0",
        desc = params.name .. " - 氢页面",
    }
    local code = luaTemp:gsub('{url}', params.url):gsub('{ssColor}', string.format("#%x", params.themeColor))

    write(infoPath, JSON.encode(info))
    write(luaPath, code)

    drawLogo(params.name, logoPath, params.themeColor)

    activity.toast('打包成功，到主界面看一下吧！')
end

-- create view table

local function editText(id, hint, inputType)
    local t = {
        EditText,
        id = id,
        layout_width = "fill",
        layout_height = "48dp",
        textColor = "#444444",
        hintTextColor = "#AAAAAA",
        textSize = "13sp",
        hint = hint,
        singleLine = true,
        layout_marginBottom = "12dp",
    }
    if inputType then t.inputType = inputType end

    return t
end

local layout = {
    FrameLayout,
    layout_width = "match",
    layout_height = "match",
    background = "#f1f1f1",
    {
        ImageView,
        id = 'iv_bg',
        layout_width = "match",
        layout_height = "360dp",
    },
    {
        LinearLayout,
        layout_width = "match",
        gravity = "center_horizontal",
        orientation = "vertical",
        paddingLeft = "16dp",
        paddingRight = "16dp",
        {
            TextView,
            layout_marginTop = "40dp",
            text = "打包网页",
            textColor = "#ffffff",
            textSize = "20sp",
        },
        {
            TextView,
            id = 'tv_left',
            layout_marginTop = "40dp",
            textColor = "#fafafa",
            text = '        该插件可以将网页应用转化成氢应用的插件，这样就可把一些做的比较好的网站或在线H5小游戏直接加入氢应用了，给你轻而纯粹的应用体验。',
            lineSpacingMultiplier = 1.4,
        },
        {
            FrameLayout,
            layout_width = "match",
            layout_marginTop = "56dp",
            layout_marginLeft = "16dp",
            layout_marginRight = "16dp",
            {
                LinearLayout,
                layout_width = "match",
                layout_marginBottom = "32dp",
                background = "#ffffff",
                orientation = "vertical",
                paddingBottom = "24dp",
                paddingLeft = "16dp",
                paddingRight = "16dp",
                paddingTop = "16dp",
                editText('et_url', '网址 http(s)://', 11),
                editText('et_name', '插件名称'),
                editText('et_themeColor', '主题色（如 #3273EC 选填）'),
                {
                    Button,
                    id = "bt_test",
                    layout_width = "fill",
                    layout_marginTop = "24dp",
                    layout_marginBottom = "48dp",
                    textSize = "13sp",
                    text = "戳我预览",
                    background = "#eeeeee",
                    textColor = "#444444",
                }
            },
            {
                FloatingActionButton,
                id = "fab",
                layout_width = "48dp",
                layout_height = "48dp",
                layout_gravity = 81,
                layout_marginBottom = "12dp",
                src = '#packwap/check.png',
                elevation = "2dp",
            },
        },
    },
}

local function getParams()
    local url = et_url.getText().toString()
    local name = et_name.getText().toString()
    local c = et_themeColor.getText().toString()
    if c ~= '' and (not c:find("^#")) then
        c = '#' .. c
        et_themeColor.setText(c)
    end

    local color = string.match(c, '#([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])')
    if color == nil then
        color = 0x33000000
    else
        color = tonumber('0xff' .. color)
    end
    return { url = url, name = name, themeColor = color }
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))

    if Build.VERSION.SDK_INT < 16 then
        iv_bg.setBackgroundDrawable(gd)
    else
        iv_bg.setBackground(gd)
    end

    bt_test.onClick = function()
        local params = getParams()
        if params.url == '' then
            activity.toast('URL和名字不能为空')
            return
        end
        if not params.url:find("^http") then
            params.url = 'http://' .. params.url
            et_url.setText(params.url)
        end


        local intent = Intent(activity, LuaActivity)
        intent.putExtra("luaPath", 'packwap/testwap.lua')
        intent.putExtra("url", url)
        intent.putExtra("params", JSON.encode(params))
        activity.startActivity(intent)
    end

    fab.onClick = function()
        local params = getParams()
        if params.url == '' or params.name == '' then activity.toast('URL和名字不能为空') return end
        pack(params)
    end
end
