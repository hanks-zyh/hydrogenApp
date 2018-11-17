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

local fragmentNews = require "bilibili/fragment_news"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#fb7299",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#fb7299",
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


table.insert(data.fragments, fragmentNews.newInstance(0))
table.insert(data.titles, '全站')

table.insert(data.fragments, fragmentNews.newInstance(1))
table.insert(data.titles, '动画')

table.insert(data.fragments, fragmentNews.newInstance(33))
table.insert(data.titles, '番剧')

table.insert(data.fragments, fragmentNews.newInstance(167))
table.insert(data.titles, '国创')

table.insert(data.fragments, fragmentNews.newInstance(23))
table.insert(data.titles, '电影')

table.insert(data.fragments, fragmentNews.newInstance(11))
table.insert(data.titles, '电视剧')

table.insert(data.fragments, fragmentNews.newInstance(3))
table.insert(data.titles, '音乐')

table.insert(data.fragments, fragmentNews.newInstance(129))
table.insert(data.titles, '舞蹈')

table.insert(data.fragments, fragmentNews.newInstance(4))
table.insert(data.titles, '游戏')

table.insert(data.fragments, fragmentNews.newInstance(36))
table.insert(data.titles, '科技')

table.insert(data.fragments, fragmentNews.newInstance(160))
table.insert(data.titles, '生活')

table.insert(data.fragments, fragmentNews.newInstance(119))
table.insert(data.titles, '鬼畜')

table.insert(data.fragments, fragmentNews.newInstance(155))
table.insert(data.titles, '时尚')

table.insert(data.fragments, fragmentNews.newInstance(5))
table.insert(data.titles, '娱乐')

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
