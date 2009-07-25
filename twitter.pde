// global variables are bad but they're soooo good

String api_user = "USERNAME";
String api_password = "PASSWORD";
String ego_user = "USERNAME";

float time = 0;
float dt = 0;
long MILLIS_IN_DAY = 1000 * 60 * 60 * 24;

Viz viz;
import twitter4j.*;
Twitter twitter;

PFont droid;
DateFormat dates;
Date today;

Pattern rtpat = Pattern.compile("@[a-zA-Z0-9_]+");

void setup()
{
  try
  {
    loadFonts();
    
    size(750, 500);
    frameRate(30);
    textFont(droid);
    ellipseMode(RADIUS);
    strokeCap(SQUARE);
    
    dates = new SimpleDateFormat("EEE, MMM d, hh:mm aaa");
    today = new Date();  

    // note: the API will fail pretty hard if you have a rate
    // limit cap. if you are nice they will lift it.
    twitter = new Twitter(api_user, api_password);
    viz = new Viz(500, 250);
    println("REMAINING: " + twitter.rateLimitStatus().getRemainingHits());
    viz.set_ego(ego_user);
    viz.add_remaining_links();    
  } catch (TwitterException e) {    
    println("fail whale!");
    println(e.getMessage());
    println(e.getStackTrace());
  }
}

void draw()
{
  background(255,255,255);
  calc_dt();
  viz.update();
  viz.draw();
}

void calc_dt()
{
  float now = ((float) millis()) / 1000;
  if (time != 0)
    dt = now - time;
  time = now;
}

void loadFonts()
{
  droid = loadFont("DroidSansMono-12.vlw");
}

void mousePressed()
{
  viz.start_drag();
}

void mouseDragged()
{
  viz.drag();
}

void mouseReleased()
{
  viz.stop_drag();
}
