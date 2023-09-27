package el;

import javax.swing.JFileChooser;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import java.io.File;

public class Open {
	
	public static File file(Env env) throws OWLOntologyCreationException {
		JFileChooser fileChooser = new JFileChooser();
		fileChooser.setCurrentDirectory(new File(env.conf.get("ontologies", "dir").toString()));
		int result = fileChooser.showOpenDialog(env.parent);
		if (result == JFileChooser.APPROVE_OPTION) {
		    File selectedFile = fileChooser.getSelectedFile();
		    System.out.println("Selected file: " + selectedFile.getAbsolutePath());
		    return selectedFile;
		} else {
			return null;
		}
	}
}

