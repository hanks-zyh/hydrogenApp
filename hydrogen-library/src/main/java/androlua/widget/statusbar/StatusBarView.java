package androlua.widget.statusbar;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.os.Build;
import android.util.AttributeSet;
import android.view.View;


/**
 * StatusBarView
 * Created by hanks on 18-4-17.
 */

public class StatusBarView extends View {
    private int statusBarColor;
    private int statusBarHeight;

    public StatusBarView(Context context) {
        this(context, null);
    }

    public StatusBarView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public StatusBarView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        statusBarColor = Color.BLACK;
        statusBarHeight = getStatusBarHeight(context);
    }

    public void setStatusBarColor(int statusBarColor) {
        this.statusBarColor = statusBarColor;
        invalidate();
    }

    public void setStatusBarHeight(int statusBarHeight) {
        this.statusBarHeight = statusBarHeight;
        getLayoutParams().height = statusBarHeight;
        requestLayout();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        canvas.drawColor(statusBarColor);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        setMeasuredDimension(widthMeasureSpec, statusBarHeight);
    }

    private int getStatusBarHeight(Context context) {
        if (Build.VERSION.SDK_INT < 21) {
            return 0;
        }
        int result = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    private int getNavigationBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("navigation_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }
}
