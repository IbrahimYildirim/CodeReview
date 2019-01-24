package nitted.dk.robochallenge.Model;

/**
 * Created by Ibrahim on 11/07/2017.
 */

public class Grid {

    private int column, row;

    public Grid(final int column, final int row) {
        this.column = column;
        this.row = row;
    }

    public int getColumn() {
        return column;
    }

    public int getRow() {
        return row;
    }

    public void setColumn(int column) {
        this.column = column;
    }

    public void setRow(int row) {
        this.row = row;
    }
}
