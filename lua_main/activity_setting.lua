require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v7.widget.AppCompatCheckBox"
import "android.net.Uri"
import "java.io.File"
import "androlua.utils.DialogUtils"
import "android.support.v7.widget.AppCompatSeekBar"
import "androlua.common.LuaFileUtils"
import "android.graphics.BitmapFactory"
local Media = import "android.provider.MediaStore$Images$Media"
local CompressFormat = import "android.graphics.Bitmap$CompressFormat"

local DialogBuilder = import "android.app.AlertDialog$Builder"

local JSON = require "cjson"
local config_file = "luandroid"
local sp = activity.getSharedPreferences(config_file, Context.MODE_PRIVATE)
local CODE_PICK_BG, CODE_PICK_LOGO, CODE_PICK_SPLASH = 0x1, 0x2, 0x3
local config = JSON.decode(sp.getString('config', '{}'))

local divider = {
    View,
    layout_width = "match",
    layout_height = "0.5dp",
    background = "#f1f1f1",
}

local dialog_progress = {
    RelativeLayout,
    padding = "16dp",
    {
        TextView,
        id = 'tv_progress',
        layout_alignParentRight = true,
        layout_centerVertical = true,
        textSize = "14sp",
        textColor = "#444444",
    },
    {
        AppCompatSeekBar,
        id = 'progress',
        layout_width = "fill",
        layout_toLeftOf = "tv_progress"
    }
}

local function layoutTitle(text)
    return {
        TextView,
        layout_width = "fill",
        layout_height = "16dp",
        textColor = "#666666",
        background = "#fafafa",
        textSize = "13sp",
        gravity = "center_vertical",
        paddingLeft = "16dp",
    }
end

local function layoutText(text, id, tvId)
    return {
        LinearLayout,
        id = id,
        layout_height = "48dp",
        layout_width = "fill",
        orientation = "horizontal",
        gravity = "center_vertical",
        background = "@drawable/layout_selector_tran",
        {
            TextView,
            paddingLeft = "16dp",
            text = text,
            textColor = "#444444",
            textSize = "14sp",
        },
        {
            TextView,
            id = tvId,
            singleLine = true,
            ellipsize = "middle",
            layout_width = "fill",
            paddingLeft = "16dp",
            paddingRight = "16dp",
            gravity = 'right',
            textColor = "#999999",
            textSize = "12sp",
        }
    }
end

local function layoutCheckBox(text, id, checked)
    return {
        RelativeLayout,
        layout_width = "match",
        layout_height = "48dp",
        paddingLeft = "16dp",
        {
            TextView,
            text = text,
            textColor = "#444444",
            textSize = "14sp",
            layout_centerVertical = true,
        },
        {
            AppCompatCheckBox,
            id = id,
            layout_width = "50dp",
            layout_height = "50dp",
            layout_centerVertical = true,
            layout_alignParentRight = true,
            checked = checked,
        }
    }
end

local layout_content = {
    ScrollView,
    layout_width = "fill",
    layout_height = "fill",
    background = "#FFFFFF",
    {
        LinearLayout,
        layout_width = "fill",
        layout_height = "fill",
        orientation = "vertical",

        layoutTitle('界面'),
        layoutText('首页背景', 'layout_home_bg', 'tv_home_bg'),
        divider,
        layoutText('首页Logo', 'layout_home_logo', 'tv_home_logo'),
        divider,
        layoutText('APP启动图', 'layout_home_splash', 'tv_home_splash'),
        divider,
        layoutText('图标圆角大小', 'layout_home_radius', 'tv_home_radius'),
        divider,
        layoutText('背景不透明度', 'layout_home_alpha', 'tv_home_alpha'),
        divider,
        layoutText('恢复默认设置', 'layout_reset'),

        layoutTitle('其他'),
        {
            LinearLayout,
            id = 'layout_support',
            layout_height = "48dp",
            layout_width = "fill",
            orientation = "horizontal",
            gravity = "center_vertical",
            background = "@drawable/layout_selector_tran",
            {
                TextView,
                paddingLeft = "16dp",
                text = '续一秒(๑￫ܫ￩)',
                textColor = "#D86758",
                textSize = "14sp",
            },
        },
        divider,
        layoutText('应用评分/更新', 'layout_market'),
        divider,
        layoutText('推荐给好基友', 'layout_shareapp'),

        layoutTitle(''),
    }
}

