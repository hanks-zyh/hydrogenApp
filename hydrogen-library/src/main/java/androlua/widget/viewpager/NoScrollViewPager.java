package androlua.widget.viewpager;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;


/**
 * 可以禁止左右滑动
 * Created by hanks on 16/7/18.
 */
public class NoScrollViewPager extends ViewPager {

    private boolean isPagingEnabled = false;

    public NoScrollViewPager(Context context) {
        super(context);
    }

    public NoScrollViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return this.isPagingEnabled && super.onTouchEvent(event);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event) {
        return this.isPagingEnabled && super.onInterceptTouchEvent(event);
    }


    @Override
    protected boolean canScroll(View v, boolean checkV, int dx, int x, int y) {
        if (v != this && v instanceof ViewPager) {

            int currentItem = ((ViewPager) v).getCurrentItem();
            int countItem = ((ViewPager) v).getAdapter().getCount();
            return !((currentItem == (countItem - 1) && dx < 0) || (currentItem == 0 && dx > 0));
        }
        return super.canScroll(v, checkV, dx, x, y);
    }

    public void setPagingEnabled(boolean b) {
        this.isPagingEnabled = b;
    }
}
