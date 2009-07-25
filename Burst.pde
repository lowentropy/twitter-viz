// Bursts are sent out by pulsing nodes.
// They indicate "traffic" on the twitter network.
public class Burst
{
  // link burst is travelling on
  Link link;
  
  // which side did we start on? 0/1
  int side;
  
  // current fractional position
  float pos;
  
  // direction of travel +/- 1
  float dir;
  
  // color is same as source node
  color dot_color;
  
  // constructor
  public Burst(Link link, int side, color dot_color)
  {
    this.link = link;
    this.side = side;
    this.dot_color = dot_color;
    this.pos = side;
    this.dir = (side > 0) ? -1.0 : 1.0;
  }
  
  // travel along the link
  public void update()
  {
    pos += dt * viz.burst_speed * dir;
    if ((side == 0 && pos > 1) || (side == 1 && pos < 0)) {
      // if we arrive at other end, flash the target node
      // and remove ourselves from the link
      link.people[1-side].flash(dot_color);
      link.remove_burst(this);
    }
  }
  
  // draw a small colored circle
  public void draw()
  {
    float x1 = link.people[0].x + viz.cx;
    float y1 = link.people[0].y + viz.cy;
    float x2 = link.people[1].x + viz.cx;
    float y2 = link.people[1].y + viz.cy;
    float x = x1 * (1-pos) + x2 * pos;
    float y = y1 * (1-pos) + y2 * pos;
    
    noStroke();
    fill(dot_color);
    float r = viz.burst_radius;
    ellipse(x, y, r, r);
  }
}
