--
-- Created by IntelliJ IDEA.
-- User: hanks
-- Date: 2017/5/13
-- Time: 00:01
-- To change this template use File | Settings | File Templates.
--
require "import"

import "android.widget.*"
import "android.content.*"

local Adapter = luajava.bindClass("androlua.LuaAdapter")
local ImageLoader = luajava.bindClass("androlua.LuaImageLoader")
local LuaFragment = luajava.bindClass("androlua.LuaFragment")
local Http = luajava.bindClass("androlua.LuaHttp")
local ITHomeUtils = luajava.bindClass("pub.hanks.sample.ITHomeUtils")


function readContent(str, pattern, defalut)
    for content in string.gmatch(str, pattern) do
        return content
    end
    return defalut
end


function runOnUiThread(activity, f)
    activity.runOnUiThread(luajava.createProxy('java.lang.Runnable', {
        run = f
    }))
end



function getData(path, data, adapter, fragment)
    --  http://api.ithome.com/xml/newslist/news.xml  news_3213df6f23a21dfa.xml
    --  http://api.ithome.com/xml/slide/news.xml
    -- <cid>166</cid> 的是广告  含有 live 的是直播
    local id = ''
    if #data > 0 then
        id = '_' .. ITHomeUtils.desEncode(data[#data].newsid)
    end
    local url = string.format('http://api.ithome.com/xml/newslist/' .. path, id)
    Http.request({ url = url }, function(error, code, body)
        for item in string.gmatch(body, '<item.->(.-)</item>') do
            local news = {}
            news.cid = readContent(item, '<cid>(.-)</cid>')
            if news.cid ~= '166' then
                news.newsid = readContent(item, '<newsid>(.-)</newsid>', 0)
                news.title = readContent(item, '<title>%s*<!%[CDATA%[(.-)]]>%s*</title>', 'errorTitle')
                news.url = readContent(item, '<url>(.-)</url>', 'http://hanks.pub')
                news.postdate = readContent(item, '<postdate>(.-)</postdate>')
                news.image = readContent(item, '<image>(.-)</image>')
                news.description = readContent(item, '<description>%s*<!%[CDATA%[(.-)]]>%s*</description>')
                news.hitcount = readContent(item, '<hitcount>(.-)</hitcount>')
                news.commentcount = readContent(item, '<commentcount>(.-)</commentcount>')
                news.forbidcomment = readContent(item, '<forbidcomment>(.-)</forbidcomment>')
                data[1 + #data] = news
            end
        end
        runOnUiThread(fragment.getActivity(), function()
            adapter.notifyDataSetChanged()
        end)
    end)
end

function launchDetail(fragment, newsid)
    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'ithome/activity_news_detail.lua')
    intent.putExtra("newsid", newsid)
    activity.startActivity(intent)
end

function newInstance(path)

    -- create view table
    local layout = {
        ListView,
        id = "listview",
        layout_width = "fill",
        layout_height = "fill",
    }

    local item_view = {
        FrameLayout,
        layout_width = "fill",
        layout_height = "wrap",
        paddingLeft = "16dp",
        paddingRight = "12dp",
        paddingTop = "12dp",
        paddingBottom = "12dp",
        {
            ImageView,
            id = "iv_image",
            layout_gravity = "center_vertical",
            layout_width = "72dp",
            layout_height = "72dp",
        },
        {
            TextView,
            id = "tv_title",
            layout_marginLeft = "84dp",
            layout_width = "fill",
            maxLines = "2",
            lineSpacingMultiplier = '1.2',
            layout_gravity = "top",
            textSize = "14sp",
            textColor = "#222222",
        },
        {
            TextView,
            id = "tv_date",
            layout_gravity = "bottom",
            layout_marginLeft = "84dp",
            layout_width = "fill",
            textSize = "12sp",
            textColor = "#aaaaaa",
        }
    }

    local lastId
    local data = {}
    local ids = {}
    local contentView = loadlayout(layout, ids)

    local fragment = LuaFragment.newInstance()
    local adapter
    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onDestroyView = function() end,
        onDestroy = function() end,
        onCreateView = function(inflater, container, savedInstanceState)
            return contentView
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = Adapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
                getCount = function() return #data end,
                getItem = function(position) return nil end,
                getItemId = function(position) return position end,
                getView = function(position, convertView, parent)
                    position = position + 1 -- lua 索引从 1开始
                    if position == #data then
                        print('load more')
                        getData(path, data, adapter, fragment)
                    end
                    if convertView == nil then
                        local views = {} -- store views
                        convertView = loadlayout(item_view, views, ListView)
                        if parent then
                            local params = convertView.getLayoutParams()
                            params.width = parent.getWidth()
                        end
                        convertView.setTag(views)
                    end
                    local views = convertView.getTag()
                    local item = data[position]
                    if item then
                        ImageLoader.load(views.iv_image, item.image)
                        views.tv_date.setText(item.postdate)
                        views.tv_title.setText(item.title)
                    end
                    return convertView
                end
            }))
            ids.listview.setAdapter(adapter)
            ids.listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
                onItemClick = function(adapter, view, position, id)
                    local newsid = data[position + 1].newsid
                    launchDetail(fragment, newsid)
                end,
            }))
            getData(path, data, adapter, fragment)
        end,
    }))
    return fragment
end

return {
    newInstance = newInstance
}