local layout = {
    LinearLayout,
    layout_width = "match",
    layout_height = "match",
    orientation = "vertical",
    background = "#666666",
    statusBarColor = "#222222",
    {
        LinearLayout,
        orientation = "horizontal",
        layout_width = "fill",
        layout_height = "56dp",
        background = "#222222",
        gravity = "center_vertical",
        {
            ImageView,
            id = "back",
            layout_width = "56dp",
            layout_height = "56dp",
            src = "@drawable/ic_menu_back",
            background = "@drawable/layout_selector_tran",
            scaleType = "centerInside",
        },
        {
            TextView,
            layout_height = "56dp",
            layout_width = "fill",
            id = "tv_title",
            gravity = "center_vertical",
            paddingLeft = "8dp",
            textColor = "#FFFFFF",
            textSize = "16sp",
            text = "设置",
        },
    },
    {
        FrameLayout,
        layout_width = "fill",
        layout_height = "fill",
        layout_content,
        {
            View,
            layout_width = "fill",
            layout_height = "3dp",
            background = "@drawable/shadow_line_top",
        }
    },
}

local function layout_item_pay(id, drawable, text)
    return {
        LinearLayout,
        gravity = 'center_vertical',
        background = '@drawable/layout_selector_tran',
        paddingTop = '8dp',
        paddingLeft = '8dp',
        paddingBottom = '8dp',
        id = id,
        {
            ImageView,
            layout_width = '72dp',
            layout_height = '72dp',
            src = drawable,
        },
        {
            TextView,
            layout_width = '200dp',
            textSize = '14sp',
            paddingLeft = '8dp',
            textColor = '#222222',
            text = text,
        },
    }
end

local layout_pay = {
    LinearLayout,
    layout_width = 'fill',
    background = '#ffffff',
    orientation = 'vertical',
    gravity = 'center',
    layout_item_pay('iv_wechat', '@drawable/wechat', '微信捐赠（zyhan8866）'),
    layout_item_pay('iv_alipay', '@drawable/alipay', '支付宝捐赠'),
    layout_item_pay('iv_qq', '@drawable/qq', 'QQ捐赠（1161745215）'),
}

local function updateConfigUI(config)
    if config == nil then return end
    tv_home_bg.setText(config.home_bg or '默认')
    tv_home_logo.setText(config.home_logo or '默认')
    tv_home_splash.setText(config.home_splash or '自动(每日一张)')
    tv_home_radius.setText(config.home_icon_radius or '40')
    tv_home_alpha.setText(config.home_bg_alpha or '9')
end

local function saveConfig(config)
    sp.edit().putString("config", JSON.encode(config)).apply()
    updateConfigUI(config)
end

local function getIdentifier(type, name) -- drawable  ic_back
    return activity.getResources().getIdentifier(name, type, activity.getPackageName())
end

local function copyText(text)
    local clipboard = activity.getSystemService(Context.CLIPBOARD_SERVICE)
    local clip = ClipData.newPlainText("氢应用", text)
    clipboard.setPrimaryClip(clip)
