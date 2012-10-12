class Scale {
  
  PVector domain;
  PVector range;
  
  float value(double input) {
    double p = (input - domain.x) / (domain.y - domain.x);
    
    return (float) (range.x + ((range.y - range.x) * p));
  }
  
  float rev(double input) {
    double p = (input - range.x) / (range.y - range.x);
    
    return (float) (domain.x + ((domain.y - domain.x) * p));
  }
}
