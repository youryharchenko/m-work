package swing;

import java.awt.Component;
import java.awt.Font;
import java.awt.TextArea;


public class Work {
    Font logFont = new Font("Serif", Font.PLAIN, 14);
    TextArea log = new TextArea("");
    
    public void run() {
        log.setText(log.getText() + String.format("\nNot implemented\n\n"));
    }

    public Component getComponent() {
        
        log.setEditable(false);
        log.setFont(logFont);

        return (Component)log;
    }

    public void writeLog(String str) {
        log.setText(log.getText() + str);
    }
}
