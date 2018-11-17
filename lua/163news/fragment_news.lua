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

    -- http://3g.163.com/touch/jsonp/sy/recommend/30-10.html?hasad=1&miss=25&refresh=A&offset=0&size=10&callback=syrec3
    -- http://3g.163.com/touch/jsonp/sy/recommend/40-10.html?hasad=1&miss=25&refresh=A&offset=0&size=10&callback=syrec4
    -- http://3g.163.com/touch/reconstruct/article/list/BBM54PGAwangning/10-10.html
    -- http://3g.163.com/touch/reconstruct/article/list/BBM54PGAwangning/20-10.html
    -- http://3g.163.com/touch/reconstruct/article/list/BCR1UC1Qwangning/0-10.html

    local url = string.format('http://3g.163.com/touch/reconstruct/article/list/%s/%d-10.html', params.rid, params.page * 10)
    print(url)

    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        body = body:sub(10, #body - 1)
        local arr = JSON.decode(body)[params.rid]
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
    if not item.url:find('^http://') then
        WebViewActivity.start(activity, item.skipURL, 0xFFff3333)
        return
    else
        local activity = fragment.getActivity()
        local intent = Intent(activity, LuaActivity)
        intent.putExtra("luaPath", '163news/activity_news_detail.lua')
        intent.putExtra("url", item.url)
        activity.startActivity(intent)
    end
end

local function dateStr(d)
    if type(d) == 'string' then
        local Y, M, D, h, m, s = string.match(d, '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')
        return dateStr(os.time({ day = D, month = M, year = Y, hour = h, min = m, sec = s }))
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
            LinearLayout,
            id = "layout_imgs",
            layout_below = "tv_title",
            layout_marginTop = "8dp",
            layout_marginBottom = "8dp",
            layout_width = "match",
        },
        {
            TextView,
            id = "tv_date",
            layout_below = "layout_imgs",
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
                        if item.imgextra and #item.imgextra > 0 then

                            views.iv_image.setVisibility(8)
                            views.layout_imgs.setVisibility(0)
                            views.layout_imgs.removeAllViews()
                            item.imgextra[#item.imgextra + 1] = { imgsrc = item.imgsrc }
                            local len = #item.imgextra
                            if len > 3 then len = 3 end
                            for i = 1, len do
                                local img = loadlayout(singleImg, {}, LinearLayout)
                                LuaImageLoader.load(img, item.imgextra[i].imgsrc)
                                views.layout_imgs.addView(img)
                            end
                        else
                            views.iv_image.setVisibility(0)
                            views.layout_imgs.setVisibility(8)
                            LuaImageLoader.load(views.iv_image, item.imgsrc)
                        end
                        views.tv_date.setText(string.format('%s        %s', dateStr(item.ptime), item.source))
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
