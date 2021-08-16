#include <sourcemod>
#include <sdktools>
#include <cstrike>
 
#define COLOR_PREFIX      "\x01 \x0B[\x01Xtense\x0B]\x01"
#define COLOR_NORMAL      "\x01"
#define COLOR_HIGHLIGHT   "\x0B"

// Global arrays to track client cooldowns for connect and disconnect messages
bool gClientCooldownC[MAXPLAYERS+1] = false;
bool gClientCooldownD[MAXPLAYERS+1] = false;

// Global timer arrays to track client cooldown timers for connect and disconnect messages
Handle gTimer_CooldownC[MAXPLAYERS+1];
Handle gTimer_CooldownD[MAXPLAYERS+1];

public Plugin myinfo = {
    name = "Xtense :: Welcome",
    author = "dnhen",
    description = "Display SteamID for joining and leaving players",
    version = "0.4",
    url = "http://www.sourcemod.net/"
};

public OnClientPostAdminCheck(int client)
{
    char cName[64], steamID[128];

    if(GetClientName(client, cName, sizeof(cName)) && GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID)) && !gClientCooldownC[client]){ // If we can get the clients username and steamID and cooldown isnt on
        PrintToChatAll("%s %s[%s%s%s] %s%s %sis joining the game.", COLOR_PREFIX, COLOR_HIGHLIGHT, COLOR_NORMAL, steamID, COLOR_HIGHLIGHT, COLOR_HIGHLIGHT, cName, COLOR_NORMAL);
        PrintToServer("[%s] %s is joining the game.", steamID, cName);

        // Enable the cooldown for connect messages, and start the timer to disable the cooldown
        gClientCooldownC[client] = true;
        gTimer_CooldownC[client] = CreateTimer(30.0, Timer_ClientCooldownC, client);
    }
}

public OnClientDisconnect(int client)
{
    char cName[64], steamID[128];

    if(GetClientName(client, cName, sizeof(cName)) && GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID)) && !gClientCooldownD[client]){ // If we can get the clients username and steamID and cooldown isnt on
        PrintToChatAll("%s %s[%s%s%s] %s%s %s has left the game.", COLOR_PREFIX, COLOR_HIGHLIGHT, COLOR_NORMAL, steamID, COLOR_HIGHLIGHT, COLOR_HIGHLIGHT, cName, COLOR_NORMAL);
        PrintToServer("[%s] %s has left the game.", steamID, cName);

        // Enable the cooldown for disconnect messages, and start the timer to disable the cooldown
        gClientCooldownD[client] = true;
        gTimer_CooldownD[client] = CreateTimer(30.0, Timer_ClientCooldownD, client);
    }
}

// --------------------
// Connect and disconnect cooldown timers
// --------------------

public Action Timer_ClientCooldownC(Handle timer, int client){
    gClientCooldownC[client] = false;
}

public Action Timer_ClientCooldownD(Handle timer, int client){
    gClientCooldownD[client] = false;
}

// --------------------
// Reset all timers
// --------------------

public void OnMapEnd(){
    for(int i = 1; i <= MaxClients; i++){
        gClientCooldownC[i] = false;
        gClientCooldownD[i] = false;
        KillTimer(gTimer_CooldownC[i]);
        KillTimer(gTimer_CooldownD[i]);
    }
}