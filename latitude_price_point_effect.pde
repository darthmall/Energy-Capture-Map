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

Scale lat;
Scale energy;
Scale land;

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
  
  lat = new Scale();
  lat.range = new PVector(AXIS_SIZE, world.width);
  lat.domain = new PVector(-50, 60);
  
  energy = new Scale();
  energy.range = new PVector(height - AXIS_SIZE, world.height + MARGIN);
  energy.domain = new PVector(0, 3.5);
  
  land = new Scale();
  land.range = energy.range;
  land.domain = new PVector(0, 636000);

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
}

float maize(float x) {
  return 0.20317 + 0.0012365*x + 0.00041396*pow(x,2) + -7.9757E-7 * pow(x,3);
}

float cane(float x) {
  return 0.86884 + (-0.0083336)*x + 0.00091813*pow(x,2) + 1.418E-5 * pow(x,3);
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

  for (float i = lat.domain.x; i <= lat.domain.y; i += step) {
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

void mousePressed() {
  float v = energy.value(minEnergy);
  
  if (mouseX >= lat.range.x && mouseX <= lat.range.y &&
      mouseY >= v - 5 && mouseY <= v + 5) {
    dragging = true;
    dragOffset = v - mouseY;
  }
}

void mouseDragged() {
  if (dragging) {
    minEnergy = round(energy.rev(mouseY + dragOffset) * 100) / 100f;
    minEnergy = max(energy.domain.x, minEnergy);
    minEnergy = min(energy.domain.y, minEnergy);

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


