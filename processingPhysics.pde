ArrayList<Body> bodies = new ArrayList<Body>();
long tLast;
boolean paused=false;
boolean step=false;

void setup() {
  size(800,800);
  tLast = millis();
  noFill();
  
  testRandomShapes();
}

void reset() {
  println("reset()");
  bodies.clear();
  paused=false;
  step=false;
}

void keyReleased() {
  println("key="+key);
  switch(key) {
    case '1':  testRandomShapes();  break;
    case '2':  testOneBoxAndOneCircle(); break;
    case '3':  testTwoCircles();  break;
    case '4':  testOneBallAndWall();  break;
    case '5':  testOneBoxAndWall();  break;
    case ' ':  step=true;  break;
    default: break;
  }
}

void draw() {
  long now = millis();
  float dt = now-tLast;
  if(dt<30) return;
  tLast = now;

  if(paused && !step) {
    dt=0;
  } else {
    dt*=0.001;
  }
  step=false;
  
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
