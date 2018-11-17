package androlua.widget.video;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;

import org.json.JSONException;
import org.json.JSONObject;

import androlua.LuaImageLoader;
import androlua.base.BaseActivity;
import cn.jzvd.JZVideoPlayer;
import cn.jzvd.JZVideoPlayerStandard;
import pub.hanks.luajandroid.R;

/**
 * Created by hanks on 2017/6/2. Copyright (C) 2017 Hanks
 */

public class VideoPlayerActivity extends BaseActivity {

    public static void start(Context context, String json) {
        Intent starter = new Intent(context, VideoPlayerActivity.class);
        starter.putExtra("json", json);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video);
        this.getWindow().getDecorView().setBackgroundColor(Color.TRANSPARENT);
        JZVideoPlayerStandard videoplayer = (JZVideoPlayerStandard) findViewById(R.id.videoplayer);
        try {
            String extra = getIntent().getStringExtra("json");
            JSONObject json = new JSONObject(extra);
            String url = json.getString("url");
            String poster = "";
            if (json.has("poster")) {
                poster = json.getString("poster");
            }
            LuaImageLoader.load(videoplayer.thumbImageView, poster);
            videoplayer.setAllControlsVisiblity(0, 0, 0, 0, 0, View.INVISIBLE, View.INVISIBLE);
            videoplayer.setUp(url, JZVideoPlayer.SCREEN_WINDOW_LIST, "");
//            JZVideoPlayerStandard.startFullscreen(this, JZVideoPlayerStandard.class, url, "");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onBackPressed() {
        if (JZVideoPlayer.backPress()) {
            return;
        }
        super.onBackPressed();
    }

    @Override
    protected void onPause() {
        super.onPause();
        JZVideoPlayer.releaseAllVideos();
    }
}
