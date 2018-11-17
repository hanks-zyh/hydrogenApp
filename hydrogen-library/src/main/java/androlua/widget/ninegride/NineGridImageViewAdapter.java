package androlua.widget.ninegride;

import android.content.Context;
import android.widget.ImageView;

import java.util.List;

/**
 * Created by Jaeger on 16/2/24.
 * <p>
 * Email: chjie.jaeger@gmail.com
 * GitHub: https://github.com/laobie
 */
public abstract class NineGridImageViewAdapter {
    protected abstract void onDisplayImage(Context context, ImageView imageView, String t);

    protected void onItemImageClick(Context context, ImageView imageView, int index, List<String> list) {
    }

    protected ImageView generateImageView(Context context) {
        ImageView imageView = new ImageView(context);
        imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
        return imageView;
    }
}