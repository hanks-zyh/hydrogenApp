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

local fragmentNews = require "appinn/fragment_news"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#B64926",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#B64926",
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


table.insert(data.fragments, fragmentNews.newInstance("https://www.appinn.com/page/%d/"))
table.insert(data.titles, '最新')

table.insert(data.fragments, fragmentNews.newInstance("https://www.appinn.com/category/android/page/%d/"))
table.insert(data.titles, 'Android')

table.insert(data.fragments, fragmentNews.newInstance("https://www.appinn.com/category/ios/page/%d/"))
table.insert(data.titles, 'Mac/iOS')

table.insert(data.fragments, fragmentNews.newInstance("https://www.appinn.com/category/chrome/page/%d/"))
table.insert(data.titles, 'Chrome')

table.insert(data.fragments, fragmentNews.newInstance("https://www.appinn.com/category/tools/page/%d/"))
table.insert(data.titles, '常用软件')


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
    activity.setStatusBarColor(0xffB64926)
    activity.setContentView(loadlayout(layout))
    viewPager.setAdapter(adapter)
    tab.setSelectedTabIndicatorColor(0xffffffff)
    tab.setTabTextColors(0x88ffffff, 0xffffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end
