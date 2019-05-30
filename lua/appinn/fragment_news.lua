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
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require("log")
local function getData(params, data, adapter, fragment, swipe_layout, reload)
    if reload then
        params.page = 1
    end
    local url = "https://feeds.appinn.com/appinns/"
    print(url)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        params.page = params.page + 1
        local arr = {}
        for div in string.gmatch(body, '<item>(.-)</item>') do
            local title, url, content, img = string.match(div,'<title>(.-)</title>%s+<link>(.-)</link>.-<description><!.CDATA.(.-)...</description>.-<img%s+src="(.-)"')
            local item = {title = title, url = url, content = content, img=img }
            arr[#arr + 1] = item
        end
--        log.print_r(arr)
        uihelper.runOnUiThread(fragment.getActivity(), function()
            if reload then
                for k, _ in ipairs(data) do data[k] = nil end
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
    if item == nil or item.url == nil then
        activity.toast('没有 url 可以打开')
        return
    end
    WebViewActivity.start(activity, item.url, 0xffB64926)
end

local function newInstance()

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
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        FrameLayout,
        layout_width = "fill",
        layout_height = "114dp",
        paddingLeft = "8dp",
        paddingRight = "8dp",
        {
            ImageView,
            id = "iv_image",
            layout_marginTop="12dp",
            layout_gravity = "right",
            layout_width = "90dp",
            layout_height = "90dp",
            scaleType = "centerCrop",
        },
        {
            TextView,
            layout_marginTop="12dp",
            id = "tv_title",
            layout_width = "fill",
            layout_marginRight = "100dp",
            maxLines = 2,
            lineSpacingMultiplier = 1.1,
            textSize = "14sp",
            textColor = "#333333",
        },
        {
            TextView,
            layout_gravity = "bottom",
            id = "tv_desc",
            layout_width = "fill",
            layout_marginRight = '100dp',
            layout_marginBottom = '12dp',
            maxLines = 3,
            lineSpacingMultiplier = 1.1,
            textSize = "11sp",
            textColor = "#888888",
        },
        {View, layout_width = "fill", layout_height = "1dp", background="#f1f1f1",},
    }


    local hadLoadData
    local isVisible
    local lastId
    local params = { rid = rid, page = 1}
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
                        views.tv_title.setTypeface(nil, 1);
                    end
                    local views = convertView.getTag()
                    local item = data[position]
                    if item then
                        if item.img then
                            views.iv_image.setVisibility(0)
                            pcall(function() 
                                print(item.img)
                                LuaImageLoader.load(views.iv_image, item.img or "")
                            end)
                        else
                            views.iv_image.setVisibility(8)
                        end
                        views.tv_title.setText(item.title or '')
                        views.tv_desc.setText(item.content or '')
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
