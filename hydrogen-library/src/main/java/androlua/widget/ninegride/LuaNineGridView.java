package androlua.widget.ninegride;

import android.content.Context;
import android.util.AttributeSet;

import com.luajava.LuaTable;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by hanks on 2017/5/31. Copyright (C) 2017 Hanks
 */

public class LuaNineGridView extends NineGridImageView {

    public LuaNineGridView(Context context) {
        super(context);
    }

    public LuaNineGridView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public void setImagesData(LuaTable lists) {
        List<String> data = new ArrayList<>();
        int size = lists.size();
        for (int i = 1; i <= size; i++) {
            data.add((String) lists.get(i));
        }
        setImagesData(data);
    }
}
