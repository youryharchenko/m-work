package swing;

import java.util.ArrayList;
import java.util.List;
import java.util.Queue;

import org.apache.commons.collections4.IteratorUtils;
import org.apache.commons.collections4.queue.CircularFifoQueue;

public class TabuSearch {

    private int nValues;
    private int nTabu;
    private State[][] states;
    private TabuList tabuList;
    private NeighborSolutionHandler neighborSolutionHandler;

    public TabuSearch(int nV, double d, double v0, int nTabu) {

        this.nValues = nV;
        this.nTabu = nTabu;
        this.states = new State[nValues][nValues];
        this.tabuList = new TabuList();
        this.neighborSolutionHandler = new NeighborSolutionHandler();

        double x = v0, y = v0;
        for (int row = 0; row < nValues; row++) {
            y = v0;
            for (int col = 0; col < nValues; col++) {
                states[row][col] = new State(x, y, CostFunction.f(x, y));
                y += d;
            }
            x += d;
        }

        for (int i = 0; i < nValues; i++) {
            states[i][0].addNeigbor(states[i][1]);
            states[i][199].addNeigbor(states[i][198]);
            states[0][i].addNeigbor(states[1][i]);
            states[199][i].addNeigbor(states[198][i]);
        }

        for (int row = 1; row < nValues - 1; row++) {
            for (int col = 1; col < nValues - 1; col++) {
                states[row][col].addNeigbor(states[row - 1][col]);
                states[row][col].addNeigbor(states[row + 1][col]);
                states[row][col].addNeigbor(states[row][col - 1]);
                states[row][col].addNeigbor(states[row][col + 1]);
            }
        }
    }

    public class State {

        private double x, y, z;

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

        public double getZ() {
            return z;
        }

        public void setZ(double z) {
            this.z = z;
        }

        private List<State> neighbors;

        public List<State> getNeighbors() {
            return neighbors;
        }

        public State(double x, double y, double z) {
            this.x = x;
            this.y = y;
            this.z = z;
            neighbors = new ArrayList<State>();
        }

        public void addNeigbor(State state) {
            neighbors.add(state);
        }

        @Override
        public String toString() {
            return String.format("State(x=%f, y=%f, z=%f)", x, y, z);
        }
    }

    public class TabuList {
        private Queue<State> tabuList;

        public TabuList() {
            this.tabuList = new CircularFifoQueue<State>(nTabu);
        }

        public List<State> getTabuItems() {
            return IteratorUtils.toList(this.tabuList.iterator());
        }

        public void add(State solution) {
            this.tabuList.add(solution);
        }
    }

    public class NeighborSolutionHandler {

        public State getBestNeighbor(State[][] states, List<State> neighborStates, List<State> tabuStates) {

            neighborStates.removeAll(tabuStates);

            if(neighborStates.size() == 0) 
                return states[100][100];

            State bestSolution = neighborStates.get(0);

            for(int i = 1; i < neighborStates.size(); i++) {
                if(neighborStates.get(i).getZ() < bestSolution.getZ())
                    bestSolution = neighborStates.get(i);
            }

            System.out.println("Best solution is: " + bestSolution);
            return bestSolution;
        }
    }

    public class CostFunction {

        public static double f(double x, double y) {
            return Math.exp(-x * x - y * y) * Math.sin(x);
        }

    }

    public State solve(int initX, int initY, int nIter) {

        State initialSolution = states[initX][initY];
        State bestState = initialSolution;
        State currentState = initialSolution;

        int iterationCounter = 0;

        while (iterationCounter < nIter) {
            List<State> candidateNeighbors = currentState.getNeighbors();
            List<State> solutionsTabu = tabuList.getTabuItems();

            State bestNeighborFound = neighborSolutionHandler.getBestNeighbor(states, candidateNeighbors, solutionsTabu);

            if (bestNeighborFound.getZ() < bestState.getZ()) {
                bestState = bestNeighborFound;
            }

            tabuList.add(currentState);

            currentState = bestNeighborFound;

            iterationCounter++;

        }

        return bestState;
    }

}
