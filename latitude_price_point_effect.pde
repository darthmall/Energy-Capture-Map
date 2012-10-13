float MARGIN = 20;
float AXIS_SIZE = 60;

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

color thresholdColor = #ae2640;
color[] maizeColors = {
  0x66f6eff7, 0x66bdc9e1, 0x6667a9cf, 0x661c9099, 0x66016c59
};
color[] caneColors = {
  0x66feebe2, 0x66fbb4b9, 0x66f768a1, 0x66c51b8a, 0x667a0177
};
color[] grays = {
  #f7f7f7, #cccccc, #969696, #636363, #252525
};

boolean dragging = false;
float dragOffset = 0;

boolean drawCane = true;
boolean drawMaize = true;
boolean debug = false;

PVector legendPos;

ArrayList<PVector> cane;
ArrayList<PVector> maize;

void setup() {
  size(740, 720);

  tickLabelFont = loadFont("AvenirNext-Regular-14.vlw");
  
  world = loadImage("world.png");
  mercator = new MercatorMap(604, 340, 79, -56.3653, -180, 180);
  
  upperBounds();
  
  x = new Scale();
  x.range = new PVector(AXIS_SIZE, world.width);
  x.domain = new PVector(-50, 60);
  
  y = new Scale();
  y.range = new PVector(height - AXIS_SIZE, world.height + MARGIN);
  y.domain = new PVector(0, 3.5);
  
  cane = new ArrayList<PVector>();
  maize = new ArrayList<PVector>();
  loadData("cane.csv", cane);
  loadData("maize.csv", maize);
  
  legendPos = new PVector(world.width + MARGIN, MARGIN);
  
  smooth();
}

void draw() {
  background(255);
  
  translate(MARGIN, 0);
  worldMap();
  plot();
  
  // Axes
  fill(grays[2]);
  stroke(grays[2]);
  strokeWeight(1);
  axes();
  
  pushMatrix();
  translate(legendPos.x, legendPos.y);
  legend();
  popMatrix();
  
  if (debug) {
    debug();
  }

}

void worldMap() {
    // Draw the map
  image(world, 0, 0);
  
  // Latitude bands
  for (float i = minLatitude; i <= maxLatitude; i += step) {
    float m = maize(i) - minEnergy;
    float c = cane(i) - minEnergy;
    PVector tl = mercator.getScreenLocation(new PVector(i+step/2, -180));
    PVector br = mercator.getScreenLocation(new PVector(i-step/2, 180));
    float w = br.x - tl.x;
    float h = br.y - tl.y;
    
    noStroke();
    if (m > 0 && drawMaize) {
      fill(maizeColors[int(round((m / maxMaize * 100))) / (100 / (maizeColors.length - 1))]);
      rect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    }
    
    
    if (c > 0 && i <= 40 && drawCane) {
      fill(caneColors[int(round((c / maxCane * 100))) / (100 / (caneColors.length - 1))]);
      rect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    }
  }
}

void plot() {
  // Draw cane data
  noStroke();
  
  if (drawCane) {
    fill(caneColors[1]);
    
    for (int i = 0; i < cane.size(); i++) {
      PVector p = cane.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
  }

  if (drawMaize) {
    fill(maizeColors[1]);
    for (int i = 0; i < maize.size(); i++) {
      PVector p = maize.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
  }
  
  // Draw the regression lines
  noFill();
  
  if (drawCane) {
    stroke(caneColors[4]);
    strokeWeight(2);
    beginShape();
    for (float i = minLatitude; i < 40; i += step) {
      curveVertex(x.value(i), y.value(cane(i)));
    }
    endShape();
  }
  
  if (drawMaize) {
    stroke(maizeColors[4]);
    beginShape();
    for (float i = minLatitude; i < maxLatitude; i += step) {
      curveVertex(x.value(i), y.value(maize(i)));
    }
    endShape();
  }
  
  // Draw the threshold
  stroke(thresholdColor);
  strokeWeight(1);
  line(x.range.x + 5, y.value(minEnergy), x.range.y, y.value(minEnergy));
  fill(thresholdColor);
  textAlign(RIGHT);
  text(String.format("%.2f", minEnergy), x.range.y, y.value(minEnergy) - 2.8);
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
  translate(x.range.x - 47, y.range.x + (y.range.y - y.range.x) / 2);
  rotate(-HALF_PI);
  text("GJ Harvested Energy per GJ Ecosystem Energy", 0, 0);
  popMatrix();
}

void legend() {
  textAlign(LEFT);

  noStroke();
  
  fill(grays[drawMaize ? 3 : 1]);
  text("Maize", 21, 14);
  fill(grays[drawCane ? 3 : 1]);
  text("Cane", 21, 35);
  

  if (drawMaize) {
    noStroke();
    fill(maizeColors[4]);
  } else {
    noFill();
    stroke(maizeColors[1]);
  }
  rect(0, 0, 16.8, 16.8);  
  

  if (drawCane) {
    noStroke();
    fill(caneColors[4]);
  } else {
    stroke(caneColors[1]);
    noFill();
  }
    
  rect(0, 21, 16.8, 16.8);
  
}

void upperBounds() {
  for (float i = minLatitude; i <= maxLatitude; i += step) {
    if (i <= 40) {
      maxCane = max(maxCane, cane(i) - minEnergy);
    }
    maxMaize = max(maxMaize, maize(i) - minEnergy);
  }
}

void loadData(String filename, ArrayList<PVector> data) {
  BufferedReader reader = createReader(filename);
  String l;
  
  do {
    try {
      l = reader.readLine();
      
      if (l != null) {
        String[] toks = l.split(",");
      
        data.add(new PVector(x.value(float(toks[0])), y.value(float(toks[1]))));
      }
      
    } catch (IOException e) {
      e.printStackTrace();
      l = null;
    }
  } while (l != null);
}

void debug() {
  noFill();
  stroke(grays[3]);
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

void mousePressed() {
  float v = y.value(minEnergy);
  
  if (mouseX >= x.range.x && mouseX <= x.range.y &&
      mouseY >= v - 5 && mouseY <= v + 5) {
    dragging = true;
    dragOffset = v - mouseY;
  }
}

void mouseDragged() {
  if (dragging) {
    minEnergy = round(y.rev(mouseY + dragOffset) * 100) / 100f;
    minEnergy = max(y.domain.x, minEnergy);
    minEnergy = min(y.domain.y, minEnergy);

    upperBounds();
  }
}

void mouseReleased() {
  dragging = false;
}

void mouseClicked() {
  PVector p = new PVector(mouseX - legendPos.x, mouseY - legendPos.y);
  
  if (p.x >= 0 && p.y >= 0 && p.x <= 90) {
    if (p.y <= 16.8) {
      drawMaize = !drawMaize;
    } else if (p.y >= 21 && p.y <= 37.8) {
      drawCane = !drawCane;
    } 
  }
}


