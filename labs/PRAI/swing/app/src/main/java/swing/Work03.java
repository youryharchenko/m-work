package swing;

import java.awt.Font;
import java.awt.TextArea;

public class Work03 extends Work {

    @Override
    public void run() {

        Font logFont = new Font(Font.MONOSPACED, Font.PLAIN, 14);
        log.setFont(logFont);

        int[][] map1 = {
                { 1, 1, 1, 1, 1, 1 },
                { 2, 1, 0, 0, 0, 1 },
                { 0, 1, 0, 1, 0, 1 },
                { 0, 0, 0, 1, 0, 0 },
                { 0, 1, 0, 1, 1, 0 },
                { 0, 0, 0, 1, 0, 3 }
        };

        MazeSolver maze1 = new MazeSolver(map1, log);
        maze1.findWay();
        maze1.showSolution();

        int[][] map2 = {
                { 1, 1, 1, 1, 1, 1 },
                { 2, 1, 0, 0, 0, 1 },
                { 0, 1, 0, 1, 0, 1 },
                { 0, 0, 0, 1, 1, 0 },
                { 0, 1, 0, 1, 1, 0 },
                { 0, 0, 0, 1, 0, 3 }
        };

        MazeSolver maze2 = new MazeSolver(map2, log);
        maze2.findWay();
        maze2.showSolution();

        int[][] map3 = {
                { 1, 0, 0, 0, 1, 1 },
                { 2, 0, 1, 0, 0, 1 },
                { 0, 1, 0, 1, 0, 1 },
                { 0, 0, 0, 1, 0, 0 },
                { 0, 1, 0, 1, 1, 0 },
                { 0, 0, 0, 1, 3, 0 }
        };

        MazeSolver maze3 = new MazeSolver(map3, log);
        maze3.findWay();
        maze3.showSolution();
    }

}
