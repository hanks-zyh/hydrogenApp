package androlua.widget.ninegride;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import java.util.ArrayList;
import java.util.List;

import androlua.LuaImageLoader;

/**
 * Created by Jaeger on 16/2/24.
 * <p>
 * Email: chjie.jaeger@gamil.com
 * GitHub: https://github.com/laobie
 */
public class NineGridImageView<T> extends ViewGroup {

    public final static int STYLE_GRID = 0;     // 宫格布局
    public final static int STYLE_FILL = 1;     // 全填充布局

    private int mRowCount;       // 行数
    private int mColumnCount;    // 列数

    private int mMaxSize;        // 最大图片数
    private int mShowStyle;     // 显示风格
    private int mGap;           // 宫格间距
    private int mSingleImgWidth;
    private int mSingleImgHeight; // 单张图片时的尺寸
    private int mGridSize;   // 宫格大小,即图片大小

    private List<ImageView> mImageViewList = new ArrayList<>();
    private List<String> mImgDataList = new ArrayList<>();
    private NineGridImageViewAdapter mAdapter;
    private int totalWidth;

    public NineGridImageView(Context context) {
        this(context, null);
    }

    public NineGridImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.mGap = 0;
        this.mSingleImgHeight = dp2px(180);
        this.mSingleImgWidth = dp2px(180);
        this.mShowStyle = STYLE_GRID;
        this.mMaxSize = 9;
    }

    /**
     * 设置 宫格参数
     *
     * @param imagesSize 图片数量
     * @param showStyle  显示风格
     * @return 宫格参数 gridParam[0] 宫格行数 gridParam[1] 宫格列数
     */
    protected static int[] calculateGridParam(int imagesSize, int showStyle) {
        int[] gridParam = new int[2];
        switch (showStyle) {
            case STYLE_FILL:
                if (imagesSize < 3) {
                    gridParam[0] = 1;
                    gridParam[1] = imagesSize;
                } else if (imagesSize <= 4) {
                    gridParam[0] = 2;
                    gridParam[1] = 2;
                } else {
                    gridParam[0] = imagesSize / 3 + (imagesSize % 3 == 0 ? 0 : 1);
                    gridParam[1] = 3;
                }
                break;
            default:
            case STYLE_GRID:
                gridParam[0] = imagesSize / 3 + (imagesSize % 3 == 0 ? 0 : 1);
                gridParam[1] = 3;
        }
        return gridParam;
    }

    public void setSingleImgSize(int width, int height) {
        int targetH = dp2px(180);
        int targetW = getScreenWidth() - dp2px(32);
        if (height > 2000) {
            height = 2000;
        }
        if (width > 3000) {
            width = 3000;
        }
        float scale = 1f;
        float scaleY = targetH * 1f / height;
        float scaleX = targetW * 1f / width;
        if (height < targetH) {
            if (width * scaleY > targetW) {
                scale = scaleX;
            } else {
                scale = scaleY;
            }
        } else {
            scale = Math.min(scaleX, scaleY);
        }
        this.mSingleImgWidth = (int) (width * scale);
        this.mSingleImgHeight = (int) (height * scale);

    }

    public NineGridImageViewAdapter getAdapter() {
        return mAdapter;
    }

    /**
     * 设置适配器
     *
     * @param adapter 适配器
     */
    public void setAdapter(NineGridImageViewAdapter adapter) {
        mAdapter = adapter;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int width = MeasureSpec.getSize(widthMeasureSpec);
        int height = MeasureSpec.getSize(heightMeasureSpec);
        totalWidth = width - getPaddingLeft() - getPaddingRight();
        if (mImgDataList == null || mImgDataList.isEmpty()) {
            setMeasuredDimension(width, height);
            return;
        }
        switch (mImgDataList.size()) {
            case 1:
                mColumnCount = 1;
                mRowCount = 1;
                mGridSize = height = mSingleImgHeight;
                break;
            case 2:
            case 4:
                mGridSize = (int) ((totalWidth - mGap) / 2f);
                mRowCount = mImgDataList.size() / 2;
                mColumnCount = 2;
                height = mGridSize * mRowCount + mGap * (mRowCount - 1);
                break;
            default:
                mColumnCount = 3;
                mRowCount = mImgDataList.size() % 3 == 0 ? mImgDataList.size() / 3 : mImgDataList.size() / 3 + 1;
                mGridSize = (int) ((totalWidth - 2 * mGap) / 3f);
                height = mGridSize * mRowCount + (mGap * mRowCount - 1);
                break;
        }
        height = height + getPaddingTop() + getPaddingBottom();
        setMeasuredDimension(width, height);
    }

    private int dp2px(float dp) {
        float density = getContext().getResources().getDisplayMetrics().density;
        return (int) (0.5F + dp * density);
    }

    private int getScreenWidth() {
        return getContext().getResources().getDisplayMetrics().widthPixels;
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        int childCount = getChildCount();
        if (childCount == 0) {
            return;
        }
        if (childCount == 1) {
            View child = getChildAt(0);
            child.layout(getPaddingLeft(), getPaddingTop(), getPaddingLeft() + mSingleImgWidth, getPaddingTop() + mSingleImgHeight);
            return;
        }

        for (int i = 0; i < childCount; i++) {
            View child = getChildAt(i);
            int rowNum = i / mColumnCount;
            int columnNum = i % mColumnCount;
            int left = (mGridSize + mGap) * columnNum + getPaddingLeft();
            int top = (mGridSize + mGap) * rowNum + getPaddingTop();
            int right = left + mGridSize;
            int bottom = top + mGridSize;
            child.layout(left, top, right, bottom);
        }
    }


    /**
     * 设置图片数据
     *
     * @param lists 图片数据集合
     */
    public void setImagesData(List<String> lists) {
        if (lists == null || lists.isEmpty()) {
            this.setVisibility(GONE);
            return;
        } else {
            this.setVisibility(VISIBLE);
        }
        removeAllViews();
        int newShowCount = getNeedShowCount(lists.size());
        int[] gridParam = calculateGridParam(newShowCount, mShowStyle);
        mRowCount = gridParam[0];
        mColumnCount = gridParam[1];
        mImgDataList.clear();
        mImgDataList.addAll(lists);
        for (int i = 0; i < newShowCount; i++) {
            ImageView iv = getImageView();
            if (iv == null) {
                continue;
            }
            int w,h;
            if (newShowCount == 1) {
                iv.setScaleType(ImageView.ScaleType.FIT_XY);
                w = mSingleImgWidth;
                h = mSingleImgHeight;
            } else {
                w = h = mGridSize;
                iv.setScaleType(ImageView.ScaleType.CENTER_CROP);
            }

            addView(iv, new ViewGroup.LayoutParams(w,h));
            LuaImageLoader.load(iv, mImgDataList.get(i));
            final int finalI = i;
            iv.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    mAdapter.onItemImageClick(getContext(), (ImageView) v, finalI, mImgDataList);
                }
            });
            mAdapter.onDisplayImage(getContext(), iv, mImgDataList.get(i));
        }
        requestLayout();
    }

    private int getNeedShowCount(int size) {
        if (mMaxSize > 0 && size > mMaxSize) {
            return mMaxSize;
        } else {
            return size;
        }
    }

    /**
     * 获得 ImageView
     * 保证了 ImageView 的重用
     */
    private ImageView getImageView() {
        if (mAdapter != null) {
            ImageView imageView = mAdapter.generateImageView(getContext());

            return imageView;
        } else {
            Log.e("NineGirdImageView", "Your must set a NineGridImageViewAdapter for NineGirdImageView");
            return null;
        }
    }

    /**
     * 设置宫格间距
     *
     * @param gap 宫格间距 px
     */
    public void setGap(int gap) {
        mGap = gap;
    }

    /**
     * 设置显示风格
     *
     * @param showStyle 显示风格
     */
    public void setShowStyle(int showStyle) {
        mShowStyle = showStyle;
    }


    /**
     * 设置最大图片数
     *
     * @param maxSize 最大图片数
     */
    public void setMaxSize(int maxSize) {
        mMaxSize = maxSize;
    }

}