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

-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    statusBarColor = "#F79100",
    {
        TextView,
        layout_width = "fill",
        layout_height = "48dp",
        background = "#F79100",
        gravity = "center",
        text = "奇趣百科",
        textColor = "#FFFFFF",
        textSize = "18sp",
    },
    {
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
}

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    webview.setVisibility(0)
    progressBar.setVisibility(8)
    webview.loadUrl('http://hanks.pub/joke/')
end

function onDestroy()
    if webview then
        webview.getParent().removeView(webview)
        webview.destroy()
        webview = nil
    end
end
