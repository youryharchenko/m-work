package swing;

import java.util.List;
import java.util.Random;
import java.util.concurrent.ExecutionException;

import javax.swing.SwingWorker;

public class SimulatedAnnealing {

    private Random randomGenerator;
    private double currentCoordinateX;
    private double nextCoordinateX;
    private double bestCoordinateX;

    double maxTemp; // Constants.MAX_TEMPERATURE
    double minTemp; // Constants.MIN_TEMPERATURE
    double coolRate; // Constants.COOLING_RATE);

    public SimulatedAnnealing(double maxTemp, double minTemp, double coolRate) {
        this.randomGenerator = new Random();

        this.maxTemp = maxTemp;
        this.minTemp = minTemp;
        this.coolRate = coolRate;

    }

    public double f(double x) {
        // return (x - 0.3) * (x - 0.3) * (x - 0.3) - 5 * x + x * x - 2;
        return Math.sin(4 * x) + 2 * Math.sin(Math.pow(Math.E, x));
    }

    private double getRandomX(double minX, double maxX) {
        return randomGenerator.nextDouble() * (maxX - minX) + minX;
    }

    private double getEnergy(double x) {
        return f(x);
    }

    private double acceptanceProbability(double actualEnergy, double newEnergy, double temp) {
        if(newEnergy < actualEnergy) return 1.0;

        return Math.exp((actualEnergy - newEnergy) / temp);
    }

    public void search(Work08 work, double startX, double endX, double dx) {

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

                
                double temp = maxTemp;

                while (temp > minTemp) {
                
                    nextCoordinateX = getRandomX(startX, endX);

                    double currentEnergy = getEnergy(currentCoordinateX);
                    double newEnergy = getEnergy(nextCoordinateX);

                    if(acceptanceProbability(currentEnergy, newEnergy, temp) > Math.random())
                        currentCoordinateX = nextCoordinateX;

                    if(f(currentCoordinateX) < f(bestCoordinateX))
                        bestCoordinateX = currentCoordinateX;

                    temp = temp * (1 - coolRate);

                    
                    publish(new double[] { f(bestCoordinateX), bestCoordinateX });
                    Thread.sleep(100);
                    
                }
                    
                return new double[] { f(bestCoordinateX), bestCoordinateX };
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

                for (int i = 0; i < chunks.size(); i++) {

                    double[] v = chunks.get(i);
                    String msg = String.format("y=%f, x=%f", v[0], v[1]);
                    System.out.println(msg);
                    //work.writeLog(msg + "\n");

                    work.plot.setXp(v[1]);
                    work.plot.setYp(v[0]);

                    work.plot.repaint();

                }

            }

        };

        worker.execute();
    }

}
