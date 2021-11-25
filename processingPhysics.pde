//--------------------------------------------------
// Physics in 2D
// dan@marginallyclever.com 2021-11-04
//--------------------------------------------------
import controlP5.*;

ControlP5 cp5;
DropdownList d1;

// things that can collide
ArrayList<Body> bodies = new ArrayList<Body>();
// all contacts in a given step of the scene
ArrayList<Manifold> contacts = new ArrayList<Manifold>();
ArrayList<Constraint> constraints = new ArrayList<Constraint>();

// time of last frame, to control physics-steps-per-second
long tLast;

boolean paused=false;  // are we?
boolean step=false;  // should we?

PVector gravity = new PVector(0,9.8);
PVector camera = new PVector(0,0,1);

boolean moveCameraOn=false;

boolean dragShapeOn=false;
Body bodyUnderCursor;
Constraint bodyToCursor = new PinConstraint(null,new PVector(),new PVector());



void setup() {
  size(800,800);
  cp5 = new ControlP5(this);
  d1 = cp5.addDropdownList("Choose test")
        .setPosition(20,20);
  d1.addItem("Random shapes",0);
  d1.addItem("One box and one circle",1);
  d1.addItem("Two circles",2);
  d1.addItem("One ball and wall",3);
  d1.addItem("One box and wall",4);
  d1.addItem("Two boxes",5);
  d1.addItem("One box and one circle corner hit",6);
  d1.addItem("Stacked boxes",7);
  d1.addItem("Pinned boxes",8);
    
  camera.set(width/2,height/2,1);
  //camera.set(0,0,1);
  noFill();
  createWorldEdges();
  tLast = millis();
}


// d1 events happen here
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
    if(theEvent.getController()==d1) {
      int i = (int)theEvent.getController().getValue();
      switch(i) {
      case 0:  testRandomShapes();  break;
      case 1:  testOneBoxAndOneCircle();  break;
      case 2:  testTwoCircles();  break;
      case 3:  testOneBallAndWall();  break;
      case 4:  testOneBoxAndWall();  break;
      case 5:  testTwoBoxes();  break;
      case 6:  testOneBoxAndOneCircleCornerHit();  break;
      case 7:  testStackedBoxes();  break;
      case 8:  testPinnedBoxes();  break;
      default:  println("ERROR: controlEvent() undefined test.");  break;
      }
    }
  }
}

void reset() {
  println("reset()");
  gravity.set(0,0);
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
    case 'f':
    case 'F':  paused=!paused;  break;
    case 'g':
    case 'G':  gravity.y = ( gravity.y == 0 ? 9.8 : 0 );  break;
    case '=':  camera.z=1;  break;
    case ' ':  step=true;  break;
    default: break;
  }
}

void mousePressed() {
  if(mouseButton == CENTER) moveCameraOn=true;
  else moveCameraOn=false;
  if(mouseButton == LEFT) beginDragShape();
}

void mouseReleased() {
  if(mouseButton == CENTER) moveCameraOn=false;
  if(mouseButton == LEFT) endDragShape();
}

void beginDragShape() {
  if(!dragShapeOn && bodyUnderCursor!=null) {
    println("beginDragShape");
    bodyToCursor.aBody = bodyUnderCursor;
    dragShapeOn=true;
    PVector mouseWorld = screenSpaceToWorldSpace(new PVector(mouseX,mouseY,0));
    bodyToCursor.aPoint.set(bodyUnderCursor.worldToLocal(mouseWorld));
    bodyToCursor.bPoint.set(mouseWorld);
  }
}

void dragShape() {
  println("a");
  if(!dragShapeOn) return;
  println("b");
  if(bodyToCursor.aBody==null) return;
  println("dragging");
  PVector mouseWorld = screenSpaceToWorldSpace(new PVector(mouseX,mouseY,0));
  bodyToCursor.bPoint.set(mouseWorld);
  bodyToCursor.resolveConstraint();
}

void endDragShape() {
  println("endDragShape");
  dragShapeOn=false;
}


void mouseDragged() {
  if( !moveCameraOn ) return;
  float dx = mouseX-pmouseX;
  float dy = mouseY-pmouseY;
  camera.x -= dx / camera.z;
  camera.y -= dy / camera.z;
}

void mouseWheel(MouseEvent event) {
  if(d1.isMouseOver()) return;  // do not zoom when scrolling drop down list.
  
  float zoomChange = event.getCount()/10.0;
  println("zoomChange="+zoomChange);

  PVector m = new PVector(mouseX,mouseY,0);
  PVector before = screenSpaceToWorldSpace(m);
  
  camera.z += zoomChange;
  camera.z = max( camera.z, 0.05);
 
  PVector after = screenSpaceToWorldSpace(m);
  PVector diff = PVector.sub(after,before);
  
  camera.x -= diff.x;
  camera.y -= diff.y;
}

PVector screenSpaceToWorldSpace(PVector in) {
  float z = camera.z;
  float iz = 1.0/z;
  float x = in.x - (width  / 2.0);
  float y = in.y - (height / 2.0);
  
  PVector out = new PVector(
    x*iz + camera.x,
    y*iz + camera.y
  );
  return out;
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
  scale(camera.z);
  translate(
    -camera.x+(width/2.0)/camera.z,
    -camera.y+(height/2.0)/camera.z
  );
  
  PVector mouseWorld = screenSpaceToWorldSpace(new PVector(mouseX,mouseY,0));
  stroke(255,0,0);
  drawStar(mouseWorld,20);
  stroke(0,255,0);
  drawStar(camera,10);
  
  contacts.clear();
  
  testAllCollisions();
  
  for( Body b : bodies ) {
    b.integrateForces(dt);
  }
  
  for( Manifold m : contacts ) {
    m.resolveCollisions();
  }
  
  for( Constraint c : constraints ) {
    c.resolveConstraint();
  }
  dragShape();
  
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
  
  highlightBodyUnderCursor(mouseWorld);
  
  popMatrix();
}

void highlightBodyUnderCursor(PVector mouseWorld) {
  strokeWeight(4);
  bodyToCursor.aBody=null;
  
  for( Body b : bodies ) {
    if(b.pointInside(mouseWorld)) {
      if(!dragShapeOn) bodyUnderCursor = b;
      b.render();
    }
  }
  strokeWeight(1);
}

void drawStar(PVector p,float radius) {
  line(p.x-radius, p.y       , p.x+radius, p.y       );
  line(p.x       , p.y-radius, p.x       , p.y+radius);
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

boolean pointInTriangle(PVector pt,PVector v1,PVector v2,PVector v3) {
  float d1 = pointInTriangleSign(pt, v1, v2);
  float d2 = pointInTriangleSign(pt, v2, v3);
  float d3 = pointInTriangleSign(pt, v3, v1);

  boolean has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  boolean has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

  return !(has_neg && has_pos);
}

float pointInTriangleSign(PVector p1, PVector p2, PVector p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}
