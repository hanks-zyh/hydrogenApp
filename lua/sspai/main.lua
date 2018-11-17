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
local fragmentNews = require "sspai/fragment_news"


-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#D8171C",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#D8171C",
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


table.insert(data.fragments, fragmentNews.newInstance('p14'))
table.insert(data.titles, '每日更新')

table.insert(data.fragments, fragmentNews.newInstance('p15756'))
table.insert(data.titles, 'Matrix')

table.insert(data.fragments, fragmentNews.newInstance('p15757'))
table.insert(data.titles, '效率工具')

table.insert(data.fragments, fragmentNews.newInstance('p15912'))
table.insert(data.titles, '手机摄影')

table.insert(data.fragments, fragmentNews.newInstance('p15913'))
table.insert(data.titles, '生活方式')

table.insert(data.fragments, fragmentNews.newInstance('p15914'))
table.insert(data.titles, '游戏')

table.insert(data.fragments, fragmentNews.newInstance('p15104'))
table.insert(data.titles, '硬件')

table.insert(data.fragments, fragmentNews.newInstance('p15915'))
table.insert(data.titles, '人物')

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
