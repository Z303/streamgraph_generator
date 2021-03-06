/**
 * streamgraph_generator
 * Processing Sketch
 * Explores different stacked graph layout, ordering and coloring methods
 * Used to generate example graphics for the Streamgraph paper
 *
 * Press Enter to save image
 *
 * @author Lee Byron
 * @author Martin Wattenberg
 */

String      fileName = "people.csv";

final boolean     isGraphCurved    = true; // catmull-rom interpolation
final int         seed             = 28;   // random seed


final float       imageScale       = 3.0f;

final float       DPI              = 300;
final float       widthInches      = 7.756/imageScale;
final float       heightInches     = 5.6102/imageScale;

final int         backgroundColour = 255;

final int         outlineColour    = 100;
final float       outlineWidth     = 9.0f/imageScale;

final int         insideColour     = 185;
final float       insideWidth      = 3.0f/imageScale;

DataSource  data;
LayerLayout layout;
LayerSort   ordering;
ColorPicker coloring;

Layer[]     layers;

void setup() {
  size(int(widthInches*DPI), int(heightInches*DPI));
  smooth();
  noLoop();

  // GENERATE DATA
  String lines[] = loadStrings(fileName);   
  data     = new DiaryDataSource(lines);

  // ORDER DATA
  //ordering = new LateOnsetSort();
  //ordering = new VolatilitySort();
  ordering = new InverseVolatilitySort();
  //ordering = new BasicLateOnsetSort();
  //ordering = new NoLayerSort();

  // LAYOUT DATA
  //layout   = new StreamLayout();
  //layout   = new MinimizedWiggleLayout();
  layout   = new ThemeRiverLayout();
  //layout   = new StackLayout();

  // COLOR DATA
  //coloring = new LastFMColorPicker(this, "layers-nyt.jpg");
  coloring = new LastFMColorPicker(this, "layers.jpg");
  //coloring = new RandomColorPicker(this);

  //=========================================================================

  // calculate time to generate graph
  long time = System.currentTimeMillis();

  // generate graph
  layers = data.make();
  layers = ordering.sort(layers);
  layout.layout(layers);
  coloring.colorize(layers);

  // fit graph to viewport
  scaleLayers(layers, 1, height - 1);

  // give report
  long layoutTime = System.currentTimeMillis()-time;
  
  println("Data has " + layers.length + " layers, each with " + layers[0].size.length + " datapoints.");
  println("Layout Method: " + layout.getName());
  println("Ordering Method: " + ordering.getName());
  println("Coloring Method: " + layout.getName());
  println("Elapsed Time: " + layoutTime + "ms");
}

// adding a pixel to the top compensate for antialiasing letting
// background through. This is overlapped by following layers, so no
// distortion is made to data.
// detail: a pixel is not added to the top-most layer
// detail: a shape is only drawn between it's non 0 values
void draw() {

  int n = layers.length;
  int m = layers[0].size.length;
  int start;
  int end;
  int lastIndex = m - 1;
  int lastLayer = n - 1;
  int pxl;
  
  background(backgroundColour);

  stroke(outlineColour);  
  strokeWeight(outlineWidth);

  fill(outlineColour);  

  // calculate time to draw graph
  long time = System.currentTimeMillis();

  // generate graph
  for (int i = 0; i < n; i++) {
    start = max(0, layers[i].onset - 1);
    end   = min(m - 1, layers[i].end);
    pxl   = i == lastLayer ? 0 : 1;
 
    // draw shape
    beginShape();

    // draw top edge, left to right
    graphVertex(start, layers[i].yTop, isGraphCurved, i == lastLayer);
    for (int j = start; j <= end; j++) {
      graphVertex(j, layers[i].yTop, isGraphCurved, i == lastLayer);
    }
    graphVertex(end, layers[i].yTop, isGraphCurved, i == lastLayer);

    // draw bottom edge, right to left
    graphVertex(end, layers[i].yBottom, isGraphCurved, false);
    for (int j = end; j >= start; j--) {
      graphVertex(j, layers[i].yBottom, isGraphCurved, false);
    }
    graphVertex(start, layers[i].yBottom, isGraphCurved, false);

    endShape(CLOSE);
  }
  
  stroke(insideColour);  
  strokeWeight(insideWidth);    
  
  // generate graph
  for (int i = 0; i < n; i++) {
    start = max(0, layers[i].onset - 1);
    end   = min(m - 1, layers[i].end);
    pxl   = i == lastLayer ? 0 : 1;

    // set fill color of layer
    fill(layers[i].rgb);

    // draw shape
    beginShape();

    // draw top edge, left to right
    graphVertex(start, layers[i].yTop, isGraphCurved, i == lastLayer);
    for (int j = start; j <= end; j++) {
      graphVertex(j, layers[i].yTop, isGraphCurved, i == lastLayer);
    }
    graphVertex(end, layers[i].yTop, isGraphCurved, i == lastLayer);

    // draw bottom edge, right to left
    graphVertex(end, layers[i].yBottom, isGraphCurved, false);
    for (int j = end; j >= start; j--) {
      graphVertex(j, layers[i].yBottom, isGraphCurved, false);
    }
    graphVertex(start, layers[i].yBottom, isGraphCurved, false);

    endShape(CLOSE);
  }  

  // give report
  long layoutTime = System.currentTimeMillis() - time;
  println("Draw Time: " + layoutTime + "ms");
}

void graphVertex(int point, float[] source, boolean curve, boolean pxl) {
  float x = map(point, 0, layers[0].size.length - 1, 0, width);
  float y = source[point] - (pxl ? 1 : 0);
  if (curve) {
    curveVertex(x, y);
  } else {
    vertex(x, y);
  }
}

void scaleLayers(Layer[] layers, int screenTop, int screenBottom) {
  // Figure out max and min values of layers.
  float min = Float.MAX_VALUE;
  float max = Float.MIN_VALUE;
  for (int i = 0; i < layers[0].size.length; i++) {
    for (int j = 0; j < layers.length; j++) {
      min = min(min, layers[j].yTop[i]);
      max = max(max, layers[j].yBottom[i]);
    }
  }

  float scale = (screenBottom - screenTop) / (max - min);
  for (int i = 0; i < layers[0].size.length; i++) {
    for (int j = 0; j < layers.length; j++) {
      layers[j].yTop[i] = screenTop + scale * (layers[j].yTop[i] - min);
      layers[j].yBottom[i] = screenTop + scale * (layers[j].yBottom[i] - min);
    }
  }
}

void keyPressed() {
  if (keyCode == ENTER) {
    println();
    println("Rendering image...");
    String fileName = "images/streamgraph-" + dateString() + ".png";
    save(fileName);
    println("Rendered image to: " + fileName);
  }

  // hack for un-responsive non looping p5 sketches
  if (keyCode == ESC) {
    redraw();
  }
}

String dateString() {
  return year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "@" +
    nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
}
