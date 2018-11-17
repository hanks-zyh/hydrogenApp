package androlua.widget.picture;

import android.Manifest;
import android.app.DownloadManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.PointF;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.model.GlideUrl;
import com.bumptech.glide.load.model.LazyHeaders;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.davemorrissey.labs.subscaleview.ImageSource;
import com.davemorrissey.labs.subscaleview.ImageViewState;
import com.davemorrissey.labs.subscaleview.SubsamplingScaleImageView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;

import androlua.LuaHttp;
import androlua.adapter.LuaFragmentPageAdapter;
import androlua.base.BaseFragment;
import androlua.common.LuaFileUtils;
import androlua.common.LuaStringUtils;
import androlua.common.LuaToast;
import pub.hanks.luajandroid.R;

/**
 * Created by hanks on 2017/6/2. Copyright (C) 2017 Hanks
 */

public class PicturePreviewActivity extends AppCompatActivity {

    private LuaFragmentPageAdapter adapter;
    private ArrayList<String> uris = new ArrayList<>();
    private ArrayList<Fragment> fragments = new ArrayList<>();
    private int currentIndex;
    private ViewPager viewPager;
    private TextView tv_count;
    private ArrayList<String> headerList = new ArrayList<>();
    private boolean isVisible;
    private ImageView iv_share, iv_download;
    private Context context;

    public static void start(Context context, String json) {
        Intent starter = new Intent(context, PicturePreviewActivity.class);
        starter.putExtra("json", json);
        context.startActivity(starter);
    }


    public void setStatusBarColor(int color) {
        if (Build.VERSION.SDK_INT >= 21) {
            View decorView = getWindow().getDecorView();
            int option = View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_IMMERSIVE
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE;
            decorView.setSystemUiVisibility(option);
            getWindow().setStatusBarColor(color);
        }
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_picture);
        context = this;

        setStatusBarColor(Color.TRANSPARENT);
        getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        getWindow().getDecorView().setBackgroundColor(Color.TRANSPARENT);

        ElasticDragDismissFrameLayout dragDismissLayout = (ElasticDragDismissFrameLayout) findViewById(R.id.dragdismiss_drag_dismiss_layout);
        dragDismissLayout.addListener(new ElasticDragDismissFrameLayout.ElasticDragDismissCallback() {
            @Override
            public void onDragDismissed() {
                super.onDragDismissed();
                PicturePreviewActivity.this.supportFinishAfterTransition();
            }
        });

        dragDismissLayout.setDragElasticity(ElasticDragDismissFrameLayout.DRAG_ELASTICITY_XXLARGE);
        dragDismissLayout.halfDistanceRequired();

        tv_count = (TextView) findViewById(R.id.tv_count);
        iv_download = (ImageView) findViewById(R.id.iv_download);
        iv_share = (ImageView) findViewById(R.id.iv_share);
        viewPager = (ViewPager) findViewById(R.id.viewpager);
        adapter = new LuaFragmentPageAdapter(getSupportFragmentManager(), new LuaFragmentPageAdapter.AdapterCreator() {
            @Override
            public long getCount() {
                return fragments.size();
            }

            @Override
            public Fragment getItem(int position) {
                return fragments.get(position);
            }

            @Override
            public String getPageTitle(int position) {
                return (position + 1) + "/" + fragments.size();
            }
        });
        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                tv_count.setText(adapter.getPageTitle(position));
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
        viewPager.setAdapter(adapter);
        getData();
        iv_download.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    int hasWriteContactsPermission = ContextCompat.checkSelfPermission(PicturePreviewActivity.this,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE);
                    if (hasWriteContactsPermission != PackageManager.PERMISSION_GRANTED) {
                        requestPermission();
                    } else {
                        int currentItem = viewPager.getCurrentItem();
                        downloadPicture(context, uris.get(currentItem), headerList);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        iv_share.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    Intent sendIntent = new Intent(Intent.ACTION_SEND);
                    int i = viewPager.getCurrentItem();
                    sendIntent.putExtra(Intent.EXTRA_TEXT, uris.get(i) +  "\n来自【氢应用】https://www.coolapk.com/apk/pub.hydrogen.android " );
                    sendIntent.setType("text/plain");
                    if (sendIntent.resolveActivity(getPackageManager()) != null) {
                        startActivity(sendIntent);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void getData() {
        // { "uris":[], "currentIndex":0, "headers":["UA:android",""] }
        String str = getIntent().getStringExtra("json");

        if (TextUtils.isEmpty(str) && Intent.ACTION_VIEW.equals(getIntent().getAction())) {
            Uri uri = getIntent().getData();
            str = uri.getQueryParameter("data");
        }

        if (TextUtils.isEmpty(str)) {
            Toast.makeText(this, "数据出错", Toast.LENGTH_SHORT).show();
            return;
        }

        try {
            JSONObject json = new JSONObject(str);
            if (json.has("headers")) {
                JSONArray headers = json.getJSONArray("headers");
                for (int i = 0; i < headers.length(); i++) {
                    headerList.add(headers.getString(i));
                }
            }
            if (json.has("uris")) {
                JSONArray list = json.getJSONArray("uris");
                for (int i = 0; i < list.length(); i++) {
                    uris.add(list.getString(i));
                }
            }
            if (json.has("currentIndex")) {
                currentIndex = json.getInt("currentIndex");
            }

            tv_count.setText(String.format("%s/%s", 1, uris.size()));
            for (final String uri : uris) {
                PicturePreviewFragment fragment = PicturePreviewFragment.newInstance(uri, headerList);
                fragments.add(fragment);
            }
            adapter.notifyDataSetChanged();
            viewPager.setCurrentItem(currentIndex, false);

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    private void downloadPicture(Context context, final String uri, final ArrayList<String> headers) {
        try {
            DownloadManager manager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);  //得到系统的下载管理
            DownloadManager.Request request = new DownloadManager.Request(Uri.parse(uri));  //得到连接请求对象
            //request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_WIFI);
            if (headers != null) {
                for (String header : headers) {
                    int i = header.indexOf(":");
                    if (i <= 0) {
                        continue;
                    }
                    String key = header.substring(0, i);
                    String v = header.substring(i + 1);
                    request.addRequestHeader(key, v);
                }
            }
            request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
            request.setDescription("下载中...");
            request.setTitle("下载");
            request.setDestinationInExternalPublicDir(Environment.DIRECTORY_PICTURES, System.currentTimeMillis() + ".jpg");
            manager.enqueue(request);
            LuaToast.show("正在保存...");
        } catch (Exception e) {
            final String savePath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).getAbsolutePath() + System.currentTimeMillis() + ".jpg";
            new Thread() {
                @Override
                public void run() {
                    LuaHttp.downloadFile(uri, savePath, headers);
                }
            }.start();
            LuaToast.show("正在保存...");
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 0x200: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(this, "授权成功", Toast.LENGTH_SHORT).show();
                }
            }
        }
    }

