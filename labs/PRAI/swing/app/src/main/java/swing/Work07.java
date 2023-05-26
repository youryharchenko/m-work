package swing;

public class Work07 extends Work {
    
    @Override
    public void run() {
    
        

                
        writeLog(String.format("\nStart .... \n"));
        
        //let's use tabu search to solve the optimization
        TabuSearch tabuSearch = new TabuSearch(200, 0.1, -10.0, 400);
        //we have to define a starting point (at random)
        TabuSearch.State result = tabuSearch.solve(100, 100, 10^5);
        System.out.println(result);

        writeLog(String.format("\nDone: result=%s\n", result));

        writeLog(String.format("\nFinish\n\n"));

    }

}
