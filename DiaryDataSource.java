import java.util.*;
import java.lang.String;

/**
 * BelievableDataSource
 * Create test data for layout engine.
 *
 * @author Lee Byron
 * @author Martin Wattenberg
 */
public class DiaryDataSource implements DataSource {
 
  public Random rnd;
  
  public String rawData[];
  
  public DiaryDataSource(String lines[]) {
    rnd = new Random(2);
    rawData = lines;
  }

  public Layer[] make() {
    // count the number of lines ( -1 for the legend on the first line)
    int numLayers = rawData.length - 1;
    
    // count the items in each line
    String [] chars = rawData[0].split(",");
      
    // -2 for the timestamp and name tuimes the number of hours in the day      
    int sizeArrayLength = (chars.length - 2) * 24;
    
    
    
    Layer[] layers = new Layer[numLayers];

    for (int i = 0; i < numLayers; i++) {
      String name   = "Layer #" + i;
      float[] size  = new float[sizeArrayLength];
      size          = makeRandomArray(sizeArrayLength);
      layers[i]     = new Layer(name, size);
    }

    return layers;
  }

  protected float[] makeRandomArray(int n) {
    float[] x = new float[n];

    // add a handful of random bumps
    for (int i=0; i<5; i++) {
      addRandomBump(x);
    }

    return x;
  }

  protected void addRandomBump(float[] x) {
    float height  = 1 / rnd.nextFloat();
    float cx      = (float)(2 * rnd.nextFloat() - 0.5);
    float r       = rnd.nextFloat() / 10;

    for (int i = 0; i < x.length; i++) {
      float a = (i / (float)x.length - cx) / r;
      x[i] += height * Math.exp(-a * a);
    }
  }  

}
