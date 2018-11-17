package androlua.widget.htmltext;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowManager;
import android.widget.TextView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.resource.drawable.GlideDrawable;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.Target;
import com.bumptech.glide.request.target.ViewTarget;


public class URLImageParser implements Html.ImageGetter {
    private TextView container;

    public URLImageParser(TextView v) {
        this.container = v;
    }

    @Override
    public Drawable getDrawable(String url) {
        final UrlDrawable urlDrawable = new UrlDrawable();
        final String source = url;

        debug("Url is " + url);
        DisplayMetrics metrics = new DisplayMetrics();
        ((WindowManager) container.getContext().getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(metrics);
        final float dpi = (int) metrics.density;

        Glide.with(container.getContext()).load(source).diskCacheStrategy(DiskCacheStrategy.ALL).
                listener(new RequestListener<String, GlideDrawable>() {
                    @Override
                    public boolean onException(Exception e, String s, Target<GlideDrawable> glideDrawableTarget, boolean b) {
                        debug("Error in Glide listener");
                        if (e != null) {
                            e.printStackTrace();
                        }
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(GlideDrawable glideDrawable, String s, Target<GlideDrawable> glideDrawableTarget, boolean b, boolean b2) {
                        return false;
                    }
                }).
                into(new ViewTarget<TextView, GlideDrawable>(container) {
                    @Override
                    public void onResourceReady(GlideDrawable d, GlideAnimation<? super GlideDrawable> glideAnimation) {
                        int width = (int) (d.getIntrinsicWidth() * dpi);
                        int height = (int) (d.getIntrinsicHeight() * dpi);
                        d.setBounds(0, 0, width, height);
                        d.setVisible(true, true);

                        d.setCallback(new Drawable.Callback() {
                            @Override
                            public void invalidateDrawable(Drawable who) {

                            }

                            @Override
                            public void scheduleDrawable(Drawable who, Runnable what, long when) {

                            }

                            @Override
                            public void unscheduleDrawable(Drawable who, Runnable what) {

                            }
                        });

                        urlDrawable.setBounds(0, 0, width, height);
                        urlDrawable.drawable = d;
                        debug("Lisnt1er ended " + width + ", " + height + ", source: " + source + ", animated? " + d.isAnimated() + ", " + d.getClass().getSimpleName());

                        if (d instanceof GifDrawable) {
                            debug("Gif drawable ! animated? " + d.isAnimated() + ", " + (d.getCallback() == null));
                            GifDrawable a = (GifDrawable) d;
                            d.setLoopCount(GlideDrawable.LOOP_FOREVER);
                            d.start();
                        }
                    }

                });
        return urlDrawable;
    }

    private void debug(String msg) {
        Log.d("AAA", msg);
    }
}