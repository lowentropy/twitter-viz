// Pretty much the central class, it represents people on
// twitter as pulsing colored circles.
//
// The outside radius indicates the total followers and friends,
// while the inside radius indicates just the number of friends.
//
// The larger the colored ring, the more this person is a
// "source" as opposed to a "sink".
//
// You can hover over a person to see their biographical info,
// or click them to see their tweets.
public class Person implements Comparable
{
  // twitter variables
  String twitter_id;
  String user;
  String name;
  String bio;
  PImage pic;
  int num_friends;
  int num_followers;
  URL pic_url;
  Status[] tweets;
  String status;
  
  // keeping track of best buds
  String[] friends;
  Person[] max_friends;
  Link[] links;
  Map str_map;
  
  // internal use
  color inner_color;
  color outer_color;
  boolean expanded = false;
  float fresh = 0;
  float sort_val;

  // statistics
  float posts_per_day;
  float beat_period;
  float beat_time = 0;
  
  // graphical controls
  boolean selected;
  boolean hovered;
  
  // circle radii
  float x = viz.screen_size/2, y = viz.screen_size/2;
  float inner_radius = 20;
  float outer_radius = 50;
  float anim_inner_radius;
  float anim_outer_radius;
  
  
  // Construct person by looking up all their info 
  public Person(String id_or_name) throws TwitterException
  {
    this(twitter.getUserDetail(id_or_name));
  }
  
  // Construct person from known info
  public Person(ExtendedUser user) throws TwitterException
  {
    this.user = user.getScreenName().toLowerCase();
    this.name = user.getName();
    this.bio = user.getDescription();
    this.num_followers = user.getFollowersCount();
    this.num_friends = user.getFriendsCount();
    this.twitter_id = Integer.toString(user.getId());
    this.posts_per_day = ((float) user.getStatusesCount())
                       / viz.days_since(user.getCreatedAt());
    this.beat_period = viz.beat_time_scale / this.posts_per_day;
    this.pic_url = user.getProfileImageURL();
    this.pic = loadImage(this.pic_url.toString());
    this.status = user.getStatusText();
    find_radii();
    outer_color = viz.next_color();
    inner_color = color(255,255,255);
  }
  
  // gets the latest 100 tweets, so we can search for links
  void get_tweets() throws TwitterException
  {
    Paging p = new Paging(1,100);
    java.util.List statuses = twitter.getUserTimeline(this.user, p);
    tweets = new Status[statuses.size()];
    for (int i = 0; i < tweets.length; i++)
      tweets[i] = (Status) statuses.get(i);
  }
  
  // query twitter to get the names of all our friends
  void get_friends() throws TwitterException
  {
    java.util.List friends = twitter.getFriends(this.user);
    this.friends = new String[friends.size()];
    for (int i = 0; i < friends.size(); i++)
      this.friends[i] = ((User) friends.get(i)).getScreenName();
  }
  
  // this is the meaty part. search tweets for references to
  // people, and count them to determine the link strength.
  // then put them into +str_map+.
  void get_link_strengths() throws TwitterException
  {
    int found = 0;
    java.util.Map days_map = new java.util.HashMap();
    str_map = new HashMap();
    
    for (int i = 0; i < tweets.length; i++)
    {
      Matcher m = rtpat.matcher(tweets[i].getText());
      if (!m.find()) continue;
      String n = m.group().substring(1).toLowerCase();
      
      if (str_map.containsKey(n))
      {
        float num = ((Float) str_map.get(n)).floatValue();
        str_map.put(n, num + 1.0);
      } else {
        str_map.put(n, 1.0);
        days_map.put(n, viz.days_since(tweets[i].getCreatedAt()));
        found++;
      }
      
      if (found >= viz.max_friends)
        break;
    }
    
    for (Iterator i = str_map.keySet().iterator(); i.hasNext();)
    {
      String name = (String) i.next();
      float num = ((Float) str_map.get(name)).floatValue();
      int days = ((Integer) days_map.get(name)).intValue();
      float strength = 100 + num * 10 - days;
      str_map.put(name, strength);
      println(user + " -> " + name + " : " + strength);
    }
    
    println(user + ": " + found + " links tested");
  }
  
