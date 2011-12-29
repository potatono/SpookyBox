import processing.net.*;

/* Paranoids for Spooky Box Version 1.2
 * By Jacob Joaquin
 *
 * jacobjoaquin@gmail.com
 * Thumbuki  http://www.thumbuki.com/
 *
 * Copyright (C) 2008 Jacob Joaquin
 * License: GNU LESSER GENERAL PUBLIC LICENSE
 *     http://www.gnu.org/licenses/lgpl.txt
 *
 *
 * Tested with Processing 0135 Beta.
 */


import com.nycresistor.processing.*;

Paranoid myParanoid;
SpookyBox mySpookyBox;
boolean button1LastValue;
boolean button2LastValue;
boolean button3LastValue;
boolean button4LastValue;

color[] palette = new color[5];
static final int COLOR_MODE_STATIC = 0;
static final int COLOR_MODE_FLOW = 1;
static final int COLOR_MODE_RANDOM = 2;
int paranoidColorMode = 0;
int colorStaticCounter = 0;
int colorFlowCounter = 0;


static final int ELLIPSE_MODE_STATIC = 0;
static final int ELLIPSE_MODE_RANDOM = 1;
int paranoidEllipseMode = 0;

int paranoidScale = 0;

void setup() {
  size(800, 600);
  smooth();
  // noLoop();
  mySpookyBox = new SpookyBox(this, SpookyBox.NETWORK);
palette[0] = #ff0000;
palette[1] = #ff8888;
palette[2] = #ff8800;
palette[3] = #ff0088;
palette[4] = #880000;
  myParanoid = new Paranoid();

  button1LastValue = false;
  button2LastValue = false;
  button3LastValue = false;
  button4LastValue = false;
}

void draw() {

  // Check for Paranoid Update based on button press
  if (mySpookyBox.isButton1()) {
    if (button1LastValue == false) {
      button1LastValue = true;
      myParanoid = new Paranoid();
    }  
  } 
  else {
    button1LastValue = false;
  }

  // Change Color Mode
  if (mySpookyBox.isButton2()) {
    if (button2LastValue == false) {
      button2LastValue = true;
      paranoidColorMode++;
      paranoidColorMode %= 3;
    }  
  } 
  else {
    button2LastValue = false;
  }

  // Cycle Ellipse Mode
  if (mySpookyBox.isButton3()) {
    if (button3LastValue == false) {
      button3LastValue = true;
      paranoidEllipseMode++;
      paranoidEllipseMode %= 2;
    }  
  } 
  else {
    button3LastValue = false;
  }

  if (mySpookyBox.isButton4()) {
    if (button4LastValue == false) {
      button4LastValue = true;
      paranoidScale++;
      paranoidScale %= 4;
    }  
  } 
  else {
    button4LastValue = false;
  }



  // Update mode color mode
  colorStaticCounter = 0;

  // Draw scene
  background(0);
  myParanoid.draw((float)width / 2.0, (float)height / 2.0);    
}

color shiftHue(color c, float shift) {
  float red = red(c);
  float green = green(c);
  float blue = blue(c);

  float red1 = 0;
  float green1 = 0;
  float blue1 = 0;

  if (shift < 0.333) {
    float shift1 = shift * 3;
    red1 = red * (1 - shift1) + green * shift1;
    green1 = green * (1 - shift1) + blue * shift1;
    blue1 = blue * (1 - shift1) + red * shift1;
  } 
  else if (shift < 0.666) {
    float shift1 = (0.666 - shift) * 3;
    blue1 = green * (1 - shift1) + red * shift1;
    red1 = blue * (1 - shift1) + green * shift1;
    green1 = red * (1 - shift1) + blue * shift1;
  } 
  else {
    float shift1 = (1 - shift) * 3;
    green1 = green * (1 - shift1) + red * shift1;
    blue1 = blue * (1 - shift1) + green * shift1;
    red1 = red * (1 - shift1) + blue * shift1;
  }

  return color(red1, green1, blue1, alpha(c));
}





class MySphere {
  float x;
  float y;
  float z;
  float diameter;

  MySphere(float thisX, float thisY, float thisZ, float s) {
    x = thisX;
    y = thisY;
    z = thisZ;
    diameter = s;
  }

  float getX() {
    return x;
  }

  float getY() {
    return y;
  }

  float getZ() {
    return z;
  }

  float getDiameter() {
    return diameter;
  }

  void setX(float thisX) {
    x = thisX;
  }

  void setY(float thisY) {
    y = thisY;
  }

  void setZ(float thisZ) {
    z = thisZ;
  }

  void setDiameter(float d) {
    diameter = d; 
  }
}





