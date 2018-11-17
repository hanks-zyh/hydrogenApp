package androlua.widget.webview;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.ColorInt;
import android.support.annotation.Nullable;
import android.support.v4.view.GravityCompat;
import android.support.v7.widget.PopupMenu;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.TextView;

import androlua.LuaUtil;
import androlua.base.BaseActivity;
import androlua.widget.statusbar.StatusBarView;
import pub.hanks.luajandroid.R;

/**
 * Created by hanks on 2017/6/2. Copyright (C) 2017 Hanks
 */

public class WebViewActivity extends BaseActivity {

    private EditText etUrl;
    private String url, webTitle;
    private int color;
    private WebView mWebView;
    private View loading;
    private View layout_toolbar;
    private View ivRefresh, iv_more;
    private Bitmap colorBitmap;
    private Canvas canvas;
    private StatusBarView view_statusbar;

    public static void start(Context context, String url) {
        start(context, url, Color.TRANSPARENT);
    }

    public static void start(Context context, String url, int color) {
        Intent starter = new Intent(context, WebViewActivity.class);
        starter.putExtra("url", url);
        starter.putExtra("color", color);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_webview);
        etUrl = (EditText) findViewById(R.id.et_url);
        loading = findViewById(R.id.loading);
        layout_toolbar = findViewById(R.id.layout_toolbar);
        mWebView = (WebView) findViewById(R.id.webview);
        ivRefresh = findViewById(R.id.iv_refresh);
        iv_more = findViewById(R.id.iv_more);
        view_statusbar = (StatusBarView) findViewById(R.id.view_statusbar);
        colorBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.RGB_565);
        canvas = new Canvas(colorBitmap);

        WebSettings settings = mWebView.getSettings();
        settings.setUseWideViewPort(true);
        settings.setAppCacheEnabled(true);
        settings.setJavaScriptCanOpenWindowsAutomatically(true);
        settings.setDisplayZoomControls(false);
        settings.setSupportMultipleWindows(true);
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowContentAccess(true);
        settings.setDatabaseEnabled(true);

        if (Build.VERSION.SDK_INT >= 19) {
            mWebView.setWebContentsDebuggingEnabled(true);
        }

        url = getIntent().getStringExtra("url");
        color = getIntent().getIntExtra("color", 0);
        if (color == Color.TRANSPARENT) {
            setLightStatusBar();
        } else {
            setStatusBarColor(color);
            layout_toolbar.setBackgroundColor(color);
        }
        etUrl.setText(url);
        etUrl.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (TextUtils.isEmpty(url) || TextUtils.isEmpty(webTitle)) {
                    return;
                }
                if (hasFocus) {
                    etUrl.setText(url);
                } else {
                    etUrl.setText(webTitle);
                }
            }
        });
        mWebView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int newProgress) {
                super.onProgressChanged(view, newProgress);
            }

            @Override
            public void onReceivedTitle(WebView view, String title) {
                super.onReceivedTitle(view, title);
                webTitle = title;
                etUrl.setText(title);
            }

        });
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
                loading.setVisibility(View.VISIBLE);
                ivRefresh.setVisibility(View.GONE);
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                loading.setVisibility(View.GONE);
                ivRefresh.setVisibility(View.VISIBLE);
                fetchColor();
            }

            @Deprecated
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return !url.startsWith("http://") && !url.startsWith("https://") && !url.startsWith("hydrogen://");
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView webView, WebResourceRequest webResourceRequest) {
                String url = "";
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                    url = webResourceRequest.getUrl().toString();
                }
                return !url.startsWith("http://") && !url.startsWith("https://") && !url.startsWith("hydrogen://");
            }
        });

        ivRefresh.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mWebView.loadUrl(url);
            }
        });

        mWebView.loadUrl(url);

        iv_more.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PopupMenu popupMenu = new PopupMenu(iv_more.getContext(), v, GravityCompat.START);
                popupMenu.getMenu().add(Menu.NONE, 1, Menu.NONE, "复制链接");
                popupMenu.getMenu().add(Menu.NONE, 2, Menu.NONE, "在浏览器打开");
                popupMenu.getMenu().add(Menu.NONE, 3, Menu.NONE, "分享");
                popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem item) {
                        if (TextUtils.isEmpty(url)) {
                            return false;
                        }
                        switch (item.getItemId()) {
                            case 1:
                                android.content.ClipboardManager clipboard = (android.content.ClipboardManager) WebViewActivity.this.getSystemService(Context.CLIPBOARD_SERVICE);
                                android.content.ClipData clip = android.content.ClipData.newPlainText("lua", url);
                                clipboard.setPrimaryClip(clip);
                                break;
                            case 2:
                                Intent intent = new Intent(Intent.ACTION_VIEW);
                                intent.setData(Uri.parse(url));
                                WebViewActivity.this.startActivity(intent);
                                break;
                            case 3:
                                Intent sendIntent = new Intent(Intent.ACTION_SEND);
                                sendIntent.putExtra(Intent.EXTRA_TEXT, url);
                                sendIntent.setType("text/plain");
                                WebViewActivity.this.startActivity(sendIntent);
                                break;
                        }
                        return false;
                    }
                });
                popupMenu.show();
            }
        });
        etUrl.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                String url = etUrl.getText().toString();
                if (!TextUtils.isEmpty(url) && url.startsWith("http")) {
                    mWebView.loadUrl(url);
                }
                return false;
            }
        });

    }

    private boolean canAsBgColor(int i) {
        return Color.red(i) < 220 || Color.green(i) < 220 || Color.blue(i) < 220;
    }

    private void fetchColor() {
        if (mWebView != null && mWebView.getVisibility() == View.VISIBLE && mWebView.getScrollX() < LuaUtil.dp2px(20)) {
            mWebView.draw(canvas);
            if (colorBitmap != null) {
                int pixel = colorBitmap.getPixel(0, 0);
                if (canAsBgColor(pixel)) {
                    layout_toolbar.setBackgroundColor(pixel);
                    if (pixel == Color.WHITE) {
                        setLightStatusBar();
                    } else {
                        setStatusBarColor(pixel);
                    }
                }
            }
        }
    }

    @Override
    public void onBackPressed() {
        if (mWebView.canGoBack()) {
            mWebView.goBack();
            return;
        }
        super.onBackPressed();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        try {
            if (mWebView != null) {
                if (mWebView.getParent() instanceof ViewGroup) {
                    ((ViewGroup) mWebView.getParent()).removeAllViews();
                }
                mWebView.stopLoading();
                mWebView.setWebChromeClient(null);
                mWebView.setWebViewClient(null);
                mWebView.removeAllViews();
                mWebView.destroy();
                mWebView = null;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
