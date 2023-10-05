package el;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTabbedPane;
import javax.swing.JTree;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreePath;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyManager;



public class App {
	
	Conf conf = new Conf("el.ini");
	
	Neo neo = new Neo(conf); 
	
    UIManager.LookAndFeelInfo[] looks = UIManager.getInstalledLookAndFeels();
    JFrame frame = new JFrame("EL - Ontologies + Agent-Oriented Design");

    JMenuBar mb = new JMenuBar();

    JMenu mFile = new JMenu("File");
    JMenuItem mNew = new JMenuItem("New...");
    JMenuItem mOpen = new JMenuItem("Open...");


    JMenu mView = new JMenu("View");
    JMenuItem mLookAndFeel = new JMenu("LookAndFeel");

    JMenu mHelp = new JMenu("Help");

    DefaultMutableTreeNode rootNode = new DefaultMutableTreeNode("System");
    DefaultMutableTreeNode ontoNode = new DefaultMutableTreeNode("Ontologies");
    DefaultMutableTreeNode agntNode = new DefaultMutableTreeNode("Agents");

    JTree tree = new JTree(rootNode);
    JScrollPane treeScrollPane = new JScrollPane(tree);

    JTabbedPane tabs = new JTabbedPane();
    JScrollPane tabsScrollPane = new JScrollPane(tabs);
    JSplitPane cenPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, treeScrollPane, tabsScrollPane);
    JPanel statPanel = new JPanel();

    OWLOntologyManager man = OWLManager.createOWLOntologyManager();
    
    Env env = new Env(conf, frame, man, neo);

    void run() {

        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(1024, 720);

        setupMenu();
        setupTreeNodes();

        frame.getContentPane().add(BorderLayout.SOUTH, statPanel);
        frame.getContentPane().add(BorderLayout.NORTH, mb);
        frame.getContentPane().add(BorderLayout.CENTER, cenPane);

        try {
            UIManager.setLookAndFeel(looks[looks.length - 1].getClassName());
        } catch (Exception e) {
            e.printStackTrace();
        }

        SwingUtilities.updateComponentTreeUI(frame);

        tree.setPreferredSize(new Dimension(300, 0));
        tree.expandRow(0);

        frame.setVisible(true);

    }

    void setupMenu() {
        mb.add(mFile);
        mFile.add(mNew);
        mNew.addActionListener(new NewListener());
        mFile.add(mOpen);
        mOpen.addActionListener(new OpenListener());

        mb.add(mView);
        mb.add(mHelp);

        // m1.add(m1_1);
        // m1.add(m1_2);

        mView.add(mLookAndFeel);
        for (UIManager.LookAndFeelInfo look : looks) {
            String name = look.getClassName();
            JMenuItem item = new JMenuItem(name);
            item.addActionListener(new LookListener());
            mLookAndFeel.add(item);
        }
    }

    void setupTreeNodes() {
        rootNode.add(ontoNode);
        rootNode.add(agntNode);
        //rootNode.add(w02_1_1Node);
        //rootNode.add(w02_1_2Node);
        //rootNode.add(w02_2_1Node);
        //rootNode.add(w02_2_2Node);
        //rootNode.add(w03Node);
        //rootNode.add(w04Node);
        //rootNode.add(w05Node);
        //rootNode.add(w06_1Node);
        //rootNode.add(w06_2Node);
        //rootNode.add(w07Node);
        //rootNode.add(w08Node);
        
    }

    public static void main(String[] args) {
        App app = new App();
        app.run();
    }

    class NewListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            System.out.println(e.getActionCommand());

        }
    }

    class OpenListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            System.out.println(e.getActionCommand());
            OWLOntology o;
            try {
				File f =  Open.file(env);
				if (f != null) {
					o = env.man.loadOntologyFromOntologyDocument(f);
					DefaultMutableTreeNode node = new DefaultMutableTreeNode(f.getName()); 
					ontoNode.add(node);
					tree.repaint();
					tree.expandPath(new TreePath(ontoNode.getPath()));
				}
			} catch (OWLOntologyCreationException e1) {
				e1.printStackTrace();
				JOptionPane.showMessageDialog(frame,
					    e1.getMessage(),
					    "Open ontologie error",
					    JOptionPane.ERROR_MESSAGE);
			}
        }
    }

    class LookListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            System.out.println(e.getActionCommand());
            try {
                UIManager.setLookAndFeel(e.getActionCommand());
                SwingUtilities.updateComponentTreeUI(frame);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}