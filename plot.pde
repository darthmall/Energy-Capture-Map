void axes() {
  textFont(tickLabelFont);

  textAlign(CENTER);
  for (float i = lat.domain.x, j = 0; i <= lat.domain.y; i += 10, j++) {
    line(lat.value(i), energy.range.x, lat.value(i), energy.range.x + 5);
    
    if (j % 2 == 0) {
      text(str(int(i)), lat.value(i), energy.range.x + 20);
    }
  }
  
  textAlign(RIGHT);
  for (float i = energy.domain.x, j = 0; i <= energy.domain.y; i += 0.5, j++) {
    line(lat.range.x, energy.value(i), lat.range.x - 5, energy.value(i));
    
    if (j % 2 == 0) {
      text(str(i), lat.range.x - 10, energy.value(i) + 3);
    }
  }
  
  textAlign(CENTER);
  textFont(tickLabelFont);
  text("Latitude", lat.range.x + (lat.range.y - lat.range.x)/2, energy.range.x + 41);

  pushMatrix();
  translate(lat.range.x - 47, energy.range.x + (energy.range.y - energy.range.x) / 2);
  rotate(-HALF_PI);
  text("GJ Harvested Energy per GJ Ecosystem Energy", 0, 0);
  popMatrix();
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
        float latitude = float(toks[0]);
        float ratio = float(toks[1]);
        float landuse = float(toks[2]);
        
        if (domainUnset) {
          domain.x = latitude;
          domain.y = latitude;
          domainUnset = false;
        } else {
          domain.x = min(domain.x, latitude);
          domain.y = max(domain.y, latitude);
        }
      
        data.add(new PVector(lat.value(latitude),
          energy.value(ratio),
          land.value(landuse)
        ));
      }
      
    } catch (IOException e) {
      e.printStackTrace();
      l = null;
    }
  } while (l != null);
}


void plot() {
  // Draw cane data
  noStroke();
  
  if (showCane && !showMaize) {
    fill(caneColors[2]);
    beginShape();
    vertex(caneDomain.x, land.value(0));
    
    for (int i = 0; i < caneData.size(); i++) {
      PVector p = caneData.get(i);
      vertex(p.x, p.z);
    }
    
    vertex(caneDomain.y, land.value(0));
    endShape();
  }
  
  if (showMaize && !showCane) {
    fill(maizeColors[2]);
    beginShape();
    vertex(maizeDomain.x, land.value(0));
    
    for (int i = 0; i < maizeData.size(); i++) {
      PVector p = maizeData.get(i);
      vertex(p.x, p.z);
    }
    
    vertex(maizeDomain.y, land.value(0));
    endShape();
  }
  
  if (showCane) {
    fill(caneColors[3]);
    
    for (int i = 0; i < caneData.size(); i++) {
      PVector p = caneData.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
  }

  if (showMaize) {
    fill(maizeColors[3]);
    for (int i = 0; i < maizeData.size(); i++) {
      PVector p = maizeData.get(i);
      ellipse(p.x, p.y, 5, 5);
    }
  }
  
  // Draw the regression lines
  noFill();
  
  if (showCane) {
    stroke(caneColors[6]);
    strokeWeight(2);
    beginShape();
    for (float i = caneDomain.x; i <= caneDomain.y; i += step) {
      vertex(lat.value(i), energy.value(cane(i)));
    }
    endShape();
  }
  
  if (showMaize) {
    stroke(maizeColors[6]);
    beginShape();
    for (float i = maizeDomain.x; i < maizeDomain.y; i += step) {
      vertex(lat.value(i), energy.value(maize(i)));
    }
    endShape();
  }
  
  // Draw the threshold
  stroke(thresholdColor);
  strokeWeight(1);
  line(lat.range.x + 5, energy.value(minEnergy), lat.range.y, energy.value(minEnergy));
  fill(thresholdColor);
  textAlign(RIGHT);
  text(String.format("%.2f", minEnergy), lat.range.y, energy.value(minEnergy) - 2.8);
}
