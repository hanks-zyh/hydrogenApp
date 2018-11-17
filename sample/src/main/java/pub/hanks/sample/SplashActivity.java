package pub.hanks.sample;

import android.Manifest;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import org.json.JSONObject;

import java.util.Calendar;
import java.util.Locale;

import androlua.LuaActivity;
import androlua.LuaImageLoader;
import androlua.LuaManager;
import androlua.base.BaseActivity;
import androlua.common.LuaConstants;
import androlua.common.LuaFileUtils;
import androlua.common.LuaSp;
import androlua.common.LuaStringUtils;
import pub.hydrogen.android.BuildConfig;
import pub.hydrogen.android.R;

import static android.content.pm.PackageManager.PERMISSION_GRANTED;

public class SplashActivity extends BaseActivity {
    public static final String FILE_SP = "pub_hanks_sample";
    private ImageView iv_bg;
    private TextView tv_author, tv_day, tv_date, tv_text, tv_default;
    private View layout_default, layer;
    private LuaSp sp;

    public static void getOpenView(Context context, int type, Object iAdSuccessBack) {

    }

    public static void getOpenNativeView(Context context, int type, Object iAdSuccessBack) {

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        View decorView = getWindow().getDecorView();
        int option = View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE;
        decorView.setSystemUiVisibility(option);

        setStatusBarColor(Color.TRANSPARENT);
        setContentView(R.layout.activity_splash);
        iv_bg = (ImageView) findViewById(R.id.iv_bg);
        tv_author = (TextView) findViewById(R.id.tv_author);
        tv_text = (TextView) findViewById(R.id.tv_text);
        tv_date = (TextView) findViewById(R.id.tv_date);
        tv_day = (TextView) findViewById(R.id.tv_day);
        tv_default = (TextView) findViewById(R.id.tv_default);
        layout_default = findViewById(R.id.layer_defalut);
        layer = findViewById(R.id.layer);

        final ViewGroup layout_ad = (ViewGroup) findViewById(R.id.layout_ad);
        sp = LuaSp.getInstance("luandroid");
        initContent();
        initFiles();
        if (ActivityCompat.checkSelfPermission(this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE) != PERMISSION_GRANTED
                || ActivityCompat.checkSelfPermission(this,
                Manifest.permission.READ_EXTERNAL_STORAGE) != PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    Manifest.permission.READ_EXTERNAL_STORAGE
            }, 0x233);
        } else {
            launch();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 0x233) {
            if (ActivityCompat.checkSelfPermission(this,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE) == PERMISSION_GRANTED
                    || ActivityCompat.checkSelfPermission(this,
                    Manifest.permission.READ_EXTERNAL_STORAGE) == PERMISSION_GRANTED) {
                launch();
            } else {
                ActivityCompat.requestPermissions(this, new String[]{
                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE
                }, 0x233);
            }
        }
    }


    private void launch() {
        tv_day.postDelayed(new Runnable() {
            @Override
            public void run() {
                launchMain();
            }
        }, 2000);
    }

    private void initContent() {
        try {
            Calendar calendar = Calendar.getInstance(Locale.getDefault());
            tv_day.setText(String.format(Locale.getDefault(), "%d", calendar.get(Calendar.DAY_OF_MONTH)));
            String week = getWeekStr(calendar.get(Calendar.DAY_OF_WEEK) - 1);
            tv_date.setText(String.format(Locale.getDefault(), "/ %d月  星期%s",
                    calendar.get(Calendar.MONTH) + 1, week));
            tv_default.setText(String.format(Locale.getDefault(), "%d年%d月%d日，星期%s\n遇见你，真好",
                    calendar.get(Calendar.YEAR),
                    calendar.get(Calendar.MONTH) + 1,
                    calendar.get(Calendar.DAY_OF_MONTH),
                    week));
            String splash = sp.get("splash", "");
            String config = LuaSp.getInstance("luandroid").get("config", "");

            boolean customSplash = false;
            if (!LuaStringUtils.isEmpty(config)) {
                JSONObject configJson = new JSONObject(config);
                if (configJson.has("home_splash")) {
                    String home_splash = configJson.getString("home_splash");
                    if (home_splash != null) {
                        Log.e("==============", "initContent: " + home_splash);
                        LuaImageLoader.load(iv_bg, handleImageOnKitKat(Uri.parse(home_splash)));
                        layer.setVisibility(View.VISIBLE);
                        customSplash = true;
                    }
                }
            }
            if (!LuaStringUtils.isEmpty(splash)) {
                JSONObject json = new JSONObject(splash);
                tv_text.setText(json.getString("text"));
                tv_author.setText(json.getString("from"));
                if (!customSplash) {
                    LuaImageLoader.load(iv_bg, json.getString("img"));
                    layer.setVisibility(View.VISIBLE);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String getImagePath(Uri uri, String selection) {
        String path = null;
        Cursor cursor = getContentResolver().query(uri, null, selection, null, null);
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
            }
            cursor.close();
        }
        return path;
    }

    private String handleImageOnKitKat(Uri uri) {
        String imagePath = null;
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.KITKAT) {
            return uri.toString();
        }
        if (DocumentsContract.isDocumentUri(this, uri)) {
            String docId = DocumentsContract.getDocumentId(uri);
            if ("com.android.providers.media.documents".equals(uri.getAuthority())) {
                String id = docId.split(":")[1];
                String selection = MediaStore.Images.Media._ID + "=" + id;
                imagePath = getImagePath(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, selection);
            } else if ("com.android.providers.downloads.documents".equals(uri.getAuthority())) {
                Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"),
                        Long.valueOf(docId));
                imagePath = getImagePath(contentUri, null);
            }
        } else if ("content".equalsIgnoreCase(uri.getScheme())) {
            imagePath = getImagePath(uri, null);
        }
        return imagePath;
    }


    private String getWeekStr(int week_index) {
        String[] weeks = {"日", "一", "二", "三", "四", "五", "六"};
        if (week_index < 0) {
            week_index = 0;
        }
        return weeks[week_index];
    }

    private void initFiles() {
        new Thread() {
            @Override
            public void run() {
                super.run();
                LuaFileUtils.copyAssetsFlies("lua", LuaManager.getInstance().getLuaDir());
                LuaSp.getInstance(FILE_SP).save(LuaConstants.KEY_VERSION, BuildConfig.VERSION_CODE);
            }
        }.start();
    }

    public void launchMain() {
        Intent intent = new Intent(this, LuaActivity.class);
        intent.putExtra("luaPath", LuaManager.getInstance().getLuaDir() + "/main.lua");
//        intent.putExtra("luaPath", LuaManager.getInstance().getLuaExtDir() + "/main.lua");
        startActivity(intent);
        tv_day.postDelayed(new Runnable() {
            @Override
            public void run() {
                finish();
            }
        }, 2000);
    }
}
