package pub.hanks.sample.adapter;

import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.helper.ItemTouchHelper;

/**
 * Created by hanks on 2017/7/13.
 */

public class DragTouchHelper extends ItemTouchHelper.Callback {

    private Creator creator;

    public DragTouchHelper(Creator creator) {
        this.creator = creator;
    }

    @Override
    public int getMovementFlags(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder) {
        int dragFlags = 0;
        int swipeFlags = 0;
        if (creator != null) {
            dragFlags = (int) creator.getDragFlags();
            swipeFlags = (int) creator.getSwipeFlags();
        }
        return makeMovementFlags(dragFlags, swipeFlags);
    }

    @Override
    public boolean onMove(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder, RecyclerView.ViewHolder target) {
        if (creator != null) {
            return creator.onMove(recyclerView, viewHolder, target);
        }
        return false;

    }

    @Override
    public void onSwiped(RecyclerView.ViewHolder viewHolder, int direction) {
        if (creator != null) {
            creator.onSwiped(viewHolder, direction);
        }

    }

    @Override
    public boolean isLongPressDragEnabled() {
        if (creator != null) {
            return creator.isLongPressDragEnabled();
        }
        return super.isLongPressDragEnabled();
    }

    @Override
    public void onSelectedChanged(RecyclerView.ViewHolder viewHolder, int actionState) {
        if (creator != null) {
            creator.onSelectedChanged(viewHolder, actionState);
        }
        super.onSelectedChanged(viewHolder, actionState);
    }

    @Override
    public void clearView(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder) {
        if (creator != null) {
            creator.clearView(recyclerView, viewHolder);
        }
        super.clearView(recyclerView, viewHolder);
    }

    public interface Creator {
        boolean onMove(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder, RecyclerView.ViewHolder target);

        void onSwiped(RecyclerView.ViewHolder viewHolder, int direction);

        void onSelectedChanged(RecyclerView.ViewHolder viewHolder, int actionState);

        void clearView(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder);

        long getDragFlags();

        long getSwipeFlags();

        boolean isLongPressDragEnabled();
    }
}
