require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v4.view.ViewPager"
import "android.support.v7.widget.Toolbar"
import "androlua.LuaActivity"
import "androlua.LuaAdapter"
import "androlua.LuaImageLoader"
import "androlua.common.LuaFileUtils"
import "androlua.LuaHttp"
import "java.io.File"
import "android.os.Build"
import "android.graphics.drawable.ColorDrawable"
import "android.graphics.drawable.GradientDrawable"
import "android.support.v7.widget.RecyclerView"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.GridLayoutManager"
import "android.support.v7.widget.helper.ItemTouchHelper"
import "pub.hanks.sample.adapter.DragTouchHelper"
import "android.support.design.widget.BottomSheetBehavior"
import "android.support.design.widget.CoordinatorLayout"
import "android.support.v4.view.MotionEventCompat"
import "android.view.MotionEvent"
local FileUtils = import "androlua.common.LuaFileUtils"
local DialogBuilder = import "android.app.AlertDialog$Builder"
local uihelper = require "uihelper"
local log = require "log"
local JSON = require "cjson"
local md5 = require "md5"
local data = {}
local adapter
local touchHelper
local dataAll = {}
local adapterAll
local touchHelperAll
local config = {}
local sp = activity.getSharedPreferences("luandroid", Context.MODE_PRIVATE)
local home_bg

local gd = GradientDrawable()
gd.setShape(GradientDrawable.OVAL)
gd.setColor(0xFFFFFFFF)

activity.setSwipeBackEnable(false)

local bottomBehavior = BottomSheetBehavior()
bottomBehavior.setPeekHeight(uihelper.dp2px(32))

local layout = {
    CoordinatorLayout,
    layout_width = "fill",
    layout_height = "fill",
    focusable = true,
    focusableInTouchMode = true,
    {
        ImageView,
        id = "iv_home_bg",
        layout_width = "fill",
        layout_height = "fill",
        scaleType = "centerCrop",
    },
    {
        View,
        id = "layout_container",
        layout_width = "fill",
        layout_height = "fill",
        background = "#FAFFFFFF",
    },
    {
        LinearLayout,
        layout_width = "fill",
        layout_height = "fill",
        gravity = "center_horizontal",
        orientation = 1,
        paddingLeft = "16dp",
        paddingRight = "16dp",
        {
            RelativeLayout,
            layout_height = "48dp",
            layout_width = "fill",
            layout_marginLeft = "16dp",
            layout_marginTop = "36dp",
            layout_marginRight = "8dp",
            {
                TextView,
                id = "tv_date",
                text = "23月33日 333",
                textSize = "14sp",
                layout_centerVertical = true,
                textColor = "#aa333333",
            },
            {
                ImageView,
                id = "iv_setting",
                layout_height = "48dp",
                layout_width = "48dp",
                padding = "12dp",
                scaleType = "center",
                src = "@drawable/ic_setting",
                layout_alignParentRight = true,
            }
        },
        {
            ImageView,
            id = "iv_logo",
            layout_height = "56dp",
            layout_width = "56dp",
            layout_marginTop = "24dp",
            visibility = "invisible",
            src = "@drawable/logo_no_bg",
        },
        {
            RelativeLayout,
            layout_height = "48dp",
            layout_width = "fill",
            background = "#AAEBF0F2",
            layout_marginLeft = "16dp",
            layout_marginTop = "36dp",
            layout_marginRight = "16dp",
            {
                TextView,
                id = "tv_add_plugin",
                layout_height = "fill",
                layout_width = "fill",
                gravity = "center",
                text = "漫画 | 资讯 | 视频 | 图片",
                textColor = "#9DAEBF",
                textSize = "12sp",
            },
            {
                TextView,
                id = "tv_updateCount",
                layout_height = "18dp",
                layout_width = "18dp",
                layout_margin = "12dp",
                layout_alignParentRight = true,
                layout_centerVertical = true,
                gravity = "center",
                text = "3",
                textColor = "#9DAEBF",
                textSize = "9sp",
                elevation = "1dp",
                visibility = 8,
            },
        },
        {
            RecyclerView,
            id = "recyclerView",
            layout_width = "fill",
            layout_marginTop = "32dp",
            clipToPadding = false,
            layout_marginLeft = "8dp",
            layout_marginRight = "8dp",
            overScrollMode = 2,
            fadingEdgeLength = 0,
            verticalFadingEdgeEnabled = false,
            horizontalFadingEdgeEnabled = false,
        },
    },
    {
        LinearLayout,
        id = "bottomLayout",
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        applayout_behavior = bottomBehavior,
        {
            ImageView,
            layout_width = "fill",
            layout_height = "48dp",
            src = "@drawable/ic_arrow_up",
            scaleType = "centerInside",
            alpha = 0.9,
        },
        {
            RecyclerView,
            background = "#ffffff",
            id = "recyclerView_all",
            layout_width = "fill",
            layout_height = "fill",
            paddingTop = "40dp",
            clipToPadding = false,
            paddingLeft = "14dp",
            paddingRight = "14dp",
            overScrollMode = 2,
            fadingEdgeLength = 0,
            verticalFadingEdgeEnabled = false,
            horizontalFadingEdgeEnabled = false,
        },
    },
}

