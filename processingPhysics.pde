//--------------------------------------------------
// Physics in 2D
// dan@marginallyclever.com 2021-11-04
//
// see https://www.youtube.com/watch?v=SHinxAhv1ZE
// see https://www.cs.ubc.ca/~rhodin/2020_2021_CPSC_427/lectures/D_CollisionTutorial.pdf
// see godot engine https://github.com/godotengine/godot
// see ImpulseEngine https://github.com/RandyGaul/ImpulseEngine
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

// for dragging (makes a rubber band that pulls a shape)
boolean dragShapeOn=false;
Body bodyUnderCursor;
SpringConstraint bodyToCursor = new SpringConstraint(null,new PVector(),new PVector());

// for applying impulses to shapes (nudge them)
boolean applyImpulseOn = false;
PVector applyImpulseStart = new PVector();


void setup() {
  size(800,800);
  cp5 = new ControlP5(this);
  d1 = cp5.addDropdownList("Choose test")
          .setPosition(20,20)
          .addItem("Random shapes",0)
          .addItem("One circle",1)
          .addItem("One box",2)
          .addItem("One box and one circle",3)
          .addItem("Two circles",4)
          .addItem("One ball and wall",5)
          .addItem("One box and wall",6)
          .addItem("Two boxes",7)
          .addItem("One box and one circle corner hit",8)
          .addItem("Stacked boxes",9)
          .addItem("Pinned boxes",10);
  
  noFill();
  reset();
  
  bodyToCursor.springConstant=10;
  
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
      case 1:  testOneCircle();  break;
      case 2:  testOneBox();  break;
      case 3:  testOneBoxAndOneCircle();  break;
      case 4:  testTwoCircles();  break;
      case 5:  testOneBallAndWall();  break;
      case 6:  testOneBoxAndWall();  break;
      case 7:  testTwoBoxes();  break;
      case 8:  testOneBoxAndOneCircleCornerHit();  break;
      case 9:  testStackedBoxes();  break;
      case 10:  testPinnedBoxes();  break;
      default:  println("ERROR: controlEvent() undefined test.");  break;
      }
    }
  }
}

void reset() {
  println("reset()");
  gravity.set(0,0);
  bodies.clear();
  constraints.clear();
  paused=false;
  step=false;
  createWorldEdges();
  resetCamera();
}

void resetCamera() {
  camera.set(width/2,height/2,1);
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
    case ' ':  step=true;  paused=true;  break;
    case '+':  bodyToCursor.springConstant++;  println("springConstant="+bodyToCursor.springConstant);  break;
    case '-':  bodyToCursor.springConstant--;  println("springConstant="+bodyToCursor.springConstant);  break;
    default: break;
  }
}

void mousePressed() {
  if(mouseButton == CENTER) moveCameraOn=true;
  else moveCameraOn=false;
  if(mouseButton == LEFT) beginDragShape();
  if(mouseButton == RIGHT) beginApplyImpulse();
}

void mouseReleased() {
  if(mouseButton == CENTER) moveCameraOn=false;
  if(mouseButton == LEFT) endDragShape();
  if(mouseButton == RIGHT) endApplyImpulse();
}

void beginApplyImpulse() {
  if(applyImpulseOn) return;
  
  applyImpulseOn=true;
  applyImpulseStart = getMouseWorld();
}

void endApplyImpulse() {
  if(!applyImpulseOn) return;
  applyImpulseOn=false;
  if(bodyUnderCursor==null) return;
  
  PVector applyImpulseEnd = getMouseWorld();
  PVector diff = PVector.sub(applyImpulseEnd,applyImpulseStart);
  diff.mult(bodyUnderCursor.mass);
  
  bodyUnderCursor.applyImpulse(diff,bodyUnderCursor.getR(applyImpulseEnd));
}

void drawApplyImpulse() {
  if(!applyImpulseOn) return;
  PVector applyImpulseEnd = getMouseWorld();
  PVector t0 = applyImpulseStart.copy();
  
  float steps=10;
  for(float i=1;i<=steps;++i) {
    PVector t1 = PVector.lerp(applyImpulseStart,applyImpulseEnd,i/steps);
    stroke(255.0* i/steps,0,0);
    line(t0.x,t0.y,t1.x,t1.y);
    t0.set(t1);
  }
}

PVector getMouseWorld() {
  return screenSpaceToWorldSpace(new PVector(mouseX,mouseY,0));
}

void beginDragShape() {
  if(!dragShapeOn && bodyUnderCursor!=null) {
    dragShapeOn=true;
    //println("beginDragShape");
    bodyToCursor.aBody = bodyUnderCursor;
    PVector mouseWorld = getMouseWorld();
    bodyToCursor.aPoint.set(bodyUnderCursor.worldToLocal(mouseWorld));
    bodyToCursor.bPoint.set(mouseWorld);
    bodyToCursor.setRestingLength();
  }
}

void dragShape() {
  if(!dragShapeOn) return;
  if(bodyToCursor.aBody==null) return;
  PVector mouseWorld = getMouseWorld();
  bodyToCursor.bPoint.set(mouseWorld);
  bodyToCursor.resolveConstraint();
}

void endDragShape() {
  //println("endDragShape");
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
  
  PVector mouseWorld = getMouseWorld();
  stroke(255,0,0);
  drawStar(mouseWorld,20);
  stroke(0,255,0);
  drawStar(camera,10);
  
  contacts.clear();
  
  testAllCollisions();
  
  for( Body b : bodies ) {
    b.integrateForces(dt);
  }
  
  for( Constraint c : constraints ) {
    c.resolveConstraint();
  }
  
  for( Body b : bodies ) {
    b.integrateVelocity(dt);
  }
  
  for( Manifold m : contacts ) {
    m.resolveCollisions();
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
  
  dragShape();
  updateBodyUnderCursor(mouseWorld);
  highlightBodyUnderCursor();
  drawApplyImpulse();
  
  popMatrix();
}

void updateBodyUnderCursor(PVector mouseWorld) {
  bodyUnderCursor=null;
  
  for( Body b : bodies ) {
    if(b.pointInside(mouseWorld)) {
      if(!dragShapeOn) {
        bodyUnderCursor = b;
        return;
      }
    }
  }
}

void highlightBodyUnderCursor() {
  if(bodyUnderCursor==null) return;
  strokeWeight(3);
  bodyUnderCursor.render();
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

// see https://www.mathopenref.com/coordtrianglearea.html
float triangleArea(PVector a,PVector b,PVector c) {
  return abs((a.x*(b.y-c.y) + b.x*(c.y-a.y) + c.x*(a.y-b.y)) / 2.0);
}


void lineA2B(PVector a,PVector b) {
  line(a.x,a.y,b.x,b.y);
}

void lineAPlusB(PVector a,PVector b) {
  line(a.x,a.y,a.x+b.x,a.y+b.y);
}