class Paranoid {
  private final static int MAX_SPHERES = 200;
  ArrayList spheres;
  float colorHue = 0;

  Paranoid() {
    spheres = new ArrayList();
    generateParanoid(0, 0, 3, 30, 0.1, 0, PI, 40);
    center();

    colorHue = random(1);
  }

  void generateParanoid(float x, float y, float min, float max, float odds, float lastAngle, float spread, int nLimbs) {
    float angle = ((random(1) - 0.5) * spread) + lastAngle;
    float length = (random(1) * (max - min) + min);
    float x1 = (cos(angle) * length) + x;
    float y1 = (sin(angle) * length) + y;
    float zRandom = random(120) - 60;

    spheres.add(new MySphere((x1 + x) * 0.5, (y1 + y) * 0.5, zRandom, length * 0.4));

    if (nLimbs >= 1 && spheres.size() < MAX_SPHERES) {
      generateParanoid(x1, y1, min, max, odds, angle, spread, nLimbs - 1);

      if (random(1) < odds) {
        generateParanoid(x1, y1, min, max, odds, angle, spread, nLimbs - 1);
      }
    }
  }

  void draw(float x, float y) {
    int nSpheres = spheres.size();

    for (int i = 0; i < nSpheres; i++) {
      MySphere thisSphere = (MySphere) spheres.get(i);
      color c = palette[(int) random(5)];

      drawSphere(x + thisSphere.getX(), thisSphere.getY() + y, thisSphere.getZ(), thisSphere.getDiameter(), c);
      drawSphere(x - thisSphere.getX(), thisSphere.getY() + y, thisSphere.getZ(), thisSphere.getDiameter(), c);
    }
  }

  void center() {
    int nSpheres = spheres.size();
    float difference = (getHighestY() + getLowestY()) / 2.0;

    for (int i = 0; i < nSpheres; i++) {
      MySphere thisSphere = (MySphere) spheres.get(i);

      thisSphere.setY(thisSphere.getY() - difference);
    }

  }

  float getHighestY() {
    float distance = 0;
    int nSpheres = spheres.size();

    for (int i = 0; i < nSpheres; i++) {
      MySphere thisSphere = (MySphere) spheres.get(i);

      if (distance < thisSphere.getY()) {
        distance = thisSphere.getY();
      }
    }

    return distance;
  }

  float getLowestY() {
    float distance = 0;
    int nSpheres = spheres.size();

    for (int i = 0; i < nSpheres; i++) {
      MySphere thisSphere = (MySphere) spheres.get(i);

      if (distance > thisSphere.getY()) {
        distance = thisSphere.getY();
      }
    }

    return distance;
  }

  void drawSphere(float x, float y, float z, float diameter, color c) {

    color c1 = 255;
    color c2 = 255;
    float knob3 = 0;

    switch(paranoidColorMode) {
    case COLOR_MODE_STATIC:
      c1 = palette[colorStaticCounter];
      colorStaticCounter++;
      colorStaticCounter %= 5;
      c2 = palette[colorStaticCounter];
      knob3 = mySpookyBox.getKnob3() / 1024.0;

      c1 = shiftHue(c1, knob3);
      c2 = shiftHue(c2, knob3);
      break;

    case COLOR_MODE_FLOW:
      c1 = palette[colorFlowCounter];
      colorFlowCounter++;
      colorFlowCounter %= 5;
      c2 = palette[colorFlowCounter];
      knob3 = mySpookyBox.getKnob3() / 1024.0;

      c1 = shiftHue(c1, knob3);
      c2 = shiftHue(c2, knob3);
      break;

    case COLOR_MODE_RANDOM:
      c1 = palette[(int) random(5)];
      c2 = palette[(int) random(5)];
      knob3 = mySpookyBox.getKnob3() / 1024.0;

      c1 = shiftHue(c1, knob3);
      c2 = shiftHue(c2, knob3);

      break;
    }

    fill(c1, mySpookyBox.getKnob2() / 1024.0 * 240.0 + 15);
    stroke(c2, mySpookyBox.getKnob1() / 1024.0 * 255.0);

    float eh = 3;
    float ev = 30;

    switch (paranoidEllipseMode) {
    case ELLIPSE_MODE_STATIC:
      eh = 3;
      ev = 30;
      break;

    case ELLIPSE_MODE_RANDOM:
      eh = random(3);
      ev = random(30);

      break;
    }

    float thisScale = pow(2, paranoidScale + 1) / 8 + 1;

    ellipse(x, y, eh, ev * thisScale);
    ellipse(x, y, diameter * thisScale, diameter * thisScale);
  }
}

