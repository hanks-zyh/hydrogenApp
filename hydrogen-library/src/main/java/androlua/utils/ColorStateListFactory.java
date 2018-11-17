package androlua.utils;

import android.content.res.ColorStateList;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.RippleDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.StateListDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.os.Build;

import java.util.Arrays;

/**
 * Created by hanks on 2017/5/31. Copyright (C) 2017 Hanks
 */

public class ColorStateListFactory {

    public static ColorStateList newInstance(int normalColor) {
        return ColorStateList.valueOf(normalColor);
    }

    public static ColorStateList newInstance(int normalColor, int selectedColor) {
        int[][] states = new int[][]{
                {-android.R.attr.state_checked},
                {android.R.attr.state_checked},
                {android.R.attr.state_pressed},
                {android.R.attr.state_enabled},
                {android.R.attr.state_selected},
        };
        int[] colorList = new int[9];
        colorList[0] = normalColor;
        colorList[1] = selectedColor;
        colorList[2] = selectedColor;
        colorList[3] = selectedColor;
        colorList[4] = selectedColor;
        return new ColorStateList(states, colorList);
    }


    public static Drawable getRippleDrawable(
            int normalColor, int pressedColor) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            return new RippleDrawable(ColorStateList.valueOf(pressedColor),
                    null, getRippleMask(normalColor));
        } else {
            return getStateListDrawable(normalColor, pressedColor);
        }
    }

    private static Drawable getRippleMask(int color) {
        float[] outerRadii = new float[8];
        // 3 is radius of final ripple,
        // instead of 3 you can give required final radius
        Arrays.fill(outerRadii, 3);

        RoundRectShape r = new RoundRectShape(outerRadii, null, null);
        ShapeDrawable shapeDrawable = new ShapeDrawable(r);
        shapeDrawable.getPaint().setColor(color);
        return shapeDrawable;
    }

    public static StateListDrawable getStateListDrawable(
            int normalColor, int pressedColor) {
        StateListDrawable states = new StateListDrawable();
        states.addState(new int[]{android.R.attr.state_pressed},
                new ColorDrawable(pressedColor));
        states.addState(new int[]{android.R.attr.state_focused},
                new ColorDrawable(pressedColor));
        states.addState(new int[]{android.R.attr.state_activated},
                new ColorDrawable(pressedColor));
        states.addState(new int[]{},
                new ColorDrawable(normalColor));
        return states;
    }
}
