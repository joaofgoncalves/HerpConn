/** This class contains the basic functions to compute shortest path values.
 */

import java.util.Comparator;
import java.util.PriorityQueue;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Arrays;
import java.util.Random;
import java.util.List;
import java.io.*;


public class ShortestPath{

    private MyVertex[][] vertexArray;

    //this comparator orders vertices with respect to proximity to the source
    private final Comparator vertexComparator = new Comparator(){
	    public int compare(Object left, Object right){
		    double shortestDistanceLeft = getShortestDistance ((MyVertex)left);
		    double shortestDistanceRight = getShortestDistance ((MyVertex)right);
		    if (shortestDistanceLeft > shortestDistanceRight){
			    return +1;
		    }
		    else if (shortestDistanceLeft < shortestDistanceRight){
			    return -1;
		    }
		    else{
			    return 0;
		    }
            }
      };

     public double cellSize;
     private MyVertex firstTargetReached;
     private boolean targetFound;
     public HashSet shortestPathVertices;
     private double shortestPathLength;
     private double shortestPathCost;
     private boolean prob;

    //containers
    public HashMap shortestDistances;
    public HashMap predecessor;
    private PriorityQueue fila;
    private int numVertices;

    /** Calculates the number of vertices in the path.
     * @return double path length: the number of vertices in the path.
     */
    public double getPathLength(){
	 	return this.shortestPathLength;
   }

   /** Calculates the cumulative cost of the path.
    * @return double path cost.
    */
   public double getPathCost(){
   		return this.shortestPathCost;
   }

    /**Implements Dikjstra's shortest path algorithm.
     * @param MyVertex[][] vertexArray:
     * @param HashSet sourceSet:
     * @param double cellSize: the raster resolution in user-defined units.
     * The distance between cell1 and cell2 is calculated as mean(cost1, cost2)*cellSize.
     * Thus a value >1 should only be used if cost1, cost1 represent absolute costs such as fuel price or
     * energy expenditure. If cost1, cost2 are relative costs, cellSize should be set to 1.
     * @param boolean prob: true if all multiple paths are returned (stochastic version of the shortest path),
     * false if only one path is returned.
     */
     public ShortestPath(MyVertex[][] vertexArray, HashSet sourceSet, double cellSize, boolean prob){
	  	 this.shortestPathCost=0;
	  	 this.shortestPathLength=0;
	     this.cellSize = cellSize;
	     this.vertexArray = vertexArray;
	     this.prob=prob;
	     numVertices = vertexArray.length*vertexArray[0].length;
	     shortestDistances = new HashMap();
	     predecessor = new HashMap(numVertices);
	     fila = new PriorityQueue(11, vertexComparator);
	     fila.clear();
	     shortestDistances.clear();
	     predecessor.clear();
	     for(Iterator it = sourceSet.iterator(); it.hasNext();){
		     MyVertex sourceVertex = (MyVertex)it.next();
		     sourceVertex.setColor("grey");
		     shortestDistances.put(sourceVertex, 0.0);
		     fila.add(sourceVertex);
	     }
	     for(int i = 0; i<vertexArray.length; i++){
		     for(int j = 0; j<vertexArray[0].length; j++){
			     MyVertex v = vertexArray[i][j];
			     if(v.isSource()==false && v.isTarget()==false){
				     shortestDistances.put(v, Double.POSITIVE_INFINITY);
			     }
		     }
	     }
    }

    //principal function
    public void execute(){
	    this.shortestPathLength=0;
	    while(fila.isEmpty()==false){
		    MyVertex v = extractMinimum();
		    relaxNeighbors(v);
		    v.setColor("black");
		    if(v.isTarget() && !targetFound){
			    targetFound=true;
			    firstTargetReached=v;
		    }
	    }
    }

    //get vertex from priority queue
    private MyVertex extractMinimum(){
	    MyVertex v = (MyVertex)fila.poll();
	    return v;
    }

    //recalculate tentative distances
    private void relaxNeighbors(MyVertex v){
	    HashSet neighbors;
	    if(prob){
		    neighbors = v.getNeighbors(1.5, vertexArray, true);
		    if(neighbors.isEmpty() && fila.isEmpty()){
			    neighbors = v.getNeighbors(1.5, vertexArray, false);
		    }
	    }
	    else{
		    neighbors = v.getNeighbors(1.5, vertexArray, false);
	    }
	    for(Iterator it = neighbors.iterator(); it.hasNext();){
		    MyVertex w = (MyVertex)it.next();
		    if(w.getColor()!="black"){
			    double edgeWeight = Double.POSITIVE_INFINITY;
			    edgeWeight = v.getDistance(w)*((w.getCost()+v.getCost())/2);
			    double distanceV = getShortestDistance(v);
			    double distanceW = getShortestDistance(w);
			    if(distanceW > distanceV + edgeWeight){
				    shortestDistances.put(w, new Double(distanceV + edgeWeight));
				    if(w.getColor()=="white"){
					    w.setColor("grey");
					    fila.add(w);
				    }
				    else if(w.getColor()=="grey"){
					    fila.remove(w);//this will update the position of vertex w on the queue
					    fila.add(w);
				    }
				    setPredecessor(w,v);
			    }
		    }
	    }
    }//end relaxNeighbors