end

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    activity.disableDrawer()
    updateConfigUI(config)
    back.onClick = function()
        activity.finish()
    end

    layout_market.onClick = function()
        local intent = Intent(Intent.ACTION_VIEW)
        intent.setData(Uri.parse('market://details?id=pub.hydrogen.android'))
        activity.startActivity(intent)
    end

    layout_home_bg.onClick = function()
        pcall(function()
            activity.toast('长按可恢复默认')
            local intent = Intent(Intent.ACTION_GET_CONTENT)
            intent.setType("image/*")
            activity.startActivityForResult(intent, CODE_PICK_BG)
        end)
    end

    layout_home_logo.onClick = function()
        pcall(function()
            activity.toast('长按可恢复默认')
            local intent = Intent(Intent.ACTION_GET_CONTENT)
            intent.setType("image/*")
            activity.startActivityForResult(intent, CODE_PICK_LOGO)
        end)
    end

    layout_home_splash.onClick = function()
        pcall(function()
            activity.toast('长按可恢复默认')
            local intent = Intent(Intent.ACTION_GET_CONTENT)
            intent.setType("image/*")
            activity.startActivityForResult(intent, CODE_PICK_SPLASH)
        end)
    end

    layout_home_logo.setOnLongClickListener(luajava.createProxy('android.view.View$OnLongClickListener', {
        onLongClick = function(view)
            config.home_logo = nil
            saveConfig(config)
            activity.toast('已恢复默认')
            return true
        end
    }))

    layout_home_bg.setOnLongClickListener(luajava.createProxy('android.view.View$OnLongClickListener', {
        onLongClick = function(view)
            config.home_bg = nil
            config.home_bg_alpha = '9'
            saveConfig(config)
            activity.toast('已恢复默认')
            return true
        end
    }))

    layout_home_splash.setOnLongClickListener(luajava.createProxy('android.view.View$OnLongClickListener', {
        onLongClick = function(view)
            config.home_splash = nil
            saveConfig(config)
            activity.toast('已恢复默认')
            return true
        end
    }))

    layout_home_radius.onClick = function()
        local ids = {}
        DialogBuilder(activity).setView(loadlayout(dialog_progress, ids, ViewGroup)).show()
        ids.progress.setMax(50)
        ids.progress.setProgress(tonumber(config.home_icon_radius) or 40)
        ids.tv_progress.setText(config.home_icon_radius or '40')
        ids.progress.setOnSeekBarChangeListener(luajava.createProxy('android.widget.SeekBar$OnSeekBarChangeListener', {
            onProgressChanged = function(bar, progress, fromUser)
                config.home_icon_radius = '' .. progress
                ids.tv_progress.setText(config.home_icon_radius)
                saveConfig(config)
            end
        }))
    end

    layout_home_alpha.onClick = function()
        local ids = {}
        DialogBuilder(activity).setView(loadlayout(dialog_progress, ids, ViewGroup)).show()
        ids.progress.setMax(10)
        ids.progress.setProgress(tonumber(config.home_bg_alpha) or 9)
        ids.tv_progress.setText(config.home_bg_alpha or '9')
        ids.progress.setOnSeekBarChangeListener(luajava.createProxy('android.widget.SeekBar$OnSeekBarChangeListener', {
            onProgressChanged = function(bar, progress, fromUser)
                config.home_bg_alpha = '' .. progress
                ids.tv_progress.setText(config.home_bg_alpha)
                saveConfig(config)
            end
        }))
    end

    layout_reset.onClick = function()
        DialogBuilder(activity).setTitle('重置设置').setMessage('重置到默认的设置？').setNegativeButton('取消', nil).setPositiveButton('确定', luajava.createProxy('android.content.DialogInterface$OnClickListener', {
            onClick = function(dialog, which)
                config = {}
                saveConfig(config)
            end
        })).show()
    end

    layout_shareapp.onClick = function()
        pcall(function()
            local intent = Intent(Intent.ACTION_SEND)
            intent.putExtra(Intent.EXTRA_TEXT, '震惊，所有用了这个 APP 的人都再也离不开了! http://coolapk.com/apk/pub.hydrogen.android');
            intent.setType("text/plain");
            activity.startActivity(Intent.createChooser(intent, '分享'))
        end)
    end

    layout_support.onClick = function()
        local ids = {}
        DialogBuilder(activity).setView(loadlayout(layout_pay, ids, ViewGroup)).show()
        ids.iv_wechat.onClick = function()
            copyText('zyhan8866')
            activity.toast('已复制"zyhan8866"')

            local bitmap = BitmapFactory.decodeResource(activity.getResources(), getIdentifier('drawable', 'qr_wechat'));
            local path = activity.getExternalFilesDir('qr').getAbsolutePath() .. '/qr_wechat.png'
            LuaFileUtils.bitmapToFile(bitmap, File(path), CompressFormat.PNG, 100)
            Media.insertImage(activity.getContentResolver(), path, "氢应用", "微信二维码");
            activity.toast('二维码已保存：' .. path)

            pcall(function()
                local intent = Intent(Intent.ACTION_MAIN)
                local cmp = ComponentName("com.tencent.mm", "com.tencent.mm.ui.LauncherUI")
                intent.addCategory(Intent.CATEGORY_LAUNCHER);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.setComponent(cmp);
                activity.startActivity(intent)
            end)
        end
        ids.iv_alipay.onClick = function()
            xpcall(function()
                local intentFullUrl = "intent://platformapi/startapp?saId=10000007&clientVersion=3.7.0.0718&qrcode=https%3A%2F%2Fqr.alipay.com%2Ftsx04452i1hjmquygc9be4b%3F_s%3Dweb-other&_t=1472443966571#Intent;scheme=alipayqr;package=com.eg.android.AlipayGphone;end"
                activity.startActivity(Intent.parseUri(intentFullUrl, 1))
            end,
                function()
                    local url = "https://qr.alipay.com/tsx04452i1hjmquygc9be4b"
                    activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                end)
        end
        ids.iv_qq.onClick = function()
            local qqUrl = "mqqwpa://im/chat?chat_type=wpa&uin=1161745215&version=1"
            activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(qqUrl)))
        end
    end
end

function onActivityResult(requestCode, resultCode, data)
    if resultCode ~= -1 or data == nil then
        return
    end
    local uri = data.getData()
    if requestCode == CODE_PICK_BG and uri then
        config.home_bg = uri.toString()
        saveConfig(config)
        return
    end

    if requestCode == CODE_PICK_LOGO and uri then
        config.home_logo = uri.toString()
        saveConfig(config)
        return
    end

    if requestCode == CODE_PICK_SPLASH and uri then
        config.home_splash = uri.toString()
        saveConfig(config)
        return
    end
end
