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

local fragmentNews = require "it168/fragment_news"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#3164ba",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#3164ba",
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


table.insert(data.fragments, fragmentNews.newInstance(1,2))
table.insert(data.titles, '评测')

table.insert(data.fragments, fragmentNews.newInstance(1,0))
table.insert(data.titles, '手机')

table.insert(data.fragments, fragmentNews.newInstance(8,0))
table.insert(data.titles, '笔记本')
table.insert(data.titles, '手机')

table.insert(data.fragments, fragmentNews.newInstance(4,0))
table.insert(data.titles, '键盘鼠标')


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
    activity.setStatusBarColor(0xff3164ba)
    activity.setContentView(loadlayout(layout))
    viewPager.setAdapter(adapter)
    tab.setSelectedTabIndicatorColor(0xffffffff)
    tab.setTabTextColors(0x88ffffff, 0xffffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end