    //set predecessor relationships
    private void setPredecessor(MyVertex v, MyVertex w){
	    predecessor.put(v,w);
    }

    /** Identifies the predecessor vertex in the ShortestPath.
     * @param MyVertex v: the vertex whose predecessor we want to know.
     * @return MyVertex the predecessor vertex.
     */
    public MyVertex getPredecessor(MyVertex v){
	    return (MyVertex) predecessor.get(v);
    }


    /**Computes the shortest distance from source for a given vertex.
     * @param MyVertex vertex: the vertex to which the shortest path is to be computed.
     * @return double distance: the distance between the vertex and the source. 
     * If cellSize==1 these are relative distance values, if cellSize!=1 these are absolute values (e.g. fuel cost).
     * Returns null if the vertex is not in the path.
     */
    public double getShortestDistance (MyVertex vertex){
	    Double d = (Double) shortestDistances.get(vertex);
	    return (d == null) ? Double.POSITIVE_INFINITY : d.doubleValue();
    }

    //methods below are for finding the one best shortest path
    //returns first cell in target to be reached, which is used to retrace the best path between target and source
    private MyVertex getFirstTarget(){
	    return this.firstTargetReached;
    }

    /** Returns the list of vertices in the ShortestPath.
     * @return HashSet shortestPathVertices: a set containing all vertices in the path.
     */
    public HashSet getShortestPathVertices(){
	    this.shortestPathVertices = new HashSet();
	    MyVertex startVertex = this.firstTargetReached;
	    getPath(startVertex);
	    return this.shortestPathVertices;
    }

    //populate the set "shortestPathVertices" with the vertices in the optimum path.
    private void getPath(MyVertex v){
	    boolean sourceFound = false;
	    if(getPredecessor(v)!=null){
		    MyVertex w = getPredecessor(v);
		    shortestPathVertices.add(w);
		    shortestPathLength=shortestPathLength+ (v.getDistance(w)*cellSize);
		    shortestPathCost=shortestPathCost+ v.getCost();
		    if(w.isSource()){
			    sourceFound=true;
		    }
		    else{
			    getPath(w);
		    }
	    }
    }


/** Produces a random raster and computes the cumulative cost raster that can be compared with results from ArcGIS.
 * @param String args[0] is the name of the output ascii random raster.
 * @param String args[1] is the name of the output ascii cumulative cost raster.
 * The graph is output to the screen for debugging.
 * The raster is small (8x8) to facilitate debugging.
 */
public static void main(String[]args)throws IOException{
	int r = 8;
        int c = 8;

        //print random raster
        PrintWriter outRandom = new PrintWriter(new BufferedWriter(new FileWriter(args[0])));
        outRandom.println("ncols " + c);
        outRandom.println("nrows " + r);
        outRandom.println("xllcorner 0");
        outRandom.println("yllcorner 0");
        outRandom.println("cellsize 1");
        outRandom.println("NODATA_value -9999");

        //create vertex array where vertex cost is a random integer number
        MyVertex[][] vertexArray = new MyVertex[r][c];
        Random randomNumber = new Random (System.currentTimeMillis());
        for(int i=0; i<r; i++){
		for(int j=0; j<c; j++){
			int value = randomNumber.nextInt();
			outRandom.print(value + " ");
			vertexArray[i][j]= new MyVertex(i, j, r, c, value); //random values for edge weights
		}
		outRandom.println("");
        }
        outRandom.close();

        //compute shortest path, source is the upper left corner
        HashSet sourceSet = new HashSet();
        MyVertex source = vertexArray[0][0];
        source.setAsSource();
        sourceSet.add(source);

        //print results which can be compared with ArcGIS
        ShortestPath myPath = new ShortestPath(vertexArray, sourceSet, 1, false);
        double pixelValue;
        myPath.execute();
        PrintWriter outPath = new PrintWriter(new BufferedWriter(new FileWriter(args[1])));
        outPath.println("ncols " + c);
        outPath.println("nrows " + r);
        outPath.println("xllcorner 0");
        outPath.println("yllcorner 0");
        outPath.println("cellsize 1");
        outPath.println("NODATA_value -9999");
        for(int i = 0; i<r; i++){
            for(int j = 0; j<c; j++){
                    pixelValue = myPath.getShortestDistance(vertexArray[i][j]);
                    if(pixelValue == Double.POSITIVE_INFINITY){
                        outPath.print("-9999" + " ");
                    }
                    else{
                        outPath.print(pixelValue + " ");
                    }
            }
        }
        outPath.close();

      //print shortest distances and neighborhood information to screen
      for(int i=0; i<vertexArray.length; i++){
	      for(int j = 0; j<vertexArray[0].length; j++){
		      System.out.print(myPath.getShortestDistance(vertexArray[i][j])+ " ");
	      }
	      System.out.println("");
      }
      System.out.println("***********");
      for(int i = 0; i<vertexArray.length; i++){
	      for(int j =0; j<vertexArray[0].length; j++){
		      MyVertex w = vertexArray[i][j];
		      System.out.print(w.toString()+ " : ");
		      if(myPath.predecessor.get(w)==null){
			      System.out.println("null");
		      }
		      else{
			      System.out.print("predecessor " + myPath.predecessor.get(w).toString());
		      }
	      }
      }

  }//end main

}//end ShortestPath




