// add .float is_bleeding; to defs.qc

void(vector org, vector vel, float damage) SpawnBlood;
void(string gibname, float dm) ThrowGib;
void(string gibname, float dm) ThrowHead;
void(vector dir, vector org, entity own) throw_blood_splat;

void() gibs_spray_blood =
{
        if(self.velocity != '0 0 0')
        {
                particle(self.origin,'0 0 0',75,10);
                particle(self.origin,'0 0 5',73,10);
                particle(self.origin,'0 0 5',69,10);
	
                self.think = gibs_spray_blood;  // make it so particles keep coming
                self.nextthink = time + 0.05;
        }
        else
        {
                // check to see if it's a head
                if((self.frame == 0) && (self.view_ofs == '0 0 8'))
                        self.nextthink = -1;
                else
                {
                        self.think = SUB_Remove;
                        self.nextthink = time + 60 + random()*10;
                }
        }
}

void() player_is_bleeding =
{
    particle(self.origin,'0 0 0',75,5);
    particle(self.origin,'0 0 5',73,2);
    particle(self.origin,'0 0 5',69,3);
}

float() crandom; //function prototype for crandom

//splat_think: Controls behavior of splats after they have hit the wall
void() splat_think =
{
        if ( (self.attack_finished <= time) ||
             (self.flags & FL_ONGROUND) )
        {
                remove(self); //remove if: time "runs out" or on ground
                return;
        }
        self.velocity_z = random()*-10; //splat slowly slides down walls, changing speed
        self.angles = vectoangles(self.velocity); //point in direction of movement
        self.nextthink = time + 0.2;
}

//splat_touch: Called(by the engine) when splats touch the world or an entity
//after being spawned
void() splat_touch =
{
        if ( (other != world) ||
             (pointcontents(self.origin) <= -3) ||
             (self.flags & FL_ONGROUND) )
        {
                remove(self); //remove if: didn't hit wall, in liquid, or on ground
                return;
        }

        self.velocity = self.avelocity = '0 0 0'; //stop moving and spinning
        self.movetype = MOVETYPE_FLY; //changed to remove effect of gravity
        self.touch = SUB_Null; //don't call this (touch) function again
        self.attack_finished = time + 4 + (2*random()); //set random "time limit"

        self.think = splat_think;
        self.nextthink = time + 0.2;
}

//throw_blood_splat: This will create a blood splat at "org", moving in
//direction "dir", and owned by "own"
void(vector dir, vector org, entity own) throw_blood_splat =
{
        local entity splat;
        //local vector dir;

        if ( !((own.flags & FL_MONSTER) ||
               (own.classname == "player")) )
                return; //only monsters and players should create splats!

        splat = spawn();
        splat.owner = own; //move through hit monster/player
        splat.movetype = MOVETYPE_TOSS; //gravity with no bouncing
        splat.solid = SOLID_BBOX; //does not move through other entities (besides owner)

        dir = normalize(dir); //make sure "dir" has length 1
        splat.velocity = dir * (450 + 50*random()); //random velocity in direction of shot
        splat.velocity_x = splat.velocity_x + crandom()*40; //randomize x velocity (+/- 40)
        splat.velocity_y = splat.velocity_y + crandom()*40; //randomize y velocity (+/- 40)
        splat.velocity_z = splat.velocity_z + 120 + 50*random(); //randomize z velocity (+ 120-170)
        splat.avelocity = '3000 1000 2000'; //spin fast!
        splat.touch = splat_touch;
	
        splat.nextthink = time + 2;
        splat.think = SUB_Remove;

        setmodel (splat, "progs/zom_gib.mdl");
        setsize (splat, '0 0 0', '0 0 0');     
        setorigin (splat, org); //start splat at point of damage
}

void() kick_touch = 
{
	local vector v;

	// only a player can kick it
	if (other.classname != "player")
		return;

	//randomize sound
	if (random()< 0.8)
		sound(other, CHAN_ITEM, "zombie/z_hit.wav", 1, ATTN_NORM);
	else
		sound(other, CHAN_ITEM, "zombie/z_miss.wav", 1, ATTN_NORM);

	//define velocity 
	//you can play with these formulas to adjust
	//trajectory
	v_x = (other.velocity_x*2+50*random());
	v_y = (other.velocity_y*2+50*random());
	v_z =250 + 160 * random()+(other.velocity_y+other.velocity_x)*0.30;

	self.flags = self.flags - ( self.flags & FL_ONGROUND );
	self.velocity = v;
}
