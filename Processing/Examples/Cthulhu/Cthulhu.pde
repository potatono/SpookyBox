import processing.net.*;

PImage cthulhu;
PFont scaryFont;
int x = 450;
int y = 60;
int lines = 14;
String callofcthulhu[];
int offset = 0;
import com.nycresistor.processing.*;
SpookyBox mySpookyBox;

void displayLines() {
  // Actually, using global variables in here is kind of uncool. Ah well.
  for (int count = 0; count < lines; count++) {
     text(callofcthulhu[count+offset], x, y+(35*count));
  }
}

void setup() 
{
  frameRate(15);
  size(800, 600);
  background(0);
  scaryFont = loadFont("AmericanTypewriter-16.vlw");
  textFont(scaryFont, 16);
  /*
    Permission is granted to copy, distribute and/or modify this document under the terms of the 
    GNU Free Documentation License, Version 1.2 or any later version published by the Free Software Foundation; 
    with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. 
    A copy of the license is included in the section entitled "GNU Free Documentation License".
    http://commons.wikimedia.org/wiki/Image:Cthulhu_and_R%27lyeh.jpg
  */
  cthulhu = loadImage("cthulhu.jpg");
  // As of 2008, most works of H.P. Lovecraft are in the Public Domain: http://en.wikisource.org/wiki/The_Call_of_Cthulhu
  callofcthulhu = loadStrings("callofcthulhu.txt");
  displayLines();
  mySpookyBox = new SpookyBox(this, SpookyBox.NETWORK);
}

void draw() 
{ 
  /*
    The knobs change the color of the Great Old One
  */
  fill(255);
  /*
    Left buttons make the spooky story go backward
  */
  if (mySpookyBox.wasButton1() || mySpookyBox.wasButton3()){
    if ((offset - lines) >= 0) { 
      offset = offset - lines;
      background(0);
      displayLines();
    }
  }
  /*
    Right buttons make the spooky story go forward
  */
  if (mySpookyBox.wasButton2() || mySpookyBox.wasButton4()){
    if ((offset + lines) <= callofcthulhu.length) {
      offset = offset + lines;
      background(0);
      displayLines();
    }
  }
  
  float  r = 255 - mySpookyBox.getKnob1()/4;
  float  i = 255 - mySpookyBox.getKnob2()/4;
  float  j = 255 - mySpookyBox.getKnob3()/4;
  tint(r, i, j);
  image(cthulhu, 0, 0); // Ph�nglui mglw�nafh Cthulhu R�lyeh wgah�nagl fhtagn.

}
