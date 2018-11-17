package androlua;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.support.v7.app.AlertDialog;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.HttpAuthHandler;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.luajava.LuaException;
import com.luajava.LuaObject;

/**
 * LuaWebView
 * Created by hanks on 2017/5/27.
 */
public class LuaWebView extends WebView {
    private WebChromeClientListener webChromeClientListener;
    private WebViewClientListener webViewClientListener;

    public LuaWebView(Context context) {
        this(context, null);
    }

    public LuaWebView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LuaWebView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        if (Build.VERSION.SDK_INT >= 19) {
            setLayerType(View.LAYER_TYPE_HARDWARE, null);
        } else {
            setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        }
        WebSettings setting = getSettings();
        setting.setSupportZoom(false);
        setting.setBuiltInZoomControls(false);
        setting.setDefaultFontSize(14);
        setting.setDefaultFixedFontSize(14);
        setting.setUseWideViewPort(true);
        setting.setLoadWithOverviewMode(true);
        setting.setDomStorageEnabled(true);
        setting.setAllowContentAccess(true);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            setting.setAllowFileAccessFromFileURLs(true);
        }
        setting.setAppCacheEnabled(true);
        setting.setDatabaseEnabled(true);
        setting.setSaveFormData(true);
        setting.setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
        setting.setAllowFileAccess(true);
        setting.setJavaScriptEnabled(true);
        setWebChromeClient(new LuaWebChromeClient());
        setWebViewClient(new LuaWebViewClient());
        if (Build.VERSION.SDK_INT >= 19) {
            setWebContentsDebuggingEnabled(true);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            setting.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        }

        setFocusable(true);
        setFocusableInTouchMode(true);
    }

    public void release() {
        if (getParent() == null || !(getParent() instanceof ViewGroup)) {
            return;
        }
        ((ViewGroup) getParent()).removeView(this);
        destroy();
    }


    public void injectObjectToJavascript(LuaObject luaObject, String objectName) {
        addJavascriptInterface(new JavascriptInterface(luaObject), objectName);
    }

    public void setWebChromeClientListener(WebChromeClientListener webChromeClientListener) {
        this.webChromeClientListener = webChromeClientListener;
    }

    public void setWebViewClientListener(WebViewClientListener webViewClientListener) {
        this.webViewClientListener = webViewClientListener;
    }

    public interface WebViewClientListener {
        boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request);

        boolean shouldOverrideKeyEvent(WebView view, KeyEvent event);

        WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request);

        void onPageFinished(WebView view, String url);

        void onPageStarted(WebView view, String url, Bitmap favicon);

        void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error);

    }

    public interface WebChromeClientListener {

        void onProgressChanged(WebView view, int newProgress);

        void onReceivedTitle(WebView view, String title);

        void onReceivedIcon(WebView view, Bitmap icon);

        void onReceivedTouchIconUrl(WebView view, String url, boolean precomposed);
    }

    public static class JavascriptInterface {
        private final LuaObject luaObject;

        public JavascriptInterface(LuaObject luaObject) {
            this.luaObject = luaObject;
        }

        @android.webkit.JavascriptInterface
        public void call(String json) {
            try {
                luaObject.call(json);
            } catch (LuaException e) {
                e.printStackTrace();
            }
        }
    }

    public class LuaWebViewClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            if (url.startsWith("hydrogen://")) {
                Intent intent = new Intent();
                intent.setAction(Intent.ACTION_VIEW);
                intent.addCategory(Intent.CATEGORY_BROWSABLE);
                intent.addCategory(Intent.CATEGORY_DEFAULT);
                intent.setData(Uri.parse(url));
                if (intent.resolveActivity(view.getContext().getPackageManager()) != null) {
                    view.getContext().startActivity(intent);
                }
                return true;
            }
            return super.shouldOverrideUrlLoading(view, url);
        }

        @Override
        public void onReceivedSslError(WebView view, final SslErrorHandler handler, SslError error) {
            try {
                Context context = getContext();
                if (context == null || !(context instanceof Activity)) {
                    super.onReceivedSslError(view, handler, error);
                    return;
                }
                new AlertDialog.Builder(context)
                        .setMessage("error ssl cert invalid")
                        .setPositiveButton("continue", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                handler.proceed();
                            }
                        }).setNegativeButton("cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        handler.cancel();
                    }
                }).show();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {

            if (webViewClientListener != null) {
                return webViewClientListener.shouldOverrideUrlLoading(view, request);
            }
            return super.shouldOverrideUrlLoading(view, request);
        }

        @Override
        public boolean shouldOverrideKeyEvent(WebView view, KeyEvent event) {
            return super.shouldOverrideKeyEvent(view, event);
        }

        @Override
        public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
            handler.proceed(host.trim(), realm.trim());
        }

        @Override
        public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
            super.onReceivedHttpError(view, request, errorResponse);
        }

        @Override
        public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
            if (webViewClientListener != null) {
                return webViewClientListener.shouldInterceptRequest(view, request);
            }
            return super.shouldInterceptRequest(view, request);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            if (webViewClientListener != null) {
                webViewClientListener.onPageFinished(view, url);
            }
            super.onPageFinished(view, url);
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            if (webViewClientListener != null) {
                webViewClientListener.onPageStarted(view, url, favicon);
            }
            super.onPageStarted(view, url, favicon);
        }

        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            if (webViewClientListener != null) {
                webViewClientListener.onReceivedError(view, request, error);
            }
            super.onReceivedError(view, request, error);
        }
    }

    public class LuaWebChromeClient extends WebChromeClient {

        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            if (webChromeClientListener != null) {
                webChromeClientListener.onProgressChanged(view, newProgress);
            }
            super.onProgressChanged(view, newProgress);
        }

        @Override
        public void onReceivedTitle(WebView view, String title) {
            if (webChromeClientListener != null) {
                webChromeClientListener.onReceivedTitle(view, title);
            }
            super.onReceivedTitle(view, title);
        }

        @Override
        public void onReceivedIcon(WebView view, Bitmap icon) {
            if (webChromeClientListener != null) {
                webChromeClientListener.onReceivedIcon(view, icon);
            }
            super.onReceivedIcon(view, icon);
        }

        @Override
        public void onReceivedTouchIconUrl(WebView view, String url, boolean precomposed) {
            if (webChromeClientListener != null) {
                webChromeClientListener.onReceivedTouchIconUrl(view, url, precomposed);
            }
            super.onReceivedTouchIconUrl(view, url, precomposed);
        }
    }
}
