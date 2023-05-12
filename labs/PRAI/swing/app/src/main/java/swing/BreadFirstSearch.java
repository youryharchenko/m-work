package swing;

import java.awt.TextArea;
import java.util.LinkedList;
import java.util.Queue;

public class BreadFirstSearch {

    TextArea log;

    BreadFirstSearch(TextArea log ) {
        this.log = log;
    }

    public void traverse(Vertex root) {
        Queue<Vertex> queue = new LinkedList<>();
        root.setVisited(true);

        queue.add(root);
        while (!queue.isEmpty()) {
            Vertex actualVertex = queue.remove();

            System.out.println("Actual visited vertex: " + actualVertex);
            log.setText(log.getText() + String.format("Actual visited vertex: <%s>\n", actualVertex));

            for (Vertex v : actualVertex.getAdjacencyList()) {
                if (!v.isVisited()) {
                    v.setVisited(true);
                    queue.add(v);
                }
            }
        }
    }

}
