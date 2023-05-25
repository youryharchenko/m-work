package swing;

import java.util.List;
import java.util.concurrent.ExecutionException;

import javax.swing.SwingWorker;

public class HillClimbing {

    // private static final double START_X = -1;
    // private static final double END_X = 2;

    // interval is [START_X, END_X] !!!
    public double f(double x) {
        return -0.09 * Math.pow(x - 0.1, 4) + 3 * Math.pow(x - 0.4, 2) + 12;
    }

    public void hillClimbingSearch(Work06_2 work, double startX, double endX, double dx) {

        int n = (int) ((endX - startX) / dx);

        double[] xs = new double[n];
        double[] ys = new double[n];

        double x = startX;
        System.out.println(String.format("start=%f", startX));
        for (int i = 0; i < n; i++) {
            xs[i] = x;
            ys[i] = f(x);
            x += dx;
        }
        System.out.println(String.format("end=%f", x));

        work.plot.xs = xs;
        work.plot.ys = ys;

        SwingWorker<double[], double[]> worker = new SwingWorker<double[], double[]>() {

            @Override
            protected double[] doInBackground() throws Exception {
                
                double maxX = startX;
                double maxY =f(startX);
                double actualX = startX;
                int t = 0;

                while (f(actualX + dx) >= f(maxX)) {
                    t++;

                    maxX = actualX + dx;
                    maxY = f(maxX);
                    System.out.println("x: " + actualX + " f(x):" + maxY);

                    if (t > 5) {
                        t = 0;
                        publish(new double[] { maxY, maxX });
                        Thread.sleep(10);
                    }
                    actualX += dx;
                }
                
                return new double[] { maxY, maxX };
            }

            protected void done() {
                double[] res;
                try {
                    // Retrieve the return value of doInBackground.
                    res = get();
                    // statusLabel.setText(Completed with status: ' + status);
                    String msg = String.format("\n\nDone: The maximum value is y=%f and x=%f\n", res[0], res[1]);
                    System.out.println(msg);
                    work.writeLog(msg);
                    work.plot.setXp(res[1]);
                    work.plot.setYp(res[0]);

                    work.plot.repaint();

                } catch (InterruptedException e) {
                    // This is thrown if the thread's interrupted.
                } catch (ExecutionException e) {
                    // This is thrown if we throw an exception
                    // from doInBackground.
                }
            }

            @Override
            // Can safely update the GUI from this method.
            protected void process(List<double[]> chunks) {
                // Here we receive the values that we publish().
                // They may come grouped in chunks.

                for (int i = 0; i < chunks.size(); i++) {

                    double[] v = chunks.get(i);
                    String msg = String.format("y=%f, x=%f", v[0], v[1]);
                    System.out.println(msg);
                    work.writeLog(msg + "\n");

                    work.plot.setXp(v[1]);
                    work.plot.setYp(v[0]);

                    work.plot.repaint();

                }

            }

        };

        worker.execute();
    }
}
