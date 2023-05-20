package swing;

import java.util.Comparator;

public class NodeComparator implements Comparator<Node>{

    @Override
    public int compare(Node o1, Node o2) {
        return Double.compare(o1.getF(), o2.getF());
    }

}
