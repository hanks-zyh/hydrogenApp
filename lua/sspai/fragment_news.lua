--
-- Created by IntelliJ IDEA.
-- User: hanks
-- Date: 2017/5/13
-- Time: 00:01
-- To change this template use File | Settings | File Templates.
--
require "import"

import "android.widget.*"
import "android.content.*"
import "androlua.LuaAdapter"
import "androlua.LuaImageLoader"
import "androlua.LuaFragment"
import "androlua.LuaHttp"
import "androlua.widget.webview.WebViewActivity"
import "android.support.v4.widget.SwipeRefreshLayout"
import "android.graphics.drawable.GradientDrawable"
import "android.os.Build"
local Orientation = import "android.graphics.drawable.GradientDrawable$Orientation"
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"

local colors = luajava.createArray("int", { 0x77000000, 0x00000000 })
local gd = GradientDrawable(Orientation.TOP_BOTTOM, colors)
gd.setCornerRadius(uihelper.dp2px(3))

local function getData(params, data, adapter, fragment, swipe_layout, reload)
    local url = string.format('https://api.qingmang.me/v2/article.list?token=c400a7e21688496ca3e7f17c6b0d1846&category_id=%s', params.rid)
    if params.nextUrl then url = params.nextUrl end
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        local json = JSON.decode(body)
        if json.hasMore and json.nextUrl then params.nextUrl = json.nextUrl end
        local arr = json.articles
        uihelper.runOnUiThread(fragment.getActivity(), function()
            if reload then
                for k, _ in pairs(data) do data[k] = nil end
            end
            local s = #data
            for i = 1, #arr do
                data[#data + 1] = arr[i]
            end
            adapter.notifyDataSetChanged()
            swipe_layout.setRefreshing(false)
        end)
    end)
end

local function launchDetail(fragment, item)
    local activity = fragment.getActivity()
    if item == nil or item.webUrl == nil then
        activity.toast('没有 url 可以打开')
        return
    end
    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'sspai/activity_news_detail.lua')
    intent.putExtra("url", item.webUrl)
    activity.startActivity(intent)
end

local function newInstance(rid)

    -- create view table
    local layout = {
        SwipeRefreshLayout,
        layout_width = "fill",
        layout_height = "fill",
        id = "swipe_layout",
        {
            ListView,
            id = "listview",
            background = '#FFFFFF',
            dividerHeight = 0,
            paddingTop = "16dp",
            clipToPadding = false,
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        LinearLayout,
        background = '#ffffff',
        orientation = 'vertical',
        layout_width = "fill",
        {
            FrameLayout,
            layout_marginLeft = '16dp',
            layout_marginRight = '16dp',
            layout_width = "fill",
            layout_height = "140dp",
            {
                ImageView,
                id = "iv_image",
                layout_width = "fill",
                layout_height = "fill",
                scaleType = "centerCrop",
            },
            {
                View,
                background = gd,
                layout_width = "fill",
                layout_height = "90dp",
            },
            {
                TextView,
                id = "tv_title",
                layout_width = "fill",
                layout_marginLeft = '16dp',
                layout_marginRight = '16dp',
                layout_marginTop = '8dp',
                maxLines = 2,
                lineSpacingMultiplier = 1.3,
                textSize = "16sp",
                textColor = "#EEFFFFFF",
            },
        },
        {
            TextView,
            id = "tv_desc",
            layout_width = "fill",
            layout_marginTop = '8dp',
            layout_marginLeft = '16dp',
            layout_marginRight = '16dp',
            layout_marginBottom = '16dp',
            maxLines = 4,
            lineSpacingMultiplier = 1.3,
            textSize = "12sp",
            textColor = "#666666",
        },
        {
            View,
            layout_width = "fill",
            layout_height = "16dp",
        }
    }


    local hadLoadData
    local isVisible
    local lastId
    local params = { rid = rid }
    local data = {}
    local ids = {}
    local adapter
    local fragment = LuaFragment.newInstance()
    local function lazyLoad()
        if not isVisible then return end
        if hadLoadData then return end
        if adapter == nil then return end
        hadLoadData = true
        getData(params, data, adapter, fragment, ids.swipe_layout)
    end

    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onCreateView = function(inflater, container, savedInstanceState)
            return loadlayout(layout, ids)
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
                getCount = function() return #data end,
                getView = function(position, convertView, parent)
                    position = position + 1 -- lua 索引从 1开始
                    if convertView == nil then
                        local views = {} -- store views
                        convertView = loadlayout(item_view, views, ListView)
                        convertView.getLayoutParams().width = parent.getWidth()
                        convertView.setTag(views)
                    end
                    local views = convertView.getTag()
                    local item = data[position]
                    if item then
                        if item.covers and #item.covers > 0 then
                            views.iv_image.setVisibility(0)
                            LuaImageLoader.loadWithRadius(views.iv_image, 3, item.covers[1].url .. '?imageMogr2/quality/95/thumbnail/!1440x480r/gravity/Center/crop/1440x480')
                        else
                            views.iv_image.setVisibility(8)
                        end
                        views.tv_title.setText(item.title or 'ERROR TITLE')
                        views.tv_desc.setText(item.snippet or '')
                    end
                    if position == #data then getData(params, data, adapter, fragment, ids.swipe_layout) end
                    return convertView
                end
            }))
            ids.listview.setAdapter(adapter)
            ids.listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
                onItemClick = function(adapter, view, position, id)
                    launchDetail(fragment, data[position + 1])
                end,
            }))
            ids.swipe_layout.setRefreshing(true)
            ids.swipe_layout.setOnRefreshListener(luajava.createProxy('android.support.v4.widget.SwipeRefreshLayout$OnRefreshListener', {
                onRefresh = function()
                    getData(params, data, adapter, fragment, ids.swipe_layout, true)
                end
            }))
            lazyLoad()
        end,
        onUserVisible = function(visible)
            isVisible = visible
            lazyLoad()
        end,
    }))
    return fragment
end

return {
    newInstance = newInstance
}
