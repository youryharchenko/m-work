package swing;

import java.awt.TextArea;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.PriorityQueue;
import java.util.Set;

public class AStarSearch {

    TextArea log;

    private Node source;
    private Node destination;
    private Set<Node> explored;
    private PriorityQueue<Node> queue;

    public AStarSearch(Node source, Node destination, TextArea log) {
        this.log = log;

        this.source = source;
        this.destination = destination;
        this.explored = new HashSet<>();
        this.queue = new PriorityQueue<>(new NodeComparator());
    }

    public void run() {

        queue.add(source);
        //System.out.print(source);System.out.println(source.getParent());

        while (!queue.isEmpty()) {
            // we always get the node with the lowest f(x) value possible
            Node current = queue.poll();
            explored.add(current);
            // we have found the destination node
            if (current == destination)
                break;
            // consider the adjacent nodes
            for (Edge edge : current.getAdjacencyList()) {
                Node child = edge.getTarget();
                double cost = edge.getWeight();
                double tempG = current.getG() + cost;
                double tempF = tempG + heuristic(current, destination);
                // if we have not considered the child and the f(x) is higher
                if (explored.contains(child) && tempF >= child.getF()) {
                    continue;
                }
                // else if we have not visited OR the f(x) score is lower
                else if (!queue.contains(child) || tempF < child.getF()) {
                    // this is how we can track the shortest path (predecessor)
                    child.setParent(current);
                    child.setG(tempG);
                    child.setF(tempF);
                    // we have it in the queue but now we have a lower value
                    // instead of update - we remove and reinsert again
                    if (queue.contains(child))
                        queue.remove(child);
                    queue.add(child);
                    //System.out.print(child);System.out.println(child.getParent());
                }
            }
        }
    }

    public void printSolutionPath() {
        List<Node> path = new ArrayList<>();

        for (Node node = destination; node != null; node = node.getParent()) {
            path.add(node);
            if (node == source)
                break;
        }

        Collections.reverse(path);
        System.out.println(path);
        log.setText(log.getText() + String.format("%s\n", path));
    }

    private double heuristic(Node node1, Node node2) {
        return Math.sqrt(((node1.getX() - node2.getX()) * (node1.getX() - node2.getX())) +
                ((node1.getY() - node2.getY()) * (node1.getY() - node2.getY())));
    }

}
