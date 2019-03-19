/** This class stores vertex information vertices have information on their spatial 
 * location as well as the ability to compute distance from other vertices
 */

import java.util.*;

public class MyVertex {
    private int iIndex;
    private int jIndex;
    private int rows;
    private int cols;
    private int cost;
    private boolean isSource;
    private boolean isTarget;    
    private String color;
    private boolean isInPath;
    
    /**Constructor for MyVertex object.
     * @param int i row location in MyVertex array
     * @parem int j column location in MyVertex array
     * @param int rows number of rows in MyVertex array
     * @param int cols number of columns in MyVertex array
     * @param double cost cost associated with transversing vertex in any direction
     */
    public MyVertex(int i, int j, int rows, int cols, int cost){
        this.iIndex=i;
        this.jIndex=j;
        this.rows = rows;
        this.cols = cols;
        this.cost = cost;
        this.color = "white";
        this.isSource=false;
        this.isTarget=false;     
        this.isInPath=false;
    }
  
    /** Returns the row position of a vertex in the vertex array
     * @return int vertex row
     */
    public int getI(){
        return this.iIndex;
    }

    /** Returns the column position of a vertex in the vertex array
     * @return int vertex column
     */
    public int getJ(){
        return this.jIndex;
    }

    /** Returns the cost associated with the vertex
     * @return double cost
     */
    public double getCost(){
        if(this.cost==Integer.MAX_VALUE){
            return Double.POSITIVE_INFINITY;
        }
        else{
            return (new Integer(this.cost)).doubleValue();
        }
    }
    
    /** Labels the vertex as a source 
     */
    public void setAsSource(){
        this.isSource=true;
    }
    
    /** Labels the vertex as a target 
     */
    public void setAsTarget(){
        this.isTarget=true;
    }
    
    /** Checks whether a vertex is a target
     * @return boolean is the vertex a target?
     */
    public boolean isTarget(){
        return this.isTarget;
    }
    
    /** Checks whether a vertex is a source
     * @return boolean is the vertex a source?
     */
    public boolean isSource(){
        return this.isSource;
    }
    
    /** Labels the vertex to represent whether it has been visited in Dijktra's algorithm
     * @param String vertex color: "white", "gray", or "black" 
     */
    public void setColor(String color){
        this.color=color;
    }
  
    /** Stores vertex cost
     * @param int cost: the relative cost to cross a vertex in any direction
     */
    public void setCost(int cost){
        this.cost = cost;
    }
    
    /** Gets the color of a vertex
     * @return String vertex color. The colors used by Dijktra's algorithm are "white", "gray", and "black"
     */
    public String getColor(){
        return this.color;
    }
        
    /** Returns a HashSet with this vertice's neighbors. Pixels with negative value are excluded.
     * @param double neighborhood: the threshold distance below which vertices are considered neighbors. In number of pixels.
     * The maximum neighborhood is set by the vertexArray dimensions
     * @param MyVertex[][] vertexArray: the array from which neighbors are drawn
     * @param boolean probabilistic: if true, a random subset of neighbors is returned
     * neighbors with lower cost are more likely to be returned; if false, all neighbors are returned
     * @return HashSet the vertice's neighbors
     */
        public HashSet getNeighbors(double neighborhood, MyVertex[][] vertexArray, boolean probabilistic){   
        HashSet eightNeighbors = new HashSet();
        int minRow = (iIndex - neighborhood <0) ? 0 : (int) Math.ceil(iIndex-neighborhood);
        int maxRow = (iIndex + neighborhood >rows) ? rows : (int) Math.ceil(iIndex + neighborhood);
        int minCol = (jIndex - neighborhood <0) ? 0 : (int) Math.ceil(jIndex - neighborhood);
        int maxCol = (jIndex + neighborhood > cols)? cols : (int) Math.ceil(jIndex + neighborhood);
        for(int i =minRow; i<maxRow; i++){
            for(int j = minCol; j<maxCol; j++){
                if(Math.sqrt(((iIndex - i)*(iIndex - i))+ ((jIndex - j)*(jIndex-j)))<= neighborhood){
                    if(!(i==iIndex && j== jIndex)){
                        eightNeighbors.add(vertexArray[i][j]);
                    }
                }
            }
        }
        if(!probabilistic){
            return(eightNeighbors);
        }
        double sumCost=0;
        for(Iterator it = eightNeighbors.iterator(); it.hasNext(); ){
            MyVertex v = (MyVertex)it.next();
            sumCost = sumCost+v.getCost();
        }
        HashSet selectNeighbors = new HashSet();
        for(Iterator it = eightNeighbors.iterator(); it.hasNext(); ){
            MyVertex v = (MyVertex)it.next();
            double prob = v.getCost()/sumCost;
            Random generator = new Random();
            double dice = generator.nextDouble();
            if(dice>prob){
                selectNeighbors.add(v);
            }
        }
        return(selectNeighbors);     
    }//end getNeighbors
        
    /** Calculates the Euclidian (straight-line) distance between two vertices in number of pixels
     * @param MyVertex the vertex from which distance is computed
     * @return double distance: the number of pixels separating the two vertices
     */
    public double getDistance(MyVertex w){
        int vi = this.iIndex;
        int vj = this.jIndex;
        int wi = w.iIndex;
        int wj = w.jIndex;
        double distance= Math.sqrt(((vi-wi)*(vi-wi))+((vj-wj)*(vj-wj)));
        if(distance<0){
            throw new RuntimeException("Distances between vertices must be non-negative");
        }
        else{
            return distance;
        }
    }//end getDistance
    
    /** Shows the vertex's ij position
     * @return String vertex name: v 0,0 is the upperleft vertex in the vertexArray
     */
    public String toString(){
        return "v " + this.iIndex + "," + this.jIndex;
    }
    
}//end class MyVertex
    
   