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
    }
}

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))
    local url = activity.getIntent().getStringExtra('url')
    webview.loadUrl(url)
end

function onDestroy()
    if webview then
        webview.getParent().removeView(webview)
        webview.destroy()
        webview = nil
    end
end