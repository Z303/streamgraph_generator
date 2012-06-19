import java.util.*;

/**
 * BelievableDataSource
 * Create test data for layout engine.
 *
 * @author Lee Byron
 * @author Martin Wattenberg
 */
public class DiaryDataSource implements DataSource {
/*
  public DiaryDataSource(String lines[]) {
  }

  public Layer[] make() {
    int numLayers = 5;
    int sizeArrayLength = 45;
    Layer[] layers = new Layer[numLayers];
   
 
  // count the number of lines
  numLayers = lines.length;
  
  // count the items in each line
  layerSize = 0;
  for (int i=0; i < lines.length; i++) {
    String [] chars=split(lines[i],',');
    if (chars.length>layerSize) {
      layerSize=chars.length;
    }
  }   
  
    
    for (int i = 0; i < numLayers; i++) {
      String name   = "Layer #" + i;
      float[] size  = new float[sizeArrayLength];
      for (int j = 0; j < numLayers; j++) {
        size[j] = 0;
      }
      layers[i]     = new Layer(name, size);
    }

    return layers;
  }
*/  
  public Random rnd;

  public DiaryDataSource(String lines[]) {
    rnd = new Random(2);
  }

  public Layer[] make() {
    int numLayers = 5;
    int sizeArrayLength = 45;    
    
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
