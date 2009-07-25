// controls the global behavior of the visualization.
public class Viz
{
  // controls size of screen areas
  public int screen_size;
  public int sidebar_size;
  
  // controls distribution of graph
  public int max_friends = 2;
  public int max_depth = 2;

  // controls how num friends/followers creates area
  public float max_area = 10000; // max rad ~ 56
  public float area_scale = 10; // 1 follower = 10 area ~ 1.8 rad
  
  // controls the look and timing of "heartbeats"
  public float beat_rad_scale = 0.1; // 10% of primary radius
  public float beat_time_scale = 10; // 1 bps = 10 ppd
  public float beat_length = 0.5; // 0.5 sec pulse
  
  // controls the width of links
  public float width_scale = 3.0;
  public float default_strength = 20.0;
  public float default_distance = 90.0;
  
  // controls the appearance of bursts
  public float burst_speed = 0.7;
  public float burst_radius = 5.0;
  public float burst_fade = 300.0;
  
  // list of colors for circles
  color[] colors = new color[] {#444455, #0000ee, #11dd00, #dd2200};
  int color_index = 0;
  
  // the center of the network
  Person ego;
  java.util.List people;
  java.util.List links;
  java.util.Map people_map;

  // pan control
  boolean dragging = false;
  int mx, my;
  int cx = 0, cy = 0;  

  // construct the screen  
  public Viz(int screen_size, int sidebar_size)
  {
    this.screen_size = screen_size;
    this.sidebar_size = sidebar_size;
    people = new java.util.ArrayList();
    links = new java.util.ArrayList();
    people_map = new java.util.HashMap();
  }
  
  // set the universe's center
  public void set_ego(String id) throws TwitterException
  {
    set_ego(new Person(id));
  }
  
  // chooses colors in rotation
  public color next_color()
  {
    color c = colors[color_index];
    color_index = (color_index + 1) % colors.length;
    return c;
  }
  
  // sets the central twitter user, and expands outwards
  public void set_ego(Person p) throws TwitterException
  {
    ego = p;
    ego.selected = true;
    ego.x = screen_size / 2;
    ego.y = screen_size / 2;
    add_person(ego);
    
    ego.expand(1, max_depth, 0);
  }
  
  // the nodes added recursively probably have links to each
  // other as well. so search all combinations and add those
  // links in.  
  public void add_remaining_links()
  {
    for (int i = 0; i < people.size(); i++)
    {
      Person a = (Person) people.get(i);
      for (int j = 0; j < people.size(); j++)
      {
        if (i == j)
          continue;
        Person b = (Person) people.get(j);
        for (int k = 0; k < a.friends.length; k++)
          if (a.friends[k].toLowerCase().equals(b.user))
            make_link(a, b, 10, false, true);
      }
    }
    
    for (Iterator i = links.iterator(); i.hasNext();)
    {
      Link l = (Link) i.next();
      l.people[0].ensure_link(l);
      l.people[1].ensure_link(l);
    }
  }

  // get person by name. all people are stored in a global hash.  
  public Person get_person(String name)
  {
    name = name.toLowerCase();
    Object o = people_map.get(name);
    if (o != null)
      return (Person) o;
    try {
      Person p = new Person(name);
      add_person(p);
      return p;
    } catch (TwitterException e) {
      return null;
    }
  }

  // add person to global hash  
  public void add_person(Person p)
  {
    people.add(p);
    people_map.put(p.user, p);
  }
  
  // add link to global list (for rendering)
  public void add_link(Link l)
  {
    links.add(l);
  }
  
  // create a link between the given people. has some extra
  // parameters to control what happens when the link is already
  // found.
  public Link make_link(Person a, Person b, float strength, boolean addit, boolean post_add)
  {
    for (Iterator i = links.iterator(); i.hasNext();)
    {
      Link l = (Link) i.next();
      if (l.links(a, b))
      {
        if (addit)
          l.add_strength(strength);
        l.follows[0] = true;
        return l;
      }
    }
    Link l = new Link(a, b, strength);
    l.follows[0] = true;
    add_link(l);
    if (post_add)
    {
      a.add_link(l);
      b.add_link(l);
    }
    return l;
  }

  // time update  
  public void update()
  {
    for (int i = 0; i < people.size(); i++)
      ((Person) people.get(i)).update(mousePressed);
    for (int i = 0; i < links.size(); i++)
      ((Link) links.get(i)).update();
  }
  
  // draw the entire viz
  public void draw()
  {
    for (int i = 0; i < links.size(); i++)
      ((Link) links.get(i)).draw();
    for (int i = 0; i < people.size(); i++)
      ((Person) people.get(i)).draw();
    for (int i = 0; i < people.size(); i++)      
      ((Person) people.get(i)).draw_hover();
    for (int i = 0; i < people.size(); i++)      
      ((Person) people.get(i)).draw_tweets();    
  }

  // helper function, finding f.p. days since the given
  // date. keep in mind that processing's +millis+ is
  // different that System.getCurrentTimeMillis.
  public int days_since(Date date)
  {
    long diff = today.getTime() - date.getTime();
    return ((int) (diff / MILLIS_IN_DAY));
  }
  
  // start dragging the screen, record initial mouse position
  public void start_drag()
  {
    mx = mouseX;
    my = mouseY;
    dragging = true;
  }
  
  // drag the dang screen
  public void drag()
  {
    if (dragging)
    {
      int dx = mouseX - mx;
      int dy = mouseY - my;
      mx = mouseX;
      my = mouseY;
      pan(dx, dy);
    }
  }

  // no more drag
  public void stop_drag()
  {
    dragging = false;
  }

  // pan the screen, like a multitouch interface.
  void pan(int dx, int dy)
  {
    cx += dx;
    cy += dy;
  }
}
