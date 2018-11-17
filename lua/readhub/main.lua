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
import "android.support.v7.widget.Toolbar"
import "pub.hydrogen.android.R"
import "android.net.Uri"
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local fragmentNews = require "readhub/fragment_news"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#FFFFFF",
    {
        Toolbar,
        background = '#FFFFFF',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
        titleTextColor = "#434343",
    },
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#FFFFFF",
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

table.insert(data.fragments, fragmentNews.newInstance('topic'))
table.insert(data.titles, '热门话题')

table.insert(data.fragments, fragmentNews.newInstance('news'))
table.insert(data.titles, '科技动态')

table.insert(data.fragments, fragmentNews.newInstance('technews'))
table.insert(data.titles, '开发者资讯')

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
    activity.setSupportActionBar(toolbar)
    activity.setStatusBarColor(0x33000000)
    activity.setTitle('ReadHub')
    toolbar.setNavigationIcon(LuaDrawable.create('readhub/readhub.png'))
    viewPager.setAdapter(adapter)
    viewPager.setOffscreenPageLimit(#data.fragments)
    viewPager.setCurrentItem(0)
    tab.setSelectedTabIndicatorColor(0xff434343)
    tab.setTabTextColors(0x88434343, 0xff434343)
    tab.setTabMode(TabLayout.MODE_FIXED)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end

function onCreateOptionsMenu(menu)
    menu.add("网页版")
    return true
end

function onOptionsItemSelected(item)
    local title = item.getTitle()
    if title == "网页版" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('https://readhub.me/')))
    end
end