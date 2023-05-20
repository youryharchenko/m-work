package swing;

import java.awt.TextArea;
import java.util.ArrayList;
import java.util.List;

public class Work04 extends Work {
    
    @Override
    public void run(TextArea log) {

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

        //b.addNeighbor(a);
        b.addNeighbor(c);
        b.addNeighbor(d);

        //c.addNeighbor(b);

        //d.addNeighbor(b);
        d.addNeighbor(e);

        //e.addNeighbor(d);

        //f.addNeighbor(a);
        
        //g.addNeighbor(a);
        g.addNeighbor(h);

        //h.addNeighbor(g);
                
        log.setText(log.getText() + String.format("\nStart .... \n"));

        IDDFS alg1 = new IDDFS(f, log); 
        alg1.runDeepeningSearch(a); 

        IDDFS alg2 = new IDDFS(d, log); 
        alg2.runDeepeningSearch(a); 

        IDDFS alg3 = new IDDFS(e, log); 
        alg3.runDeepeningSearch(a); 

        log.setText(log.getText() + String.format("Finish\n\n"));
    }

}
