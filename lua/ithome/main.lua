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

local fragmentNews = require "ithome/fragment_news"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#D22222",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#D22222",
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

--
--        <cg n="最新" id="101" s="1" lu="http://api.ithome.com/xml/newslist/news.xml" su="http://api.ithome.com/xml/slide/slide.xml"></cg>
--        <cg n="排行榜" id="102" s="1" lu="http://api.ithome.com/xml/newslist/rank.xml" su=""></cg>
--        <cg n="三星" id="115" s="0" lu="http://api.ithome.com/xml/newslist/sanxing.xml" su=""></cg>
--        <cg n="华为" id="116" s="0" lu="http://api.ithome.com/xml/newslist/huawei.xml" su=""></cg>
--        <cg n="小米" id="117" s="0" lu="http://api.ithome.com/xml/newslist/xiaomi.xml" su=""></cg>
--        <cg n="魅族" id="118" s="0" lu="http://api.ithome.com/xml/newslist/meizu.xml" su=""></cg>
--        <cg n="OPPO" id="119" s="0" lu="http://api.ithome.com/xml/newslist/oppo.xml" su=""></cg>
--        <cg n="vivo" id="120" s="0" lu="http://api.ithome.com/xml/newslist/vivo.xml" su=""></cg>
--        <cg n="锤子" id="121" s="0" lu="http://api.ithome.com/xml/newslist/chuizi.xml" su=""></cg>
--        <cg n="LG" id="122" s="0" lu="http://api.ithome.com/xml/newslist/lg.xml" su=""></cg>
--        <cg n="联想" id="123" s="0" lu="http://api.ithome.com/xml/newslist/lenovo.xml" su=""></cg>
--        <cg n="一加" id="124" s="0" lu="http://api.ithome.com/xml/newslist/yijia.xml" su=""></cg>
--        <cg n="评测室" id="105" s="1" lu="http://api.ithome.com/xml/newslist/labs.xml" su="http://api.ithome.com/xml/slide/labs.xml"></cg>
--        <cg n="发布会" id="154" s="1" lu="http://api.ithome.com/xml/newslist/live.xml" su=""></cg>
--        <cg n="手机" id="103" s="1" lu="http://api.ithome.com/xml/newslist/phone.xml" su="http://api.ithome.com/xml/slide/phone.xml"></cg>
--        <cg n="数码" id="104" s="1" lu="http://api.ithome.com/xml/newslist/digi.xml" su="http://api.ithome.com/xml/slide/digi.xml"></cg>
--        <cg n="极客学院" id="151" s="1" lu="http://api.ithome.com/xml/newslist/geek.xml" su=""></cg>
--        <cg n="VR" id="106" s="1" lu="http://api.ithome.com/xml/newslist/vr.xml" su="http://api.ithome.com/xml/slide/vr.xml"></cg>
--        <cg n="智能汽车" id="107" s="1" lu="http://api.ithome.com/xml/newslist/auto.xml" su="http://api.ithome.com/xml/slide/auto.xml"></cg>
--        <cg n="电脑" id="108" s="1" lu="http://api.ithome.com/xml/newslist/pc.xml" su="http://api.ithome.com/xml/slide/pc.xml"></cg>
--        <cg n="安卓" id="152" s="0" lu="http://api.ithome.com/xml/newslist/android.xml" su="http://api.ithome.com/xml/slide/android.xml"></cg>
--        <cg n="网络焦点" id="111" s="0" lu="http://api.ithome.com/xml/newslist/internet.xml" su="http://api.ithome.com/xml/slide/internet.xml"></cg>
--        <cg n="行业前沿" id="112" s="0" lu="http://api.ithome.com/xml/newslist/it.xml" su="http://api.ithome.com/xml/slide/it.xml"></cg>
--        <cg n="游戏电竞" id="113" s="0" lu="http://api.ithome.com/xml/newslist/game.xml" su="http://api.ithome.com/xml/slide/game.xml"></cg>
--        <cg n="苹果" id="109" s="0" lu="http://api.ithome.com/xml/newslist/ios.xml" su="http://api.ithome.com/xml/slide/ios.xml"></cg>
--        <cg n="Windows" id="110" s="0" lu="http://api.ithome.com/xml/newslist/windows.xml" su="http://api.ithome.com/xml/slide/windows.xml"></cg>
--        <cg n="科普" id="114" s="0" lu="http://api.ithome.com/xml/newslist/discovery.xml" su="http://api.ithome.com/xml/slide/discovery.xml"></cg>

table.insert(data.fragments, fragmentNews.newInstance("news%s.xml"))
table.insert(data.titles, '最新')

table.insert(data.fragments, fragmentNews.newInstance("android%s.xml"))
table.insert(data.titles, '安卓')

table.insert(data.fragments, fragmentNews.newInstance("ios%s.xml"))
table.insert(data.titles, '苹果')

table.insert(data.fragments, fragmentNews.newInstance("windows%s.xml"))
table.insert(data.titles, 'Windows')

table.insert(data.fragments, fragmentNews.newInstance("game%s.xml"))
table.insert(data.titles, '游戏')

table.insert(data.fragments, fragmentNews.newInstance("it%s.xml"))
table.insert(data.titles, '行业前沿')


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
    activity.setStatusBarColor(0xffd22222)
    activity.setContentView(loadlayout(layout))
    viewPager.setAdapter(adapter)
    tab.setSelectedTabIndicatorColor(0xffffffff)
    tab.setTabTextColors(0x88ffffff, 0xffffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end
