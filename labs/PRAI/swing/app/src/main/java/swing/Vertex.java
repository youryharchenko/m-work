package swing;

import java.util.ArrayList;
import java.util.List;

public class Vertex {

    private String name; // - для збереження назви вершини;
    private boolean visited; // - для збереження ознаки відвідування вершини;
    private List<Vertex> adjacencyList; // - список суміжних вершин (потрібний імпорт java.util.List);

    public Vertex(String name) {
        this.name = name;
        this.adjacencyList = new ArrayList<Vertex>();
    }

    @Override
    public String toString() {
        return "V:" + this.name;
    }

    public String getName() {
        return this.name;
    }

    public boolean isVisited() {
        return visited;
    }

    public void setVisited(boolean visited) {
        this.visited = visited;
    }

    private int depthLevel = 0;

    public int getDepthLevel() {
        return depthLevel;
    }

    public void setDepthLevel(int depthLevel) {
        this.depthLevel = depthLevel;
    }

    public List<Vertex> getAdjacencyList() {
        return adjacencyList;
    }

    public void addNeighbor(Vertex vertex) {
        this.adjacencyList.add(vertex);
    }

    public List<Vertex> getNeighbors() {
        return adjacencyList;
    }

}
