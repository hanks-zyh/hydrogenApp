package androlua.widget.statusbar;

import android.content.Context;
import android.graphics.Rect;
import android.os.Build;
import android.util.AttributeSet;
import android.view.WindowInsets;
import android.widget.FrameLayout;

/**
 * @author Kevin
 *         Date Created: 3/7/14
 *         <p>
 *         https://code.google.com/p/android/issues/detail?id=63777
 *         <p>
 *         When using a translucent status bar on API 19+, the window will not
 *         resize to make room for input methods (i.e.
 *         {@link android.view.WindowManager.LayoutParams#SOFT_INPUT_ADJUST_RESIZE} and
 *         {@link android.view.WindowManager.LayoutParams#SOFT_INPUT_ADJUST_PAN} are
 *         ignored).
 *         <p>
 *         To work around this; override {@link #fitSystemWindows(Rect)},
 *         capture and override the system insets, and then call through to FrameLayout's
 *         implementation.
 *         <p>
 *         For reasons yet unknown, modifying the bottom inset causes this workaround to
 *         fail. Modifying the top, left, and right insets works as expected.
 */
public final class FixInsetsFrameLayout extends FrameLayout {
    private int[] mInsets = new int[4];

    public FixInsetsFrameLayout(Context context) {
        super(context);
    }

    public FixInsetsFrameLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public FixInsetsFrameLayout(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    private boolean insetEnable = false;

    public void setInsetEnable(boolean insetEnable) {
        this.insetEnable = insetEnable;
    }

    @Override
    protected final boolean fitSystemWindows(Rect insets) {
        if (!insetEnable && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // Intentionally do not modify the bottom inset. For some reason,
            // if the bottom inset is modified, window resizing stops working.

            mInsets[0] = insets.left;
            mInsets[1] = insets.top;
            mInsets[2] = insets.right;

            insets.left = 0;
            insets.top = 0;
            insets.right = 0;
        }

        return super.fitSystemWindows(insets);
    }

    @Override
    public final WindowInsets onApplyWindowInsets(WindowInsets insets) {
        if (!insetEnable && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mInsets[0] = insets.getSystemWindowInsetLeft();
            mInsets[1] = insets.getSystemWindowInsetTop();
            mInsets[2] = insets.getSystemWindowInsetRight();
            return super.onApplyWindowInsets(insets.replaceSystemWindowInsets(0, 0, 0,
                    insets.getSystemWindowInsetBottom()));
        } else {
            return insets;
        }
    }
}