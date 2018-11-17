package androlua;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.widget.ImageView;

import com.bumptech.glide.DrawableTypeRequest;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.model.GlideUrl;
import com.bumptech.glide.load.model.LazyHeaders;
import com.bumptech.glide.load.resource.bitmap.CenterCrop;

import jp.wasabeef.glide.transformations.BlurTransformation;
import jp.wasabeef.glide.transformations.RoundedCornersTransformation;
import pub.hanks.luajandroid.R;

/**
 * user image loader
 * Created by hanks on 2017/5/12. Copyright (C) 2017 Hanks
 */

public class LuaImageLoader {

    public static void load(ImageView imageView, String uri) {
        load(imageView.getContext(), imageView, uri);
    }
    public static void loadWithRadius(ImageView imageView, float radius, String uri) {
        Context context = imageView.getContext();
        GradientDrawable gd = new GradientDrawable();
        gd.setCornerRadius(LuaUtil.dp2px(radius));
        gd.setColor(0xffebf0f2);
        load(context, imageView, uri, radius, 0, gd, gd);

    }

    public static void load(Context context, ImageView imageView, String uri) {

        load(context, imageView, uri, 0, 0,
                ContextCompat.getDrawable(context, R.drawable.ic_loading),
                ContextCompat.getDrawable(context, R.drawable.ic_loading));
    }

    public static void load(Context context, ImageView imageView, String uri, float radius, float blueRadius,
                            Drawable placeholderDrawable, Drawable errorDrawable) {
        if (imageView == null || uri == null) {
            return;
        }
        boolean loadLocal = false;
        if (uri.startsWith("#")) { // load local file
            uri = uri.substring(1);
            loadLocal = true;
        }

        if (!uri.startsWith("http://") && !uri.startsWith("https://")
                && !uri.startsWith("content://") && !uri.startsWith("file://")) {
            String path = uri;
            if (!uri.startsWith("/")) {
                path = LuaManager.getInstance().getLuaExtDir() + "/" + uri;
            }
            if (loadLocal) {
                imageView.setImageBitmap(BitmapFactory.decodeFile(path));
                return;
            }
            uri = "file://" + path;
        }
        DrawableTypeRequest manager = Glide.with(context).load(uri);
        BlurTransformation blurTransformation = null;
        RoundedCornersTransformation roundedCornersTransformation = null;

        if (radius > 0){
            roundedCornersTransformation = new RoundedCornersTransformation(context, LuaUtil.dp2px(radius), 0);
        }
        if (blueRadius > 0) {
            blurTransformation = new BlurTransformation(context, (int) blueRadius);
        }
        if (radius > 0 && blueRadius > 0) {
            manager.bitmapTransform(new CenterCrop(context),roundedCornersTransformation, blurTransformation);
        } else if (radius > 0) {
            manager.bitmapTransform(new CenterCrop(context),roundedCornersTransformation);
        } else if (blueRadius > 0) {
            manager.bitmapTransform(new CenterCrop(context),blurTransformation);
        }
        manager
                .placeholder(placeholderDrawable)
                .error(errorDrawable)
                .crossFade()
                .into(imageView);
    }

    public static void load(ImageView imageView, String uri, String referer) {
        if (imageView == null || uri == null) {
            return;
        }
        LazyHeaders headers = new LazyHeaders.Builder()
                .addHeader("Referer", referer)
                .build();
        GlideUrl glideUrl = new GlideUrl(uri, headers);
        Glide.with(imageView.getContext())
                .load(glideUrl)
                .placeholder(R.drawable.ic_loading)
                .error(R.drawable.ic_loading)
                .crossFade()
                .into(imageView);
    }
}
