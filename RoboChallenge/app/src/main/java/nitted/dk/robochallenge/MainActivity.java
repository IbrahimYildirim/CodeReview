package nitted.dk.robochallenge;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.widget.Toast;

import butterknife.ButterKnife;
import nitted.dk.robochallenge.Model.Grid;
import nitted.dk.robochallenge.Model.Robot;

public class MainActivity extends AppCompatActivity {

    private Grid grid;
    private Robot robot;
    private InputFragment inputFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ButterKnife.bind(this);

        showNewInputFragment();
    }

    public void showNewInputFragment() {
        inputFragment = new InputFragment();
        showFragment(inputFragment);
    }

    public void startRobot(@NonNull final Bundle data) {
        // All data validated, start robot
        final int gridColumnSize = data.getInt(InputFragment.bundleGridColumnKey);
        final int gridRowSize = data.getInt(InputFragment.bundleGridRowKey);
        final int robotStartColumn = data.getInt(InputFragment.bundleRobotStartColumnKey);
        final int robotStartRow = data.getInt(InputFragment.bundleRobotStartRowKey);
        final Robot.Direction startDirection = Robot.Direction.fromAngle(data.getInt(InputFragment.bundleRobotStartDirectionKey));
        final String routeCode = data.getString(InputFragment.bundleRouteKey);

        Log.d(this.getLocalClassName(), "Grid: " + gridColumnSize + "x" + gridRowSize);
        Log.d(this.getLocalClassName(), "Robot: " + robotStartColumn + "x" + robotStartRow + ", Direction: " + startDirection.toString());

        grid = new Grid(gridColumnSize, gridRowSize);
        robot = new Robot(grid, new Grid(robotStartColumn, robotStartRow), startDirection);

        //Variable to count errors
        int errors = 0;

        for (int i = 0; i < routeCode.length(); i++) {
            String s = String.valueOf(routeCode.charAt(i));

            try {
                robot.turn(Robot.Turn.fromString(s));
                Log.d(this.getLocalClassName(), robot.toString());
            } catch (Exception e) {
                errors++;
            }
        }

        Toast.makeText(this, robot.toString() + " exceptions: " + String.valueOf(errors), Toast.LENGTH_LONG).show();
    }

    private void showFragment(final Fragment fragment) {
        FragmentManager manager = getSupportFragmentManager();
        FragmentTransaction ft = manager.beginTransaction();

        ft.setCustomAnimations(R.anim.fade_in, R.anim.fade_out);
        ft.replace(R.id.fragment_container, fragment);
        ft.commit();
    }
}
