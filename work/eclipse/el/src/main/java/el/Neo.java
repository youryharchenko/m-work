package el;

import java.io.File;

import org.neo4j.dbms.api.DatabaseManagementService;
import org.neo4j.dbms.api.DatabaseManagementServiceBuilder;
import org.neo4j.graphdb.GraphDatabaseService;

public class Neo {
	
	public File path;
	public DatabaseManagementService man;
	public GraphDatabaseService db;
	
	
	public Neo(Conf conf) {
		this.path = new File(conf.get("db", "dir").toString());
		this.man = new DatabaseManagementServiceBuilder(this.path.toPath()).build();
		this.db = this.man.database(conf.get("db", "name").toString());
		registerShutdownHook( this.man);
	}


	private void registerShutdownHook(final DatabaseManagementService m) {
		Runtime.getRuntime().addShutdownHook( new Thread()
	    {
	        @Override
	        public void run()
	        {
	            m.shutdown();
	        }
	    } );
	}

}
