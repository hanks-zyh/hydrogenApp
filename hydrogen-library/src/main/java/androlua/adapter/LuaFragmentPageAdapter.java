package androlua.adapter;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

/**
 * Created by hanks on 2017/5/26. Copyright (C) 2017 Hanks
 */

public class LuaFragmentPageAdapter extends FragmentPagerAdapter {

    private AdapterCreator creator;

    public LuaFragmentPageAdapter(FragmentManager fm, AdapterCreator creator) {
        super(fm);
        this.creator = creator;
    }

    @Override
    public Fragment getItem(int position) {
        return creator.getItem(position);
    }

    @Override
    public int getCount() {
        return (int) creator.getCount();
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return creator.getPageTitle(position);
    }

    public interface AdapterCreator {
        long getCount();

        Fragment getItem(int position);

        String getPageTitle(int position);
    }
}
