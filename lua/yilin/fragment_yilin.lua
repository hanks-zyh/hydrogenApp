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
import "java.lang.String"

local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"

local pageList = {}


local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

local function getData(params, data, adapter, fragment, swipe_layout, reload)

    local function getPageList()
        LuaHttp.request({ url = 'http://www.92yilin.com/' }, function(error, code, body)
            for booklist in string.gmatch(body, "<table class='booklist'>(.-)</table>") do
                local arr = {}
                for td in string.gmatch(booklist, '<td.-</td>') do
                    if not td:find('colspan') then
                        local url = string.match(td, "<a href=.(.-).%s")
                        arr[#arr + 1] = url
                    end
                end
                pageList[#pageList + 1] = arr
            end
            getData(params, data, adapter, fragment, swipe_layout, reload)
        end)
    end

    if #pageList == 0 then
        getPageList(params, data, adapter, fragment, swipe_layout, reload)
        return
    end

    local list = pageList[params.id]
    local pageUrl = 'http://www.92yilin.com/' .. list[params.page]
    LuaHttp.request({ url = pageUrl }, function(error, code, body)
        if error or code ~= 200 then return end
        uihelper.runOnUiThread(fragment.getActivity(), function()
            if reload then
                for k, _ in pairs(data) do data[k] = nil end
            end
            for span in string.gmatch(body, "<span.->.-</span>") do
                if span:find('maglisttitle') then
                    local url, title = string.match(span, '<a .- href="(.-)" title="(.-)">')
                    data[#data + 1] = { title = title, url = pageUrl:gsub('index.html', url) }
                else
                    local h2 = string.match(span, '<span.->(.-)</span>')
                    h2 = trim(h2)
                    data[#data + 1] = { h2 = h2 }
                end
            end
            params.page = params.page + 1
            adapter.notifyDataSetChanged()
            swipe_layout.setRefreshing(false)
            swipe_layout.setEnable(false)
        end)
    end)
end

local function launchDetail(fragment, item)
    local activity = fragment.getActivity()
    if item == nil or item.url == nil then
        return
    end

    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'yilin/activity_detail.lua')
    intent.putExtra("url", '' .. item.url)
    activity.startActivity(intent)
end

local function newInstance(id)

    -- create view table
    local layout = {
        SwipeRefreshLayout,
        layout_width = "fill",
        layout_height = "fill",
        id = "swipe_layout",
        {
            ListView,
            id = "listview",
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        LinearLayout,
        layout_width = "fill",
        layout_height = "wrap",
        orientation = "vertical",
        {
            TextView,
            id = "tv_h1",
            layout_height = "40dp",
            layout_width = "fill",
            paddingLeft = "16dp",
            gravity = "center_vertical",
            textSize = "14sp",
            visibility = "gone",
            background = "#eef1f6",
            textColor = "#1f2d3d",
        },
        {
            TextView,
            id = "tv_title",
            layout_height = "56dp",
            layout_width = "fill",
            paddingLeft = "16dp",
            paddingRight = "16dp",
            singleLine = true,
            ellipsize = "end",
            gravity = "center_vertical",
            textSize = "14sp",
            textColor = "#1f2d3d",
        }
    }

    local hadLoadData
    local isVisible
    local data = {}
    local params = { id = id, page = 1 }
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
                        if item.h2 then
                            views.tv_h1.setVisibility(0)
                            views.tv_title.setVisibility(8)
                            views.tv_h1.setText(item.h2 or '意林')
                        else
                            views.tv_h1.setVisibility(8)
                            views.tv_title.setVisibility(0)
                            views.tv_title.setText(' · ' .. item.title)
                        end
                    end

                    if position == #data then
                        getData(params, data, adapter, fragment, ids.swipe_layout)
                    end

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
