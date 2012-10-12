PFont tickLabelFont;

float step = 3;
float minEnergy = 1.0;
float minLatitude = -42;
float maxLatitude = 54;
float maxCane = 0;
float maxMaize = 0;

PImage world;
MercatorMap mercator;

Scale x;
Scale y;

color maizeFrom = color(199, 233, 192, 153);
color maizeTo = color(0, 109, 44, 153);
color caneTo = color(8, 81, 156, 153);
color caneFrom = color(198, 219, 239, 153);

boolean debug = false;

void setup() {
  size(1079, 721);

  tickLabelFont = loadFont("AvenirNext-Regular-14.vlw");
  
  world = loadImage("world.png");
  mercator = new MercatorMap(540, 361, 84, -58, -180, 180);
  
  for (float i = minLatitude; i < maxLatitude; i += step) {
    if (i <= 35) {
      maxCane = max(maxCane, cane(i) - minEnergy);
    }
    maxMaize = max(maxMaize, maize(i) - minEnergy);
  }
  
  x = new Scale();
  x.range = new PVector(600, width - 20);
  x.domain = new PVector(-50, 60);
  
  y = new Scale();
  y.range = new PVector(height * 0.75, height * 0.25);
  y.domain = new PVector(0, 3.5);
  
  smooth();
}

void draw() {
  background(255);

  // Draw the map
  pushMatrix();
  translate(0, (height - 361) / 2);
  
  image(world, 0, 0);
  
  // Latitude bands
  for (float i = minLatitude; i < maxLatitude; i += step) {
    float m = maize(i) - minEnergy;
    float c = cane(i) - minEnergy;
    PVector tl = mercator.getScreenLocation(new PVector(i+step, -180));
    PVector br = mercator.getScreenLocation(new PVector(i, 180));
    float w = br.x - tl.x;
    float h = br.y - tl.y;
    
    noStroke();
    if (m > 0) {
      fill(lerpColor(maizeFrom, maizeTo, m / maxMaize));
      rect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    }
    
    
    if (c > 0 && i <= 35) {
      fill(lerpColor(caneFrom, caneTo, c / maxCane));
      rect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    }
  }
  
  popMatrix();
  
  // Draw the regression lines
  noFill();
  stroke(caneTo);
  strokeWeight(2);
  beginShape();
  for (float i = minLatitude; i < 35; i += step) {
    curveVertex(x.value(i), y.value(cane(i)));
  }
  endShape();
  
  stroke(maizeTo);
  beginShape();
  for (float i = minLatitude; i < maxLatitude; i += step) {
    curveVertex(x.value(i), y.value(maize(i)));
  }
  endShape();
  
  // Draw the threshold
  stroke(255, 0, 0);
  strokeWeight(1);
  line(x.range.x + 5, y.value(minEnergy), x.range.y, y.value(minEnergy));
  
  // Axes
  fill(170);
  stroke(170);
  strokeWeight(1);
  axes();
  
  if (debug) {
    debug();
  }

}

float maize(float x) {
  return 0.20317 + 0.0012365*x + 0.00041396*pow(x,2) + -7.9757E-7 * pow(x,3);
}

float cane(float x) {
  return 0.86884 + (-0.0083336)*x + 0.00091813*pow(x,2) + 1.418E-5 * pow(x,3);
}

void axes() {
  textFont(tickLabelFont);

  textAlign(CENTER);
  for (float i = x.domain.x, j = 0; i <= x.domain.y; i += 10, j++) {
    line(x.value(i), y.range.x, x.value(i), y.range.x + 5);
    
    if (j % 2 == 0) {
      text(str(int(i)), x.value(i), y.range.x + 20);
    }
  }
  
  textAlign(RIGHT);
  for (float i = y.domain.x, j = 0; i <= y.domain.y; i += 0.5, j++) {
    line(x.range.x, y.value(i), x.range.x - 5, y.value(i));
    
    if (j % 2 == 0) {
      text(str(i), x.range.x - 10, y.value(i) + 3);
    }
  }
  
  textAlign(CENTER);
  textFont(tickLabelFont);
  text("Latitude", x.range.x + (x.range.y - x.range.x)/2, y.range.x + 41);

  pushMatrix();
  translate(x.range.x - 37, height / 2);
  rotate(-HALF_PI);
  text("GJ Harvested Energy per GJ Ecosystem Energy", 0, 0);
  popMatrix();
}

void debug() {
  noFill();
  stroke(0xAA888888);
  strokeWeight(1);
  line(width/2, 0, width/2, height);
  line(0, height/2, width, height/2);
}

void keyPressed() {
  switch (key) {
    case ENTER:
    case RETURN:
      saveFrame("map.tiff");
      break;
      
     case TAB:
       debug = !debug;
       break;
  }
}

