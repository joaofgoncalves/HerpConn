/**This class has IO functions.
 * Input functions convert ascii rasters into MyVertex[][] arrays representing a landscape.
 * Output functions covert MyVertex[][] arrays into ascii rasters.
 */

import java.io.*;
import java.util.*;

public class RasterIO{  
    private HashSet sourceSet;
    private HashSet targetSet;
    private int numRows;
    private int numCols;
    private String header;
    private MyVertex[][] vertexArray;
  
    /** Returns the MyVertex[][] array representing the cost surface.
     * @return MyVertex[][] the array with relative costs.
     */
    public MyVertex[][] getArray(){
        return this.vertexArray;
    }

    /**Returns the source vertices.
     * @return HashSet a set containing all vertices marked as source.
     */
    public HashSet getSourceSet(){
        return this.sourceSet;
    }

    /**Returns the target vertices.
     * @return HashSet a set containing all vertices marked as target.
     */
    public HashSet getTargetSet(){
        return this.targetSet;
    }

    /**Returns column dimension of the costArray.
     * @return int number of columns.
     */
    public int getCols(){
        return this.numCols;
    }

    /**Returns row dimension of the costArray.
     * @return int number of rows.
     */
    public int getRows(){
        return this.numRows;
    }
    
    //default constructor, can be used when building a random raster (see Main)
    private RasterIO(){
    }

    /**Reads ascii rasters, stores cost surface, header with spatial information, and location of source/target vertices.
     * @param String costFile: the path to the ascii file containing relative costs. 
     * Any negative values will be set to positive infinity, meaning that no paths will go through those vertices.
     * @param String stFile: the path to the ascii file containing source (marked as -1) and target (marked as -2) vertices.
     * The results may or may not be the same if source and target vertices are exchanged.
     * The ascii raster must have a header with 6 lines, otherwise an exception is thrown.
     */
    public RasterIO(String costFile, String stFile)throws IOException{
        BufferedReader inputCost = new BufferedReader(new FileReader(costFile)); 
        StringBuffer h = new StringBuffer();   
        String headerLine;
        int rows1=0;
        int cols1=0;
        int rows2=0;
        int cols2=0;
        for (int k = 0; k<6; k++){
            headerLine= inputCost.readLine();
            if(k==0){
                StringTokenizer firstLine = new StringTokenizer(headerLine);
                firstLine.nextToken();
                cols1 = Integer.parseInt(firstLine.nextToken());
            }
            if(k==1){
                StringTokenizer secondLine = new StringTokenizer(headerLine);
                secondLine.nextToken();
                rows1 = Integer.parseInt(secondLine.nextToken());
            }
            h.append(headerLine);
            h.append('\n');
        }    
        this.header = h.toString();   
        //get header from st raster
        BufferedReader inputST = new BufferedReader(new FileReader(stFile));
        for (int k = 0; k<6; k++){
            String a = inputST.readLine();
            if(k==0){
                StringTokenizer firstLine = new StringTokenizer(a);
                firstLine.nextToken();
                cols2 = Integer.parseInt(firstLine.nextToken());
            }
            if(k==1){
                StringTokenizer secondLine = new StringTokenizer(a);
                secondLine.nextToken();
                rows2 = Integer.parseInt(secondLine.nextToken());
            }
        }       
        //check if headers match
        if(cols1==cols2 && rows1==rows2 && rows1>0 && cols1>0){
            this.numCols=cols1;
            this.numRows=rows1;
        }
        else{
            throw new RuntimeException("Dimensions of ST raster and cost raster do not match");
        }       
        //initialize containers
        vertexArray = new MyVertex[this.numRows][this.numCols];
        sourceSet = new HashSet();
        targetSet = new HashSet(); 
        //read from cost file
        String line;        
        StringBuffer text = new StringBuffer();
        while((line=inputCost.readLine())!=null){
            text.append(line);
        }
        StringTokenizer words = new StringTokenizer(text.toString());
        int pixelValue;        
        for (int i = 0; i<numRows; i++){
            for (int j = 0; j<numCols; j++){
                pixelValue = Integer.parseInt(words.nextToken());
                if(pixelValue>=0){
                    MyVertex v = new MyVertex(i, j, numRows, numCols, pixelValue);
                    vertexArray[i][j]=v;
                }
                else{//THESE ARE NODATA VALUES; they get the maximum cost
                    MyVertex v = new MyVertex(i,j, numRows, numCols, Integer.MAX_VALUE);
                    vertexArray[i][j]=v;
                }
            }
        }       
        //read from stFile      
        text = new StringBuffer();
        while((line=inputST.readLine())!=null){
            text.append(line);
        }       
        words = new StringTokenizer(text.toString());  
        for (int i = 0; i<numRows; i++){
            for (int j = 0; j<numCols; j++){
                pixelValue = Integer.parseInt(words.nextToken());
                if(pixelValue==-1){
                    MyVertex v = vertexArray[i][j];
                    v.setAsSource();
                    sourceSet.add(v);
                }
                else if(pixelValue==-2){
                    MyVertex v = vertexArray[i][j];
                    v.setAsTarget();
                    targetSet.add(v);
                }
                this.sourceSet = sourceSet;
                this.targetSet = targetSet;
            }
        }        
}//end RasterIO
    