  // update time. this controls pulsing, hovering, and
  // the flashing inner circle.
  public void update(boolean do_sel)
  {
    beat_time += dt;
    boolean add_pulse = false;
    while (beat_time > beat_period)
    {
      beat_time -= beat_period;
      add_pulse = true;
    }
    anim_radius();
    try_hover();
    fresh -= dt * viz.burst_fade;
    if (fresh < 0)
      fresh = 0;
    if (do_sel)
      selected = hovered;
    if (add_pulse)
      pulse();
  }
  
  // draw the inner and outer circles
  public void draw()
  {
    float x = this.x + viz.cx;
    float y = this.y + viz.cy;
    // outer draw
    stroke(0,0,0);
    strokeWeight(1);
    fill(outer_color);
    float rad = anim_outer_radius;
    ellipse(x, y, rad, rad);
    // inner draw
    float r2 = anim_inner_radius;
    noStroke();
    fill(255,255,255);
    ellipse(x, y, r2, r2);
    fill(inner_color, fresh);
    ellipse(x, y, r2+1, r2+1);
    // outline
    if (selected)
    {
      stroke(0,0,0);
      strokeWeight(2);
      noFill();
      rad += 5;
      ellipse(x, y, rad, rad);
    }
  }

  // we pulsed, so send out bursts to our links  
  void pulse()
  {
    if (links == null)
      return;
    for (int i = 0; i < links.length; i++)
      links[i].pulse_from(this);
  }
  
