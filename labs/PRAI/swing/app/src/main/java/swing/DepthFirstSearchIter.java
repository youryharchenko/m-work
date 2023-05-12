package swing;

import java.awt.TextArea;
import java.util.List;
import java.util.Stack;

public class DepthFirstSearchIter {
    TextArea log;

    private Stack<Vertex> stack;

    DepthFirstSearchIter(TextArea log) {
        this.log = log;
        stack = new Stack<Vertex>();
    }

    public void dfs(List<Vertex> vertexList) {
        // if we have independent clasters
        for (Vertex v : vertexList) {
            if (!v.isVisited()) {
                v.setVisited(true);
                dfsHelper(v);
            }
        }
    }

    private void dfsHelper(Vertex rootVertex) {
        stack.add(rootVertex);
        rootVertex.setVisited(true);

        while (!stack.isEmpty()) {
            Vertex actualVertex = stack.pop();

            System.out.println(actualVertex);
            log.setText(log.getText() + String.format("Actual visited vertex: <%s>\n", actualVertex));

            // consider all neighbors
            for (Vertex v : actualVertex.getNeighbors()) {
                if (!v.isVisited()) {
                    v.setVisited(true);
                    stack.add(v);
                }
            }
        }
    }

}
