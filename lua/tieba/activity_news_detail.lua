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
local log = require("log")
-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#ff198ef1",
    {
        LinearLayout,
        orientation = "horizontal",
        layout_width = "fill",
        layout_height = "56dp",
        background = "#ff198ef1",
        gravity = "center_vertical",
        {
            ImageView,
            id = "back",
            layout_width = "40dp",
            layout_height = "40dp",
            layout_marginLeft = "8dp",
            scaleType = "centerInside",
            src = "@drawable/ic_menu_back",
        },
        {
            TextView,
            layout_height = "56dp",
            layout_width = "fill",
            paddingRight = "16dp",
            singleLine = true,
            textIsSelectable = true,
            ellipsize = "end",
            id = "tv_title",
            gravity = "center_vertical",
            paddingLeft = "8dp",
            textColor = "#ffffff",
            textSize = "18sp",
        },
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
    article,aside,details,figcaption,figure,footer,header,hgroup,main,nav,section,summary{display:block}audio,canvas,video{display:inline-block}audio:not([controls]){display:none;height:0}html{font-family:sans-serif;-webkit-text-size-adjust:100%}body{font-family:'Helvetica Neue',Helvetica,Arial,Sans-serif;background:#fff;padding-top:0;margin:0}a:focus{outline:thin dotted}a:active,a:hover{outline:0}h1{margin:.67em 0}h1,h2,h3,h4,h5,h6{font-size:16px}abbr[title]{border-bottom:1px dotted}hr{box-sizing:content-box;height:0}mark{background:#ff0;color:#000}code,kbd,pre,samp{font-family:monospace,serif;font-size:1em}pre{white-space:pre-wrap}q{quotes:\201C\201D\2018\2019}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sup{top:-0.5em}sub{bottom:-0.25em}img{border:0;vertical-align:middle;color:transparent;font-size:0}svg:not(:root){overflow:hidden}figure{margin:0}fieldset{border:1px solid silver;margin:0 2px;padding:.35em .625em .75em}legend{border:0;padding:0}table{border-collapse:collapse;border-spacing:0;overflow:hidden}a{text-decoration:none}blockquote{border-left:3px solid #d0e5f2;font-style:normal;display:block;vertical-align:baseline;font-size:100%;margin:.5em 0;padding:0 0 0 1em}ul,ol{padding-left:20px}.content{color:#444;line-height:1.6em;font-size:16px;margin:16px 16px 0 16px;}.content img{max-width:100%;margin:4px auto}.content img+img{margin-top:15px}.content img[src*="zhihu.com/equation"]{display:inline-block;margin:0 3px}.content a{color:#259}.content a:hover{text-decoration:underline}
    .i {border-bottom: 1px solid #EFEFEF; padding-top: 16px; padding-bottom: 16px; }  td.l,td.r{ font-size: 12px;} span.g{color: #5199E2;}
]]
local htmlTemplate = [[
<!DOCTYPE html>
<html>
<head>
    <title>氢应用-贴吧</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
    <style type="text/css"> %s </style>
</head>
<body>
<div id="list" class="content"> %s </div>
<div id="more" style="height:48px; line-height:48px; text-align:center;color: #569ADD;">下一页</div> 
<script type="text/javascript">

function launchReply(lnk){
    var s = {};
    s.method = 'launchReply';
    s.data = lnk;
    window.luaApp.call(JSON.stringify(s));
}
function initLoadMore(){
    document.getElementById('more').onclick = function() {
        var s = {};
        s.method = 'loadMore';
        window.luaApp.call(JSON.stringify(s));
        document.getElementById('more').textContent = '正在加载...'
    }
    var arr = document.querySelectorAll("div.i");
    for(var i=0;i<arr.length;i++){
        var links = arr[i].querySelectorAll('uu[href]')
        var lnk = ''
        for(var j=0;j<links.length;j++){
            lnk = links[j].getAttribute('href')
            if (lnk.lastIndexOf('flr')>=0){
                break;
            }
            lnk = ''
        }
        if (lnk != ''){
            arr[i].onclick = (function(lnk){
                return function() { launchReply(lnk) }
            })(lnk)
        }
    }
}

function hideLoadMore(){
    document.getElementById('more').style.display = 'none'
}

function openImgActivity(a, b) {
    var c = JSON.stringify({
        currentIndex: b,
        uris: a
    });
    var d = "hydrogen://pub.hydrogen.android?action=open_img&data=" + c;
    var e = document.createElement("iframe");
    e.src = d;
    e.style.display = "none";
    document.body.appendChild(e);
    setTimeout(function() {
        document.body.removeChild(e)
    },
    2000)
}

function previewImgage(g) {
    g.stopPropagation()
    var e = g.target || g.srcElement;
    var c = [];
    var d = 0;
    var h = document.querySelectorAll(".content img");
    for (var f = 0; f < h.length; f++) {
        var url = h[f].getAttribute("src"); 
        c[f] = 'http://imgsrc.baidu.com/forum/pic/item/' + url.match('[0-9a-z]*.jpg*$')
        if (e.getAttribute("src").indexOf(url) != -1) {
            d = f
        }
    }
    openImgActivity(c, d)
}

function init() {
    var a = document.querySelectorAll(".content img");
    for (var b = 0; b < a.length; b++) {
        a[b].addEventListener("click", previewImgage)
    }
}
function appendList(h){
    document.getElementById('more').textContent = '下一页'
    var list = document.getElementById('list');
    var newList = document.createElement('div');
    newList.innerHTML = h;
    list.appendChild(newList)
    init();
}

initLoadMore();
init();
</script>
</body>
</html>
]]

local params = { rid, page = 0 }

function html_unescape(s)
    return s:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"):gsub("&quot;", '"'):gsub("&#39;", "'"):gsub("&#47;", "/")
end

local function getData(fromJs)

    local url = string.format('http://c.tieba.baidu.com/mo/q----,sz@320_240-1-3---2/m?kz=%s&new_word=&pn=%d&lp=6021', params.rid, params.page * 30)
    if params.pid and params.kid then
        url = string.format('http://c.tieba.baidu.com/mo/q----,sz@320_240-1-3---2/flr?pid=%s&kz=%s&pn=%d&pinf=1_2_20', params.pid, params.kid, params.page * 30)
    end
    LuaHttp.request({ url = url }, function(error, code, body)
        local tag = 'class="d">(.-)笑话大放送'
        if params.pid and params.kid then
            tag = 'class="m t">(.-)</body>'
        end
        local content = string.match(body, tag)
        content = html_unescape(content)
        content = content:gsub('&quality=45&size=b96_2000', '&quality=80&size=b400_2000')
        local nextUrl = string.find(content, '>下一页')
        if nextUrl then
            params.page = params.page + 1
        end
        content = content:gsub('<a href=', '<uu href='):gsub('</a>', '</uu>'):gsub('<form.->.-</form>', '')
        local data = string.format(htmlTemplate, css, content)
        uihelper.runOnUiThread(activity, function()
            if nextUrl == nil then
                webview.loadUrl("javascript:hideLoadMore()")
            end
            if fromJs then
                webview.loadUrl(string.format("javascript:appendList('%s')", content))
                return
            end
            webview.loadDataWithBaseURL("http://c.tieba.baidu.com/mo/q----,sz@320_240-1-3---2/", data, "text/html", "utf-8", nil)
        end)
    end)
end

local function callback(jsonStr)
    local json = JSON.decode(jsonStr)
    if json.method == 'loadMore' then
        getData(true)
        return
    end

    if json.method == 'launchReply' then
        local lnk = json.data
        local item = {
            reply = true,
            title = '回复',
            url = lnk
        }
        local intent = Intent(activity, LuaActivity)
        intent.putExtra("luaPath", 'tieba/activity_news_detail.lua')
        intent.putExtra("item", JSON.encode(item))
        activity.startActivity(intent)
        return
    end
end

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    back.onClick = function()
        activity.finish()
    end

    local str = activity.getIntent().getStringExtra("item"):gsub('\\/', '/')
    local item = JSON.decode(str)
    tv_title.setText(item.title)
    if item.reply then
        local pid, kid = string.match(item.url, 'pid=(%d+)&kz=(%d+)')
        params.pid = pid
        params.kid = kid
    else
        params.rid = string.match(item.url, '/p/(%d+)')
    end

    webview.setVisibility(0)
    progressBar.setVisibility(8)
    getData()
    webview.injectObjectToJavascript(callback, "luaApp")
end

function onBackPressed()
    if webview.canGoBack() then webview.goBack() return true end
    return false
end

function onDestroy()
    if webview then
        webview.getParent().removeView(webview)
        webview.destroy()
        webview = nil
    end
end
