package util;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDDocumentInformation;
import org.apache.pdfbox.text.PDFTextStripper;

public class Pdf {

	static String pdir = "/home/youry/Documents/NUBIP/Magistr/3/work/references/";
	static String tdir = "/home/youry/Documents/NUBIP/Magistr/3/work/text/";

	public static void main(String[] args) {
		//String newLine = System.getProperty("line.separator");
		File dir = new File(pdir);
		// File file = new File(dir + "st_051-ek_bak.pdf");
		try {
			for (File f : dir.listFiles()) {
				if (f.getName().startsWith("st_") || f.getName().startsWith("opp_")) {
					System.out.println("---------------------------------------------------");
					System.out.println(f);
					
					PrintWriter out = new PrintWriter(tdir+f.getName()+".txt");
					
					PDDocument doc = Loader.loadPDF(f);

					PDDocumentInformation info = doc.getDocumentInformation();
					Set<String> mdata = info.getMetadataKeys();
					for (String k : mdata) {
						String s = k + " : " + info.getCustomMetadataValue(k);
						System.out.println(s);
						out.println(s);
					}
					
					PDFTextStripper stripper = new PDFTextStripper();
					stripper.setSortByPosition(true);
					
					String text = stripper.getText(doc);
					
					out.println(text);
					out.close();
					//System.out.println(text);

					doc.close();
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

}
