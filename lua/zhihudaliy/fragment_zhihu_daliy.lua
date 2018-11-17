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
import "androlua.LuaImageLoader"

local uihelper = require "uihelper"
local JSON = require "cjson"

local function fetchData(id, data, adapter, fragment)
    local url
    if id then url = string.format('http://news-at.zhihu.com/api/4/theme/%d', id)
    else
        url = string.format('http://news.at.zhihu.com/api/4/news/before/%s', data.lastPage)
    end

    LuaHttp.request({ url = url }, function(error, code, body)
        local json = JSON.decode(body)
        if json.date then data.lastPage = json.date end
        local stories = json.stories
        for i = 1, #stories do
            local item = {}
            item.type = stories[i].type
            item.id = stories[i].id
            item.title = stories[i].title
            item.images = stories[i].images
            data.news[#data.news + 1] = item
        end
        uihelper.runOnUiThread(fragment.getActivity(), function()
            adapter.notifyDataSetChanged()
        end)
    end)
end

local function launchDetail(fragment, newsid)
    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'zhihudaliy/activity_zhihu_daliy_detail.lua')
    intent.putExtra("newsid", string.format('%d', newsid))
    activity.startActivity(intent)
end

function newInstance(id)

    -- create view table
    local layout = {
        ListView,
        id = "listview",
        layout_width = "fill",
        layout_height = "fill",
    }

    local item_view = {
        RelativeLayout,
        layout_height = "wrap",
        paddingLeft = "16dp",
        paddingRight = "12dp",
        paddingTop = "16dp",
        paddingBottom = "16dp",
        {
            ImageView,
            id = "iv_image",
            layout_alignParentRight = true,
            layout_width = "72dp",
            layout_height = "72dp",
        },
        {
            TextView,
            id = "tv_title",
            paddingRight = "16dp",
            maxLines = "2",
            layout_alignParentLeft = true,
            lineSpacingMultiplier = '1.3',
            textSize = "14sp",
            textColor = "#222222",
            layout_toLeftOf = "iv_image",
        },
    }

    local data = {
        news = {},
        lastPage = '99990101',
    }
    local ids = {}

    local fragment = LuaFragment.newInstance()
    local adapter
    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onDestroyView = function() end,
        onDestroy = function() end,
        onCreateView = function(inflater, container, savedInstanceState)
            return loadlayout(layout, ids)
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
                getCount = function() return #data.news end,
                getItem = function(position) return nil end,
                getItemId = function(position) return position end,
                getView = function(position, convertView, parent)
                    position = position + 1 -- lua 索引从 1开始
                    if position == #data.news then
                        if id == nil then
                            fetchData(id, data, adapter, fragment)
                        end
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
                    local item = data.news[position]
                    if item then
                        if item.images and #item.images[1] then
                            views.iv_image.setVisibility(0)
                            LuaImageLoader.load(views.iv_image, item.images[1])
                        else views.iv_image.setVisibility(8)
                        end
                        views.tv_title.setText(item.title)
                    end
                    return convertView
                end
            }))
            ids.listview.setAdapter(adapter)
            ids.listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
                onItemClick = function(adapter, view, position, id)
                    local newsid = data.news[position + 1].id
                    launchDetail(fragment, newsid)
                end,
            }))
            fetchData(id, data, adapter, fragment) -- getdata may call ther lua files
        end,
    }))
    return fragment
end

return {
    newInstance = newInstance
}
