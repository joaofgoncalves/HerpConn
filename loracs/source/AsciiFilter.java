/*This class helps with file browsing
* The filter makes sure only ascii files are displayed to the user
**/

import java.io.File;
import javax.swing.*;
import javax.swing.filechooser.*;

public class AsciiFilter extends FileFilter {
    
    /*Ensures that only text files are accepted
     * @param File file object
     * @return Boolean file is a text file?
     **/
    public boolean accept(File f) {
        if(f.isDirectory()){
            return true;
        }
        String extension = getExtension(f);
        if(extension.equals("ascii") || extension.equals("txt") || extension.equals("asc")){
            return true;
        }
        return false;
    }//end accept

    /*Returns the description of accepted files
     * @return String file description
     */
    public String getDescription() {
        return "Ascii rasters";
    }//end getDescription

    /*Extracts the extension of an input file
     * @param File input file
     * @return String file extension
     */
    public static String getExtension(File f) {
        String ext = null;
        String s = f.getName();
        int i = s.lastIndexOf(".");
        ext = s.substring(i+1).toLowerCase();
        return ext;
    }//end getExtension
    
}//end AsciiFilter
