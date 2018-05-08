import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0; 
float proxSensorThreshold = 10; //you will need to change this per your device.
float accX;
float accY;
float accZ;

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;

PFont bold, reg;
boolean correctFlag = false;
boolean waitForChoose2 = false;

void setup() {
  size(540, 600, P2D); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);

  rectMode(CENTER);
  bold = createFont("Arial Bold", 60);
  reg = createFont("Arial", 40);
  
  textFont(reg); //sets the font to Arial size 20
  textAlign(CENTER);
  
  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey
  noStroke(); //no stroke

  countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 1) + " sec per target", width/2, 150);
    return;
  }

/**
 * Ellipses
  for (int i=0; i<4; i++)
  {
    if (targets.get(index).target==i)
      fill(0, 255, 0);
    else
      fill(180, 180, 180);
    ellipse(300, i*150+100, 100, 100);
  }
*/

  if (targets.get(index).action==0)
  {
    if (correctFlag) { 
      fill(0,255,0);
    } else {
      fill(100);
    }
    rect(width/2,120,width,height/2);
    fill(255);
    text("UP", width/2, height/2);
  }
  else {
    if (correctFlag) { 
      fill(0,255,0);
    } else {
      fill(100);
    }
    rect(width/2,160+height/2,width,height/2);
    fill(255);
    text("DOWN", width/2, height/2);
  }
  
  fill(255, 0, 0);
  ellipse(cursorX, cursorY, 50, 50);

  fill(150);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  //text("Target #" + (targets.get(index).target)+1, width/2, 100);
  
  int num = targets.get(index).target;
  
  switch(num) {
  case 0: 
    if (!correctFlag) {
      fill(0,255,0);
      textFont(bold); 
    }
    text("OUT",  width/2, 100);
    fill(255);
    textFont(reg);
    text("IN",  width/2, 580);
    text("LEFT",  60, height/2);
    text("RIGHT",  480, height/2);
    break;
  case 1: 
    if (!correctFlag) {
      fill(0,255,0);
      textFont(bold); 
    }
    text("IN",  width/2, 580);
    fill(255);
    textFont(reg);
    text("OUT",  width/2, 100);
    text("LEFT",  60, height/2);
    text("RIGHT",  480, height/2);
    break;
  case 2:
    if (!correctFlag) {
      fill(0,255,0);
      textFont(bold); 
    }
    text("LEFT",  60, height/2);
    fill(255);
    textFont(reg);
    text("OUT",  width/2, 100);
    text("IN",  width/2, 580);
    text("RIGHT",  480, height/2);
    break;
  case 3:
    if (!correctFlag) {
      fill(0,255,0);
      textFont(bold); 
    }
    text("RIGHT",  480, height/2);
    fill(255);
    textFont(reg);
    text("OUT",  width/2, 100);
    text("IN",  width/2, 580);
    text("LEFT",  60, height/2);
    break;
  }

}

boolean isCorrect(Target t, float x, float y) {
  return (t.target == 0 && y > 3) ||
        (t.target == 1 && y < -3) ||
        (t.target == 2 && x < -3) ||
        (t.target == 3 && x > 3);
}

void onAccelerometerEvent(float x, float y, float z)
{
  int index = trialIndex;
  accX = x;
  accY = y;
  accZ = z;

  if (userDone || index>=targets.size())
    return;

  cursorX = 300+x*40; //cented to window and scaled
  cursorY = 300-y*40; //cented to window and scaled
  println("x: " + (x) + "    y: " + (y) + "    z: " + (z-9.8));

  Target t = targets.get(index);

  if (t==null)
    return;
    
  print(isCorrect(t,x,y));
  
  if(isCorrect(t,x,y)) 
    correctFlag = true;
 
  // if correct initial choose 4 direction, then check for up/down is correct.
  if (countDownTimerWait < 0 && isCorrect(t,x,y)) {
    print("Enter first check");
    correctFlag = true;
    countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
    waitForChoose2 = true;
  } else if (!waitForChoose2 && countDownTimerWait < 0 && 
        (((t.target == 0 || t.target ==1) && abs(y) > 3) ||
        ((t.target == 2 || t.target == 3) && abs(x) > 3))) { 
    println("wrong round 1 action!"); 

    if (trialIndex>0)
      trialIndex--; //move back one trial as penalty!
    correctFlag = false;
    countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  } 
  
  //Check if correct motion UP/DOWN
  print("ZZZ:  " + correctFlag);
  if (countDownTimerWait < 0 && correctFlag) {
    print("Enter z!!!");
    if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1)) {
      println("Right target, right z direction!");
      correctFlag = false;
      countDownTimerWait = 60;
      trialIndex++; //next trial!
    } else if (((z-9.8)<-4 && t.action==0) || ((z-9.8)>4 && t.action==1)) {
      correctFlag = false;
      println("right target, WRONG z direction!");
    }
  }
}



 /*
  if (light<=proxSensorThreshold && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  {
    if (hitTest()==t.target)//check if it is the right target
    {
      //println(z-9.8); use this to check z output!
      if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1))
      {
        println("Right target, right z direction!");
        trialIndex++; //next trial!
      } else
      {
        if (trialIndex>0)
          trialIndex--; //move back one trial as penalty!
        println("right target, WRONG z direction!");
      }
      countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
    } 
  } else if (light<=proxSensorThreshold && countDownTimerWait<0 && hitTest()!=t.target)
  { 
    println("wrong round 1 action!"); 

    if (trialIndex>0)
      trialIndex--; //move back one trial as penalty!

    countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  }
}


int hitTest() 
{
  for (int i=0; i<4; i++)
    if (dist(300, i*150+100, cursorX, cursorY)<100)
      return i;

  return -1;
}
*/

/*
void onLightEvent(float v) //this just updates the light value
{
  light = v;
}
*/
