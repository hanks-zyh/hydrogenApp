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
local log = require "log"

local function dateStr(d)
    if type(d) == 'string' then
        local y,m,d,h,M,s = string.match(d,'(%d%d%d%d)[-](%d%d)[-](%d%d)T(%d%d):(%d%d):(%d%d).') 
        return dateStr(os.time({ year = y, month = m, day = d, hour = h+8, min = M, sec=s}))
    end
    local now = os.time()
    local dx = now - d
    if dx < 600 then
        return '刚刚'
    elseif dx < 3600 then
        return math.floor(dx / 60) .. '分钟前'
    elseif dx < 3600 * 24 then
        return math.floor(dx / 3600) .. '小时前'
    else
        return os.date('%y-%m-%d', d)
    end
end

local function getData(params, data, adapter, fragment, swipe_layout, reload)
    local url = string.format('https://api.readhub.me/%s?pageSize=10', params.rid)
    
    if params.lastId then  
        url = string.format('https://api.readhub.me/%s?lastCursor=%d&pageSize=10', params.rid, tonumber(params.lastId))
    end
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        local json = JSON.decode(body) 
        local arr = json.data
        local lastItem = arr[#arr]
        log.print_r(lastItem)
        if lastItem.order then 
            params.lastId = lastItem.order
        else
            local y,m,d,h,M,s = string.match(lastItem.publishDate,'(%d%d%d%d)[-](%d%d)[-](%d%d)T(%d%d):(%d%d):(%d%d).')
            a = { year = y, month = m, day = d, hour = h+8, min = M, sec=s}
            params.lastId = os.time(a) * 1000
        end
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
    local url
    if item.newsArray and #item.newsArray > 0 then
        url = item.newsArray[1].mobileUrl
    end

    if item.url then url = item.url end

    if url == nil then return end
    local activity = fragment.getActivity()
    WebViewActivity.start(activity,url, 0xff406d91)
    
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
            background = '#EEEEEE',
            dividerHeight = 0,
            paddingTop = "8dp",
            clipToPadding = false,
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        FrameLayout,
        layout_width = "fill",
        {
            LinearLayout,
            background = '#FFFFFF',
            layout_marginLeft = "16dp",
            layout_marginRight = "16dp",
            layout_marginTop = "8dp",
            layout_marginBottom = "8dp",
            elevation = "2dp",
            orientation = 'vertical',
            layout_width = "fill",
            {
                TextView,
                id = "tv_title",
                layout_width = "fill",
                layout_margin = '16dp',
                maxLines = 2,
                lineSpacingMultiplier = 1.3,
                textSize = "16sp",
                textColor = "#434343",
            },
            {
                TextView,
                id = "tv_time",
                layout_width = "fill",
                layout_marginLeft = '16dp',
                layout_marginRight = '16dp',
                layout_marginBottom = '16dp',
                maxLines = 4,
                lineSpacingMultiplier = 1.3,
                textSize = "12sp",
                textColor = "#666666",
            },
        },
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
                        views.tv_title.setTypeface(nil, 1);
                    end
                    local views = convertView.getTag()
                    local item = data[position]
                    if item then
                        views.tv_title.setText(item.title or 'ERROR TITLE')
                        views.tv_time.setText( dateStr(item.updatedAt or item.publishDate or os.time() ))
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
