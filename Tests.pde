
void testOneBallAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  BodyCircle a = addCircle(40,1);  
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}

void testOneBoxAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  BodyPolygon a = addBox(30*4,20*4,1);
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}

void testTwoBoxes() {
  println("testTwoBoxes()");
  reset();
  bodies.clear();
  
  BodyPolygon a = addBox(30*4,20*4,1);
  BodyPolygon b = addBox(30*4,40*4,1);
  
  a.position.set(width/2-100,height/2-15);
  b.position.set(width/2+100,height/2);
  a.velocity.set(15,0);
  b.velocity.set(0,0);
  a.angularV.set(0,0,radians(10));
  a.angularV.set(0,0,radians(-40));
}

void testTwoCircles() {
  println("testTwoCircles()");
  reset();
  
  BodyCircle a = addCircle(15,1);
  BodyCircle b = addCircle(30,1);
  
  a.position.set(width/2-50,height/2-15);
  b.position.set(width/2+50,height/2);
  a.velocity.set(15,0);
  b.velocity.set(0,0);
  a.angularV.set(0,0,radians(10));
  a.angularV.set(0,0,radians(-40));
}

void testOneBoxAndOneCircle() {
  println("testOneBoxAndOneCircle()");
  reset();
  
  BodyCircle a = addCircle(50,1);
  BodyPolygon b = addBox(5*20,10*20,1);
  b.updateRadius();
  b.myColor = color(128,0,0);

  a.position.set(width/2-90,height/2-60);
  b.position.set(width/2+50,height/2);
  a.velocity.set(35,0);
  b.velocity.set(0,0);
}

void testOneBoxAndOneCircleCornerHit() {
  println("testOneBoxAndOneCircleCornerHit()");
  reset();
  
  BodyCircle a = addCircle(50,1);
  BodyPolygon b = addBox(5*20,5*20,1);
  b.updateRadius();
  b.myColor = color(128,0,0);

  a.position.set(width/2-90,height/2);
  b.position.set(width/2+50,height/2);
  b.angle.set(0,0,radians(45));
  a.velocity.set(35,0);
  b.velocity.set(0,0);
}


void testRandomShapes() {
  println("testRandomShapes()");
  reset();
  
  for(int i=0;i<20;++i) {
    int dice = (int)random(1,20);
    if(i<8) {
      BodyCircle b = addCircle(random(5,30),1);
      b.position.set(random(width-b.radius*2)+b.radius,
                     random(height-b.radius*2)+b.radius);
    } else if(i<16) {
      BodyPolygon b = addBox(random(10,50),random(20,40),1);
      b.position.set(random(width-b.radius*2)+b.radius,
                     random(height-b.radius*2)+b.radius);
    } else {
      BodyPolygon b = addMeteor(random(25,30),random(30,40),1);
      b.position.set(random(width-b.radius*2)+b.radius,
                     random(height-b.radius*2)+b.radius);
    }
    Body b = bodies.get(bodies.size()-1); 
    b.velocity.set(random(50)-25,random(50)-25);
    b.angularV.z=random(-5,5);
  }
}

void testStackedBoxes() {
  reset();
  
  for(int i=0;i<6;++i) {
    BodyPolygon a = addBox(200+20*i,50,1);
    a.position.set(400,200+80*i);
  }
  gravity.set(0,9.8);
}

void testPinnedBoxes() {
  reset();
  
  BodyPolygon a = addBox(150,50,1);
  a.position.set(400+(150/2+10),400-20);
  PVector pinPoint = new PVector(400+20,400);
  constraints.add(new PinConstraint(a,a.worldToLocal(pinPoint),pinPoint));
    
  BodyPolygon b = addBox(150,50,1);
  b.position.set(400-(150/2+10),400-20);
  pinPoint = new PVector(400-40,400);
  constraints.add(new PinConstraint(b,b.worldToLocal(pinPoint),pinPoint));
  
  gravity.set(0,9.8);
}

void testHingedBoxes() {
  reset();
  
  BodyPolygon a = addBox(150,50,1);
  BodyPolygon b = addBox(150,50,1);
  
  a.position.set(400+(150/2+10),400-20);
  b.position.set(400-(150/2+10),400-20);

  PVector pinPoint = new PVector(400,400);
  constraints.add(new HingeConstraint(a,a.worldToLocal(pinPoint),b,b.worldToLocal(pinPoint)));
}


void testOneCircle() {
  reset();
  BodyCircle c = addCircle(100,1);
  c.position=new PVector(400,400);
}


void testOneBox() {
  reset();
  BodyPolygon c = addBox(50,400,1);
  c.position=new PVector(400,400);
}


BodyCircle addCircle(float r,float m) {
  BodyCircle b = new BodyCircle(r,m * PI * sq(r));
  bodies.add(b);
  return b;
}

BodyPolygon addBox(float w,float h,float m) {
  //println("addBox()");
  BodyPolygon b = new BodyPolygon();
  bodies.add(b);
  
  b.points.add(new PVector(-w/2,-h/2));
  b.points.add(new PVector( w/2,-h/2));
  b.points.add(new PVector( w/2, h/2));
  b.points.add(new PVector(-w/2, h/2));
  b.updateRadius();
  b.updateShape();
  b.computeMass(m);
    
  return b;
}

BodyPolygon addBox(PVector a,PVector b) {
  //println("addBox()");
  BodyPolygon box = addBox(b.x-a.x,b.y-a.y,1);
  box.position.set((a.x+b.x)/2,
                   (a.y+b.y)/2);
  return box;
}

BodyPolygon addMeteor(float rMin,float rMax,float m) {
  //println("addMeteor()");
  BodyPolygon b = new BodyPolygon();
  bodies.add(b);
  int count = (int)random(4,20);
  for(int i=0;i<count;++i) {
    float rad = PI*2*(float)i/(float)count;
    float d = random(rMin,rMax);
    b.points.add(new PVector(cos(rad)*d,sin(rad)*d));
  }
  b.updateRadius();
  b.updateShape();
  b.computeMass(m);

  return b;
}
