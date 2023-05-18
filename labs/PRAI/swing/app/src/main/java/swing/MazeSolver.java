package swing;

import java.awt.TextArea;

public class MazeSolver {
    private int startRow = -1;
    private int startCol = -1;
    private int endRow = -1;
    private int endCol = -1;
    private int[][] maze;
    private boolean[][] visited;
    TextArea log;

    public MazeSolver(int[][] maze, TextArea log) {
        this.maze = maze;
        this.visited = new boolean[maze.length][maze.length];
        for (int row = 0; row < maze.length; row++) {
            for (int col = 0; col < maze[0].length; col++) {
                if (maze[row][col] == 2) {
                    this.startRow = row;
                    this.startCol = col;
                }
                if (maze[row][col] == 3) {
                    this.endRow = row;
                    this.endCol = col;
                }
            }
        }
        
        this.log = log;
    }

    public void findWay() {
        if (startCol == -1 || startRow == -1 || endCol == -1 || endRow == -1) {
            System.out.println("Start/end (both) position(-s) is not correct");
            log.setText(log.getText() + String.format("\nStart/end (both) position(-s) is not correct\n"));
            return;
        } 
        if (dfs(startRow, startCol)) {
            System.out.println("Solution exists...");
            log.setText(log.getText() + String.format("\nSolution exists\n"));
        } else {
            System.out.println("No solution exists...");
            log.setText(log.getText() + String.format("\nNo solution exists\n"));
        }
    }

    private boolean isFeasible(int x, int y) {
        // we check the vertical dimension
        if (x < 0 || x > maze.length - 1)
            return false;
        // we check the horizontal dimension
        if (y < 0 || y > maze.length - 1)
            return false;
        // when we have already considered that state
        if (visited[x][y])
            return false;
        // there is an obstacle in the way
        if (maze[x][y] == 1)
            return false;
        return true;
    }

    private boolean dfs(int x, int y) {
        // base-case
        
        if (isFeasible(x, y)) {
            if (maze[x][y] == 3)
                return true;

            if (maze[x][y] != 2) 
                maze[x][y] = 9;
            visited[x][y] = true;

            // then we have to visit the next cells (U,D,L,R)
            // going down
            if (dfs(x + 1, y))
                return true;
            // going up
            if (dfs(x - 1, y))
                return true;
            // going to the right
            if (dfs(x, y + 1))
                return true;
            // going to the left
            if (dfs(x, y - 1))
                return true;
            // BACKTRACK
            visited[x][y] = false;
            return false;
        }
        return false;
    }

    void showSolution() {
        //log.setText(log.getText() + String.format("\nSolution\n"));
        for (int row = 0; row < visited.length; row++) {
            String rowStr = "";
            for (int col = 0; col < visited[0].length; col++) {
                if (maze[row][col] == 1)
                    rowStr += "#";
                else if (maze[row][col] == 2)
                    rowStr += "S";
                else if (maze[row][col] == 3)
                    rowStr += "E";
                else if (visited[row][col])
                    rowStr += ".";
                else if (maze[row][col] == 9)
                    rowStr += "*";
                else
                    rowStr += " ";

                rowStr += " ";
            }
            System.out.println(rowStr);
            log.setText(log.getText() + String.format("%s\n", rowStr));
        }
        log.setText(log.getText() + String.format("\n"));
    }

}
