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
import "pub.hydrogen.android.BuildConfig"

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
    activity.setContentView(loadlayout(layout))
    webview.loadUrl('https://wapbaike.baidu.com/')
    if BuildConfig.VERSION_CODE < 15 then
        activity.toast("氢应用版本太低，可能无法正常使用，请升级最新版本！")
    end
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
