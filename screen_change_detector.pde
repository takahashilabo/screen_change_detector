import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.awt.Toolkit;
import java.awt.image.BufferedImage;
import java.awt.Robot;
import java.awt.Rectangle;
import java.awt.AWTException;

//パラメタ
int TOP = 500; //検出する窓
int LEFT = 1500;
int W = 400;
int H = 300;
float D = 0.2; //無視する前回今回の平均輝度差
String SOUND_FILENAME = "46.mp3";

Minim minim;
AudioPlayer sound;

void setup() {
  surface.setResizable(true);
  surface.setSize(W, H);
  frameRate(1);
  loadParam();
  minim = new Minim(this);
  sound = minim.loadFile(SOUND_FILENAME);
}

void loadParam() {
  JSONObject json = loadJSONObject("param.json");
  TOP = json.getInt("TOP");
  LEFT = json.getInt("LEFT");
  W = json.getInt("W");
  H = json.getInt("H");
  D = json.getFloat("D");
  SOUND_FILENAME = json.getString("SOUND_FILENAME");
  surface.setSize(W, H);
}

float pre_b = 0;
float b_diff = 0;

boolean detectMotion(PImage img) {
  img.updatePixels();
  float b = 0;
  for (int i=0; i<W*H; i++) {
    b += brightness(img.pixels[i]);
  }
  b /= (W*H);
  b_diff = abs(pre_b - b);
  boolean ret = (b_diff > D);
  pre_b = b;
  
  return ret;
}

void draw() {
  Robot robot;
  try {
    robot = new Robot();
  } 
  catch (AWTException e) {
    return;
  }

  BufferedImage a = robot.createScreenCapture(new Rectangle(LEFT, TOP, W, H));
  PImage pimg = new PImage(a);
  image(pimg, 0, 0);
  text(b_diff, 0, 10);
  if (detectMotion(pimg)) {
    sound.rewind();
    sound.play();
  }
}
