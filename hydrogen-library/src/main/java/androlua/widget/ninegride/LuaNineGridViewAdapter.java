package androlua.widget.ninegride;

import android.content.Context;
import android.widget.ImageView;

import java.util.List;

/**
 * Created by hanks on 2017/5/31. Copyright (C) 2017 Hanks
 */

public class LuaNineGridViewAdapter extends NineGridImageViewAdapter {
    AdapterCreator adapterCreator;

    public LuaNineGridViewAdapter(AdapterCreator adapterCreator) {
        this.adapterCreator = adapterCreator;
    }

    @Override
    protected void onDisplayImage(Context context, ImageView imageView, String url) {
        adapterCreator.onDisplayImage(context, imageView, url);
    }

    @Override
    protected void onItemImageClick(Context context, ImageView imageView, int index, List<String> list) {
        super.onItemImageClick(context, imageView, index, list);
        adapterCreator.onItemImageClick(context, imageView, index, list);
    }

    public interface AdapterCreator {
        void onDisplayImage(Context context, ImageView imageView, String url);

        void onItemImageClick(Context context, ImageView imageView, int index, List<String> list);
    }
}
