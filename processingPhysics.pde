ArrayList<Body> bodies = new ArrayList<Body>();
ArrayList<Manifold> contacts = new ArrayList<Manifold>();
long tLast;
boolean paused=false;
boolean step=false;
PVector gravity = new PVector(0,9.8);


void setup() {
  size(800,800);
  noFill();
  createWorldEdges();  
  tLast = millis();
}

void reset() {
  println("reset()");
  bodies.clear();
  paused=false;
  step=false;
  createWorldEdges();
}

void createWorldEdges() {
  BodyBox b = new BodyBox(new PVector(0,0),new PVector(width,10));
  b.setStatic();
  bodies.add(b);

  b = new BodyBox(new PVector(0,0),new PVector(10,height));
  b.setStatic();
  bodies.add(b);
  
  b = new BodyBox(new PVector(width-10,0),new PVector(width,height));
  b.setStatic();
  bodies.add(b);

  b = new BodyBox(new PVector(0,height-10),new PVector(width,height));
  b.setStatic();
  bodies.add(b);
}

void keyReleased() {
  println("key="+key);
  switch(key) {
    case '1':  testRandomShapes();  break;
    case '2':  testOneBoxAndOneCircle(); break;
    case '3':  testTwoCircles();  break;
    case '4':  testOneBallAndWall();  break;
    case '5':  testOneBoxAndWall();  break;
    case '6':  testTwoBoxes();  break;
    case 'f':
    case 'F':  paused=!paused;  break;
    case ' ':  step=true;  break;
    default: break;
  }
}

void draw() {
  long now = millis();
  float dt = now-tLast;
  //if(dt<30) return;
  tLast = now;
  
  if(paused && !step) {
    dt=0;
  } else {
    dt*=0.001;
  }
  step=false;
  
  if(dt==0) return;
  
  background(255,255,255);
  pushMatrix();
  float s=1;
  scale(s);
  translate(width*(1-s)/2,height*(1-s)/2);
  
  contacts.clear();
  
  testForCollisions();
  
  for( Body b : bodies ) {
    //b.addGravity();
    b.integrateForces(dt);
  }
  
  for( Manifold m : contacts ) {
    m.resolveCollisions();
  }
  
  for( Body b : bodies ) {
    b.integrateVelocity(dt);
  }
  
  for( Manifold m : contacts ) {
    m.correctPosition();
  }
  
  for( Body b : bodies ) {
    b.force.set(0,0,0);
    b.torque.set(0,0,0);
  }
  
  for( Body b : bodies ) {
    b.render();
  }
  
  popMatrix();
}

String colorToString(color c) {
  return "["+red(c)+","+green(c)+","+blue(c)+"]";
}

PVector getNormalTo(PVector start,PVector end) {
  PVector n = PVector.sub(end,start);
  float temp = n.x;
  n.x=n.y;
  n.y=-temp;
  n.normalize();
  return n;
}