    private void requestPermission() {
        ActivityCompat.requestPermissions(this,
                new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                0x200);
    }


    public static class PicturePreviewFragment extends BaseFragment {
        private View.OnClickListener listener;
        private SubsamplingScaleImageView iv_big;
        private ImageView iv_small;
        private View loading;

        public static PicturePreviewFragment newInstance(String uri, ArrayList<String> headerList) {
            Bundle args = new Bundle();
            args.putString("uri", uri);
            args.putStringArrayList("headers", headerList);
            PicturePreviewFragment fragment = new PicturePreviewFragment();
            fragment.setArguments(args);
            return fragment;
        }

        public static PicturePreviewFragment newInstance(String uri) {
            Bundle args = new Bundle();
            args.putString("uri", uri);
            PicturePreviewFragment fragment = new PicturePreviewFragment();
            fragment.setArguments(args);
            return fragment;
        }

        public void setOnClickImageListener(View.OnClickListener listener) {
            this.listener = listener;
        }


        @Nullable
        @Override
        public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
            return inflater.inflate(R.layout.item_pager_image, container, false);
        }


        @Override
        public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
            super.onViewCreated(view, savedInstanceState);
            final ArrayList<String> headerList = getArguments().getStringArrayList("headers");
            final String uri = getArguments().getString("uri", "");
            if (LuaStringUtils.isEmpty(uri)) {
                return;
            }
            iv_big = (SubsamplingScaleImageView) view.findViewById(R.id.iv_big);
            iv_small = (ImageView) view.findViewById(R.id.iv_small);
            loading = view.findViewById(R.id.loading);
            loading.setVisibility(View.VISIBLE);
            iv_small.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (listener != null) {
                        listener.onClick(v);
                    }
                }
            });
            iv_big.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (listener != null) {
                        listener.onClick(v);
                    }
                }
            });


            LazyHeaders.Builder builder = new LazyHeaders.Builder();
            if (headerList != null) {
                for (String header : headerList) {
                    int i = header.indexOf(":");
                    if (i <= 0) {
                        continue;
                    }
                    String key = header.substring(0, i);
                    String v = header.substring(i + 1);
                    builder.addHeader(key, v);
                }
            }
            Glide.with(iv_big.getContext())
                    .load(new GlideUrl(uri, builder.build()))
                    .downloadOnly(new SimpleTarget<File>() {
                        @Override
                        public void onResourceReady(File resource, GlideAnimation<? super File> glideAnimation) {
                            loadFile(resource);
                        }

                        @Override
                        public void onLoadFailed(Exception e, Drawable errorDrawable) {
                            super.onLoadFailed(e, errorDrawable);
                            hideLoading();
                        }
                    });
//                    .diskCacheStrategy(DiskCacheStrategy.SOURCE)
//                    .placeholder(R.drawable.bg_circle)
//                    .error(R.drawable.bg_circle)
//                    .crossFade()
//                    .into(iv_big);
        }

        private void hideLoading() {
            if (loading != null) {
                loading.setVisibility(View.GONE);
            }
        }

        public void getImageSize(File file, int[] size) {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(file.getAbsolutePath(), options);
            size[0] = options.outWidth;
            size[1] = options.outHeight;
        }

        public void loadFile(File file) {
            if (iv_big == null || loading == null) {
                return;
            }

            if (file == null || !file.exists()) {
                LuaToast.show("加载失败..");
                hideLoading();
                return;
            }

            if ("gif".equals(LuaFileUtils.getFileType(file.getAbsolutePath()))) {
                iv_small.setVisibility(View.VISIBLE);
                iv_big.setVisibility(View.GONE);
                Glide.with(this).load(file).diskCacheStrategy(DiskCacheStrategy.SOURCE).into(iv_small);
                hideLoading();
                return;
            }

            iv_small.setVisibility(View.GONE);
            iv_big.setVisibility(View.VISIBLE);

            int[] size = new int[2];
            getImageSize(file, size);
            float scale = iv_big.getWidth() * 1.0f / size[0];
            ImageViewState state = new ImageViewState(scale, new PointF(0, 0), 0);
            iv_big.setImage(ImageSource.uri(Uri.fromFile(file)), state);
            hideLoading();
        }
    }


}
