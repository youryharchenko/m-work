package swing;

import java.awt.TextArea;

public class Work {
    public void run(TextArea log) {
        log.setText(log.getText() + String.format("\nNot implemented\n\n"));
    }
}
