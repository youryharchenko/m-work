
using GLib;
using Gtk;
using Gda;
//using Gdaui;

public class Gui : Gtk.Application {

private ApplicationWindow window;
private Box vbox;

private Paned hbox;
private TreeView tree;
private Notebook tabs;
private Statusbar sbar;

//private Database mysql;
private Connection conn;

private string host = "localhost";
private string user = "kb";
private string password = "kb";
private string database = "kb";

private string title = "";


public Gui() {
	Object(application_id: "youry.harchenko.kb.gui",
	       flags : ApplicationFlags.FLAGS_NONE);


	//mysql = new Mysql.Database ();
	var conn_str = "%s:%s@%s/;DB_NAME=%s".printf(user, password, host, database);

	try {
		conn = Connection.open_from_string("MySQL", conn_str, null, ConnectionOptions.NONE);
	} catch(Error err) {
		stdout.printf ("ERROR: %s\n", err.message);
		title = err.message;
	}
	//var isConnected = mysql.real_connect(host, user, password, database); //, port, socket, cflag);

	if ( conn != null && conn.is_opened() ) {
		stdout.printf("Connected to server: %s \n"
		              , conn.get_cnc_string ());
		title = conn.get_cnc_string ();
	}

	

}

protected override void activate () {
	// Create the window of this application and show it
	window = new ApplicationWindow (this);
	window.set_default_size (1024, 720);
	window.title = "KB Gui - %s".printf(title);
	window.delete_event.connect(() => {
			stdout.printf("App window delete_event\n");
			var q = quit_confirm();
			return !q;
		});

	init_widgets();

	window.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK |
	                   Gdk.EventMask.BUTTON_RELEASE_MASK |
	                   Gdk.EventMask.POINTER_MOTION_MASK
	                   );

	window.show_all ();
}

private void init_widgets() {

	sbar = new Statusbar();
	sbar.push(0, "Ready");

	// Explorer -
	var tree_store = new TreeStore(1,  typeof(string));

	TreeIter root;
	tree_store.append (out root, null);
	tree_store.set (root, 0, "Root", -1);

	tree = new TreeView.with_model(tree_store);
	tree.insert_column_with_attributes (-1, "TreeView", new CellRendererText(), "text", 0, null);

	var tree_win = new ScrolledWindow(null, null);
	tree_win.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
	tree_win.add(tree);

	//var text_view = new TextView();
	//text_view.margin = 5;

	// Notebook -
	tabs = new Notebook();
	//tabs.append_page(text_view, new Label("Untitled"));

	var tabs_win = new ScrolledWindow(null, null);
	tabs_win.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
	tabs_win.add(tabs);

	hbox = new Paned(Orientation.HORIZONTAL);
	tree_win.set_size_request (200,  -1);
	hbox.pack1(tree_win, true, false);
	tabs_win.set_size_request (500,  -1);
	hbox.pack2(tabs_win, true, false);


	vbox = new Box(Orientation.VERTICAL, 0);
	vbox.pack_start(hbox, true, true, 0);
	vbox.pack_start(sbar, false, false, 0);
	window.add (vbox);
}

private bool quit_confirm() {
	Dialog dlg = new Dialog.with_buttons("Quit?", window, DialogFlags.MODAL);
	dlg.add_button("Ok", 0);
	dlg.add_button("Cancel", 1);
	bool r = dlg.run() == 0 ? true : false;
	dlg.close();
	return r;
}

public static int main (string[] args) {
	var app = new Gui ();
	return app.run (args);
}
}

