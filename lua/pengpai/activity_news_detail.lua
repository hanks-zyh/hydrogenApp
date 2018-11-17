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
import "android.support.v7.widget.Toolbar"
import "android.net.Uri"
import "pub.hydrogen.android.R"
import "androlua.widget.webview.WebViewActivity"
local android_R = import "android.R"
local uihelper = require "uihelper"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#33000000",
    {
        Toolbar,
        background = '#ffffff',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
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
        {
            View,
            layout_width = "fill",
            layout_height = "3dp",
            background = "@drawable/shadow_line_top",
        }
    }
}

local css = [[
    video{width:100%}article,aside,details,figcaption,figure,footer,header,hgroup,main,nav,section,summary{display:block}audio,canvas,video{display:inline-block}audio:not([controls]){display:none;height:0}html{font-family:sans-serif;-webkit-text-size-adjust:100%}body{font-family:'Helvetica Neue',Helvetica,Arial,Sans-serif;background:#fff;padding-top:0;margin:0}a:focus{outline:thin dotted}a:active,a:hover{outline:0}h1{margin:.67em 0}h1,h2,h3,h4,h5,h6{font-size:16px}abbr[title]{border-bottom:1px dotted}hr{box-sizing:content-box;height:0}mark{background:#ff0;color:#000}code,kbd,pre,samp{font-family:monospace,serif;font-size:1em}pre{white-space:pre-wrap}q{quotes:\201C\201D\2018\2019}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sup{top:-0.5em}sub{bottom:-0.25em}img{border:0;vertical-align:middle;color:transparent;font-size:0}svg:not(:root){overflow:hidden}figure{margin:0}fieldset{border:1px solid silver;margin:0 2px;padding:.35em .625em .75em}legend{border:0;padding:0}table{border-collapse:collapse;border-spacing:0;overflow:hidden}a{text-decoration:none}blockquote{border-left:3px solid #d0e5f2;font-style:normal;display:block;vertical-align:baseline;font-size:100%;margin:.5em 0;padding:0 0 0 1em}ul,ol{padding-left:20px}.content{color:#444;line-height:1.6em;font-size:16px;margin:16px}.content img{max-width:100%;display:block;margin:30px auto}.content img+img{margin-top:15px}.content img[src*="zhihu.com/equation"]{display:inline-block;margin:0 3px}.content a{color:#259}.content a:hover{text-decoration:underline}
]]
local htmlTemplate = [[
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width; initial-scale=1; minimum-scale=1; maximum-scale=2">
    <meta content="width=device-width,user-scalable=no" name="viewport">
    <style type="text/css"> %s </style>
</head>
<body>
<div class="content"> %s </div>
<script type="text/javascript">
function openImgActivity(a,b){var c=JSON.stringify({currentIndex:b,uris:a});var d="hydrogen://pub.hydrogen.android?action=open_img&data="+c;var e=document.createElement("iframe");e.src=d;e.style.display="none";document.body.appendChild(e);setTimeout(function(){document.body.removeChild(e)},2000)}function init(){var a=document.querySelectorAll(".content img");for(var b=0;b<a.length;b++){a[b].addEventListener("click",function(g){var e=g.target||g.srcElement;var c=[];var d=0;var h=document.querySelectorAll(".content img");for(var f=0;f<h.length;f++){c[f]=h[f].getAttribute("src");if(e.getAttribute("src").indexOf(c[f])!=-1){d=f}}openImgActivity(c,d)})}}init();
</script>
</body>
</html>
]]



local function getData(url)
    print(url)
    LuaHttp.request({ url = url }, function(error, code, body)
        local content = string.match(body, 'class="news_part%s+.-">%s+(.-)<div class="news_part_all"')
        if content == nil then
            WebViewActivity.start(activity, url, 0xFF000000)
            activity.finish()
            return
        end
        local data = string.format(htmlTemplate, css, content)
        data = data:gsub('width="%d+"%s+height="%d+"', '')
        local title = string.match(body, '<h1 class="t_newsinfo">(.-)</h1>')
        uihelper.runOnUiThread(activity, function()
            webview.loadData(data, "text/html; charset=UTF-8", nil)
            activity.setTitle(title)
        end)
    end)
end

local url
function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    activity.setSupportActionBar(toolbar)
    activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)
    activity.getSupportActionBar().setDisplayShowHomeEnabled(true)
    activity.setTitle('加载中...')
    url = activity.getIntent().getStringExtra('url')
    webview.setVisibility(0)
    progressBar.setVisibility(8)
    getData(url)
end

function onDestroy()
    if webview then
        webview.getParent().removeView(webview)
        webview.destroy()
        webview = nil
    end
end


function onCreateOptionsMenu(menu)
    menu.add("浏览器打开")
    return true
end

function onOptionsItemSelected(item)
    if item.getItemId() == android_R.id.home then
        activity.onBackPressed()
        return
    end

    local title = item.getTitle()
    if title == "浏览器打开" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    end

end


