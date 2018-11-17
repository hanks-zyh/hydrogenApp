require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v7.widget.AppCompatSeekBar"
import "android.support.design.widget.FloatingActionButton"
import "android.graphics.drawable.GradientDrawable"
import "android.os.Build"
import "android.animation.ValueAnimator"
local Orientation = import "android.graphics.drawable.GradientDrawable$Orientation"

local colors = luajava.createArray("int", { 0xFF72A3FF, 0xFF607dff })
local gd = GradientDrawable(Orientation.TOP_BOTTOM, colors)

local function text(text)
    return {
        TextView,
        layout_marginLeft = '16dp',
        layout_marginTop = '12dp',
        layout_marginBottom = '4dp',
        text = text,
        textColor = '#AAAAAA',
        textSize = "10sp",
    }
end

local function seekBar(id_sb, max, progress, id_tv, text)
    return {
        LinearLayout,
        gravity = 'center_vertical',
        layout_width = 'match',
        paddingLeft = '2dp',
        {
            AppCompatSeekBar,
            layout_weight = 1,
            id = id_sb,
            max = max,
            progress = progress,
        },
        {
            TextView,
            layout_width = '20dp',
            id = id_tv,
            gravity = 'right',
            textSize = '10sp',
            text = text,
        },
    }
end

local layout = {
    FrameLayout,
    layout_width = "match",
    layout_height = "match",
    background = "#f1f1f1",
    {
        ImageView,
        id = 'iv_bg',
        layout_width = "match",
        layout_height = "360dp",
    },
    {
        FrameLayout,
        layout_width = "match",
        layout_gravity = "bottom",
        layout_marginBottom = "24dp",
        layout_marginLeft = "16dp",
        layout_marginRight = "16dp",
        {
            LinearLayout,
            layout_width = "match",
            layout_marginBottom = "32dp",
            background = "#ffffff",
            orientation = "vertical",
            paddingBottom = "24dp",
            paddingLeft = "16dp",
            paddingRight = "16dp",
            paddingTop = "16dp",
            text('女方年龄 （40岁以上女性本公式不适用）'),
            seekBar('seek_af', 40, 20, 'tv_af', '20'),
            text('女方外貌 （10为满分）'),
            seekBar('seek_lf', 10, 5, 'tv_lf', '5'),
            text('男方外貌 （10为满分）'),
            seekBar('seek_lm', 10, 5, 'tv_lm', '5'),
            text('男方资产（价值），每10万港元为1个单位，无上限'),
            {
                LinearLayout,
                gravity = 'center_vertical',
                layout_width = 'match',
                paddingLeft = '2dp',
                {
                    AppCompatSeekBar,
                    layout_weight = 1,
                    id = 'seek_wm',
                    max = 100,
                    progress = 0,
                },
                {
                    EditText,
                    inputType = 'number',
                    background = '#00FFFFFF',
                    layout_width = '20dp',
                    id = 'tv_wm',
                    gravity = 'right',
                    textSize = '10sp',
                    text = '0',
                },
            },
            text('女方曾有性行为的男性数目（性伴侣）'),
            seekBar('seek_sf', 15, 0, 'tv_sf', '0'),
            {
                View,
                layout_height = '16dp',
            },
        },
        {
            FloatingActionButton,
            id = "fab",
            layout_width = "48dp",
            layout_height = "48dp",
            layout_gravity = 81,
            layout_marginBottom = "12dp",
            src = '#papapatimer/check.png',
            elevation = "2dp",
        },
    },
    {
        LinearLayout,
        layout_width = "match",
        layout_height = "match",
        gravity = "center_horizontal",
        orientation = "vertical",
        {
            ImageView,
            layout_width = '120dp',
            layout_height = '16dp',
            layout_marginTop = "34dp",
            src = '#papapatimer/title.png',
        },
        {
            LinearLayout,
            layout_marginTop = '24dp',
            gravity = "bottom",
            {
                TextView,
                id = 'tv_left',
                textColor = "#fafafa",
                text = '交往',
                textSize = "10sp",
            },
            {
                TextView,
                id = "tv_result",
                layout_marginLeft = "8dp",
                layout_marginRight = "8dp",
                textColor = "#ffffff",
                textSize = "36sp",
                text = '999',
            },
            {
                TextView,
                id = 'tv_right',
                text = '天后',
                textColor = "#fafafa",
                textSize = "10sp",
            },
        },
        {
            LinearLayout,
            layout_marginTop = '12dp',
            gravity = "center_vertical",
            {
                ImageView,
                layout_width = '12dp',
                layout_height = '12dp',
                src = '#papapatimer/me.png',
            },
            {
                ImageView,
                id = 'iv_line',
                layout_width = '100dp',
                layout_height = '36dp',
                layout_margin = '12dp',
                src = '#papapatimer/line.png',
            },
            {
                ImageView,
                layout_width = '12dp',
                layout_height = '12dp',
                src = '#papapatimer/fe.png',
            },
        },
    },
}

local function bindSeekText(sb_id, tv_id)
    sb_id.setOnSeekBarChangeListener(luajava.createProxy('android.widget.SeekBar$OnSeekBarChangeListener', {
        onProgressChanged = function(sb, progress, fromUser)
            tv_id.setText(string.format('%d', progress))
        end
    }))
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))
    bindSeekText(seek_af, tv_af)
    bindSeekText(seek_lf, tv_lf)
    bindSeekText(seek_lm, tv_lm)
    bindSeekText(seek_wm, tv_wm)
    bindSeekText(seek_sf, tv_sf)
    if Build.VERSION.SDK_INT < 16 then
        iv_bg.setBackgroundDrawable(gd)
    else
        iv_bg.setBackground(gd)
    end


    fab.onClick = function(view)
        local v_af = seek_af.getProgress()
        local v_lm = seek_lm.getProgress()
        local v_lf = seek_lf.getProgress()
        local v_sf = seek_sf.getProgress()
        local v_wm = tonumber(tv_wm.getText().toString())
        local res = ((40 - v_af) * (40 - v_af) + v_lf * v_lf * v_lf) * 10 / ((v_lm * v_lm + v_wm) * (v_sf + 1) * (v_sf + 1));
        local text = string.format('%.2f', res)
        if text:find('.') then
            text = text:gsub('0+$', '')
            if text:find('[.]$') then
                text = text:sub(1, #text - 1)
            end
        end
        if text == 'inf' then
            text = '洗洗睡吧'
            tv_left.setVisibility(8)
            tv_right.setVisibility(8)
        else
            tv_left.setVisibility(0)
            tv_right.setVisibility(0)
        end
        tv_result.setText(text)

        local arr = luajava.createArray('float', { 1, 1.1, 0.9, 1.1, 0.9, 1 })
        local animator = ValueAnimator.ofFloat(arr).setDuration(500)
        animator.addUpdateListener(luajava.createProxy('android.animation.ValueAnimator$AnimatorUpdateListener', {
            onAnimationUpdate = function(animation)
                local value = animation.getAnimatedValue();
                if iv_line then
                    iv_line.setScaleX(value)
                    iv_line.setScaleY(value)
                end
            end
        }))
        animator.start();
    end

    local info = [[        一条在线计算拍拖几天可以啪啪啪公式，纯理论，只作参考，实战一定有误差，过可理论日子都没啪到请先自我检讨。
    
        可以作为自己交往妹子，什么时候提出啪啪啪作为依据，以免被拒绝好尴尬。。。
]]
    iv_line.onClick = function()
        local DialogBuilder = import "android.app.AlertDialog$Builder"
        DialogBuilder(activity).setMessage(info).show()
    end
end