local item_view = {
    RelativeLayout,
    layout_height = "70dp",
    background = "@drawable/layout_selector_tran",
    {
        ImageView,
        id = "icon",
        layout_width = "40dp",
        layout_height = "40dp",
        layout_marginTop = "6dp",
        layout_centerHorizontal = true,
    },
    {
        TextView,
        id = "text",
        layout_below = "icon",
        textColor = "#444444",
        textSize = "9sp",
        gravity = "center",
        layout_width = "fill",
        layout_height = "22dp",
    },
    {
        ImageView,
        layout_alignParentRight = true,
        id = "ic_del",
        layout_marginRight = "2dp",
        layout_width = "24dp",
        layout_height = "24dp",
        src = "@drawable/ic_clear",
        visibility = 'gone',
    },
}

local function saveConfig(config)
    sp.edit().putString("config", JSON.encode(config)).apply()
end

local function newActivity(luaPath)
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", luaPath)
    activity.startActivity(intent)
end

local function getData()
    local sortApps = config.sortApps or {}
    local localList = LuaFileUtils.getPluginList()
    for i = 1, #localList do
        local p = localList[i - 1]
        local item = {
            id = p.getId(),
            text = p.getName(),
            launchPage = p.getMainPath(),
            icon = p.getIconPath(),
            position = 9999 + i,
        }
        data[#data + 1] = item
        for j = 1, #sortApps do
            if sortApps[j] == item.id then
                item.position = j
            end
        end
    end
    -- sort
    table.sort(data, function(l, r) return l.position < r.position end)
    adapter.notifyDataSetChanged()
    for i = 1, #data do
        dataAll[i] = data[i];
    end
    adapterAll.notifyDataSetChanged()
    -- save new config
    local newSortApps = {}
    for i = 1, #data do
        newSortApps[#newSortApps + 1] = data[i].id
    end
    config.sortApps = newSortApps
    saveConfig(config)
end

-- 获取类似 @drawable/ic_back 的资源
local function getIdentifier(type, name) -- drawable  ic_back
    return activity.getResources().getIdentifier(name, type, activity.getPackageName())
end

local function changeTextColor()
end

local function downloadSplash(item)
    if item.img == nil then return end
    local dir = activity.getExternalFilesDir("splash").getAbsolutePath()
    if not File(dir).exists() then
        File(dir).mkdirs()
    end
    local path = dir .. "/" .. md5.sumhexa(item.img);
    if File(path).exists() then
        item.img = path
        sp.edit().putString("splash", JSON.encode(item)).apply()
        return
    end
    local options = {
        url = item.img,
        outputFile = path,
    }
    LuaHttp.request(options, function(e, code, body)
        if e or code ~= 200 then return end
        if File(path).exists() then
            item.img = path
            sp.edit().putString("splash", JSON.encode(item)).apply()
        end
    end)
end

local function initSplash()
    if not LuaUtil.isWifi() then return end
    local today = os.date('%Y%m%d')
    local url = 'https://coding.net/u/zhangyuhan/p/api_luanroid/git/raw/master/api/splash'
    LuaHttp.request({ url = url }, function(e, code, body)
        if e or code ~= 200 then return end
        local arr = JSON.decode(body).data
        for i = 1, #arr do
            if arr[i].date == today then
                downloadSplash(arr[i])
                return
            end
        end
    end)
end

local function needUpdate(localList, plugin)
    for i = 1, #localList do
        local p = localList[i - 1]
        if p.getId() == plugin.id and p.getVersionCode() < plugin.versionCode then
            return true
        end
    end
    return false
end

local function checkPluginUpdate()

    if config.update_inwifi == false then return end

    local url = 'https://coding.net/u/zhangyuhan/p/api_luanroid/git/raw/master/api/plugins'
    LuaHttp.request({ url = url }, function(error, code, body)
        local localList = FileUtils.getPluginList()
        local json = JSON.decode(body)
        local list = json.data
        local count = 0
        for i = 1, #list do
            local plugin = list[i]
            if needUpdate(localList, plugin) then
                count = count + 1
            end
        end
        uihelper.runOnUiThread(activity, function()
            if count > 0 then
                tv_updateCount.setVisibility(0)
                if Build.VERSION.SDK_INT < 16 then
                    tv_updateCount.setBackgroundDrawable(gd);
                else
                    tv_updateCount.setBackground(gd);
                end
                tv_updateCount.setText(string.format('%d', count))
            else
                tv_updateCount.setVisibility(8)
            end
        end)
    end)
end

local function launchPluginManager()
    newActivity(luajava.luadir .. '/activity_plugins.lua')
end

local isDragging = false

local function getAdapter(mData, changeColor, getItemCountFunc, getTouchHelperFunc)
    return LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = getItemCountFunc,
        getItemViewType = function(position) return 0 end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
            holder.itemView.setTag(views)
            holder.itemView.getLayoutParams().width = recyclerView.getWidth() / 5 - 1
            holder.itemView.setOnTouchListener(luajava.createProxy('android.view.View$OnTouchListener', {
                onTouch = function(v, event)
                    if isDragging and MotionEventCompat.getActionMasked(event) == MotionEvent.ACTION_DOWN then
                        getTouchHelperFunc().startDrag(holder)
                    end
                    return false
                end
            }))
            holder.itemView.setOnLongClickListener(luajava.createProxy('android.view.View$OnLongClickListener', {
                onLongClick = function(v)
                    isDragging = true
                    adapter.notifyDataSetChanged()
                    adapterAll.notifyDataSetChanged()
                    return true
                end
            }))
            holder.itemView.onClick = function()
                local p = holder.getAdapterPosition() + 1
                local item = mData[p]
                newActivity(item.launchPage)
            end
            views.ic_del.onClick = function()
                local p = holder.getAdapterPosition()
                local id
                if p + 1 <= #data then
                    id = data[p + 1].id
                    table.remove(data, p + 1)
                    adapter.notifyItemRemoved(p)
                end
                if p + 1 <= #dataAll then
                    id = dataAll[p + 1].id
                    table.remove(dataAll, p + 1)
                    adapterAll.notifyItemRemoved(p)
                end
                if id then FileUtils.removePlugin(id) end
            end
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local views = holder.itemView.getTag()
            local item = mData[position]
            if views == nil or item == nil then return end
            if isDragging then
                views.ic_del.setScaleX(0)
                views.ic_del.setScaleY(0)
                views.ic_del.setVisibility(0)
                views.ic_del.animate().scaleX(1).scaleY(1).start()
            else
                views.ic_del.setVisibility(8)
            end

            local icon = item.icon
            local radius = tonumber(config.home_icon_radius or '40')
            LuaImageLoader.loadWithRadius(views.icon, radius, icon)
            views.text.setText(item.text)
            local alpha = tonumber(config.home_bg_alpha or 9)
            if changeColor and alpha <= 5 then
                views.text.setTextColor(0xFFFFFFFF)
            else
                views.text.setTextColor(0xFF444444)
            end
        end,
    }))
