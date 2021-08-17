#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <basecomm>

#define COLOR_PREFIX      "\x01 \x0B[\x01Xtense\x0B]\x01"
#define COLOR_NORMAL      "\x01"
#define COLOR_HIGHLIGHT   "\x0B"

#define MUTETIME          60

bool mutePeriod = false;
Handle Timer_StartTimer;

public Plugin myinfo = {
    name = "Xtense :: Voice",
    author = "dnhen",
    description = "Muting system to mute Ts at the round starts, and dead cannot talk to alive",
    version = "0.4",
    url = "http://www.sourcemod.net/"
};

public void OnPluginStart(){
    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", Event_PlayerDeath);
}

// When round starts -> mute all Ts for MUTETIME seconds
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast){
    ServerCommand("sv_full_alltalk 0"); // Fix alltalk bug
    ServerCommand("sv_show_voip_indicator_for_enemies 1"); // Show the talking icon to enemy players

    mutePeriod = true; // Set mute period to be on
    Timer_StartTimer = CreateTimer(float(MUTETIME), Timer_UnmuteStart);

    for(int i = 1; i < MAXPLAYERS; i++){ // Loop through all players and mute them all (except for below)
        if(IsClientInGame(i) && GetClientTeam(i) != CS_TEAM_CT){ // If actual user and not on CT
            AdminId a = GetUserAdmin(i); // Get the users admin ID

            if(a == INVALID_ADMIN_ID){ // If the user is NOT an admin
                SetClientListeningFlags(i, VOICE_MUTED);
            }
        }
    }

    PrintToChatAll("%s Terrorists are muted for %s%d %sseconds.", COLOR_PREFIX, COLOR_HIGHLIGHT, MUTETIME, COLOR_NORMAL);
}

// When round ends -> unmute all players
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
    for(int i = 1; i < MAXPLAYERS; i++){
        if(IsClientInGame(i) && !BaseComm_IsClientMuted(i)){ // If user is in game and not admin muted
            SetClientListeningFlags(i, VOICE_NORMAL);
        }
    }

    delete Timer_StartTimer; // Kill the unmute timer (if running)
}

// When player spawns -> if in mute period and T... mute them
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
    int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get the clientID from the event userid

    if(BaseComm_IsClientMuted(client) || (mutePeriod && GetClientTeam(client) != CS_TEAM_CT)){ // If they are admin muted OR its mute period and they are not CT
            SetClientListeningFlags(client, VOICE_MUTED);
        } else {
            SetClientListeningFlags(client, VOICE_NORMAL);
        }
}

// When player dies -> mute them
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
    int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get client ID
    AdminId a = GetUserAdmin(client); // Get client's adminID

    if(a == INVALID_ADMIN_ID){ // If not admin -> mute
        SetClientListeningFlags(client, VOICE_MUTED);
    }

    PrintToChat(client, "%s You are now muted.", COLOR_PREFIX);
}

public Action Timer_UnmuteStart(Handle timer, int client){
    mutePeriod = false;
    Timer_StartTimer = INVALID_HANDLE;

    for(int i = 1; i < MAXPLAYERS; i++){
        if(IsClientInGame(i) && !BaseComm_IsClientMuted(i) && IsPlayerAlive(i)){ // If user is in game and not admin muted
            SetClientListeningFlags(i, VOICE_NORMAL);
        }
    }

    PrintToChatAll("%s Terrorists can now speak... quietly...", COLOR_PREFIX);
}

// When the player gets unmuted (from admin mute)
public void BaseComm_OnClientMute(int client, bool muteState){
    if(!muteState && mutePeriod && GetClientTeam(client) != CS_TEAM_CT){ // If unmuted (after admin mute), and in mute period and is not CT
        SetClientListeningFlags(client, VOICE_MUTED); // Re-mute player
    }
}