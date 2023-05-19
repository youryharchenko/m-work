package swing;

import java.awt.TextArea;
//import java.util.List;
import java.util.Stack;

public class IDDFS {
    TextArea log;

    private Vertex targetVertex;
    private volatile boolean isTargetFound;

    // private Stack<Vertex> stack;

    IDDFS(Vertex targetVertex, TextArea log) {
        this.log = log;
        // stack = new Stack<Vertex>();

        this.targetVertex = targetVertex;
    }

    public void runDeepeningSearch(Vertex rootVertex) {
        int depth = 0;
        while (!isTargetFound) {
            System.out.println();
            log.setText(log.getText() + String.format("\n"));
            dfs(rootVertex, depth);
            depth++;
        }
    }

    public void dfs(Vertex sourceVertex, int depthLevel) {
        Stack<Vertex> stack = new Stack<>();

        sourceVertex.setDepthLevel(0);
        stack.push(sourceVertex);

        while (!stack.isEmpty()) {
            Vertex actualNode = stack.pop();
            System.out.print(actualNode + " ");
            log.setText(log.getText() + String.format("%s ", actualNode));

            if (actualNode.getName().equals(this.targetVertex.getName())) {
                System.out.println("\nVertex found...");
                log.setText(log.getText() + String.format("\nVertex %s found\n\n", targetVertex));
                this.isTargetFound = true;
                return;
            }
            if (actualNode.getDepthLevel() >= depthLevel) {
                continue;
            }
            for (Vertex node : actualNode.getAdjacencyList()) {
                node.setDepthLevel(actualNode.getDepthLevel() + 1);
                stack.push(node);
            }
        }

    }

}
