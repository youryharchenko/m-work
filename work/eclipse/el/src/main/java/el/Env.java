package el;

import javax.swing.JFrame;

import org.semanticweb.owlapi.model.OWLOntologyManager;

public class Env {
	public JFrame parent;  
	public OWLOntologyManager man;
	public Conf conf;
	
	public Env(Conf conf, JFrame parent, OWLOntologyManager man) {
		this.conf = conf;
		this.parent = parent;
		this.man = man;
	}
}