end

local function getTouchHelperCallback(mData, mNotifyData, mAdapter, mNotifyAdapter)
    return DragTouchHelper(luajava.createProxy('pub.hanks.sample.adapter.DragTouchHelper$Creator', {
        onMove = function(rec, holder, target)
            local fromPosition = holder.getAdapterPosition() + 1
            local toPosition = target.getAdapterPosition() + 1
            local tmp = mData[fromPosition]
            table.remove(mData, fromPosition)
            table.insert(mData, toPosition, tmp)
            mAdapter.notifyItemMoved(fromPosition - 1, toPosition - 1)
        end,
        isLongPressDragEnabled = function() return false end,
        clearView = function(rec, holder)
            local sortApps = {}
            for i = 1, #mData do
                sortApps[#sortApps + 1] = mData[i].id
            end
            config.sortApps = sortApps
            saveConfig(config)
            for i = 1, #mData do
                mNotifyData[i] = mData[i]
            end
            mNotifyAdapter.notifyDataSetChanged()
        end,
        getDragFlags = function() return 0xF end,
        getSwipeFlags = function() return 0 end,
    }))
end

local weeks = {"星期日","星期一","星期二","星期三","星期四","星期五","星期六"}
function onCreate(savedInstanceState)
    activity.setLightStatusBar()
    activity.setContentView(loadlayout(layout))
    activity.disableDrawer()

    tv_date.setText(os.date('%m月%d日 ') .. weeks[os.date('%w') + 1])
    iv_logo.onClick = function(view)
        newActivity(luajava.luadir .. '/activity_setting.lua')
    end
    iv_setting.onClick = function(view)
        newActivity(luajava.luadir .. '/activity_setting.lua')
    end
    tv_add_plugin.onClick = function(args)
        launchPluginManager()
    end

    adapter = getAdapter(data, true, function()
        local size = #data
        if size > 20 then size = 20 end
        return size
    end, function() return touchHelper end)
    recyclerView.setLayoutManager(GridLayoutManager(activity, 5))
    recyclerView.setAdapter(adapter)

    adapterAll = getAdapter(dataAll, false,
        function() return #dataAll end,
        function() return touchHelperAll end)
    recyclerView_all.setLayoutManager(GridLayoutManager(activity, 5))
    recyclerView_all.setAdapter(adapterAll)

    touchHelper = ItemTouchHelper(getTouchHelperCallback(data, dataAll, adapter, adapterAll))
    touchHelper.attachToRecyclerView(recyclerView)

    touchHelperAll = ItemTouchHelper(getTouchHelperCallback(dataAll, data, adapterAll, adapter))
    touchHelperAll.attachToRecyclerView(recyclerView_all)

    initSplash()
end

function onResume()
    config = JSON.decode(sp.getString('config', '{}'))
    for k, v in pairs(data) do
        data[k] = nil
    end
    getData()
    -- bg
    if config.home_bg and config.home_bg ~= '' then
        activity.setStatusBarColor(0x00FFFFFF)
        LuaImageLoader.load(iv_home_bg, config.home_bg)
    else
        activity.setLightStatusBar()
        iv_home_bg.setImageDrawable(ColorDrawable(0xFFFFFFFF))
    end

    local alpah = tonumber(config.home_bg_alpha or 9)
    if alpah then
        layout_container.setAlpha(alpah / 10)
        changeTextColor()
    end

    if config.home_bg_alpha and config.home_bg_alpha ~= '' then
        local alpah = tonumber(config.home_bg_alpha) or 9
        if alpah then
            layout_container.setAlpha(alpah / 10)
        end
    end

    -- logo
    if config.home_logo and config.home_logo ~= '' then
        LuaImageLoader.loadWithRadius(iv_logo, 36, config.home_logo)
    else
        iv_logo.setImageResource(getIdentifier('drawable', 'logo_no_bg'))
    end

    checkPluginUpdate()
end

local mHits = { 0, 0 }
import "android.os.SystemClock"
function onBackPressed()
    if isDragging then
        isDragging = false
        adapter.notifyDataSetChanged()
        adapterAll.notifyDataSetChanged()
        return true
    end

    if bottomBehavior.getState() ~= 4 then
        bottomBehavior.setState(4)
        return true
    end

    mHits[1] = mHits[2]
    mHits[2] = SystemClock.uptimeMillis();
    if mHits[1] + 1500 < SystemClock.uptimeMillis() then
        activity.toast("再按一次退出");
        return true
    end
    return false
end