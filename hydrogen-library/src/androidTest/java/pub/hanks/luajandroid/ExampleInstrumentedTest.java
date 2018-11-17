package pub.hanks.luajandroid;

import android.animation.LayoutTransition;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Paint;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.TabLayout;
import android.support.graphics.drawable.VectorDrawableCompat;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;
import java.net.URI;

import static junit.framework.Assert.assertEquals;

/**
 * Instrumentation test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class ExampleInstrumentedTest {
    @Test
    public void useAppContext() throws Exception {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getTargetContext();

        new ColorDrawable(0xff);

        LinearLayout linearLayout = new LinearLayout(appContext);
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        assertEquals("pub.hanks.luajandroid", appContext.getPackageName());
        linearLayout.animate().scaleX(2).scaleY(2).translationX(100).setDuration(3000).start();
        VectorDrawableCompat.createFromPath("");

        linearLayout.setClickable(true);
        linearLayout.setFocusable(true);
        linearLayout.setFocusableInTouchMode(true);
        linearLayout.setBackgroundResource(R.drawable.layout_selector_tran);

        Intent intent = new Intent();
        new File(new URI(intent.getData().getPath())).getAbsolutePath();

        RecyclerView recyclerView = new RecyclerView(appContext);
        recyclerView.setVerticalFadingEdgeEnabled(false);

        GridView gridLayout = new GridView(appContext);
        gridLayout.setNumColumns(5);
        gridLayout.setStretchMode(GridView.STRETCH_SPACING);
        gridLayout.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

            }
        });
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            gridLayout.setElevation(20);
        }
        gridLayout.postDelayed(new Runnable() {
            @Override
            public void run() {

            }
        }, 1000);

        BottomSheetBehavior<RecyclerView> sheetBehavior = BottomSheetBehavior.from(recyclerView);
        if (sheetBehavior.getState() != BottomSheetBehavior.STATE_COLLAPSED) {
            sheetBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
        }

        new GridLayoutManager(appContext, 3);

        HorizontalScrollView horizontalScrollView = new HorizontalScrollView(appContext);
        horizontalScrollView.setHorizontalScrollBarEnabled(false);
        ListView listView = new ListView(appContext);
        listView.setDividerHeight(0);
        TextView textView = new TextView(appContext);
        textView.setMaxLines(1);
        textView.setSingleLine(true);
        TabLayout tabLayout = new TabLayout(appContext);
        tabLayout.setVisibility(View.VISIBLE);
        WebView webView = new WebView(appContext);
        webView.setWebChromeClient(new WebChromeClient());
        //webView.addJavascriptInterface(this, "");
        Bitmap bitmap = BitmapFactory.decodeResource(appContext.getResources(), R.id.et_url);
        tabLayout.setLayoutTransition(new LayoutTransition());
        final BottomNavigationView bottomView = new BottomNavigationView(appContext);
        ColorStateList textColor = ColorStateList.valueOf(0xFFFF0000);
        bottomView.setItemTextColor(textColor);
        bottomView.getMenu().add("");
        bottomView.getMenu().add("");
        bottomView.getMenu().add("");
        bottomView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                item.getTitle();
                item.setChecked(true);
                return true;
            }
        });

        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

        new AlertDialog.Builder(appContext)
                .setItems(new String[]{}, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                })
                .setSingleChoiceItems(new String[]{}, 0, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                })
                .show();
        RadioGroup radioGroup = new RadioGroup(appContext);
        RadioButton radioButton = new RadioButton(appContext);
        radioGroup.addView(radioButton);


        new Toolbar(appContext).setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
        GradientDrawable drawable = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{});


        CollapsingToolbarLayout collapsingToolbarLayout = new CollapsingToolbarLayout(appContext);
        CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams) collapsingToolbarLayout.getLayoutParams();
        params.setBehavior(new AppBarLayout.ScrollingViewBehavior());


        new AlertDialog.Builder(appContext).setTitle("").setMessage("")
                .setPositiveButton("取消", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                })
        .show();

        GradientDrawable gd = new GradientDrawable();
        gd.setShape(GradientDrawable.OVAL);
        gd.setColor(0xFFFFFFFF);
        // 动态代理





    }

    class MyAdapter extends BaseAdapter {

        @Override
        public int getCount() {
            return 0;
        }

        @Override
        public Object getItem(int position) {
            return null;
        }

        @Override
        public long getItemId(int position) {
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            return null;
        }
    }
}
