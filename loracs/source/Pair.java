/**A simple class to store vertices' spatial coordinates**/

public class Pair{
	public int i;
	public int j;
 
	/**Creates an object that stores row(i) and column (j) location of a vertex in the vertex array **/
	public Pair(int i, int j){
		this.i=i;
		this.j=j;
	}
  
	/**Writes vertex coordinates
	 * @return String vertex name
	 */
	public String toString(){
		return "i: " + this.i + " ; j: " + this.j;
	}  
}