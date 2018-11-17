--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- A news app
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaWebView"
import "androlua.LuaHttp"
local uihelper = require("uihelper")
local JSON = require("cjson")
-- create view table
local layout = {
    FrameLayout,
    layout_width = "fill",
    layout_height = "fill",
    {
        LuaWebView,
        id = "webview",
        layout_width = "fill",
        layout_height = "fill",
    },
    {
        ProgressBar,
        layout_gravity = "center",
        id = "progressBar",
        layout_width = "40dp",
        layout_height = "40dp",
    },
}

local htmlTemplate = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="user-scalable=no, width=device-width">
    <title>%s</title>
    <style>
    .img-place-holder{
        background-image: url(%s);
        background-size: cover;
        position: relative;
    }
    </style>
    %s
</head>
<body>%s</body>
</html>
]]

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))
    local id = activity.getIntent().getStringExtra('newsid')
    webview.setVisibility(0)
    progressBar.setVisibility(8)
    LuaHttp.request({ url = string.format('http://news-at.zhihu.com/api/4/news/%d', id) }, function(error, code, body)
        local json = JSON.decode(body)
        local title = json.title or ''
        local body = json.body or ''
        local image = json.image or 'https://pic1.zhimg.com/v2-456bb69183a78a7290c64ad7580fa2ec.jpg'
        local css = ''
        if json.css then
            for i = 1, #json.css do
                css = css .. string.format('<link rel="stylesheet" href="%s"', json.css[i])
            end
        end

        local data = string.format(htmlTemplate, title, image, css, body)
        uihelper.runOnUiThread(activity, function()
            webview.loadData(data, "text/html; charset=UTF-8", nil)
        end)
    end)
end


function onDestroy()
    if webview then
        webview.getParent().removeView(webview)
        webview.destroy()
        webview = nil
    end
end