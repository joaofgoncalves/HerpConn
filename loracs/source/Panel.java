import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import javax.swing.SwingUtilities;
import javax.swing.filechooser.*;
import java.beans.*;
import java.util.concurrent.*;
import java.util.Random;

/** This class builds the GUI that can be used as an alternative to the calling the class "ComputeAll" from the command line.
*/
public class Panel extends JPanel implements ActionListener,PropertyChangeListener {
    private JComboBox pathNum, corridorWidth;
    private JButton openButton1, openButton2, openButton3, runButton;
    private JLabel button1Label, button2Label, button3Label, combo1Label, combo2Label;
    private JFileChooser fc;
    private JPanel leftPane, centerPane, rightPane;
    private JProgressBar progressBar;
    private Task task;
    private String outputDir, costFile, stFile;
    private int numPaths, width;
    
    /** Internal class used to run the main task on the background.
     */
    class Task extends SwingWorker<Void, Integer> {
        @Override
        public Void doInBackground () throws InterruptedException, IOException{
            int progress = 0;
            setProgress(0);
            ComputeAll computeAll = new ComputeAll(costFile, stFile, width, outputDir);
            computeAll.computeCMTC();
            for(int i=0; i<numPaths; i++){
                computeAll.computePath();
                double dpaths = i*1.0;
                double dtotal = numPaths*1.0;
                int prog = (int)Math.ceil((dpaths/dtotal)*100.0);
                setProgress(prog);
            }
            computeAll.writeResults();
            return null;
        }
        @Override
        public void done() {
            try{
                get();
            }
            catch(RuntimeException e){
                JOptionPane errorPane = new JOptionPane();
                String errorMessage = e.getMessage();
                errorPane.showMessageDialog(leftPane, errorMessage, "Program error",JOptionPane.ERROR_MESSAGE);
            }
            catch(InterruptedException e){
                JOptionPane errorPane = new JOptionPane();
                String errorMessage = e.getMessage();
                errorPane.showMessageDialog(leftPane, errorMessage, "Program error",JOptionPane.ERROR_MESSAGE);
            }
            catch(ExecutionException e){
                JOptionPane errorPane = new JOptionPane();
                String errorMessage = e.getMessage();
                errorPane.showMessageDialog(leftPane, errorMessage, "Invalid Input Parameters",JOptionPane.ERROR_MESSAGE);
            }
            Toolkit.getDefaultToolkit().beep();
            runButton.setEnabled(true);
            openButton1.setEnabled(true);
            openButton2.setEnabled(true);
            openButton3.setEnabled(true);
            pathNum.setEnabled(true);
            corridorWidth.setEnabled(true);
            progressBar.setValue(0);
            setCursor(null);
        }
    }//end class Task

    /** Constructs the panel used in the GUI.
     */
    public Panel(){
        //buttons
        openButton1 = new JButton("Browse");
        openButton1.addActionListener(this);
        openButton2 = new JButton("Browse");
        openButton2.addActionListener(this);
        openButton3 = new JButton("Browse");
        openButton3.addActionListener(this);
        runButton = new JButton("Run");
        runButton.addActionListener(this);
        runButton.setAlignmentX(1);
        button1Label = new JLabel("COST Raster");
        button1Label.setHorizontalTextPosition(JLabel.LEFT);
        button2Label = new JLabel("ST Raster");
        button2Label.setHorizontalTextPosition(JLabel.LEFT);
        button3Label = new JLabel("Output Directory");
        button3Label.setHorizontalTextPosition(JLabel.LEFT);
        
        //combo boxes
        Integer [] paths = new Integer [10];
        int [] comboPaths = {10, 50, 100, 500, 750, 1000, 2500, 5000, 75000, 10000};
        for(int i=0; i<10; i++){
            paths[i]= new Integer(comboPaths[i]);
        }
        pathNum = new JComboBox(paths);
        pathNum.addActionListener(this);
        combo1Label = new JLabel("Number of Shortest Paths");
        Integer [] width = new Integer [100];
        for(int i=0; i <100; i++){
        width[i]= new Integer(i+1);
        }
        corridorWidth = new JComboBox(width);
        Dimension comboDim = new Dimension(65, 30);
        corridorWidth.setMaximumSize(comboDim);
        pathNum.setMaximumSize(comboDim);
        corridorWidth.addActionListener(this);
        combo2Label = new JLabel("Corridor Width (%)");
        combo1Label.setAlignmentX(0);
        pathNum.setAlignmentX(0);
        combo2Label.setAlignmentX(0);
        corridorWidth.setAlignmentX(0);
        //icon
        ImageIcon icon = new ImageIcon("icon.gif");
        JLabel iconLabel = new JLabel(icon);
        iconLabel.setAlignmentX(1);
        //progress bar
        progressBar = new JProgressBar(0, 100);
        progressBar.setValue(0);
        progressBar.setStringPainted(true);
        progressBar.setAlignmentX(0);
        //create panels
        leftPane = new JPanel();
        rightPane = new JPanel();
        centerPane = new JPanel();
        leftPane.setLayout(new BoxLayout(leftPane, BoxLayout.Y_AXIS));
        centerPane.setLayout(new BoxLayout(centerPane, BoxLayout.Y_AXIS));
        rightPane.setLayout(new BoxLayout(rightPane, BoxLayout.Y_AXIS));
        leftPane.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        centerPane.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        rightPane.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        //add open buttons to left pane
        leftPane.add(button1Label);
        leftPane.add(openButton1);
        leftPane.add(Box.createVerticalStrut(15));
        leftPane.add(button2Label);
        leftPane.add(openButton2);
        leftPane.add(Box.createVerticalStrut(15));
        leftPane.add(button3Label);
        leftPane.add(openButton3);
        //add combo boxes to center pane
        centerPane.add(combo1Label);
        centerPane.add(pathNum);
        centerPane.add(Box.createVerticalStrut(15));
        centerPane.add(combo2Label);
        centerPane.add(corridorWidth);
        centerPane.add(Box.createVerticalStrut(15));
        centerPane.add(progressBar);
        //add run button, and icon to right pane
        rightPane.add(iconLabel);
        rightPane.add(Box.createVerticalStrut(30));
        rightPane.add(runButton);
        //add panes
        add(leftPane, BorderLayout.WEST);
        add(centerPane, BorderLayout.CENTER);
        add(rightPane, BorderLayout.EAST);
    }//end constructor


