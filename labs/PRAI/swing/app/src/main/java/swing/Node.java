package swing;

import java.util.ArrayList;
import java.util.List;

public class Node {
    
    private String name;
    private double x;
    private double y;

    public double getX() {
        return x;
    }

    public void setX(double x) {
        this.x = x;
    }

    public double getY() {
        return y;
    }

    public void setY(double y) {
        this.y = y;
    }

    // parameters for the A* search
    private double g;
    private double h;
    private double f;

    public double getG() {
        return g;
    }

    public void setG(double g) {
        this.g = g;
    }

    public double getH() {
        return h;
    }

    public void setH(double h) {
        this.h = h;
    }

    public double getF() {
        return f;
    }

    public void setF(double f) {
        this.f = f;
    }

    // track the adjacency list (neighbors)
    private List<Edge> adjacencyList;
    
    public List<Edge> getAdjacencyList() {
        return adjacencyList;
    }

    // it tracks the previous node in the shortest path
    private Node parent;

    public Node getParent() {
        return parent;
    }

    public void setParent(Node parent) {
        this.parent = parent;
    }

    public Node(String name, double x, double y) {
        this.name = name;
        this.x = x;
        this.y = y;
        this.adjacencyList = new ArrayList<>();
    }

    public void addEdge(Edge edge) {
        this.adjacencyList.add(edge);
    }

    @Override
    public String toString() {
          return "V:" + name;
    }
}
