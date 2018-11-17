--
-- Created by IntelliJ IDEA.
-- User: hanks
-- Date: 2017/5/13
-- Time: 00:01
-- Load plugin from api
--
require "import"

import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v7.widget.Toolbar"
import "androlua.LuaImageLoader"
import "androlua.LuaHttp"
import "android.os.Build"
import "androlua.LuaAdapter"
import "android.graphics.drawable.GradientDrawable"
import "androlua.widget.marqueetext.MarqueeTextView"

local FileUtils = import "androlua.common.LuaFileUtils"
local JSON = require "cjson"
local uihelper = require "uihelper"
-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    statusBarColor = "#222222",
    {
        FrameLayout,
        layout_width = "fill",
        layout_height = "56dp",
        background = "#222222",
        {
            ImageView,
            id = "back",
            layout_width = "56dp",
            layout_height = "fill",
            src = "@drawable/ic_menu_back",
            scaleType = "centerInside",
            background = "@drawable/layout_selector_tran",
        },
        {
            TextView,
            id = "tv_title",
            layout_height = "fill",
            layout_marginLeft = "72dp",
            gravity = "center_vertical",
            textColor = "#ffffff",
            textSize = "18sp",
            text = "插件列表",
        },
        {
            TextView,
            layout_height = "fill",
            paddingRight = "16dp",
            paddingLeft = "16dp",
            layout_gravity = "right",
            id = "tv_support",
            gravity = "center",
            textColor = "#ffffff",
            textSize = "13sp",
            text = "捐赠",
            background = "@drawable/layout_selector_tran",
        },
    },
    {
        ListView,
        id = "listview",
        layout_width = "fill",
        layout_height = "fill",
    }
}

local item_view = {
    FrameLayout,
    layout_width = "fill",
    layout_height = "80dp",
    padding = "16dp",
    {
        ImageView,
        id = "icon",
        layout_gravity = "center_vertical",
        layout_width = "48dp",
        layout_height = "48dp",
        scaleType = "centerInside",
    },
    {
        TextView,
        id = "text",
        layout_width = "fill",
        layout_marginLeft = "56dp",
        textSize = "12sp",
        textColor = "#222222",
        layout_gravity = "top",
    },
    {
        TextView,
        id = "tv_version",
        layout_width = "fill",
        layout_marginLeft = "56dp",
        layout_marginRight = "96dp",
        textSize = "10sp",
        textColor = "#666666",
        layout_gravity = "center_vertical",
    },
    {
        MarqueeTextView,
        id = "desc",
        textSize = "10sp",
        textColor = "#666666",
        layout_width = "fill",
        layout_marginLeft = "56dp",
        layout_marginRight = "96dp",
        layout_gravity = "bottom",
    },
    {
        TextView,
        layout_width = "68dp",
        layout_height = "32dp",
        background = "#666666",
        layout_marginTop = "8dp",
        gravity = "center",
        id = "download",
        text = "下载",
        textSize = "12sp",
        layout_gravity = "right",
    },
}


local strokeWidth = 2;
local roundRadius = 8;
local strokeColor = 0xFF2E3135

local gd = GradientDrawable()
gd.setCornerRadius(roundRadius)
gd.setStroke(strokeWidth, strokeColor)

local function flatType(type)
    if type == 'uninstall' then return '卸载'
    elseif type == 'update' then return '更新'
    elseif type == 'downloading' then return '下载中'
    else return '安装'
    end
end

local function flatTypeColor(type)
    local color = 0xff111111
    if type == 'uninstall' then color = 0xff888888
    elseif type == 'update' then color = 0xff222222
    elseif type == 'downloading' then color = 0xffc22525
    end
    return color
end

local data = {} -- plugin list

local adapter

local function notifyAdapterData()
    uihelper.runOnUiThread(activity, function() adapter.notifyDataSetChanged() end)
end

local function compareWithLocal(localList, plugin)
    plugin.type = 'install'
    for i = 1, #localList do
        local p = localList[i - 1]
        if p.getId() == plugin.id then
            if p.getVersionCode() < plugin.versionCode then
                plugin.type = 'update'
                plugin.versionName = string.format('%s -> %s', p.getVersionName(), plugin.versionName)
                plugin.position = plugin.position - 999
            else plugin.type = 'uninstall'
            end
        end
    end
    if plugin.type == 'install' then
        plugin.position = -plugin.position
    end
end



local function getData()
    local options = {
        url = 'https://coding.net/u/zhangyuhan/p/api_luanroid/git/raw/master/api/plugins'
    }
    LuaHttp.request(options, function(error, code, body)
        local localList = FileUtils.getPluginList()
        local json = JSON.decode(body)
        local list = json.data
        for i = 1, #list do
            local plugin = list[i]
            plugin.position = i
            compareWithLocal(localList, plugin)
            data[#data + 1] = plugin;
        end
        table.sort(data, function(l, r) return l.position < r.position end)
        notifyAdapterData()
    end)
end


local function downloadPlugin(plugin)
    plugin.type = 'downloading'
    notifyAdapterData()
    FileUtils.downloadPlugin(plugin.download, plugin.id, function(pluginDir)
        plugin.type = 'uninstall'
        notifyAdapterData()
    end)
end


function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    activity.disableDrawer()
    back.onClick = function()
        activity.finish()
    end

    tv_support.onClick = function()
        xpcall(function()
            local intentFullUrl = "intent://platformapi/startapp?saId=10000007&clientVersion=3.7.0.0718&qrcode=https%3A%2F%2Fqr.alipay.com%2Faex09002nkvmcsullzrwg2b%3F_s%3Dweb-other&_t=1472443966571#Intent;scheme=alipayqr;package=com.eg.android.AlipayGphone;end"
            activity.startActivity(Intent.parseUri(intentFullUrl, 1));
        end,
            function()
                local url = "https://qr.alipay.com/aex09002nkvmcsullzrwg2b";
                activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)));
            end)
    end

    adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
        getCount = function() return #data end,
        getView = function(position, convertView, parent)
            position = position + 1 -- lua 索引从 1开始

            if convertView == nil then
                local views = {} -- store views
                convertView = loadlayout(item_view, views, ListView)
                if Build.VERSION.SDK_INT < 16 then
                    views.download.setBackgroundDrawable(gd);
                else
                    views.download.setBackground(gd);
                end
                convertView.getLayoutParams().width = parent.getWidth()
                convertView.setTag(views)
            end

            local views = convertView.getTag()
            local plugin = data[position]
            if views == nil or plugin == nil then return end

            LuaImageLoader.loadWithRadius(views.icon, 40, plugin.icon)
            views.text.setText(plugin.name)
            views.desc.setText(plugin.desc)
            views.tv_version.setText(plugin.versionName)
            views.download.setText(flatType(plugin.type))
            views.download.setTextColor(flatTypeColor(plugin.type))
            views.download.onClick = function(view)
                if plugin.type == 'downloading' then
                    return
                elseif plugin.type == 'update' or plugin.type == 'install' then
                    plugin.type = 'downloading'
                    downloadPlugin(plugin)
                else
                    FileUtils.removePlugin(plugin.id)
                    plugin.type = 'install'
                    notifyAdapterData()
                end
            end
            return convertView
        end
    }))

    listview.setAdapter(adapter)
    getData()
end
