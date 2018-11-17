package androlua.adapter;

import android.support.v7.widget.RecyclerView;
import android.view.ViewGroup;

/**
 * Created by hanks on 2017/5/31. Copyright (C) 2017 Hanks
 */

public class LuaRecyclerAdapter extends RecyclerView.Adapter {

    AdapterCreator adapterCreator;

    public LuaRecyclerAdapter(AdapterCreator adapterCreator) {
        this.adapterCreator = adapterCreator;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return adapterCreator.onCreateViewHolder(parent, viewType);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        adapterCreator.onBindViewHolder(holder, position);
    }

    @Override
    public int getItemViewType(int position) {
        return (int) adapterCreator.getItemViewType(position);
    }

    @Override
    public int getItemCount() {
        return (int) adapterCreator.getItemCount();
    }

    public interface AdapterCreator {
        RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType);

        void onBindViewHolder(RecyclerView.ViewHolder holder, int position);

        long getItemViewType(int position);

        long getItemCount();
    }
}
