package nitted.dk.robochallenge;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnCheckedChanged;
import butterknife.OnClick;
import nitted.dk.robochallenge.Model.Robot;

/**
 * Created by Ibrahim on 11/07/2017.
 */

public class InputFragment extends Fragment {

    public static String bundleRouteKey = "bundle_key_route";
    public static String bundleGridRowKey = "bundle_key_grid_row";
    public static String bundleGridColumnKey = "bundle_column_grid_key";
    public static String bundleRobotStartRowKey = "bundle_robot_row_key";
    public static String bundleRobotStartColumnKey = "bundle_robot_column_key";
    public static String bundleRobotStartDirectionKey = "bundle_direction_key";

    @BindView(R.id.grid_input_column) EditText txtColumn;
    @BindView(R.id.grid_input_row) EditText txtRow;
    @BindView(R.id.robot_input_column) EditText txtStartColumn;
    @BindView(R.id.robot_input_row) EditText txtStartRow;
    @BindView(R.id.txt_route) TextView txtRoute;

    private Robot.Direction selectedDirection;
    private StringBuilder routeCode = new StringBuilder();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        final View view = inflater.inflate(R.layout.fragment_input, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

    @OnCheckedChanged({ R.id.radio_east, R.id.radio_north, R.id.radio_south, R.id.radio_west })
    public void onRadioButtonClicked(RadioButton radioButton) {
        switch (radioButton.getId()) {
            case R.id.radio_east:
                selectedDirection = Robot.Direction.E;
                break;
            case R.id.radio_west:
                selectedDirection = Robot.Direction.W;
                break;
            case R.id.radio_north:
                selectedDirection = Robot.Direction.N;
                break;
            case R.id.radio_south:
                selectedDirection = Robot.Direction.S;
                break;
        }
    }

    @OnClick(R.id.reset_button)
    public void onReset() {
        ((MainActivity) getActivity()).showNewInputFragment();
    }

    @OnClick(R.id.next_button)
    public void onClickNext(final View view) {

        if (txtColumn.getText().length() == 0) {
            Toast.makeText(getContext(), "Enter # for Grid column", Toast.LENGTH_SHORT).show();
            txtColumn.requestFocus();
        } else if (txtRow.getText().length() == 0) {
            Toast.makeText(getContext(), "Enter # for Grid row", Toast.LENGTH_SHORT).show();
            txtColumn.requestFocus();
        } else if (txtStartColumn.getText().length() == 0) {
            Toast.makeText(getContext(), "Enter start position (column) for Robot", Toast.LENGTH_SHORT).show();
            txtStartColumn.requestFocus();
        } else if (txtStartRow.getText().length() == 0) {
            Toast.makeText(getContext(), "Enter start position (row) for Robot", Toast.LENGTH_SHORT).show();
            txtStartRow.requestFocus();
        } else if (selectedDirection == null) {
            Toast.makeText(getContext(), "Select directions for robot", Toast.LENGTH_SHORT).show();
        } else if (txtRoute.getText().length() == 0) {
            Toast.makeText(getContext(), "Select actions for robot", Toast.LENGTH_SHORT).show();
        } else {

            // All data validated, start robot
            final int gridColumnSize = Integer.parseInt(txtColumn.getText().toString());
            final int gridRowSize = Integer.parseInt(txtRow.getText().toString());
            final int robotStartColumn = Integer.parseInt(txtStartColumn.getText().toString());
            final int robotStartRow = Integer.parseInt(txtStartRow.getText().toString());
            final int startAngle = selectedDirection.getAngle();
            final String routeCode = txtRoute.getText().toString();

            if (gridColumnSize < robotStartColumn || gridRowSize < robotStartRow) {
                Toast.makeText(getContext(), "Invalid start point", Toast.LENGTH_SHORT).show();
                return;
            }

            final Bundle data = new Bundle();
            data.putInt(bundleGridRowKey, gridRowSize);
            data.putInt(bundleGridColumnKey, gridColumnSize);
            data.putInt(bundleRobotStartColumnKey, robotStartColumn);
            data.putInt(bundleRobotStartRowKey, robotStartRow);
            data.putInt(bundleRobotStartDirectionKey, startAngle);
            data.putString(bundleRouteKey, routeCode);

            ((MainActivity) getActivity()).startRobot(data);
        }
    }

    @OnClick(R.id.btn_route_left)
    public void onLeftClick() {
        routeCode.append("L");
        updateTextView();
    }

    @OnClick(R.id.btn_route_forward)
    public void onForwardClick() {
        routeCode.append("F");
        updateTextView();
    }

    @OnClick(R.id.btn_route_right)
    public void onRightClick() {
        routeCode.append("R");
        updateTextView();
    }

    @OnClick(R.id.btn_route_delete)
    public void onDeleteClick() {
        routeCode.setLength(0);
        updateTextView();
    }

    private void updateTextView() {
        txtRoute.setText(routeCode.toString());
    }

}
