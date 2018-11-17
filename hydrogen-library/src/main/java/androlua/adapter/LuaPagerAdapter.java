package androlua.adapter;

import android.support.v4.view.PagerAdapter;
import android.view.View;
import android.view.ViewGroup;

import com.luajava.LuaTable;

import java.util.ArrayList;
import java.util.List;

/**
 * adapter for viewpager
 * Created by hanks on 2017/5/13.
 */

public class LuaPagerAdapter extends PagerAdapter {

    public List<View> mListViews = new ArrayList<>();

    public LuaPagerAdapter(LuaTable luaTable) {
        addViews(luaTable);
    }

    public void addViews(LuaTable luaTable) {
        if (luaTable == null) {
            return;
        }
        int size = luaTable.keySet().size();
        for (int i = 1; i <= size; i++) {
            Object v = luaTable.get(i);
            if (v != null && v instanceof View) {
                mListViews.add((View) v);
            }
        }
    }

    @Override
    public int getCount() {
        return mListViews != null ? mListViews.size() : 0;
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view == object;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        View view = mListViews.get(position);
        container.addView(view);
        return view;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView((View) object);
    }

}
