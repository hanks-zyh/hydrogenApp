--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- douban - hot movie
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaHttp"
import "androlua.LuaAdapter"
import "androlua.widget.video.VideoPlayerActivity"
import "androlua.LuaImageLoader"
import "android.support.v7.widget.RecyclerView"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.LinearLayoutManager"
import "android.support.v7.widget.Toolbar"
import "android.net.Uri"
import "pub.hydrogen.android.R"
local uihelper = require("uihelper")
local JSON = require("cjson")
local log = require("log")
activity.setTheme(R.style.Theme_AppCompat_NoActionBar)
-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    statusBarColor = "#0077D9",
    {
        Toolbar,
        background = '#0077D9',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
    },
    {
        FrameLayout,
        layout_width = "fill",
        layout_height = "fill",
        {
            RecyclerView,
            background = "#f1f1f1",
            id = "recyclerView",
            layout_width = "fill",
            layout_height = "fill",
        },
        {
            View,
            layout_width = "fill",
            layout_height = "3dp",
            background = "@drawable/shadow_line_top",
        }
    }
}

local item_view = {
    LinearLayout,
    orientation = 'vertical',
    layout_width = "match",
    {
        LinearLayout,
        orientation = 'vertical',
        layout_width = "match",
        background = "@drawable/layout_selector_tran",
        padding = "16dp",
        {
            LinearLayout,
            id = 'layout_user',
            gravity = 'center_vertical',
            {
                ImageView,
                id = "iv_avatar",
                layout_width = "20dp",
                layout_height = "20dp",
                scaleType = "centerCrop",
            },
            {
                TextView,
                layout_width = "match",
                id = "tv_user",
                gravity = "center_vertical",
                paddingLeft = "8dp",
                textSize = "12sp",
                maxLines = 1,
                ellipsize = "end",
                textColor = "#929EA5",
            },
        },
        {
            TextView,
            id = "tv_title",
            layout_width = "match",
            paddingTop = "8dp",
            textSize = "16sp",
            textColor = "#212121",
        },
        {
            TextView,
            id = "tv_summary",
            layout_width = "match",
            paddingTop = "8dp",
            lineSpacingMultiplier = 1.2,
            maxLines = 5,
            textSize = "14sp",
            textColor = "#343434",
        },
        {
            TextView,
            id = "tv_info",
            layout_width = "match",
            paddingTop = "8dp",
            maxLines = 1,
            textSize = "12sp",
            textColor = "#919DA4",
        },
    },

    {
        View,
        layout_width = "match",
        layout_height = "8dp",
        background = '#E1E6EB',
    },
}

local data = {}
local adapter
local page = 0

function trim(s)
    if s == nil then return '' end
    return s:gsub('<.->', ''):gsub('\\n', ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function getData()
    local url = string.format('https://www.zhihu.com/node/ExploreRecommendListV2')
    local options = {
        url = url,
        method = 'POST',
        formData = { "method:next", 'params:{"limit":20,"offset":' .. page * 20 .. '}' }
    }
    LuaHttp.request(options, function(error, code, body)
        if error or code ~= 200 then
            print('fetch data error')
            return
        end
        page = page + 1
        local msg = JSON.decode(body).msg
        uihelper.runOnUiThread(activity, function()
            local s = #data
            for i = 1, #msg do
                local item = msg[i]:gsub('\\"', '"')
                local title, url = string.match(item, '<h2>(.-href="(.-)".-)</h2>')
                local likeCount = string.match(item, '<div class="zm[-]item[-]vote">(.-)</div>')
                local username = string.match(item, 'class="author[-]link".-</a>') or ''
                if username then username = '<' .. username end
                local desc = string.match(item, '<span.-class="bio">(.-)</span>')
                local summary = string.match(item, '<div.-class="zh[-]summary.->(.-)</div>')
                local commentCount = string.match(item, 'name="addcomment".->(.-)</a>')
                local avatar = string.match(item, '<img.-src="(.-)".-class="zm[-]list[-]avatar.-">')
                data[#data + 1] = {
                    url = trim(url),
                    title = trim(title),
                    avatar = trim(avatar),
                    username = trim(username),
                    desc = trim(desc),
                    summary = trim(summary),
                    likeCount = trim(likeCount),
                    commentCount = trim(commentCount)
                }
            end
            adapter.notifyItemRangeChanged(s, #data)
        end)
    end)
end

local function launchDetail(item)
    import "androlua.widget.webview.WebViewActivity"
    if item and item.url then
        local url = item.url
        if not url:find('^http') then url = 'https://www.zhihu.com' .. url end
        WebViewActivity.start(activity, url, 0xFF0077D9)
        return
    end
    activity.toast('没有 url 可以打开')
end

function onDestroy()
    LuaHttp.cancelAll()
end

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    activity.setSupportActionBar(toolbar)
    activity.setTitle('热门精选')
    toolbar.setNavigationIcon(LuaDrawable.create('zhihu-recommend/zhihu.png'))
    local screenWidth = uihelper.getScreenWidth()
    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function()
            return #data
        end,
        getItemViewType = function(position)
            return 0
        end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder
            holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
            holder.itemView.setTag(views)
            holder.itemView.onClick = function(view)
                local position = holder.getAdapterPosition() + 1
            end
            holder.itemView.getLayoutParams().width = screenWidth
            holder.itemView.onClick = function()
                local p = holder.getAdapterPosition() + 1
                launchDetail(data[p])
            end
            views.tv_title.setTypeface(nil, 1);
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local views = holder.itemView.getTag()
            if views == nil then return end
            local item = data[position]
            LuaImageLoader.loadWithRadius(views.iv_avatar, 20, item.avatar)
            if item.username == '' or item.username == '<' then
                views.layout_user.setVisibility(8)
            else
                views.layout_user.setVisibility(0)
                views.tv_user.setText(string.format('%s  %s', item.username, item.desc))
            end
            views.tv_title.setText(item.title)
            views.tv_summary.setText(item.summary)
            views.tv_info.setText(string.format('%d 赞同  %s', item.likeCount, item.commentCount))
            if position == #data then
                getData()
            end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
    getData()
end


function onCreateOptionsMenu(menu)
    menu.add("网页版")
    return true
end

function onOptionsItemSelected(item)
    local title = item.getTitle()
    if title == "网页版" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('https://www.zhihu.com/explore')))
    end
end