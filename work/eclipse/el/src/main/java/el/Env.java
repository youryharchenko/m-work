package el;

import javax.swing.JFrame;

import org.semanticweb.owlapi.model.OWLOntologyManager;

public class Env {
	public JFrame parent;  
	public OWLOntologyManager man;
	public Conf conf;
	public Neo db;
	
	public Env(Conf conf, JFrame parent, OWLOntologyManager man, Neo db) {
		this.conf = conf;
		this.parent = parent;
		this.man = man;
		this.db = db;
	}
}