   /**Prints raster to screen for debugging purposes.
    * Not to be used with large rasters.
    * @param MyVertex[][] vertexArray: the array to be printed to screen.
    */
   public void printToScreen(MyVertex[][] vertexArray){
        System.out.println("Columns: " + this.numCols);
        System.out.println("Rows: " + this.numRows);
        System.out.println("Number of source vertices: " + sourceSet.size());
        System.out.println("Number of target vertices: " + targetSet.size());       
        for(int i =0; i<vertexArray.length; i++){
            for(int j =0; j<vertexArray[0].length; j++){
                System.out.print(vertexArray[i][j].getCost() + " ");
                if(vertexArray[i][j].isSource()){
                    System.out.print("<-S ");
                }
                if(vertexArray[i][j].isTarget()){
                    System.out.print("<-T ");
                }
            }
            System.out.println("");
        }
    }//end printToScreen
    
    /**Converts MyVertex[][] array into ascii file
     * @param MyVertex[][] vertexArray: the array to be output. 
     * The "cost" field from each vertex is written to file.
     * @param String outputFile: the name of the ascii raster file for output.
     */
    public void writeRaster(MyVertex[][] vertexArray, String outputFile)throws IOException{
        PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(outputFile)));        
        out.println(this.header);              
        for(int i = 0; i<this.numRows; i++){
            for(int j =0;j<this.numCols; j++){ 
                out.print(vertexArray[i][j].getCost() + " ");
            }
                out.println();
        }
        out.close();
    }//end writeRaster
    
        /**Converts double[][] array into ascii file
     * @param double[][] vertexArray: the array to be output. 
     * @param String outputFile: the name of the ascii raster file for output.
     */
    public void writeRaster(double[][] vertexArray, String outputFile)throws IOException{
        PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(outputFile)));        
        out.println(this.header);              
        for(int i = 0; i<this.numRows; i++){
            for(int j =0;j<this.numCols; j++){ 
                out.print(vertexArray[i][j] + " ");
            }
                out.println();
        }
        out.close();
    }//end writeRaster
    
     /**Converts int[][] array into ascii file
     * @param int[][] vertexArray: the array to be output. 
     * @param String outputFile: the name of the ascii raster file for output.
     */
    public void writeRaster(int[][] vertexArray, String outputFile)throws IOException{
        PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(outputFile)));        
        out.println(this.header);              
        for(int i = 0; i<this.numRows; i++){
            for(int j =0;j<this.numCols; j++){ 
                out.print(vertexArray[i][j] + " ");
            }
                out.println();
        }
        out.close();
    }//end writeRaster
    
    /** Creates a random integer raster and prints to file.
     * @param String outputFile: the name of the ascii file for output.
     * @param int nrows: the number of rows in the raster
     * @param int ncols: the number of columns in the raster
     */
    public void randomRaster(String outputFile, int nrows, int ncols)throws IOException{
        PrintWriter outRandom = new PrintWriter(new BufferedWriter(new FileWriter(outputFile)));
        outRandom.println("ncols " + ncols);
        outRandom.println("nrows " + nrows);
        outRandom.println("xllcorner 0");
        outRandom.println("yllcorner 0");
        outRandom.println("cellsize 1");
        outRandom.println("NODATA_value -9999");      
        Random randomNumber = new Random (System.currentTimeMillis());
        for(int i=0; i<nrows; i++){
        for(int j=0; j<ncols; j++){
            int value = (int)Math.ceil(randomNumber.nextDouble()*10);
            outRandom.print(value + " ");
        }
        outRandom.println("");
        }
        outRandom.close();
    }//end randomRaster
    
    /**Main will read a test raster (input by user) and print info to screen.
     * @parm String args[0]: the ascii file with cost values.
     * @parm String args[1]: the ascii file with source (marked as -1) and target (marked as -2) vertices.
     */
    public static void main (String[]args)throws IOException{
        RasterIO rasterIO = new RasterIO(args[0], args[1]);
        MyVertex[][] test = rasterIO.getArray();
        rasterIO.printToScreen(test);
        //RasterIO rasterIO = new RasterIO();
        //rasterIO.randomRaster(args[0], Integer.parseInt(args[1]), Integer.parseInt(args[2]));
}//end main
    
}//end RasterIO
        
    
    