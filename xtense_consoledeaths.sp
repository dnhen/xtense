#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = {
    name = "Xtense :: Console Deaths",
    author = "dnhen",
    description = "Print deaths in console like CS:S",
    version = "0.1",
    url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath)
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    // Get victims user id -> client id -> victims username
    int victimUID = GetEventInt(event, "userid");
    int victim = GetClientOfUserId(victimUID);
    
    char vUsername[64];
    GetClientName(victim, vUsername, sizeof(vUsername));
    
    // Get attackers user id -> client id -> attackers username
    int attackerUID = GetEventInt(event, "attacker");
    int attacker = GetClientOfUserId(attackerUID);

    char aUsername[64];
    GetClientName(attacker, aUsername, sizeof(aUsername));
    
    char weapon[32];
    GetEventString(event, "weapon", weapon, sizeof(weapon));
    
    // Display 'attacker killed victim with weapon' in all users console
    PrintToConsoleAll("%s killed %s with %s.", aUsername, vUsername, weapon);
}