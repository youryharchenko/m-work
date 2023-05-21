package swing;

import java.awt.Color;
import java.awt.Component;
import java.awt.Graphics;

import javax.swing.JPanel;
import javax.swing.JSplitPane;

public class Work06_1 extends Work {

    class Plot extends JPanel {
            
        String title = "Title";
        int pad = 10;

        void paintPlot(Graphics g) {

            
            g.drawString(title, pad, pad * 2);


            g.setColor(Color.BLACK);
            g.drawRect(pad, pad * 3, getWidth() - pad * 2, getHeight() - pad * 4);

            //g.setColor(Color.RED);
            //g.fillRect(10, 50, 50, 50);
            
        }

        @Override
        public void paintComponent(Graphics g) {
            super.paintComponent(g);

            paintPlot(g);

            
        }

    }

    Plot plot = new Plot();
    JSplitPane pane = new JSplitPane(JSplitPane.VERTICAL_SPLIT, plot, log);

    public Work06_1() {
        log.setEditable(false);
        pane.setDividerLocation(400);

        plot.title = "Brute-force search";

    }

    @Override
    public Component getComponent() {
        return pane;
    }

    @Override
    public void run() {

        writeLog("\n Started...");

        

        writeLog("\n Finish\n");
    }

}
