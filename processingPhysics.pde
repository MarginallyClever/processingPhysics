ArrayList<Body> bodies = new ArrayList<Body>();
long tLast;

void setup() {
  size(800,800);
  tLast = millis();
  noFill();
  
  testRandomShapes();
}

void reset() {
  bodies.clear();
}

void keyReleased() {
  println("key="+key);
  switch(key) {
    case 1:  testRandomShapes();  break;
    case 2:  testOneBoxAndOneCircle(); break;
    case 3:  testTwoCircles();  break;
    default: break;
  }
}

void draw() {
  long now = millis();
  float dt = now-tLast;
  if(dt<30) return;
  tLast = now;

  dt*=0.001;
  
  background(255,255,255);
  
  for( Body b : bodies ) {
    //println(dt+"\t"+b.toString());
    //b.addGravity();
    b.accelerate(dt);
  }

  testForCollisions();
    
  for( Body b : bodies ) {
    b.move(dt);
    b.render();
  }
}
