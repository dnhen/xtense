# Xtense

Extensive addon scripts for SourceMod (https://www.sourcemod.net/), primarily for CSGO.

### How to install?
1. Download the required addons from [here](https://github.com/dnhen/sm_scripts/tree/main/compiled).
2. Move the .smx file to your 'plugins' directory (csgo/addons/sourcemod/plugins/).
3. Either restart your server, or in your server console run the command 'sm plugins load <plugin_name.smx>'.

### Xtense Core Suite (CS:GO Jailbreak Modules)
The Xtense suite is developped primarily for CS:GO Jailbreak server types. It is developed in a modular, lightweight way to allow server owners to pick and choose exactly what features they want on their server without overloading on unnecessary plugins.

- **Welcome** (xtense_welcome)
  - Welcome displays in the server chat and server console, the steamID and username of all connecting and disconnecting players, with a built in 30 second cooldown to prevent user spam, e.g. "\[STEAM_0:1:12903982\] Bob is joining the game."
    ![welcome_demo](https://user-images.githubusercontent.com/69449713/129579874-72f35953-9d70-469b-9066-d94ab8f7607c.PNG)

- **Console Deaths** (xtense_consoledeaths)
  - Console deaths displays deaths in each players console, similar to that in CS:S. The death displays as "Attacker killed Victim with Weapon", e.g. "Bob killed Fred with weapon_ak47"
    ![consoledeaths_demo](https://user-images.githubusercontent.com/69449713/129579510-a4613e23-ed92-4181-9c69-81b79c6e7bbe.PNG)

