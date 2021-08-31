# Xtense

Extensive addon scripts for SourceMod (https://www.sourcemod.net/), primarily for CSGO.

### How to install?
1. Download the required addons from [here](https://github.com/dnhen/sm_scripts/tree/main/compiled).
2. Move the .smx file to your 'plugins' directory (csgo/addons/sourcemod/plugins/).
3. Either restart your server, or in your server console run the command 'sm plugins load <plugin_name.smx>'.

### Xtense Core Suite (CS:GO Jailbreak Modules)
The Xtense Core Suite is developped primarily for CS:GO Jailbreak server types. It is developed in a modular, lightweight way to allow server owners to pick and choose exactly what features they want on their server without overloading on unnecessary plugins.

- **Welcome** (xtense_welcome)
  - Welcome displays in the server chat and server console, the steamID and username of all connecting and disconnecting players, with a built in 30 second cooldown to prevent user spam, e.g. "\[STEAM_0:1:12903982\] Bob is joining the game."

    ![welcome_demo](https://user-images.githubusercontent.com/69449713/129579874-72f35953-9d70-469b-9066-d94ab8f7607c.PNG)

- **Rollback** (xtense_rollback)
  - Rollback allows admins to roll back time, to a set time in the round. Once the command is executed, all players will be teleported to where they were the time the admin sets in the command, with the same health, same team, and same alive status.
    - !rollback <time (seconds)>
  
    ![rollback](https://user-images.githubusercontent.com/69449713/130625817-99661d6f-7cdc-44da-8d88-86c144edae18.PNG)  


- **Strip** (xtense_strip)
  - Each time a player spawns, they are stripped of all their weapons and given a knife.

- **Voice** (xtense_voice)
  - Mutes all Ts for the first 60 seconds of the round (except admins). Unmutes all players (except those muted by admins) at the end of each round.

    ![muted](https://user-images.githubusercontent.com/69449713/130625734-b5a90a66-2d3b-413d-a314-9ddded04a043.PNG)
  
    ![speak](https://user-images.githubusercontent.com/69449713/130625757-46691008-dcd8-4683-864c-a9485bf35798.PNG)


- **Console Deaths** (xtense_consoledeaths)
  - Console deaths displays deaths in each players console, similar to that in CS:S. The death displays as "Attacker killed Victim with Weapon", e.g. "Bob killed Fred with weapon_ak47"

    ![consoledeaths_demo](https://user-images.githubusercontent.com/69449713/129579510-a4613e23-ed92-4181-9c69-81b79c6e7bbe.PNG)

- **Teargas** (xtense_teargas)
  - Smoke grenades act as teargas, issuing damage to any players in the radius of the grenade whilst the smoke is showing, and freezes players inside the smoke for a predefined period if it detonates in them. This plugins also adds noblock to all players, meaning players can walk through each other (CTs and Ts). This is to enable the ability to smoke enemy team mates.

### Xtense Admin Suite (CS:GO Admin System Modules)
The Xtense Admin Suite is a light weight modular admin system, which is a simple drag and drop to install. See below, the admin commands that are contained in the system.

- **Admin** (xtense_admin)
  - Core admin system. All below commands are featured in this plugin.
    - # <message> : prints in chat and in HUD an admin broadcast
