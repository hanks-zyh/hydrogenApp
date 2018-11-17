package androlua.widget.marqueetext;

import android.content.Context;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.widget.TextView;

/**
 * 跑马灯
 * Created by hanks on 2017/6/21.
 */

public class MarqueeTextView extends android.support.v7.widget.AppCompatTextView {
    public MarqueeTextView(Context context) {
        this(context,null);
    }

    public MarqueeTextView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MarqueeTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setSingleLine(true);
        setMaxLines(1);
        setEllipsize(TextUtils.TruncateAt.MARQUEE);
    }

    @Override
    public boolean isFocused() {
        return true;
    }
}
