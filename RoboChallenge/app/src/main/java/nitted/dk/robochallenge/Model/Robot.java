package nitted.dk.robochallenge.Model;

/**
 * Created by Ibrahim on 11/07/2017.
 */

public class Robot {

    private Grid position;
    private Direction direction;
    private Grid grid;

    public Robot(final Grid grid, final Grid position, final Direction direction) {
        this.grid = grid;
        this.position = position;
        this.direction = direction;
    }

    public void turn(final Turn turn) throws Exception {

        final int newAngle;

        switch (turn) {
            case LEFT:
                // Turn 90 degrees to left
                newAngle = direction.getAngle() == 0 ? 270 : direction.getAngle() - 90;
                direction = Direction.fromAngle(newAngle);
                break;
            case RIGHT:
                // Turn 90 degrees to right
                newAngle = direction.getAngle() == 270 ? 0 : direction.getAngle() + 90;
                direction = Direction.fromAngle(newAngle);
                break;
            case FORWARD:
                // Keep same angle move forward
                moveForward();
                break;
        }
    }

    private void moveForward() throws Exception {

        switch (direction) {
            case E:
                if (position.getColumn() == grid.getColumn() - 1) {
                    throw new Exception("Out of grid");
                } else {
                    position.setColumn(position.getColumn() + 1);
                }
                break;
            case W:
                if (position.getColumn() == 0) {
                    throw new Exception("Out of grid");
                } else {
                    position.setColumn(position.getColumn() - 1);
                }
                break;
            case N:
                if (position.getRow() == 0) {
                    throw new Exception("Out of grid");
                } else {
                    position.setRow(position.getRow() - 1);
                }
                break;
            case S:
                if (position.getRow() == grid.getRow() - 1) {
                    throw new Exception("Out of grid");
                } else {
                    position.setRow(position.getRow() + 1);
                }
                break;
        }
    }

    public Direction getDirection() {
        return direction;
    }

    public void setDirection(Direction direction) {
        this.direction = direction;
    }

    public Grid getPosition() {
        return position;
    }

    public Grid getGrid() {
        return grid;
    }

    public String toString() {
        return "Position: " + position.getColumn() + "," + position.getRow() + " Direction: " + direction.toString();
    }

    public enum Turn {
        LEFT("L"), RIGHT("R"), FORWARD("F");

        public final String id;

        Turn(final String id) {
            this.id = id;
        }

        public static Turn fromString(String s) {
            for (Turn t : Turn.values()) {
                if (t.id.equals(s)) {
                    return t;
                }
            }
            return null;
        }
    }

    public enum Direction {
        // Facing east = 0 degrees
        E(0), S(90), W(180), N(270);

        private final int angle;

        Direction(int angle) {
            this.angle = angle;
        }

        public int getAngle() {
            return angle;
        }

        public static Direction fromAngle(int angle) {
            for (Direction d : Direction.values()) {
                if (d.getAngle() == angle) {
                    return d;
                }
            }
            return null;
        }
    }
}
