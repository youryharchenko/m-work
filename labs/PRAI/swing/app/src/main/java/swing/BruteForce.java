package swing;

import java.util.List;
import java.util.concurrent.ExecutionException;

import javax.swing.SwingWorker;


public class BruteForce {

    // private static final double START_X = -1;
    // private static final double END_X = 2;

    // interval is [START_X, END_X] !!!
    public double f(double x) {
        //return (x - 1) * (x - 1) - 1;
        return Math.sin(1.0/x);
    }

    public void bruteForceSearch(Work06_1 work, double startX, double endX, double dx) {

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
                double min = f(startX);
                double minX = startX;
                int t = 0;

                for (int i = 0; i < n; i++) {

                    t++;

                    if (ys[i] < min) {
                        min = ys[i];
                        minX = xs[i];

                        //System.out.println(String.format("y=%f, x=%f", min, minX));

                        
                    }

                    if (t > 5) {
                        t = 0;
                        publish(new double[] { min, minX });
                        Thread.sleep(10);
                    }
                    

                }
                return new double[] { min, minX };
            }

            protected void done() {
                double[] res;
                try {
                    // Retrieve the return value of doInBackground.
                    res = get();
                    // statusLabel.setText(Completed with status: ' + status);
                    String msg = String.format("\n\nDone: The minimum value is y=%f and x=%f\n", res[0], res[1]);
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
                
                for(int i = 0; i < chunks.size(); i++) {

                    double[] v = chunks.get(i);
                    String msg = String.format("y=%f, x=%f", v[0], v[1]);
                    System.out.println(msg);
                    work.writeLog(msg+"\n");
                    
                    work.plot.setXp(v[1]);
                    work.plot.setYp(v[0]);

                    work.plot.repaint();   

                }



                
            }

        };

        worker.execute();
    }
}
