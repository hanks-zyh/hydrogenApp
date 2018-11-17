package androlua;

import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

/**
 * LuaAdapter
 * Created by hanks on 2017/5/13.
 */

public class LuaAdapter extends BaseAdapter {

    AdapterCreator adapterCreator;

    public LuaAdapter(AdapterCreator adapterCreator) {
        this.adapterCreator = adapterCreator;
    }

    @Override
    public int getCount() {
        return (int) adapterCreator.getCount();
    }

    @Override
    public Object getItem(int position) {
        return adapterCreator.getItem(position);
    }

    @Override
    public long getItemId(int position) {
        return adapterCreator.getItemId(position);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        return adapterCreator.getView(position, convertView, parent);
    }

    public interface AdapterCreator {
        long getCount();

        Object getItem(int position);

        long getItemId(int position);

        View getView(int position, View convertView, ViewGroup parent);
    }
}
