require "import"
import "android.widget.*"
import "android.content.*"
import "android.support.design.widget.BottomNavigationView"
import "androlua.widget.viewpager.NoScrollViewPager"
import "androlua.utils.ColorStateListFactory"
import "androlua.LuaDrawable"
import "androlua.adapter.LuaFragmentPageAdapter"

-- local feedFragment = require("jike.fragment_feed")
local hotFragment = require("jike.fragment_hot")

local layout = {
    LinearLayout,
    orientation = "vertical",
    {
        NoScrollViewPager,
        id = "viewPager",
        layout_width = "fill",
        layout_weight = 1,
        background = "#ffffff",
    },
}

local data = {
    titles = { "热门", "热门", "订阅" },
    -- fragments = {recommendFragment.newInstance(), hotFragment.newInstance(), feedFragment.newInstance()},
    fragments = { hotFragment.newInstance() },
}

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
    activity.setStatusBarColor(0x33000000)
    activity.setContentView(loadlayout(layout))
    -- bottomView
    -- bottomView.setItemTextColor(ColorStateListFactory.newInstance(0xFFC7C7C7, 0xFF1E1E1E))
    -- bottomView.setItemIconTintList(ColorStateListFactory.newInstance(0xFFC7C7C7, 0xFF1E1E1E))
    -- local recommentDrawable = LuaDrawable.create('jike/img/recoment.png')
    -- local hotDrawable = LuaDrawable.create('jike/img/hot.png')
    -- local feedDrawable = LuaDrawable.create('jike/img/feed.png')
    -- bottomView.getMenu().add("推荐").setIcon(recommentDrawable)
    -- bottomView.getMenu().add("热门").setIcon(hotDrawable)
    -- bottomView.getMenu().add("订阅").setIcon(feedDrawable)
    -- bottomView.setOnNavigationItemSelectedListener(luajava.createProxy('android.support.design.widget.BottomNavigationView$OnNavigationItemSelectedListener', {
    --     onNavigationItemSelected = function(item)
    --         local title = item.getTitle()
    --         if title == "推荐" then viewPager.setCurrentItem(0, false) end
    --         if title == "热门" then viewPager.setCurrentItem(1, false) end
    --         if title == "订阅" then viewPager.setCurrentItem(2, false) end
    --         return true
    --     end
    -- }))

    -- viewpager
    viewPager.setAdapter(adapter)
end
