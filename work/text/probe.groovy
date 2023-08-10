/* groovylint-disable CompileStatic, JavaIoPackageAccess */
import org.jopendocument.dom.ODSingleXMLDocument

//import org.jopendocument.dom.OOUtils

File  file1 = new File('template/ooo2flyer_p1.odt')
ODSingleXMLDocument p1 = ODSingleXMLDocument.createFromPackage(file1)

File file2 = new File('template/ooo2flyer_p2.odt')
ODSingleXMLDocument p2 = ODSingleXMLDocument.createFromPackage(file2)

p1.add(p2)

p1.saveToPackageAs(new File('cat'))
