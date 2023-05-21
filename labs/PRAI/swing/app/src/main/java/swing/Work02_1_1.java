package swing;

import java.awt.TextArea;
import java.util.ArrayList;
import java.util.List;

public class Work02_1_1 extends Work {
    
    @Override
    public void run() {

        DepthFirstSearchIter dfs = new DepthFirstSearchIter(log);

        Vertex a = new Vertex("A");
        Vertex b = new Vertex("B");
        Vertex c = new Vertex("C");
        Vertex d = new Vertex("D");
        Vertex e = new Vertex("E");
        Vertex f = new Vertex("F");
        Vertex g = new Vertex("G");
        Vertex h = new Vertex("H");

        List<Vertex> graph = new ArrayList<Vertex>();

        graph.add(a);
        graph.add(b);
        graph.add(c);
        graph.add(d);
        graph.add(e);
        graph.add(f);
        graph.add(g);
        graph.add(h);

        a.addNeighbor(b);
        a.addNeighbor(f);
        a.addNeighbor(g);

        b.addNeighbor(a);
        b.addNeighbor(c);
        b.addNeighbor(d);

        c.addNeighbor(b);

        d.addNeighbor(b);
        d.addNeighbor(e);

        e.addNeighbor(d);

        f.addNeighbor(a);
        
        g.addNeighbor(a);
        g.addNeighbor(h);

        h.addNeighbor(g);
        
        /*
        graph.add(v1);
        graph.add(v2);
        graph.add(v3);
        graph.add(v4);
        graph.add(v5);
        
        v1.addNeighbor(v2);
        v2.addNeighbor(v3);
        v2.addNeighbor(v4);
        v4.addNeighbor(v5);
        */

        log.setText(log.getText() + String.format("\nStart .... \n"));

        dfs.dfs(graph);

        log.setText(log.getText() + String.format("Finish\n\n"));
    }

}
