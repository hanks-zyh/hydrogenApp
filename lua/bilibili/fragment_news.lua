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
local uihelper = require "uihelper"
local JSON = require "cjson"

local function getData(rid, data, adapter, fragment, swipe_layout)
    if rid == nil then rid = 0 end
    local url = string.format('https://api.bilibili.com/x/web-interface/ranking?rid=%d&day=3&jsonp=jsonp', rid)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        local arr = JSON.decode(body).data.list
        uihelper.runOnUiThread(fragment.getActivity(), function()
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
    if item and item.aid then
        local url = string.format('https://m.bilibili.com/video/av%d.html', item.aid)
        WebViewActivity.start(activity, url, 0xFFfb7299)
        return
    end
    activity.toast('没有 url 可以打开')
end

function newInstance(rid)

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
        FrameLayout,
        layout_width = "fill",
        layout_height = "wrap",
        paddingLeft = "16dp",
        paddingRight = "12dp",
        paddingTop = "12dp",
        paddingBottom = "12dp",
        {
            ImageView,
            id = "iv_image",
            layout_gravity = "center_vertical",
            layout_width = "120dp",
            layout_height = "75dp",
            scaleType = "centerCrop",
        },
        {
            TextView,
            id = "tv_title",
            layout_marginLeft = "132dp",
            layout_width = "fill",
            maxLines = "2",
            lineSpacingMultiplier = 1.3,
            layout_gravity = "top",
            textSize = "14sp",
            textColor = "#222222",
        },
        {
            TextView,
            id = "tv_date",
            layout_gravity = "bottom",
            layout_marginLeft = "132dp",
            layout_width = "fill",
            textSize = "12sp",
            textColor = "#aaaaaa",
        }
    }
    local hadLoadData
    local isVisible
    local lastId
    local data = {}
    local ids = {}
    local adapter
    local fragment = LuaFragment.newInstance()
    local function lazyLoad()
        if not isVisible then return end
        if hadLoadData then return end
        if adapter == nil then return end
        hadLoadData = true
        getData(rid, data, adapter, fragment, ids.swipe_layout)
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
                        LuaImageLoader.load(views.iv_image, item.pic)
                        views.tv_date.setText(string.format('%d 次播放        %d 条弹幕', item.play, item.video_review))
                        views.tv_title.setText(item.title)
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
