--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- A news app
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v4.view.ViewPager"
import "android.support.design.widget.TabLayout"
import "androlua.adapter.LuaFragmentPageAdapter"

local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local fragmentNews = require "yilin/fragment_yilin"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#66ae28",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#66ae28",
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


table.insert(data.fragments, fragmentNews.newInstance(1))
table.insert(data.titles, '意林')

table.insert(data.fragments, fragmentNews.newInstance(2))
table.insert(data.titles, '作文素材')

table.insert(data.fragments, fragmentNews.newInstance(3))
table.insert(data.titles, '少年版')

table.insert(data.fragments, fragmentNews.newInstance(4))
table.insert(data.titles, '原创版')

table.insert(data.fragments, fragmentNews.newInstance(5))
table.insert(data.titles, '12+')


local adapter = LuaFragmentPageAdapter(activity.getSupportFragmentManager(),
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

function onCreate(savedInstanceState)

    activity.setContentView(loadlayout(layout))
    viewPager.setAdapter(adapter)
    viewPager.setOffscreenPageLimit(#data.fragments)
    viewPager.setCurrentItem(0)
    tab.setSelectedTabIndicatorColor(0xffffffff)
    tab.setTabTextColors(0x88ffffff, 0xffffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end
