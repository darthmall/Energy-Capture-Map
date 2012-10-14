
void worldMap() {
    // Draw the map
  image(world, 0, 0);
  
  // Latitude bands
  for (float i = lat.domain.x; i <= lat.domain.y; i += step) {
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

