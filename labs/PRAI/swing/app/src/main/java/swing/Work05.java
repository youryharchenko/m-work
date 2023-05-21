package swing;

public class Work05 extends Work {
    
    @Override
    public void run() {

        Node a = new Node("A", 0, 0);
        Node b = new Node("B", 10, 20);
        Node c = new Node("C", 20, 40);
        Node d = new Node("D", 30, 10);
        Node e = new Node("E", 40, 30);
        Node f = new Node("F", 50, 10);
        Node g = new Node("G", 50, 40);

        a.addEdge(new Edge(10, a, b));
        a.addEdge(new Edge(50, a, d));

        b.addEdge(new Edge(10, b, c));
        b.addEdge(new Edge(20, b, d));

        c.addEdge(new Edge(10, c, e));
        c.addEdge(new Edge(30, c, g));

        d.addEdge(new Edge(80, d, f));

        e.addEdge(new Edge(50, e, f));
        e.addEdge(new Edge(10, e, g));

        g.addEdge(new Edge(10, g, f));
      
                
        log.setText(log.getText() + String.format("\nStart .... \n"));

        log.setText(log.getText() + String.format("Path <%s->%s>: ", a, f));
        AStarSearch search1 = new AStarSearch(a, f, log);
        search1.run();
        search1.printSolutionPath();

        log.setText(log.getText() + String.format("Path <%s->%s>: ", a, d));
        AStarSearch search2 = new AStarSearch(a, d, log);
        search2.run();
        search2.printSolutionPath();

        log.setText(log.getText() + String.format("Path <%s->%s>: ", b, f));
        AStarSearch search3 = new AStarSearch(b, f, log);
        search3.run();
        search3.printSolutionPath();

        log.setText(log.getText() + String.format("Path <%s->%s>: ", d, f));
        AStarSearch search4 = new AStarSearch(d, f, log);
        search4.run();
        search4.printSolutionPath();



        log.setText(log.getText() + String.format("Finish\n\n"));
    }

}
