/*
 * This Java source file was generated by the Gradle 'init' task.
 */
package swing;

import javax.swing.*;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreeSelectionModel;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

public class App {

    UIManager.LookAndFeelInfo[] looks = UIManager.getInstalledLookAndFeels();

    JFrame frame = new JFrame("Програмування систем штучного інтелекту");

    JMenuBar mb = new JMenuBar();

    JMenu m1 = new JMenu("File");
    JMenuItem m1_1 = new JMenuItem("Open");
    JMenuItem m1_2 = new JMenuItem("Save as");

    JMenu m2 = new JMenu("View");
    JMenuItem m2_1 = new JMenu("LookAndFeel");

    JMenu m3 = new JMenu("Help");

    Font treeFont = new Font("Serif", Font.PLAIN, 16);

    DefaultMutableTreeNode rootNode =
            new DefaultMutableTreeNode("Programming of artificial intelligence systems");
    DefaultMutableTreeNode w01Node =
            new DefaultMutableTreeNode("Work01 - BreadFirstSearch");
    DefaultMutableTreeNode w02Node =
            new DefaultMutableTreeNode("Work02_1 - DepthFirstSearchIter");
    DefaultMutableTreeNode w03Node =
            new DefaultMutableTreeNode("Work02-2 - DepthFirstSearchRec");

    JTree tree = new JTree(rootNode);
    JScrollPane treeScrollPane = new JScrollPane(tree);

    JTabbedPane tabs = new JTabbedPane();
    JScrollPane tabsScrollPane = new JScrollPane(tabs);

    JSplitPane cenPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,treeScrollPane, tabsScrollPane);

    JPanel statPanel = new JPanel(); 

    //JLabel label = new JLabel("Enter Text");
    //JTextField tf = new JTextField(10); 

    //JButton send = new JButton("Send");
    //JButton reset = new JButton("Reset");



    //JTextArea ta = new JTextArea();

    Font logFont = new Font("Serif", Font.PLAIN, 14);

    ArrayList<Work> works = new ArrayList<Work>(10);


    void setupMenu() {
        mb.add(m1);
        mb.add(m2);
        mb.add(m3);

        m1.add(m1_1);
        m1.add(m1_2);
        
        m2.add(m2_1);

        for (UIManager.LookAndFeelInfo look : looks) {
            String name = look.getClassName();

            JMenuItem item = new JMenuItem(name);
            item.addActionListener(new LookListener());
            m2_1.add(item);
        }
    }

    void setupTreeNodes() {
        rootNode.add(w01Node);
        rootNode.add(w02Node);
        rootNode.add(w03Node);
    }

    void setupContent() {

        tree.setFont(treeFont);
        tree.getSelectionModel().setSelectionMode
                (TreeSelectionModel.SINGLE_TREE_SELECTION);
        tree.addTreeSelectionListener(new TreeListener());

        treeScrollPane.setMinimumSize(new Dimension(100, 200));
        tabsScrollPane.setMinimumSize(new Dimension(200, 200));
        
        cenPane.setOneTouchExpandable(true);
        cenPane.setDividerLocation(frame.getWidth()/3);




        //statPanel.add(label); // Components Added using Flow Layout
        //statPanel.add(tf);
        //statPanel.add(send);
        //statPanel.add(reset);
    }
    
    void setupWorks() {
        works.add(new Work01());
        works.add(new Work());
        works.add(new Work());
        works.add(new Work());
        works.add(new Work());
        works.add(new Work());
        works.add(new Work());
        works.add(new Work());
        works.add(new Work());
    }

    void run() throws ClassNotFoundException, InstantiationException, IllegalAccessException, UnsupportedLookAndFeelException {
            
           
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(1024, 720);

        setupWorks();
        setupMenu();
        setupTreeNodes();
        setupContent();
        
        frame.getContentPane().add(BorderLayout.SOUTH, statPanel);
        frame.getContentPane().add(BorderLayout.NORTH, mb);
        frame.getContentPane().add(BorderLayout.CENTER, cenPane);
        
        UIManager.setLookAndFeel(looks[looks.length-1].getClassName());
        SwingUtilities.updateComponentTreeUI(frame);
        
        frame.setVisible(true);
    } 
   
    
    public static void main(String[] args) throws ClassNotFoundException, InstantiationException, IllegalAccessException, UnsupportedLookAndFeelException {
        App app = new App();
        app.run();
    }

    class TreeListener implements TreeSelectionListener {

        public void valueChanged(TreeSelectionEvent e) {
            DefaultMutableTreeNode node = (DefaultMutableTreeNode)
                           tree.getLastSelectedPathComponent();
            if (node == null) return;

            String nodeInfo = (String)(node.getUserObject());

            System.out.println(String.format("%d %s", node.getLevel(), nodeInfo));

            if (node.isLeaf()) {
                TextArea log;
                int ind = tabs.indexOfTab(nodeInfo);
                
                if (ind == -1) {
                    log = new TextArea("");
                    log.setEditable(false);
                    log.setFont(logFont);

                    System.out.println(String.format("Open tab <%s> index %d", nodeInfo, ind));
                    log.setText(log.getText() + String.format("Open tab <%s>\n", nodeInfo));

                    tabs.setSelectedComponent(tabs.add(nodeInfo, log));

                    ind = tabs.indexOfTab(nodeInfo);
                } else {
                    System.out.println(String.format("Focus tab <%s> index %d", nodeInfo, ind));
                    
                    tabs.setSelectedIndex(ind);

                    log = (TextArea)tabs.getSelectedComponent();
                    log.setText(log.getText() + String.format("Focus tab <%s>\n", nodeInfo));

                }

                Work work = works.get(ind);
                work.run(log);

            }
        }
    }

    class LookListener implements ActionListener {

        public void actionPerformed(ActionEvent e) {
            System.out.println(e.getActionCommand());
            try {
                UIManager.setLookAndFeel(e.getActionCommand());
                SwingUtilities.updateComponentTreeUI(frame);
            } catch (ClassNotFoundException e1) {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            } catch (InstantiationException e1) {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            } catch (IllegalAccessException e1) {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            } catch (UnsupportedLookAndFeelException e1) {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            }
        }
    }
}