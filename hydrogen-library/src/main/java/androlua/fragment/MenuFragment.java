package androlua.fragment;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;

import java.io.File;
import java.util.List;

import androlua.LuaActivity;
import androlua.LuaManager;
import androlua.LuaUtil;
import androlua.base.BaseFragment;
import androlua.common.LuaFileUtils;
import androlua.common.LuaStringUtils;
import androlua.plugin.Plugin;
import androlua.utils.ShortcutUtils;
import jp.wasabeef.glide.transformations.RoundedCornersTransformation;
import pub.hanks.luajandroid.R;

/**
 * MenuFragment
 * Created by hanks on 2017/8/22.
 */

public class MenuFragment extends BaseFragment {
    public static MenuFragment newInstance() {
        Bundle args = new Bundle();
        MenuFragment fragment = new MenuFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_menu, container, false);
        return view;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.add_shortcut).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getActivity() == null || !(getActivity() instanceof LuaActivity)) {
                    return;
                }

                Intent intent = getActivity().getIntent();
                String luaFile = LuaUtil.IntentHelper.getLuaPath(intent);
                String luaExtDir = LuaManager.getInstance().getLuaExtDir();
                if (!luaFile.startsWith("/")) {
                    luaFile = luaExtDir + "/" + luaFile;
                }
                File file = new File(luaFile);
                if (!file.exists()) {
                    return;
                }
                String pluginRoot;
                do {
                    pluginRoot = file.getAbsolutePath();
                    file = file.getParentFile();
                } while (!luaExtDir.equals(file.getAbsolutePath()));

                String name = "氢-" + file.getName();
                Plugin p = null;

                List<Plugin> pluginList = LuaFileUtils.getPluginList();
                for (Plugin plugin : pluginList) {
                    if (plugin.getPath().equals(pluginRoot)) {
                        name = plugin.getName();
                        p = plugin;
                        break;
                    }
                }
                if (p != null) {
                    showAddShortcutDialog(intent, name, p.getIconPath());
                } else {
                    showAddShortcutDialog(intent, name, null);
                }
            }
        });
    }

    private void showAddShortcutDialog(final Intent intent, String name, String iconPath) {
        if (getActivity() == null || !(getActivity() instanceof LuaActivity)) {
            return;
        }
        ((LuaActivity) getActivity()).closeDrawer();
        View view = View.inflate(getActivity(), R.layout.dialog_add_shortcut, null);
        final EditText et_name = (EditText) view.findViewById(R.id.name);
        final ImageView iv_icon = (ImageView) view.findViewById(R.id.icon);
        et_name.setText("氢 · " +  name);
        final Bitmap[] bm = new Bitmap[1];
        if (!LuaStringUtils.isEmpty(iconPath)) {
            GradientDrawable gd = new GradientDrawable();
            gd.setCornerRadius(LuaUtil.dp2px(100));
            gd.setColor(0xffebf0f2);
            Glide.with(this)
                    .load(iconPath)
                    .asBitmap()
                    .placeholder(gd)
                    .transform(new RoundedCornersTransformation(getContext(), LuaUtil.dp2px(100), 0))
                    .listener(new RequestListener<String, Bitmap>() {
                        @Override
                        public boolean onException(Exception e, String model, Target<Bitmap> target, boolean isFirstResource) {
                            return false;
                        }

                        @Override
                        public boolean onResourceReady(Bitmap resource, String model, Target<Bitmap> target, boolean isFromMemoryCache, boolean isFirstResource) {
                            bm[0] = resource;
                            return false;
                        }
                    }).into(iv_icon);
        }
        new AlertDialog.Builder(getActivity())
                .setTitle("放到桌面")
                .setView(view)
                .setNegativeButton("取消", null)
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        String name = et_name.getText().toString();
                        if (LuaStringUtils.isEmpty(name)) {
                            name = " ";
                        }
                        if (bm[0] == null) {
                            bm[0] = BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher);
                        }
                        ShortcutUtils.installShortcut(getActivity(), name, bm[0], intent);
                    }
                })
                .show();

    }
}
