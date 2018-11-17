require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v4.view.ViewPager"
import "android.support.design.widget.TabLayout"
import "androlua.adapter.LuaFragmentPageAdapter"
import "android.support.v7.widget.Toolbar"
import "android.support.v7.widget.RecyclerView"
import "android.support.v4.widget.SwipeRefreshLayout"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.LinearLayoutManager"
import "android.view.View"
import "java.net.URL"
import "android.net.Uri"
import "androlua.widget.picture.PicturePreviewActivity"
import "androlua.widget.webview.WebViewActivity"
import "pub.hydrogen.android.R"
import "android.support.design.widget.FloatingActionButton"
import "androlua.utils.ColorStateListFactory"
import "java.lang.String"
import "android.graphics.drawable.GradientDrawable"

local DialogBuilder = import "android.app.AlertDialog$Builder"
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"



local tabTypes = {'all','mall'}
local adapter
local data = {}
local page = 1
local sort = ""
local tab = tabTypes[1]

local filter = {
    start_price=-1,
    end_price=-1,
    filter={}
}

local bg_selector = GradientDrawable()
bg_selector.setColor(ColorStateListFactory.newInstance(0x11ffffff,0xffff0000))

activity.setTheme(R.style.Theme_AppCompat_NoActionBar)
-- create view table
local layout = {
    LinearLayout,
    layout_width = "match",
    layout_height = "match",
    orientation = "vertical",
    statusBarColor = "#ff5500",
    {
        Toolbar,
        background = '#ff5500',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
        titleTextColor = "#ffffff",
        popupTheme = R.style.ThemeOverlay_AppCompat_Light,
        {
            RelativeLayout,
            layout_width = "match",
            layout_height = "match",
            {
                EditText,
                id = 'et_key',
                layout_width = "match",
                layout_height = "match",
                maxLines = 1,
                singleLine = true,
                textColor = '#ffffff',
                hintTextColor = '#88ffffff',
                background = '#00ffffff',
                hint = "搜索商品",
                textColor = "#FFFFFF",
            }, 
            {
                ImageView,
                layout_centerVertical = true,
                layout_alignParentRight = true,
                layout_marginRight = '16dp',
                src = '#taobao/ic_search.png',
                id = 'bt_search',
            },
        },
    },
    {
        FrameLayout,
        layout_width = "match",
        layout_height = "match",
        {
            SwipeRefreshLayout,
            id = "refreshLayout",
            layout_width = "match",
            {
                RecyclerView,
                background = '#ffffff',
                id = "recyclerView",
                layout_width = "fill",
                layout_height = "fill",
            },
        },
        {
            FloatingActionButton, 
            id = 'fab',
            src = '#taobao/ic_sort.png',
            backgroundTintList = ColorStateListFactory.newInstance(0xFFFF5500),
            layout_gravity = 85,
            layout_margin = '16dp',
        },
    }
}

local item_view = {
    FrameLayout,
    layout_width = "fill",
    layout_height = "132dp",
    paddingLeft = "12dp",
    paddingRight = "12dp",
    paddingTop = "16dp",
    {
        ImageView,
        id = 'iv_image',
        layout_width = "100dp",
        layout_height = "100dp",
    },
    {
        TextView,
        id = "tv_title",
        layout_marginLeft = "108dp",
        textColor = "#4b566a",
        lineSpacingMultiplier = 1.3,
        textSize = "14sp",
        maxLines = 2,
    },
    {
        TextView,
        id = "tv_money",
        layout_marginLeft = "108dp",
        layout_marginBottom = "40dp",
        maxLines = 1,
        textSize = "17sp",
        textColor = "#ff5500",
        layout_gravity = "bottom",
    },
    {
        TextView,
        id = "tv_info",
        layout_marginLeft = "108dp",
        layout_marginBottom = "16dp",
        maxLines = 1,
        textSize = "10sp",
        textColor = "#999999",
        layout_gravity = "bottom",
    },
    {
        View,
        layout_width = 'match',
        layout_height = '0.5dp',
        background = '#eeeeee',
        layout_gravity = "bottom",
    },
}

local sortTypes = {
    names = {"综合排序","销量优先","价格从高到低","价格从低到高","信用排序"},
    keys = {"","_sale","_bid","bid","_ratesum"}
}

local function resetFilter()
    filter.start_price = -1
    filter.end_price = -1
    for i=1,#filter.filter do
        filter.filter[i] = nil
    end
end

local function launchDetail(msg)
    if msg and msg.url then
        local url = msg.url
        if url:find('^//') then url = 'https:' .. url end
        WebViewActivity.start(activity, url, 0xFFFF5500)
        return
    end

    activity.toast('没有 url 可以打开')
