package swing;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Graphics2D;

import javax.swing.JPanel;
import javax.swing.JSplitPane;

public class Work06_2 extends Work {

    class Plot extends JPanel {

        String title = "Title";
        int pad = 12;

        double xs[] = new double[]{};
        double ys[] = new double[]{};

        double xp = 0;
        double yp = 0;

        public void setXp(double xp) {
            this.xp = xp;
        }

        public void setYp(double yp) {
            this.yp = yp;
        }

        void paintPlot(Graphics2D g) {

            g.drawString(title, pad, pad * 2);

            g.setColor(Color.BLACK);
            g.drawRect(pad, pad * 3, getWidth() - pad * 2, getHeight() - pad * 4);

            int xBeg = pad;
            int yBeg = pad * 3;
            int xEnd = getWidth() - pad;
            int yEnd = getHeight() - pad;

            int n = xs.length;

            if (n == 0) return;

            double minY = ys[0];
            double maxY = ys[0];

            for (int i = 0; i < n; i++) {
                if (minY > ys[i]) minY = ys[i];
                if (maxY < ys[i]) maxY = ys[i];
            }

            double scalX = (double)(xEnd - xBeg)/(xs[n-1] - xs[0]);
            double scalY = (double)(yEnd - yBeg)/(maxY - minY);

            int shiftX = xBeg - (int)(xs[0] * scalX);
            int shiftY = yBeg - (int)(minY * scalY);

            //System.out.println(String.format("shiftX=%d, shiftY=%d", shiftX, shiftY));

            
            g.drawLine(xBeg, yEnd - shiftY + yBeg, xEnd, yEnd - shiftY + yBeg);
            g.drawLine(shiftX, yBeg, shiftX, yEnd);

            g.setStroke(new BasicStroke(2f));

            for (int i = 0; i < n - 1; i++) {
                g.drawLine((int)Math.round(xs[i] * scalX) + shiftX, 
                            yEnd - (int)Math.round(ys[i] * scalY) - shiftY + yBeg, 
                            (int)Math.round(xs[i + 1] * scalX) + shiftX, 
                            yEnd - (int)Math.round(ys[i + 1] * scalY) - shiftY + yBeg);
            }
            
            g.setColor(Color.RED);
            g.fillOval(
                (int)Math.round(xp * scalX) + shiftX - 10,
                yEnd - (int)Math.round(yp * scalY) - shiftY + yBeg - 10,
                21, 21);


            


            // g.setColor(Color.RED);
            // g.fillRect(10, 50, 50, 50);

            // g.translate(ALLBITS, ABORT);
            

        }

        @Override
        public void paintComponent(Graphics context) {
            super.paintComponent(context);

            Graphics2D g = (Graphics2D) context.create();
            paintPlot(g);

            g.dispose();
        }

    }

    public Plot plot = new Plot();
    JSplitPane pane = new JSplitPane(JSplitPane.VERTICAL_SPLIT, plot, log);

    public Work06_2() {
        log.setEditable(false);
        pane.setDividerLocation(400);

        plot.title = "Hill Climbing search";

    }

    @Override
    public Component getComponent() {
        return pane;
    }

    @Override
    public void run() {

        writeLog("\n Started...");
        writeLog("\n Function: y=-0.09*(x-0.1)^4 + 3*(x-0.4)^2 +12");

        HillClimbing hillClimbing = new HillClimbing();
        hillClimbing.hillClimbingSearch(this, -7.0, 7.0, 0.001);

        //writeLog("\n Finish\n");
    }

}
