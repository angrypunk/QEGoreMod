// angrypunk's killing sprees v1.1
//
// to use:
//
// add killspree.qc to progs.src, after defs.qc but before client.qc
//
// add hookpoints to client.qc:
//
// at top of CheckRules=
// check_if_killspree(self);
//
// at top of ClientObituary =
// check_if_end_killspree(attacker, targ);
//
// this file is public domain, use it as you see fit
// attribution is appreciated but not required

.float prev_frags;  
.float is_on_spree;

void(entity client, string s, string s) announce_start_spree = #73;
void(entity client, string s, string s, string s, string s) announce_end_spree = #73;
void(entity client, string s, string s) announce_end_spree2 = #73;

entity(entity start) find_player =
{
    return find(start,classname,"player");
}

void(entity attacker, entity targ) announce_end_killspree =
{
    local entity p = world;
    while((p = find_player(p))) 
    {
        
        if (attacker.netname == targ.netname) { announce_end_spree2(p,attacker.netname, " ended their own killing spree!"); }
        else
        {
            // sometimes this seems to be empty, so lets check?
            if (attacker.netname) { announce_end_spree(p,attacker.netname," ended ", targ.netname,"'s killing spree!\n"); }
            else { announce_end_spree2(p,targ.netname,"'s killing spree was ended.\n"); }  
        }
    }
}

void(entity player) check_if_killspree =
{
    local entity p = world;
	local float current_streak;
	current_streak = player.frags - player.prev_frags;

    if (current_streak == 3 && player.is_on_spree != 1)
    { 
		player.is_on_spree = 1;
        while((p = find_player(p))) { announce_start_spree(p,player.netname," is on a killing spree!\n"); }  
    }	
    else if (current_streak == 6 && player.is_on_spree == 1)
    {	
        player.is_on_spree = 2;
        while((p = find_player(p))) { announce_start_spree(p,player.netname," is on a killing frenzy!\n"); }  
	}	
    else if (current_streak == 9 && player.is_on_spree == 2)
    {
        player.is_on_spree = 3;
        while((p = find_player(p))) { announce_start_spree(p,player.netname," is on a killing rampage!\n"); }  
	}
    else if (current_streak == 12 && player.is_on_spree == 3)
    {
        player.is_on_spree = 4;
        while((p = find_player(p))) { announce_start_spree(p,player.netname," is unstoppable!\n"); }  
	}
}

void(entity player) reset_killspree =
{
    player.is_on_spree = 0;
    player.prev_frags = player.frags;
}

void (entity attacker, entity targ) check_if_end_killspree =
{
    if (targ.is_on_spree != 0) { announce_end_killspree(attacker, targ); }
    reset_killspree(targ);
}