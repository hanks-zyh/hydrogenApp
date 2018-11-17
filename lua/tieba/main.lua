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

local DialogBuilder = import "android.app.AlertDialog$Builder"
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local fragmentNews = require "tieba/fragment_news"

local sp = activity.getSharedPreferences('tieba', Context.MODE_PRIVATE)
local CONFIG_SITE = "sites"
activity.setTheme(R.style.Theme_AppCompat_NoActionBar)
-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#ff198ef1",
    {
        Toolbar,
        background = '#ff198ef1',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
        titleTextColor = "#FFFFFF",
    },
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#ff198ef1",
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

local sites = sp.getString(CONFIG_SITE, "二次元")
if not sites:find('||$') then sites = sites .. '||' end
for site in string.gmatch(sites, '(.-)||') do
    print(site)
    data.fragments[#data.fragments + 1] = fragmentNews.newInstance(site)
    data.titles[#data.titles + 1] = site .. '吧'
end

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
    activity.setStatusBarColor(0xff198ef1)
    activity.setTitle('贴吧')
    toolbar.setNavigationIcon(LuaDrawable.create('tieba/tieba.png'))
    viewPager.setAdapter(adapter)
    viewPager.setOffscreenPageLimit(#data.fragments)
    viewPager.setCurrentItem(0)
    tab.setSelectedTabIndicatorColor(0xffffffff)
    tab.setTabTextColors(0x88ffffff, 0xffffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end

function onCreateOptionsMenu(menu)
    menu.add("网页版")
    menu.add("管理站点")
    return true
end

local layout_intput = {
    LinearLayout,
    orientation = "vertical",
    layout_width = 'match',
    paddingBottom = '8dp',
    paddingRight = '8dp',
    {
        EditText,
        id = 'et',
        layout_margin = '16dp',
        layout_width = 'match',
    },
    {
        TextView,
        id = "insert_",
        text = "点我插入 || ",
        textSize = "13sp",
        textColor = "#888888",
        paddingLeft = "16dp",
        paddingRight = "16dp",
        layout_height = "48dp",
        background = "#11888888",
        layout_marginLeft = "20dp",        
        gravity = "center",
    },
}

local function manageSites()
    local ids = {}
    local view = loadlayout(layout_intput, ids, ViewGroup)
    ids.et.setText(sp.getString(CONFIG_SITE, '二次元'))
    ids.insert_.onClick = function() 
        ids.et.append("||")
    end
    DialogBuilder(activity).setTitle('多个贴吧之间用 || 分隔').setView(view).setNegativeButton('取消', nil).setPositiveButton('确定', luajava.createProxy('android.content.DialogInterface$OnClickListener', {
        onClick = function(dialog, which)
            local txt = ids.et.getText().toString()
            sp.edit().putString(CONFIG_SITE, txt).apply()
            activity.toast('保存成功，下次进入生效')
        end
    })).show()
end

function onOptionsItemSelected(item)
    local title = item.getTitle()
    if title == "网页版" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('http://c.tieba.baidu.com')))
    end
    if title == "管理站点" then
        manageSites()
    end
end