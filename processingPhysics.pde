//--------------------------------------------------
// Physics in 2D
// dan@marginallyclever.com 2021-11-04
//--------------------------------------------------

// things that can collide
ArrayList<Body> bodies = new ArrayList<Body>();
// all contacts in a given step of the scene
ArrayList<Manifold> contacts = new ArrayList<Manifold>();

// time of last frame, to control physics-steps-per-second
long tLast;

boolean paused=false;  // are we?
boolean step=false;  // should we?

PVector gravity = new PVector(0,9.8);

PVector camera = new PVector(0,0,1);


void setup() {
  size(800,800);
  camera.set(width/2,height/2,1);
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
  BodyPolygon b = addBox(new PVector(0,0),new PVector(width,10));
  b.setStatic();
  bodies.add(b);

  b = addBox(new PVector(0,0),new PVector(10,height));
  b.setStatic();
  bodies.add(b);
  
  b = addBox(new PVector(width-10,0),new PVector(width,height));
  b.setStatic();
  bodies.add(b);

  b = addBox(new PVector(0,height-10),new PVector(width,height));
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
    case '7':  testRandomShapesWithGravity();  break;
    case '8':  testOneBoxAndOneCircleCornerHit();  break;
    case 'f':
    case 'F':  paused=!paused;  break;
    case ' ':  step=true;  break;
    default: break;
  }
}

void mouseDragged() {
  float dx = mouseX-pmouseX;
  float dy = mouseY-pmouseY;
  camera.x-=dx;
  camera.y-=dy;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  println("mouse="+e);
  camera.z+=e/10;
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
  translate(width/2-camera.x,height/2-camera.y);
  scale(camera.z);
  
  contacts.clear();
  
  testAllCollisions();
  
  for( Body b : bodies ) {
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
