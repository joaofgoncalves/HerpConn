/**This is the central class in the package
*it calls the other classes to read, process, and write results
*/

import java.io.*;
import java.util.*;

public class ComputeAll{
    private RasterIO rasterIO;
    private double width;
    private String outputDir;
    private MyVertex[][] vertexArray;
    private int[][] MSP;
    private double[][] CMTC;
    private String stats;

     /** Labels all vertices as white. This reinitializes the vertexArray before a new ShortestPath is calculated.
      * @param MyVertex[][] vertexArray the array to be reinitialized
      */
     private void setWhite(MyVertex[][] vertexArray){
        for(int i =0; i<vertexArray.length; i++){
            for(int j=0; j<vertexArray[0].length; j++){
                  MyVertex v = vertexArray[i][j];
                  v.setColor("white");
              }
          }
      }

     /** Adds one to the cost of a vertex. 
      * This is used to mark vertices that show up in the ShortestPath.
      * @param int [][] vertexArray: the array representing the landscape
      * @param HashSet vertexSet: the vertices to be marked
      */
     private void markPathLocation(int[][] vertexArray, HashSet vertexSet){
         for(Iterator it = vertexSet.iterator(); it.hasNext(); ){
             MyVertex v = (MyVertex)it.next();
             int i = v.getI();
             int j = v.getJ();
             vertexArray[i][j] = vertexArray[i][j]+1;
         }
     }

    /**Calculates the Cumulative Minimum Transit Cost.
     */
    public void computeCMTC(){
        HashSet sourceSet = rasterIO.getSourceSet();
        HashSet targetSet = rasterIO.getTargetSet();
        int numRows = vertexArray.length;
        int numCols = vertexArray[0].length;
        this.CMTC = new double[numRows][numCols];
        ShortestPath forward = new ShortestPath(vertexArray, sourceSet, 1, false);
        forward.execute();
        setWhite(vertexArray);
        ShortestPath reverse = new ShortestPath(vertexArray, targetSet, 1, false);
        reverse.execute();
        setWhite(vertexArray);
        double forwardCost, reverseCost;
        double minCost = Double.POSITIVE_INFINITY;
        double maxCost = 0;
        for(int i = 0; i<numRows; i++){
            for(int j =0;j<numCols; j++){
                forwardCost = forward.getShortestDistance(vertexArray[i][j]);
                reverseCost = reverse.getShortestDistance(vertexArray[i][j]);
                double condcost = forwardCost + reverseCost;
                if(condcost > maxCost && condcost!= Double.POSITIVE_INFINITY){
                    maxCost = condcost;
                }
                if(condcost < minCost){
                    minCost=condcost;
                }
            }
        }
        double threshold = minCost + (width/100 * minCost);
        for(int i =0; i<numRows; i++){
            for(int j =0; j<numCols; j++){
                forwardCost = forward.getShortestDistance(vertexArray[i][j]);
                reverseCost = reverse.getShortestDistance(vertexArray[i][j]);
                double checkValue = forwardCost+reverseCost;
                if(checkValue<threshold){
                    this.CMTC[i][j] = checkValue/maxCost;//scale so value will be between 0 and 1
                }
                else{
                    this.CMTC[i][j] = -9999;//mask out cells with value larger then treshold
                }
            }
        }
    }//end computeCMTC

    /** This object stores the basic information to perform shortest path and CMTC computations.
     * @param String costFile: the ascii file containing the relative cost raster
     * @param String stFile: the ascii file containing the position of source and target pixels
     * @param int numPaths: the number of paths to be computed
     * @param double corridor width: the width of the corridor
     * @param String outputDir: the directory where results are written to
     */
    public ComputeAll(String costFile, String stFile, double corridorWidth, String outputDir)throws IOException{
        this.stats = "path_length, path_cost" + "\n";
        this.rasterIO = new RasterIO(costFile, stFile);
        this.vertexArray = rasterIO.getArray();
        this.outputDir = outputDir;
        this.width = corridorWidth;
        int numRows = vertexArray.length;
        int numCols = vertexArray[0].length;
        MSP = new int[numRows][numCols];
    }//end constructor
    
    /** Calculates one shortest path and marks the vertex array indicating path location.
     */
    public void computePath(){  
        HashSet sourceSet = rasterIO.getSourceSet();
        ShortestPath myPath = new ShortestPath(this.vertexArray, sourceSet, 1, true);
        myPath.execute();
        HashSet shortestPathVertices = myPath.getShortestPathVertices();
        markPathLocation(this.MSP, shortestPathVertices);
        double pathLength = myPath.getPathLength();
        double pathCost= myPath.getPathCost();
        this.stats = this.stats + pathLength + "," + pathCost + "\n";
        setWhite(this.vertexArray);
   }//end computeMSP
   
   /**
    * Writes MSPs and CMTC to an ascii raster and saves stats as a text file.
    */
   public void writeResults()throws IOException{
       PrintWriter outputStats = new PrintWriter(this.outputDir + System.getProperty("file.separator") + "stats.csv");
       outputStats.print(this.stats);
       outputStats.close();
       this.rasterIO.writeRaster(this.CMTC, this.outputDir + System.getProperty("file.separator")+ "CMTC.asc");
       this.rasterIO.writeRaster(this.MSP, this.outputDir + System.getProperty("file.separator") + "MSPs.asc");
    }
   
   /**This is the way to perform all shortest path calculations using the command line.
    * @param String args[0] cost file
    * @param String args[1] st file
    * @param double args[2] corridor width (0-100)
    * @param String args[3] output directory
    * @param int args[4] number of shortest paths
    */
   public static void main (String[]args)throws IOException{
       ComputeAll ca = new ComputeAll(args[0], args[1], Double.parseDouble(args[2]), args[3]);
        ca.computeCMTC();    
        int numPaths = Integer.parseInt(args[4]);
        for(int i =0; i<numPaths; i++){
           ca.computePath();
        }
        ca.writeResults();
    }
}//end class ComputeAll
