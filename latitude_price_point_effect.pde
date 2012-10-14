float MARGIN = 20;
float AXIS_SIZE = 60;

PFont tickLabelFont;

float step = 2;
float minEnergy = 1.0;

PVector caneRange;
PVector caneDomain;
PVector maizeRange;
PVector maizeDomain;

PImage world;
MercatorMap mercator;

Scale x;
Scale y;

color thresholdColor = #ae2640;
color[] caneColors = {
  0x88F7F4F9, 0x88E7E1EF, 0x88D4B9DA, 0x88C994C7,0x88DF65B0,
  0x88E7298A, 0x88CE1256, 0x88980043, 0x8867001F
};
color[] maizeColors = {
  0x88FFFFE5, 0x88F7FCB9, 0x88D9F0A3, 0x88ADDD8E, 0x8878C679,
  0x8841AB5D, 0x88238443, 0x88006837, 0x88004529
};
color[] grays = {
  #f7f7f7, #cccccc, #969696, #636363, #252525
};

boolean dragging = false;
float dragOffset = 0;

boolean showCane = true;
boolean showMaize = true;
boolean debug = false;

PVector legendPos;

ArrayList<PVector> caneData;
ArrayList<PVector> maizeData;

void setup() {
  size(740, 720);

  tickLabelFont = loadFont("AvenirNext-Regular-14.vlw");
  
  world = loadImage("world.png");
  mercator = new MercatorMap(604, 340, 79, -56.3653, -180, 180);
  
  caneDomain = new PVector(-33, 36);
  maizeDomain = new PVector(-43, 54);
  
  x = new Scale();
  x.range = new PVector(AXIS_SIZE, world.width);
  x.domain = new PVector(-50, 60);
  
  y = new Scale();
  y.range = new PVector(height - AXIS_SIZE, world.height + MARGIN);
  y.domain = new PVector(0, 3.5);

  caneData = new ArrayList<PVector>();
  caneDomain = new PVector();
  loadData("cane.csv", caneData, caneDomain);
  
  maizeData = new ArrayList<PVector>();
  maizeDomain = new PVector();
  loadData("maize.csv", maizeData, maizeDomain);
  
  updateRanges();

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
  for (float i = x.domain.x; i <= x.domain.y; i += step) {
    float m = maize(i);
    float c = cane(i);
    PVector tl = mercator.getScreenLocation(new PVector(i+step/2, -180));
    PVector br = mercator.getScreenLocation(new PVector(i-step/2, 180));
    float w = br.x - tl.x;
    float h = br.y - tl.y;
    
    boolean drawMaize = showMaize && i >= maizeDomain.x && i <= maizeDomain.y && m >= minEnergy;
    boolean drawCane = showCane && i >= caneDomain.x && i <= caneDomain.y && c >= minEnergy;

    noStroke();

    if (drawMaize && drawCane) {
      if (m > c) {
        fill(maizeColors[int(round(((m - maizeRange.x) / (maizeRange.y - maizeRange.x) * 100))) / (100 / (maizeColors.length - 1))]);
      } else {
        fill(caneColors[int(round(((c - caneRange.x) / (caneRange.y - caneRange.x) * 100))) / (100 / (caneColors.length - 1))]);
      }
    } else if (drawMaize) {
      fill(maizeColors[int(round(((m - maizeRange.x) / (maizeRange.y - maizeRange.x) * 100))) / (100 / (maizeColors.length - 1))]);
    } else if (drawCane) {
      fill(caneColors[int(round(((c - caneRange.x) / (caneRange.y - caneRange.x) * 100))) / (100 / (caneColors.length - 1))]);
    }
    
    if (drawMaize || drawCane) {
      rect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    }
  }
}

void plot() {
  // Draw cane data
  noStroke();
  
  if (showCane) {
    fill(caneColors[1]);
    
    for (int i = 0; i < caneData.size(); i++) {
      PVector p = caneData.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
  }

  if (showMaize) {
    fill(maizeColors[1]);
    for (int i = 0; i < maizeData.size(); i++) {
      PVector p = maizeData.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
  }
  
  // Draw the regression lines
  noFill();
  
  if (showCane) {
    stroke(caneColors[4]);
    strokeWeight(2);
    beginShape();
    for (float i = caneDomain.x; i <= caneDomain.y; i += step) {
      vertex(x.value(i), y.value(cane(i)));
    }
    endShape();
  }
  
  if (showMaize) {
    stroke(maizeColors[4]);
    beginShape();
    for (float i = maizeDomain.x; i < maizeDomain.y; i += step) {
      vertex(x.value(i), y.value(maize(i)));
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
  
  fill(grays[showMaize ? 3 : 1]);
  text("Maize", 21, 14);
  fill(grays[showCane ? 3 : 1]);
  text("Cane", 21, 35);
  

  if (showMaize) {
    noStroke();
    fill(maizeColors[4]);
  } else {
    noFill();
    stroke(maizeColors[1]);
  }
  rect(0, 0, 16.8, 16.8);  
  

  if (showCane) {
    noStroke();
    fill(caneColors[4]);
  } else {
    stroke(caneColors[1]);
    noFill();
  }
    
  rect(0, 21, 16.8, 16.8);
}

void updateRanges() {
  caneRange = null;
  maizeRange = null;

  for (float i = x.domain.x; i <= x.domain.y; i += step) {
    if (i >= maizeDomain.x && i <= maizeDomain.y) {
      float m = maize(i);
      
      if (maizeRange == null) {
        maizeRange = new PVector(m, m);
      } else {
        maizeRange.x = min(maizeRange.x, m);
        maizeRange.y = max(maizeRange.y, m);
      }
    }
    
    if (i >= caneDomain.x && i <= caneDomain.y) {
      float c = cane(i);
      
      if (caneRange == null) {
        caneRange = new PVector(c, c);
      } else {
        caneRange.x = min(caneRange.x, c);
        caneRange.y = max(caneRange.y, c);
      }
    }
  }
  
  if (caneRange.x < minEnergy) {
    caneRange.x = minEnergy;
  }
  
  if (maizeRange.x < minEnergy) {
    maizeRange.x = minEnergy;
  }
}

void loadData(String filename, ArrayList<PVector> data, PVector domain) {
  boolean domainUnset = true;
  BufferedReader reader = createReader(filename);
  String l;
  
  do {
    try {
      l = reader.readLine();
      
      if (l != null) {
        String[] toks = l.split(",");
        float lat = float(toks[0]);
        float ratio = float(toks[1]);
        
        if (domainUnset) {
          domain.x = lat;
          domain.y = lat;
          domainUnset = false;
        } else {
          domain.x = min(domain.x, lat);
          domain.y = max(domain.y, lat);
        }
      
        data.add(new PVector(x.value(lat), y.value(ratio)));
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

    updateRanges();
  }
}

void mouseReleased() {
  dragging = false;
}

void mouseClicked() {
  PVector p = new PVector(mouseX - legendPos.x, mouseY - legendPos.y);
  
  if (p.x >= 0 && p.y >= 0 && p.x <= 90) {
    if (p.y <= 16.8) {
      showMaize = !showMaize;
    } else if (p.y >= 21 && p.y <= 37.8) {
      showCane = !showCane;
    } 
  }
}


