--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/29
-- A zhihu daliy app
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v4.view.ViewPager"
import "android.support.design.widget.TabLayout"
import "androlua.adapter.LuaFragmentPageAdapter"
import "androlua.LuaHttp"

local JSON = require "cjson"
local uihelper = require "uihelper"
local fragment = require "zhihudaliy/fragment_zhihu_daliy"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#16A0EA",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#16A0EA",
    },
    {
        FrameLayout,
        layout_width = "fill",
        layout_height = "fill",
        {
            ViewPager,
            id = "viewPager",
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

local data = {
    titles = {},
    fragments = {},
}

local adapter

local function getData()
    LuaHttp.request({ url = "http://news-at.zhihu.com/api/4/themes" }, function(error, code, body)
        local themes = JSON.decode(body).others
        uihelper.runOnUiThread(activity, function()
            for i = 1, #themes do
                table.insert(data.titles, themes[i].name)
                table.insert(data.fragments, fragment.newInstance(themes[i].id))
            end
            adapter.notifyDataSetChanged()
        end)
    end)
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0xff16A0EA)
    activity.setContentView(loadlayout(layout))

    table.insert(data.fragments, fragment.newInstance())
    table.insert(data.titles, '首页')

    adapter = LuaFragmentPageAdapter(activity.getSupportFragmentManager(),
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
    viewPager.setAdapter(adapter)
    tab.setSelectedTabIndicatorColor(0xffffffff)
    tab.setTabTextColors(0x88ffffff, 0xffffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
    getData()
end
