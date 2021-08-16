#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = {
    name = "Xtense :: Strip",
    author = "dnhen",
    description = "Strip players at the start of each round, and gives all players a knife and 100 armour",
    version = "0.4",
    url = "http://www.sourcemod.net/"
};

public void OnPluginStart(){
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
    int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get the clientID from the event userid

    if(IsClientInGame(client) && IsClientConnected(client) && IsPlayerAlive(client)){ // If the clientID is not a bot, is in game, connected, and alive
        // 5 weapon slots in total -> check each slot
        for(int i = 0; i <= 5; i++){
            while(GetPlayerWeaponSlot(client, i) != -1){ // While that weapon slot contains a weapon
                RemoveWeapon(client, i); // Remove the weapon from the slot
            }
        }

        GivePlayerItem(client, "weapon_knife");
    }
}

public void RemoveWeapon(client, pos){
    // Get the index of the weapon at slot pos
    int wepIndex = -1;
    wepIndex = GetPlayerWeaponSlot(client, pos);

    if(wepIndex != -1){
        char className[32];
        GetEntityClassname(wepIndex, className, sizeof(className)); // Get the weapons class name (so we can kill the entity)

        RemovePlayerItem(client, wepIndex); // Remove item from players inventory
        AcceptEntityInput(wepIndex, "Kill"); // Kill the entity
    }
}