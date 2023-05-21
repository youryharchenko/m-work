package swing;

public class Work01 extends Work {
    
    @Override
    public void run() {

        BreadFirstSearch bfs = new BreadFirstSearch(log);

        Vertex a = new Vertex("A");
        Vertex b = new Vertex("B");
        Vertex c = new Vertex("C");
        Vertex d = new Vertex("D");
        Vertex e = new Vertex("E");
        Vertex f = new Vertex("F");
        Vertex g = new Vertex("G");
        Vertex h = new Vertex("H");

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

        h.addNeighbor(e);
        h.addNeighbor(f);
        h.addNeighbor(g);
        
        /* 
        a.addNeighbor(b);
        a.addNeighbor(f);
        a.addNeighbor(g);

        b.addNeighbor(a);
        b.addNeighbor(c);
        b.addNeighbor(d);

        c.addNeighbor(b);

        d.addNeighbor(b);
        d.addNeighbor(e);

        f.addNeighbor(a);

        g.addNeighbor(a);
        g.addNeighbor(h);

        h.addNeighbor(g);
        */
    

        log.setText(log.getText() + String.format("\nStart .... \n"));

        bfs.traverse(a);

        log.setText(log.getText() + String.format("Finish\n\n"));
    }

}
