// A link is a relationship between two twitter users.
// We estimate its strength by how recently and often
// they've communicated.
public class Link
{
  // two people linked
  Person[] people;
  
  // whether given person follows the other one
  boolean[] follows;
  
  // strength of the link, 0-inf.
  float strength;
  
  // width of the link in pixels
  float width;
  
  // bursts on the link
  java.util.List bursts;
  
  // to avoid angering java
  java.util.List to_remove;
  
  
  // construct link between these people
  public Link(Person a, Person b, float strength)
  {
    this.people = new Person[] {a, b};
    this.follows = new boolean[] {false, false};
    bursts = new java.util.LinkedList();
    to_remove = new java.util.LinkedList();
    this.strength = strength;
    calc_width();
  }
  
  // draw the link as a semi-transparent line
  void draw()
  {
    float x1 = people[0].x + viz.cx;
    float y1 = people[0].y + viz.cy;
    float x2 = people[1].x + viz.cx;
    float y2 = people[1].y + viz.cy;
    float r1 = people[0].anim_outer_radius;
    float r2 = people[1].anim_outer_radius;
    float a = atan2(y2-y1, x2-x1);
    float w = this.width;
    if (w > r1*1.5) w = r1*1.5;
    if (w > r2*1.5) w = r2*1.5;
    
    // this defunct code was supposed to draw arrows for
    // following indication, but it never quite worked.
    
/*    float t = w;    
    float cx1, cy1, cx2, cy2;
    
    noStroke();
    fill(0, 0, 0, 100);
    
    if (follows[0])
    {
      cx1 = x1 + (r1 + this.width) * cos(a) + 1;
      cy1 = y1 + (r1 + this.width) * sin(a) + 1;
      pushMatrix();
      translate(cx1, cy1);
      rotate(a + PI);
      draw_triangle(w, t);
      popMatrix();
    } else {
      cx1 = x1;
      cy1 = y1;
    }
    
    if (follows[1])
    {
      cx2 = x2 - (r2 + this.width) * cos(a) + 1;
      cy2 = y2 - (r2 + this.width) * sin(a) + 1;
      pushMatrix();
      translate(cx2, cy2);
      rotate(a);
      draw_triangle(w, t);
      popMatrix();
    } else {
      cx2 = x2;
      cy2 = y2;
    }
    */
    stroke(0, 0, 0, 100);
    strokeWeight(w);
    //line(cx1, cy1, cx2, cy2);
    line(x1,y1,x2,y2);
    draw_bursts();
  }
  
  // draw all bursts at once
  void draw_bursts()
  {
    for (Iterator i = bursts.iterator(); i.hasNext();)
      ((Burst) i.next()).draw();
  }
  
  // defunct, for arrows
  void draw_triangle(float w, float h)
  {
    triangle(0, h, w, 0, 0, -h);
  }
  
  // are people a and b linked by this object?
  public boolean links(Person a, Person b)
  {
    if (people[0] == a && people[1] == b)
      return true;
    if (people[1] == a && people[0] == b)
      return true;
    return false;
  }
  
  // increase strength and recalculate
  public void add_strength(float diff)
  {
    this.strength += diff;
    calc_width();
  }
  
  // width of line is log of strength.
  void calc_width()
  {
    this.width = viz.width_scale * log(strength);
    println("link: " + strength + " -> " + this.width); // DEBUG
  }
  
  // add a burst from the given person
  void pulse_from(Person p)
  {
    int i = (p == people[0]) ? 0 : 1;
    if (!follows[1-i]) return;
    bursts.add(new Burst(this, i, p.outer_color));
  }
  
  // update time.
  void update()
  {
    for (Iterator i = bursts.iterator(); i.hasNext();)
      ((Burst) i.next()).update();
    for (Iterator i = to_remove.iterator(); i.hasNext();)
      bursts.remove(i.next());
    // because iterators are touchy
    to_remove.clear();
  }
 
  // remove the burst from the link
  void remove_burst(Burst b)
  {
    to_remove.add(b);
  }
}
