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
      String currentLine = rawData[i + 1];
      
      // Find the name, skipping the timestamp
      int nameStart  = currentLine.indexOf(',');
      int nameEnd    = currentLine.indexOf(',', nameStart + 1);
      String name    = currentLine.subSequence(nameStart + 1, nameEnd).toString();
      
      // Parse the entries for each day
      String entries = currentLine.subSequence(nameEnd + 1, currentLine.length()).toString();      
      float[] data   = processEntries(entries, sizeArrayLength);     
      
      // Create the layer
      layers[i]     = new Layer(name, data);
    }

    return layers;
  }

  protected float[] processEntries(String rawDays, int n) {
    float[] x = new float[n];
    
    // zero out all the hours to start with
    for (int i=0; i<n; i++) {
      x[i] = 0;
    }    
      
    // see which hours we need to set
    final int hoursInADay = 24;
    final int days        = n / hoursInADay;
    
    String dayData        = rawDays;

    for (int i=0; i < days; i++) {
      final int dayStart = dayData.indexOf('"') + 1;
      final int dayEnd   = dayData.indexOf('"', dayStart + 1);
      
      if (dayStart < dayEnd) {
        String hourData    = dayData.subSequence(dayStart, dayEnd).toString();
  
        while (hourData != "")
        {
          // Find the current hour
          final int hoursEnd = hourData.indexOf(':');
          String currentData =  hourData.subSequence(0, hoursEnd).toString();
  
          final int hourToSet = Integer.parseInt(currentData);
          final int arrayPosition = (hoursInADay * i) + hourToSet;
          x[arrayPosition] = 1;
          System.out.printf("%d\n", arrayPosition);         
          
          // Move to the next hour
          final int endOfString = hourData.indexOf(',');
          if (endOfString == -1) {
            hourData = "";
          }
          else {
            hourData =  hourData.subSequence(endOfString + 2, hourData.length()).toString();      
          }  
        }
      }

      // Skip to the next day
      dayData = dayData.subSequence(dayEnd + 1, dayData.length()).toString();     
    }

    return x;
  }
}
