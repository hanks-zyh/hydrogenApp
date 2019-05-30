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
import "android.support.design.widget.TabLayout"
import "androlua.adapter.LuaFragmentPageAdapter"

local uihelper = require "uihelper"
local JSON = require "cjson"
local md5 = require "md5"
local adapter
local touchHelper
local adapterAll
local touchHelperAll
local sp = activity.getSharedPreferences("luandroid", Context.MODE_PRIVATE)
local home_bg

activity.setSwipeBackEnable(false)

local bottomBehavior = BottomSheetBehavior()
bottomBehavior.setPeekHeight(uihelper.dp2px(32))

local homeFragment, homeAdapter, homeGetData, homeIconIsDraggin, homeIconsSetDragging = (require "fragment_home").newInstance()
local listFragment, listAdapter, listGetData, listIconIsDraggin, listIconsSetDragging = (require "fragment_list").newInstance()

local data = {
    titles = { "home", "list" },
    fragments = { homeFragment, listFragment },
}

local root_layout = {
    FrameLayout,
    layout_width = "fill",
    layout_height = "fill",
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
        ViewPager,
        id = "viewPager",
        layout_width = "fill",
        layout_height = "fill",
    },
}


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
        local haveSplash = false
        for i = 1, #arr do
            if arr[i].date == today then
                haveSplash = true
                downloadSplash(arr[i])
                return
            end
        end
        if haveSplash == false then
            downloadSplash(arr[#arr])
        end
    end)
end


local pageAdapter = LuaFragmentPageAdapter(activity.getSupportFragmentManager(),
    luajava.createProxy("androlua.adapter.LuaFragmentPageAdapter$AdapterCreator", {
        getCount = function() return #data.fragments end,
        getItem = function(position)
            position = position + 1
            return data.fragments[position]
        end,
        getPageTitle = function(position)
            position = position + 1
            return data.titles[position]
        end
    }))

local function refreshData()
    viewPager.postDelayed(luajava.createProxy('java.lang.Runnable', {
        run = function()
            if viewPager.getCurrentItem() == 0 then
                homeGetData()
            elseif position == 1 then
                listGetData()
            end
        end
    }), 500)
end

function onCreate(savedInstanceState)
    activity.setLightStatusBar()
    activity.setContentView(loadlayout(root_layout))
    activity.disableDrawer()
    viewPager.setAdapter(pageAdapter)
    viewPager.setOffscreenPageLimit(#data.fragments)
    viewPager.setCurrentItem(0)
    viewPager.addOnPageChangeListener(luajava.createProxy('android.support.v4.view.ViewPager$OnPageChangeListener', {
        onPageSelected = function(position)
            refreshData()
        end
    }))

    initSplash()
end

function onResume()
    local config = JSON.decode(sp.getString('config', '{}'))

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
    end

    if config.home_bg_alpha and config.home_bg_alpha ~= '' then
        local alpah = tonumber(config.home_bg_alpha) or 9
        if alpah then
            layout_container.setAlpha(alpah / 10)
        end
    end

    refreshData()
end

local mHits = { 0, 0 }
import "android.os.SystemClock"
function onBackPressed()

    print(homeIconIsDraggin())
    if homeIconIsDraggin() then
        homeIconsSetDragging(false)
        homeAdapter.notifyDataSetChanged()
        listAdapter.notifyDataSetChanged()
        return true
    end
    print(listIconIsDraggin())

    if listIconIsDraggin() then
        listIconsSetDragging(false)
        homeAdapter.notifyDataSetChanged()
        listAdapter.notifyDataSetChanged()
        return true
    end

    if viewPager.getCurrentItem() ~= 0 then
        viewPager.setCurrentItem(0)
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