end

local function launchPicturePreview(msg, index)
    local urls = {}
    for i = 1, #msg.mblog.pics do
        urls[i] = msg.mblog.pics[i].large.url
    end
    local data = {
        uris = urls,
        currentIndex = index
    }
    PicturePreviewActivity.start(activity, JSON.encode(data))
end


local function fetchData(loadMore)
    -- &start_price=2&end_price=3333333&filter=service_myf
    -- https://s.m.taobao.com/search?q=多肉&sst=1&n=20&buying=buyitnow&m=api4h5&abtest=7&wlsort=7&style=list&closeModues=nav%2Cselecthot%2Conesearch&sort=_sale&page=1
    local key = et_key.getText().toString()
    if key==nil or key == '' then 
        refreshLayout.setRefreshing(false)
        return
    end
    local url = string.format("https://s.m.taobao.com/search?q=%s&tab=%s&sst=1&n=20&buying=buyitnow&m=api4h5&abtest=6&wlsort=6&sort=%s&page=%d",key,tab,sort,page)
    local t = {}
    if filter.start_price > 0 then t[#t+1] = string.format('&start_price=%d',filter.start_price) end
    if filter.end_price > 0 then t[#t+1] = string.format('&end_price=%d',filter.end_price) end
    if #filter.filter > 0 then t[#t+1] = '&filter=' .. table.concat( filter.filter, ";") end
    if #t>0 then url = url .. table.concat( t, "") end
    print(url)

    local options = {
        url = url,
    }
    LuaHttp.request(options, function(error, code, body)
        if error or code ~= 200 then
            activity.toast('网络错误')
            refreshLayout.setRefreshing(false)
            return
        end
        local listItem = JSON.decode(body).listItem
        if listItem == nil then
            listItem = {}
        end
        uihelper.runOnUiThread(activity, function()
            if page == 1 then
                for k, _ in pairs(data) do data[k] = nil end
            end
            local s = #data
            for i = 1, #listItem do
                local item = listItem[i]
                data[#data + 1] = item
            end
            page = page + 1
            if loadMore then
                adapter.notifyItemRangeChanged(s, #data)
            else
                adapter.notifyDataSetChanged()
            end
            refreshLayout.setRefreshing(false)
        end)
    end)
end


local function reload(  )
    refreshLayout.setRefreshing(true)
    page = 1
    fetchData() 
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0xFFFF5500)
    activity.setContentView(loadlayout(layout))
    activity.setSupportActionBar(toolbar)
    activity.setTitle('淘宝')
    toolbar.setTitle('淘宝')
    toolbar.setNavigationIcon(LuaDrawable.create('taobao/taobao.png'))
    toolbar.setNavigationOnClickListener(luajava.createProxy('android.view.View$OnClickListener',{
        onClick = function()
            if tab == tabTypes[1] then
                tab = tabTypes[2]
                toolbar.setNavigationIcon(LuaDrawable.create('taobao/tmall.png'))
            else
                tab = tabTypes[1]
                toolbar.setNavigationIcon(LuaDrawable.create('taobao/taobao.png'))
            end
            reload()
        end
    }))
    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function() return #data end,
        getItemViewType = function(position) return 0 end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
            holder.itemView.getLayoutParams().width = parent.getWidth()
            holder.itemView.setTag(views)
            holder.itemView.onClick = function(view)
                local position = holder.getAdapterPosition() + 1,
                print(position)
                launchDetail(data[position])
            end
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local msg = data[position]
            local views = holder.itemView.getTag()
            views.tv_title.setText(msg.title)
            views.tv_money.setText( '¥' .. msg.price)
            local fee = '免运费'
            local f = tonumber(msg.fastPostFee);
            if f and f > 0 then fee = '运费' .. f end
            views.tv_info.setText(string.format('%s    %s 人付款    %s',fee, msg.act,msg.area))
            LuaImageLoader.load(views.iv_image, 'https:'..msg.img2)
            if position == #data then fetchData(true) end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
    refreshLayout.setOnRefreshListener(luajava.createProxy('android.support.v4.widget.SwipeRefreshLayout$OnRefreshListener', {
        onRefresh = function()
            reload()
        end
    }))
    bt_search.onClick = function()
       resetFilter()
       reload()   
    end

    et_key.setImeOptions(0x00000003)
    et_key.setOnEditorActionListener(luajava.createProxy('android.widget.TextView$OnEditorActionListener', {
        onEditorAction = function(v, actionId, event)
            resetFilter()
            reload()
            return false
        end
    }))

    fab.onClick = function()
        local choiceItem = 1
        for i=1,#sortTypes.keys do
            if sort == sortTypes.keys[i] then
                choiceItem = i
            end
        end
        DialogBuilder(activity)
        .setSingleChoiceItems(sortTypes.names,choiceItem-1,luajava.createProxy('android.content.DialogInterface$OnClickListener',{
            onClick = function(dialog, which )
                dialog.dismiss()
                sort = sortTypes.keys[which+1]
                reload()
            end
        }))
        .show()
    end
end

function onCreateOptionsMenu(menu)
    menu.add("过滤").setIcon(LuaDrawable.create('taobao/ic_filter.png')).setShowAsAction(2)
    menu.add("网页版")
    return true
end


local function showFilterView()
    
    local function findCheck( parent )
       local c = parent.getChildCount()
       for i=1,c do
           local view = parent.getChildAt(i-1)
           if view.isSelected() then
                filter.filter[#filter.filter + 1] = view.getTag()
           end
       end
    end

    local function toggleCheck(v )
        v.setSelected(not v.isSelected())
        local bgColor = 0x11ffffff
        if v.isSelected() then bgColor = 0x55ffffff end
        v.setBackgroundColor(bgColor)
    end

    local function title( text )
        return {
            TextView,
            layout_marginTop = "16dp",
            layout_marginBottom = "8dp",
            text = text,
            textSize = '16sp',
        }
    end

    local function checkText(text,key)
        local selected = false
        for i=1,#filter.filter do
            if filter.filter[i] == key then
                selected = true
            end
        end
        local bgColor = 0x11ffffff
        if selected then bgColor = 0x55ffffff end 
        return 
        {
            TextView,
            backgroundColor = bgColor,
            gravity = "center",
            layout_weight = 1,
            layout_height = '30dp',
            layout_marginRight = "8dp",
            layout_marginTop= "8dp",
            text = text,
            textSize = '12sp',
            tag = key,
            clickable = true,
            selected = selected,
            onClick = toggleCheck,
        }
    end

    local filter_view = {
        LinearLayout,
        orientation="vertical",
        layout_width = "fill",
        padding = '16dp',
        title("价格区间"),
        {
            LinearLayout,
            layout_width = "fill",
            gravity= "center_vertical",
            {EditText, id = "et_price_start", textSize='13sp', layout_width = '100dp', hint = '最低价', inputType = "number", },
            {View, layout_height = "1dp",  layout_width = "8dp", background = "#eeeeee", layout_margin = "4dp", },
            {EditText, id = "et_price_end", textSize='13sp', layout_width = '100dp', hint = '最高价', inputType = "number", }, 
        },
        title("折扣和服务"),
        {
            LinearLayout,
            id = "layout_zk_1",
            layout_width = "fill",
            checkText("免运费","service_myf"),
            checkText("天猫","tab_mall"),
            checkText("全球购","service_hwsp"),
        },
        {
            LinearLayout,
            id = "layout_zk_2",
            layout_width = "fill",
            checkText("消费者保障","service_xfzbz"),
            checkText("手机专享价","service_sjzx"),
            checkText("淘金币","service_tjb"),
        },
        {
            LinearLayout,
            id = "layout_zk_3",
            layout_width = "fill",
            checkText("促销","tab_discount"),
            checkText("7天退换","service_qtth"),
            checkText("货到付款","service_hdfk"),
        },
    }

    local views = {}
    local view = loadlayout(filter_view,views,ViewGroup)
    if filter.start_price > 0 then views.et_price_start.setText(''..filter.start_price) end
    if filter.end_price >0 then views.et_price_end.setText(''..filter.end_price) end
    DialogBuilder(activity).setView(view).setNegativeButton('取消', nil).setPositiveButton('确定', luajava.createProxy('android.content.DialogInterface$OnClickListener', {
        onClick = function(dialog, which)

            resetFilter()

            local p_s = views.et_price_start.getText().toString()
            if p_s and p_s ~= '' then filter.start_price = tonumber(p_s) end

            local p_e = views.et_price_end.getText().toString()
            if p_e and p_e ~= '' then filter.end_price = tonumber(p_e) end

            findCheck(views.layout_zk_1)
            findCheck(views.layout_zk_2)
            findCheck(views.layout_zk_3)

            if filter.start_price > filter.end_price then filter.start_price,filter.end_price = filter.end_price,filter.start_price end
            log.print_r(filter)
            reload()
        end
    })).show()
end 

function onOptionsItemSelected(item)
    local title = item.getTitle()
    if title == "网页版" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('https://s.m.taobao.com/h5')))
    elseif title == '过滤'  then
       showFilterView()
    end
end


