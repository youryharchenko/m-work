package swing;

import java.awt.TextArea;
import java.util.List;
//import java.util.Stack;

public class DepthFirstSearchRec {
    TextArea log;

    //private Stack<Vertex> stack;

    DepthFirstSearchRec(TextArea log) {
        this.log = log;
        //stack = new Stack<Vertex>();
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

    private void dfsHelper(Vertex vertex) {
        System.out.println(vertex);
        log.setText(log.getText() + String.format("Actual visited vertex: <%s>\n", vertex));

        for(Vertex v: vertex.getNeighbors()) {
            if(!v.isVisited()) {
                v.setVisited(true);
                dfsHelper(v);
            }
        }

    }

}
