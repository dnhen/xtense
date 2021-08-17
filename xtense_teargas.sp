#include <sourcemod>
#include <sdktools>
#include <cstrike>

#define RADIUS            250.0
#define DAMAGE            2.0
#define DAMAGETIME        16.0
#define FREEZETIME        8.0
#define FREEZE_DISTANCE   75.0

public Plugin myinfo = {
    name = "Xtense :: Teargas",
    author = "dnhen",
    description = "Smoke grenades do damage to players",
    version = "0.4",
    url = "http://www.sourcemod.net/"
};

public void OnPluginStart(){
    HookEvent("smokegrenade_detonate", Event_SmokeNade);
}

public Action Event_SmokeNade(Event event, const char[] name, bool dontBroadcast){
    float vectorPos[3];

    int index = CreateEntityByName("point_hurt"); // Create a point hurt and store as index

    if(index == -1){ // Error creating point hurt
        return Plugin_Handled;
    }

    // Set the point hurt to have key values that are set in define
    DispatchKeyValueFloat(index, "DamageRadius", RADIUS);
    DispatchKeyValueFloat(index, "Damage", DAMAGE);
    DispatchKeyValueFloat(index, "DamageType", 32.00);
    DispatchSpawn(index);

    // Get the position of the nade, and store it in the vectorPos array.
    vectorPos[0] = GetEventFloat(event, "x");
    vectorPos[1] = GetEventFloat(event, "y") + 10;
    vectorPos[2] = GetEventFloat(event, "z");

    TeleportEntity(index, vectorPos, NULL_VECTOR, NULL_VECTOR); // Tp the point_hurt to the nade

    // Active the point hurt to start inflicting damage
    SetVariantString("OnUser1 !self,kill, -1, 20");
    AcceptEntityInput(index, "AddOutput");
    AcceptEntityInput(index, "TurnOn");
    AcceptEntityInput(index, "FireUser1");

    // Create timers to end the freeze and smoke, and parse datapack to close it at the end of freeze time.
    CreateTimer(FREEZETIME, Timer_EndFreeze);
    CreateTimer(DAMAGETIME, Timer_EndSmoke, index);

    for(int i = 1; i < MAXPLAYERS; i++){
        if(IsClientInGame(i) && IsPlayerAlive(i)){
            float clientPos[3];
            GetClientAbsOrigin(i, clientPos); // Get the clients position

            if(GetVectorDistance(vectorPos, clientPos) < FREEZE_DISTANCE){ // Check if their distance between the nade and the player is less than the slowdown distance to freeze the player
                SetEntityMoveType(i, MOVETYPE_NONE); // Freeze player
            }
        }
    }

    return Plugin_Handled;
}

public Action Timer_EndFreeze(Handle Timer){
    for(int i = 1; i < MAXPLAYERS; i++){
        if(IsClientInGame(i) && IsPlayerAlive(i)){
            // Unfreeze all players
            SetEntityMoveType(i, MOVETYPE_WALK);
        }
    }
}

public Action Timer_EndSmoke(Handle Timer, int index){ // Remove the point hurt from the smoke
    AcceptEntityInput(index, "Kill");
}