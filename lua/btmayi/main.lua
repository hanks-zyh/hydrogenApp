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
import "android.text.SpannableStringBuilder"
import "java.util.regex.Pattern"
import "java.util.regex.Matcher"
import "android.text.style.ForegroundColorSpan"
import "android.net.Uri"

local uihelper = require("uihelper")
local JSON = require("cjson")
local log = require("log")

-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    statusBarColor = "#DB3C2E",
    {
        LinearLayout,
        layout_width = "fill",
        layout_height = "48dp",
        background = "#DB3C2E",
        {
            EditText,
            id = 'et_key',
            layout_weight = 1,
            layout_height = "match",
            background = "#00DB3C2E",
            gravity = "center_vertical",
            paddingLeft = '12dp',
            hint = "磁力搜索",
            textColor = "#FFFFFF",
            hintTextColor = '#88ffffff',
            singleLine = true,
            maxLines = 1,
            textSize = "14sp",
        },
        {
            ImageView,
            id = 'iv_search',
            layout_width = "48dp",
            layout_height = "48dp",
            padding = '12dp',
            src = '#btmayi/search.png',
            background = '@drawable/layout_selector_tran',
        },
    },
    {
        RelativeLayout,
        layout_width = "fill",
        layout_height = "fill",
        {
            RecyclerView,
            id = "recyclerView",
            layout_width = "fill",
            layout_height = "fill",
        },
        {
            View,
            layout_width = "fill",
            layout_height = "3dp",
            background = "@drawable/shadow_line_top",
        },
        {
            TextView,
            id = "tv_loading",
            text = "加载中....",
            textSize = "12sp",
            textColor = "#888888",
            layout_margin = "16dp",
            visibility = 8,
            layout_alignParentBottom = true,
            layout_alignParentRight = true,
        }
    }
}

local item_view = {
    LinearLayout,
    orientation = 'vertical',
    layout_width = "match",
    background = '@drawable/layout_selector_tran',
    paddingTop = "16dp",
    {
        TextView,
        lineSpacingMultiplier = 1.3,
        id = "tv_title",
        layout_width = "fill",
        paddingLeft = '12dp',
        paddingRight = '12dp',
        textSize = "14sp",
        textColor = "#222222",
    },
    {
        TextView,
        layout_width = "fill",
        layout_marginTop = '8dp',
        paddingLeft = '12dp',
        paddingRight = '12dp',
        id = "tv_desc",
        textSize = "11sp",
        textColor = "#888888",
    },
    {
        TextView,
        layout_width = "fill",
        layout_height = "30dp",
        paddingLeft = '12dp',
        paddingRight = '12dp',
        gravity = 'center_vertical',
        id = "tv_magnet",
        visibility = 8,
        background = '@drawable/layout_selector_tran',
        textSize = "10sp",
        textColor = "#234567",
    },
    {
        ProgressBar,
        id = 'pb_loading',
        layout_width = "16dp",
        layout_height = "16dp",
        layout_margin = '12dp',
        visibility = 8,
    },
    {
        View,
        layout_width = "match",
        layout_height = 2,
        layout_marginTop = '16dp',
        background = '#e1e1e1',
    }
}


local data = {}
local params = { key = '', page = 1 }
local adapter

local function copyText(text)
    local clipboard = activity.getSystemService(Context.CLIPBOARD_SERVICE)
    local clip = ClipData.newPlainText("氢应用", text)
    clipboard.setPrimaryClip(clip)
    activity.toast('已复制到剪切板')
end

local function openOrCopy(item)
    if item.magnet == nil then
        activity.toast('磁力链不可用')
        return
    end
    copyText(item.magnet)
    activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(item.magnet)))
end

local function getData()
    if params.key == nil or params.key == '' then return end
    tv_loading.setVisibility(0)
    local url = string.format('http://www.cilicili8.com/search/%s/?c=&s=create_time&p=%d', params.key, params.page)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then
            print('fetch data error')
            return
        end
        uihelper.runOnUiThread(activity, function()
            tv_loading.setVisibility(8)
            if params.page == 1 then
                for i, v in ipairs(data) do
                    data[i] = nil
                end
            end
            params.page = params.page + 1
            for title, url, info in string.gmatch(body, '<div class="x[-]item row">.-<a title="(.-)".-href="(.-)".-class="tail">(.-)</div>') do
                info = info:gsub("^%s+", ""):gsub("%s+$", "")
                url = 'http://www.cilicili8.com' .. url
                data[#data + 1] = { title = title, info = info, url = url }
            end
            adapter.notifyDataSetChanged()
        end)
    end)
end

local function launchDetail(position)
    local item = data[position + 1]
    item.loading = true
    adapter.notifyItemChanged(position)
    LuaHttp.request({ url = item.url }, function(e, c, body)
        local magnet = string.match(body, "magnetQRCode[(]'(.-)'")
        item.magnet = magnet
        item.loading = false,
        uihelper.runOnUiThread(activity, function() adapter.notifyItemChanged(position) end)
    end)
end

function onDestroy()
    LuaHttp.cancelAll()
end

local function highlight(text, key)
    local spannable = SpannableStringBuilder(text)
    local p = Pattern.compile(key)
    local m = p.matcher(text)
    while m.find() do
        local span = ForegroundColorSpan(0xFFDB3C2E)
        spannable.setSpan(span, m.start(), m['end'](), 0x21)
    end
    return spannable
end


function onCreate(savedInstanceState)
    activity.setLightStatusBar()
    activity.setContentView(loadlayout(layout))
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
            local holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
            holder.itemView.setTag(views)
            holder.itemView.getLayoutParams().width = screenWidth
            holder.itemView.onClick = function()
                local p = holder.getAdapterPosition()
                launchDetail(p)
            end
            views.tv_magnet.onClick = function(v)
                local p = holder.getAdapterPosition() + 1
                openOrCopy(data[p])
            end
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local views = holder.itemView.getTag()
            if views == nil then return end
            local item = data[position]
            if item then
                views.tv_title.setText(highlight(item.title, params.key))
                views.tv_desc.setText(item.info)
                if item.magnet then
                    views.tv_magnet.setVisibility(0)
                    views.tv_magnet.setText(item.magnet)
                else
                    views.tv_magnet.setVisibility(8)
                end
                if item.loading then
                    views.pb_loading.setVisibility(0)
                else
                    views.pb_loading.setVisibility(8)
                end
            end
            if position == #data then getData() end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
    iv_search.onClick = function(v)
        local key = et_key.getText().toString()
        params.key = key
        params.page = 1
        getData()
    end
    et_key.setImeOptions(0x00000003)
    et_key.setOnEditorActionListener(luajava.createProxy('android.widget.TextView$OnEditorActionListener', {
        onEditorAction = function(v, actionId, event)
            local key = et_key.getText().toString()
            params.key = key
            params.page = 1
            getData()
            return false
        end
    }))
end
