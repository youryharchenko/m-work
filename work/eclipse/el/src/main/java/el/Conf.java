package el;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import org.apache.commons.configuration2.INIConfiguration;
import org.apache.commons.configuration2.ex.ConfigurationException;

public class Conf {
	
	INIConfiguration iniConfiguration = new INIConfiguration();
	
	public Conf(String name) {
		
		FileReader fileReader;
		try {
			fileReader = new FileReader(new File(name));
			iniConfiguration.read(fileReader);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (ConfigurationException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	public Object get(String sect, String prop) {
		return iniConfiguration.getSection(sect).getProperty(prop);
	}

}
