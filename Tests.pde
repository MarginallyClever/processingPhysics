
void testOneBallAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  gravity.set(0,0);
  BodyCircle a = addCircle(40,5);  
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}

void testOneBoxAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  gravity.set(0,0);
  BodyPolygon a = addBox(30*4,20*4,15);
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}

void testTwoBoxes() {
  println("testTwoBoxes()");
  reset();
  bodies.clear();
  gravity.set(0,0);
  
  BodyPolygon a = addBox(30*4,20*4,5);
  BodyPolygon b = addBox(30*4,40*4,10);
  
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
  gravity.set(0,0);
  
  BodyCircle a = addCircle(15,5);
  BodyCircle b = addCircle(30,10);
  
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
  gravity.set(0,0);
  
  BodyCircle a = addCircle(50,10);
  BodyPolygon b = addBox(5*20,10*20,20);
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
  gravity.set(0,0);
  
  BodyCircle a = addCircle(50,10);
  BodyPolygon b = addBox(5*20,5*20,20);
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
  gravity.set(0,0);
  for(int i=0;i<20;++i) {
    int dice = (int)random(1,20);
    if(i<8) {
      BodyCircle b = addCircle(random(5,30),random(1,6));
      b.position.set(random(width-b.radius*2)+b.radius,
                     random(height-b.radius*2)+b.radius);
    } else if(i<16) {
      BodyPolygon b = addBox(random(10,50),random(20,40),random(2,8));
      b.position.set(random(width-b.radius*2)+b.radius,
                     random(height-b.radius*2)+b.radius);
    } else {
      BodyPolygon b = addMeteor(random(10,20),random(20,40),random(2,8));
      b.position.set(random(width-b.radius*2)+b.radius,
                     random(height-b.radius*2)+b.radius);
    }
    Body b = bodies.get(bodies.size()-1); 
    b.velocity.set(random(50)-25,random(50)-25);
    b.angularV.z=random(-5,5);
  }
}

void testRandomShapesWithGravity() {
  testRandomShapes();
  gravity.set(0,9.8);
}

void testStackedBoxes() {
  reset();
  gravity.set(0,9.8);
  
  //BodyPolygon a = addBox(200,50,10);
  BodyPolygon b = addBox(220,50,10);
  BodyPolygon c = addBox(240,50,10);
  //a.position.set(400,400);
  b.position.set(400,500);
  c.position.set(400,600);
}

BodyCircle addCircle(float r,float m) {
  BodyCircle b = new BodyCircle(r,m);
  bodies.add(b);
  return b;
}

BodyPolygon addBox(float w,float h,float m) {
  println("addBox()");
  BodyPolygon b = new BodyPolygon();
  bodies.add(b);
  
  b.points.add(new PVector(-w/2,-h/2));
  b.points.add(new PVector( w/2,-h/2));
  b.points.add(new PVector( w/2, h/2));
  b.points.add(new PVector(-w/2, h/2));
  b.updateRadius();
  b.updateShape();
  b.setMass(m);
    
  return b;
}

BodyPolygon addBox(PVector a,PVector b) {
  println("addBox()");
  BodyPolygon box = addBox(b.x-a.x,b.y-a.y,1);
  box.position.set((a.x+b.x)/2,
                   (a.y+b.y)/2);
  return box;
}

BodyPolygon addMeteor(float rMin,float rMax,float m) {
  println("addMeteor()");
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
  b.setMass(m);

  return b;
}
