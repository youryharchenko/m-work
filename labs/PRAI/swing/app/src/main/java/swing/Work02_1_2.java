package swing;

import java.awt.TextArea;
import java.util.ArrayList;
import java.util.List;

public class Work02_1_2 extends Work {
    
    @Override
    public void run(TextArea log) {

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
        a.addNeighbor(g);
       
        c.addNeighbor(b);
        c.addNeighbor(d);
        c.addNeighbor(e);

        d.addNeighbor(a);
        d.addNeighbor(h);

        e.addNeighbor(d);

        f.addNeighbor(d);
        
        g.addNeighbor(f);
        
        h.addNeighbor(f);
        h.addNeighbor(g);
                
        log.setText(log.getText() + String.format("\nStart .... \n"));

        dfs.dfs(graph);

        log.setText(log.getText() + String.format("Finish\n\n"));
    }

}
