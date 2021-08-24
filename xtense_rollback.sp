#include <sourcemod>
#include <sdktools>
#include <cstrike>
 
#define COLOR_PREFIX      "\x01 \x0B[\x01Xtense\x0B]\x01"
#define COLOR_NORMAL      "\x01"
#define COLOR_HIGHLIGHT   "\x0B"

#define MAX_TIME_SAVED    30
#define COUNTDOWN_TIME    4

float gLogVectors[MAXPLAYERS+1][2][128][3];
int gLog[MAXPLAYERS+1][3][128];
int gCountdown = COUNTDOWN_TIME;
bool enabled = false;

public Plugin myinfo = {
    name = "Xtense :: Rollback",
    author = "dnhen",
    description = "Rollback system to roll back to a pre-defined time",
    version = "0.5",
    url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
    RegAdminCmd("rollback", Command_Rollback , ADMFLAG_GENERIC);

    PrecacheSound("weapons/c4/c4_beep1.wav");
    PrecacheSound("weapons/c4/c4_disarm.wav");

    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);

    CreateTimer(1.0, Timer_RollbackLog, _, TIMER_REPEAT); // Global rollback log timer
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast){
    CreateTimer(30.0, Timer_DisableStart);
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
    enabled = false;
}

public Action Command_Rollback(int client, int args)
{
    if(args != 1){
        PrintToChat(client, "%s Usage: !rollback <time (seconds)>", COLOR_PREFIX);
        return Plugin_Handled;
    }

    if(!enabled){
        PrintToChat(client, "%s The command is currently %sdisabled%s, please try again soon.", COLOR_PREFIX, COLOR_HIGHLIGHT, COLOR_NORMAL)
        return Plugin_Handled;
    }
 
    /* Get the time argument */
    char argTime[32];
    GetCmdArg(1, argTime, sizeof(argTime));
    int time = StringToInt(argTime);
 
    if(time < 1 || time > MAX_TIME_SAVED){ // If time is not in the range of 1 sec to MAX_TIME_SAVED
        PrintToChat(client, "%s The time argument should be in %sseconds%s, and should not be larger than %s%i seconds%s.", COLOR_PREFIX, COLOR_HIGHLIGHT, COLOR_NORMAL, COLOR_HIGHLIGHT, MAX_TIME_SAVED, COLOR_NORMAL);
        return Plugin_Handled;
    }

    enabled = false;

    // Get the admins name
    char cName[128];
    GetClientName(client, cName, sizeof(cName));

    for(int i = 1; i <= MaxClients; i++){
        if(IsValidClient(i)){
            // ALIVE LOGIC
            if(!IsPlayerAlive(i) && gLog[i][2][time]){
                CS_RespawnPlayer(i);
            }else if(IsPlayerAlive(i) && !gLog[i][2][time]){
                ForcePlayerSuicide(i);
            }

            // TEAM LOGIC
            if(GetClientTeam(i) != gLog[i][1][time]){
                ChangeClientTeam(i, gLog[i][1][time]);
                if(gLog[i][2][time]){ // Since changing teams kills player, ensure they werent dead
                    CS_RespawnPlayer(i);
                }
            }

            // FREEZE PLAYER AND SET COLOUR AND FX
            SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
            SetEntityRenderColor(i, 255, 0, 60, 150);
            SetEntityRenderFx(i, RENDERFX_STROBE_FAST);
            SetEntProp(i, Prop_Data, "m_takedamage", 0, 1); // Set god mode

            // HEALTH LOGIC
            SetEntityHealth(i, gLog[i][0][time]);

            // POSITION LOGIC
            TeleportEntity(i, gLogVectors[i][0][time], gLogVectors[i][1][time], NULL_VECTOR); // Teleport the player back to the position.
        }
    }

    CreateTimer(1.0, Timer_StartRound, _, TIMER_REPEAT);
    CreateTimer(30.0, Timer_DisableStart);

    PrintToChatAll("%s %s%s%s has rolled back %s%d%s seconds. Starting in %s%i %sseconds...", COLOR_PREFIX, COLOR_HIGHLIGHT, cName, COLOR_NORMAL, COLOR_HIGHLIGHT, time, COLOR_NORMAL, COLOR_HIGHLIGHT, COUNTDOWN_TIME+1, COLOR_NORMAL);
    EmitSoundToAll("weapons/c4/c4_beep1.wav", _, _, _, _, 1.0, _, _, _, _, _, _);
 
    return Plugin_Handled;
}

public Action Timer_DisableStart(Handle Timer, Handle data){
    enabled = true;
}

public Action Timer_StartRound(Handle Timer, Handle data)
{
    if(gCountdown > 0){
        PrintToChatAll("%s Starting in %s%d %sseconds...", COLOR_PREFIX, COLOR_HIGHLIGHT, gCountdown, COLOR_NORMAL);
        EmitSoundToAll("weapons/c4/c4_beep1.wav", _, _, _, _, 1.0, _, _, _, _, _, _);
        gCountdown--;
    }else if(gCountdown == 0){
        for(int i = 1; i <= MaxClients; i++)
        {
            if(IsValidClient(i))
            {
                // Unfreeze, and set colours back to normal
                SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
                SetEntityRenderColor(i, 255, 255, 255, 255);
                SetEntityRenderFx(i, RENDERFX_NONE);
                SetEntProp(i, Prop_Data, "m_takedamage", 2, 1); // Disable god mode
            }
        }
        
        PrintToChatAll("%s The round is now starting...", COLOR_PREFIX);
        EmitSoundToAll("weapons/c4/c4_disarm.wav", _, _, _, _, 1.0, _, _, _, _, _, _);
        gCountdown = COUNTDOWN_TIME;
        
        KillTimer(Timer);
    }
}

public Action Timer_RollbackLog(Handle timer, int client){
    for(int i = 1; i <= MaxClients; i++){ // Every second -> Loop through all clients and store their positions, death status, team, and HP
        if(IsValidClient(i)){
            // Get clients position
            float cPosition[3];
            GetClientAbsOrigin(i, cPosition);

            // Get clients angles
            float cAngles[3];
            GetClientAbsAngles(i, cAngles);

            // Get clients health, team, and alive
            int cHealth = GetClientHealth(i);
            int cTeam = GetClientTeam(i);
            int cAlive = IsPlayerAlive(i);

            // Shift the global array by 1 to the MAX_TIME_SAVED
            ShiftGlobalLog(i, MAX_TIME_SAVED);

            // gLogVectors: 0 = Positon, 1 = Angles, || gLog: 0 = Health, 1 = Team, 2 = Alive
            // gLog[client id][above code][time]
            gLogVectors[i][0][1] = cPosition;
            gLogVectors[i][1][1] = cAngles;

            gLog[i][0][1] = cHealth;
            gLog[i][1][1] = cTeam;
            gLog[i][2][1] = cAlive;
        }
    }
}

// Return true if client is in game and is connected
public bool IsValidClient(int client){
    return IsClientInGame(client) && IsClientConnected(client);
}

// Function to shift all values in the global log by one position, at the allocated index
public void ShiftGlobalLog(int index, int n){
    for(int pos = 30; pos >= 1; pos--){
        gLogVectors[index][0][pos] = gLogVectors[index][0][pos-1];
        gLogVectors[index][1][pos] = gLogVectors[index][1][pos-1];
        gLog[index][0][pos] = gLog[index][0][pos-1];
        gLog[index][1][pos] = gLog[index][1][pos-1];
        gLog[index][2][pos] = gLog[index][2][pos-1];
    }
}