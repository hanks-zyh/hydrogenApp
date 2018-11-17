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
local JSON = require "cjson"
local log = require "log"
-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    statusBarColor = "#33000000",
    {
        LuaWebView,
        id = "webview",
        layout_width = "fill",
        layout_height = "fill",
    }
}

function onCreate(savedInstanceState)
    local s  = activity.getIntent().getStringExtra("params")
    local params = JSON.decode(s)
    if params.url == nil then
        params.url = "https://www.coolapk.com/apk/pub.hydrogen.android"
    end
    layout.statusBarColor = string.format("#%x",params.themeColor)
    activity.setContentView(loadlayout(layout))
    webview.loadUrl(params.url )
end

function onBackPressed()
    if webview.canGoBack() then webview.goBack() return true end
    return false
end

function onDestroy()
    pcall(function( )
        webview.release()
    end)
end