    /** Stores information given by user.
     * @param ActionEvent: the panel component that is clicked by the user.
     */
    public void actionPerformed(ActionEvent e) {
        //store costFile
        if (e.getSource() == openButton1 ) {
            //file chooser
            fc = new JFileChooser();
            fc.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
            AsciiFilter filter = new AsciiFilter();
            fc.setFileFilter(filter);
            fc.setDialogTitle("COST Raster");
            int returnVal = fc.showOpenDialog(Panel.this);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                costFile = file.getAbsolutePath();
            }
        }
        //store stFile
        else if (e.getSource() == openButton2) {
        //file chooser
        fc = new JFileChooser();
        fc.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
        AsciiFilter filter = new AsciiFilter();
        fc.setFileFilter(filter);
        fc.setDialogTitle("ST Raster");
        int returnVal = fc.showOpenDialog(Panel.this);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = fc.getSelectedFile();
            stFile = file.getAbsolutePath();
        }
        }
        //store output directory
        else if (e.getSource() == openButton3) {
        fc = new JFileChooser();
        fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        fc.setDialogTitle("Output Directory");
        int returnVal = fc.showOpenDialog(Panel.this);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = fc.getCurrentDirectory();
            outputDir = file.getAbsolutePath();
        }
        }
        //store corridor path number
        else if(e.getSource() == pathNum){
        numPaths = ((Integer)pathNum.getSelectedItem()).intValue();
    }
        //store corridor width
        else if(e.getSource() == corridorWidth){
            width = ((Integer) corridorWidth.getSelectedItem()).intValue();
    }
        //run analysis or print error message
        else if (e.getSource() == runButton){
            pathNum.setEnabled(false);
            corridorWidth.setEnabled(false);
            openButton1.setEnabled(false);
            openButton2.setEnabled(false);
            openButton3.setEnabled(false);
            runButton.setEnabled(false);
            setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            task = new Task();
            task.addPropertyChangeListener(this);
            task.execute();
        }
    }//end actionPerformed

    /**Sets progress in the progress bar
     * 
     */
    public void propertyChange(PropertyChangeEvent evt) {
        if ("progress" == evt.getPropertyName()) {
            int progress = (Integer) evt.getNewValue();
            progressBar.setValue(progress);
        }
    }

    /** Packs all the components together into the panel.
    */
    private static void createAndShowGUI() {
        JFrame frame = new JFrame();
        frame.setTitle("LORACS: Landscape ORganization And Connectivity Survey");
        frame.setLocationRelativeTo(null);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JComponent pane = new Panel();
        pane.setOpaque(true);
        frame.setContentPane(pane);
        frame.pack();
        frame.setVisible(true);
    }//end createAndShowGUI

    /** The main calls the function createAndShowGUI within the function invokeLater.
     * This is meant to prevent the screen from feezing.
     */
    public static void main(String[] args) {
        javax.swing.SwingUtilities.invokeLater(new Runnable() {
                public void run() {
                    createAndShowGUI();
                }
        });
    }//end main

}//end class TestFrame