  // draw the hovering biographical info
  public void draw_hover()
  {
    if (!hovered)
      return;
    
    stroke(0,0,0);
    strokeWeight(2);
    fill(#336699,200);
    
    int x = mouseX+10, y = mouseY;
    if (x + 250 > viz.screen_size)
      x = ((int) viz.screen_size) - 250;
    if (y + 115 > viz.screen_size)
      y = ((int) viz.screen_size) - 115;
      
    rect(x, y, 250, 115);
    fill(255,255,255);
    
    text(name, x+5, y+15);
    text("Bio: " + bio, x+5, y+30, 240, 80);
  }
  
  // draw a list of our tweets on the RHS of the screen
  public void draw_tweets()
  {
    if (!selected)
      return;
    
    if (tweets == null)
      return;
      
    int s = viz.screen_size;
    int w = viz.sidebar_size;
    
    noStroke();
    fill(255,255,255);
    rect(s,0,w,s);
    
    stroke(0,0,0);
    strokeWeight(2);
    line(s,0,s,s);
    
    image(pic, s+5, 5);

    fill(0,0,0);
    text(name, s+60, 42);
    
    int b = 60;
    int n = (s - 60) / 85;
    
    for (int i = 0; i < n; i++)
    {
      noStroke();
      fill(#336699, 50);
      rect(s+5, b, w-10, 80);
      Status tweet = tweets[i];
      String t = dates.format(tweet.getCreatedAt())
               + "\n" + tweet.getText();
      fill(0,0,0);
      text(t, s+10, b+5, w-20, 70);
      b += 85;
      
    }
  }

  // animate our radius, so that the circle appears to pulse  
  private void anim_radius()
  {
    float len = viz.beat_length;
    if (beat_period < len)
      len = beat_period;
    if (beat_time < len)
    {
      float scale = 1 + viz.beat_rad_scale * sin(beat_time * PI / len);
      anim_inner_radius = scale * inner_radius;
      anim_outer_radius = scale * outer_radius;
    }
  }
  
  // find the radii based on numbers of friends and followers
  void find_radii()
  {
    float sum = num_friends + num_followers;
    float area = sum * viz.area_scale;
    if (area > viz.max_area)
      area = viz.max_area;
    outer_radius = sqrt(area / PI);
    inner_radius = sqrt((num_friends / sum) * area / PI);
  }
  
  // determine if mouse is over teh circle
  void try_hover()
  {
    float dx = mouseX - x - viz.cx;
    float dy = mouseY - y - viz.cy;
    float d = sqrt(dx*dx + dy*dy);
    hovered = (d < outer_radius);
  }
  
  // look up our extended info, including link strengths
  public void get_info() throws TwitterException
  {
    get_friends();
    get_tweets();
    get_link_strengths();
  }  

  // pretty-print
  void print_details()
  {
    println("Name: " + name);
    println("Bio: " + bio);
    println("Status: " + status);
    println("Image: " + pic_url);
    println("F/F: " + num_friends + "/" + num_followers);
    println("PPD: " + posts_per_day);
    println("Beat L: " + beat_period);
    println("");
  }

  // recursive function to build the graph by expanding
  // our best friends.  
  void expand(int level, int remaining, float base_angle) throws TwitterException
  {
    if (expanded)
      return;
    expanded = true;

    println("INFO " + user);
    try {
      get_info();
    } catch (TwitterException e) {
      // probably a protected user
      return;
    }
     
    if (remaining == 0)
      return;
      
    println("EXPAND " + user);
      
    int n = viz.max_friends;
    if (n > num_friends)
      n = num_friends;
    
    Person[] tosort = new Person[str_map.size()];
    
    int j = 0;
    java.util.Set known = str_map.keySet();
    for (Iterator i = known.iterator(); i.hasNext();)
    {
      String name = (String) i.next();
      Person p = viz.get_person(name);
      if (p == null) continue;
      p.sort_val = -((Float) str_map.get(name)).floatValue();
      tosort[j++] = p;
    }
    
    // dang it
    Person[] fixed = new Person[j];
    for (int i = 0; i < j; i++)
      fixed[i] = tosort[i];
    tosort = fixed;
    
    Arrays.sort(tosort);
    max_friends = new Person[n];
    links = new Link[n];
    
    if (tosort.length >= n)
    {
      for (int i = 0; i < n; i++) {
        max_friends[i] = tosort[i];
        float s = ((Float) str_map.get(tosort[i].user)).floatValue();
        links[i] = viz.make_link(this, tosort[i], s, true, false);
      }
    } else {
      for (j = 0; j < tosort.length; j++)
      {
        max_friends[j] = tosort[j];
        if (str_map.get(tosort[j].user) == null)
          println("going to fail on: " + tosort[j].user);
        float s = ((Float) str_map.get(tosort[j].user)).floatValue();
        links[j] = viz.make_link(this, tosort[j], s, true, false);
      }
      for (int i = 0; j < n; j++, i++)
      {
        Person other = viz.get_person(friends[i]);
        if (other == null) continue;
        max_friends[j] = other;
        links[j] = viz.make_link(this, other, viz.default_strength, true, false);
      }
    }
    
    float range = TWO_PI / (((level - 1) * 1.5) + 1);
    float a = base_angle - range/2 + random(0.5) - 0.25;
    float aa = range/n;
    float r = viz.default_distance + outer_radius;
    for (int i = 0; i < n; i++)
    {
      max_friends[i].move_to(x+r*cos(a), y+r*sin(a));
      max_friends[i].expand(level + 1, remaining - 1, a);
      a += aa;
    }
  }
  
  // move the circle
  void move_to(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
  
  // comparison by +sort_val+, used to order by strength
  // of friendship
  int compareTo(Object o)
  {    
    Person p = (Person) o;
    if (sort_val < p.sort_val)
      return -1;
    else if (sort_val > p.sort_val)
      return 1;
    return 0;
  }
  
  // create a link to this other guy
  public Link link_to(Person other)
  {
    if (links == null)
      return null;
    for (int i = 0; i < links.length; i++)
      if (links[i].links(this, other))
        return links[i];
    return null;
  }
  
  // set our inner circle's color, which will fade back to white
  public void flash(color c)
  {
    inner_color = c;
    fresh = 255.0;
  }
  
  // add a link. this function is stupid, because links should
  // be a list. but it was late and i was tired.
  public void add_link(Link l)
  {
    if (links == null)
      links = new Link[0];
    Link[] new_links = new Link[links.length + 1];
    for (int i = 0; i < links.length; i++)
      new_links[i] = links[i];
    new_links[links.length] = l;
    links = new_links;
  }
  
  // make sure the given link is included. sometimes they
  // end up missing for some reason.
  public void ensure_link(Link l)
  {
    if (links == null)
      links = new Link[0];
    for (int i = 0; i < links.length; i++)
      if (links[i] == l)
        return;
    add_link(l);
  }
}
