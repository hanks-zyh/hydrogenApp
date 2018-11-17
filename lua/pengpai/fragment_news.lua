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
local log = require "log"


local function getData(params, data, adapter, fragment, swipe_layout, reload)

    local url = string.format('http://www.thepaper.cn/load_chosen.jsp?nodeids=%s&topCids=1772933,1773313,1773404,1773624,1773571,&pageidx=%d&lastTime=%d', params.rid, params.page, os.time() * 1000)
    print(url)

    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        local arr = {}
       
        for img, url, title, p, source, ptime in string.gmatch(body, 'class="tiptitleImg".-<img src="(.-)".-<h2>%s+<a href="(.-)".->(.-)</a>%s+</h2>.-<p>(.-)</p>%s+<div class="pdtt_trbs">.-<a.->(.-)</a>.-<span>(.-)</span>') do
            local item = {
                img = 'http:'.. img,
                title = title,
                p = p,
                ptime = ptime,
                source = source,
                url = url
            }
            print(item)
            arr[#arr + 1] = item
        end

        uihelper.runOnUiThread(fragment.getActivity(), function()
            if reload then
                for k, _ in pairs(date) do data[k] = nil end
            end
            for i = 1, #arr do
                data[#data + 1] = arr[i]
            end
            params.page = params.page + 1
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
    local url = item.url
    if not item.url:find('^http://') then
        url = 'http://m.thepaper.cn/' .. item.url
    end
    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'pengpai/activity_news_detail.lua')
    intent.putExtra("url", url)
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
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        RelativeLayout,
        layout_width = "fill",
        layout_height = "wrap",
        paddingLeft = "16dp",
        paddingRight = "12dp",
        paddingTop = "16dp",
        paddingBottom = "16dp",
        {
            ImageView,
            id = "iv_image",
            layout_width = "110dp",
            layout_height = "83dp",
            layout_marginRight = "12dp",
            scaleType = "centerCrop",
        },
        {
            TextView,
            id = "tv_title",
            layout_toRightOf = "iv_image",
            layout_width = "fill",
            maxLines = "2",
            lineSpacingMultiplier = 1.3,
            textSize = "16sp",
            textColor = "#222222",
        },
        {
            TextView,
            id = "tv_date",
            layout_toRightOf = "iv_image",
            layout_alignParentBottom = true,
            layout_width = "fill",
            textSize = "12sp",
            textColor = "#aaaaaa",
        }
    }
    local singleImg = {
        ImageView,
        layout_width = (uihelper.getScreenWidth() - uihelper.dp2px(44)) / 3,
        layout_height = "83dp",
        layout_marginRight = "8dp",
        scaleType = "centerCrop",
    }

    local hadLoadData
    local isVisible
    local lastId
    local params = { rid = rid, page = 0 }
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

                        views.iv_image.setVisibility(0)
                        LuaImageLoader.load(views.iv_image, item.img)
                        views.tv_date.setText(string.format('%s        %s', item.ptime, item.source))
                        views.tv_title.setText(item.title)
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
