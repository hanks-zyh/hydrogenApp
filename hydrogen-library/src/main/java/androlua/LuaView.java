package androlua;

import android.content.Context;
import android.graphics.Canvas;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;

/**
 * custom view
 * Created by hanks on 2017/6/6.
 */

public class LuaView extends View {

    private Creator creator;

    public LuaView(Context context) {
        this(context, null);
    }

    public LuaView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LuaView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        if (creator != null) {
            creator.init(context, attrs, defStyleAttr);
        }
    }

    public void setCreator(Creator creator) {
        this.creator = creator;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (creator != null) {
            creator.onMeasure(widthMeasureSpec, heightMeasureSpec);
        }
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        if (creator != null) {
            creator.onFinishInflate();
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (creator != null) {
            creator.onDraw(canvas);
        }
    }

    public interface Creator {
        void init(Context context, @Nullable AttributeSet attrs, int defStyleAttr);

        void onDraw(Canvas canvas);

        void onFinishInflate();

        void onMeasure(int widthMeasureSpec, int heightMeasureSpec);
    }
}
