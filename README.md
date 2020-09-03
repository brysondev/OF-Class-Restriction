# OF-Class-Restriction

### Install Instructions:
- Get Sourcemod for Open Fortress by following the guide in the **\#server-hosting-troubleshooting** pins on the offical [Open Fortress Discord Server](https://discord.gg/Jk3NUb7)

1. Place the `.smx` file in `open_fortress/addons/sourcemod/plugins` or compile the `.sp` yourself and put it in there (if you wanna make changes). You will need **Scag's Open Fortress Tools** in order for it to compile!
2. Run server once to generate CFG.
3. Edit commands in `plugin.classrestrict_of.cfg` to launch on server start or change them live with the commands below.

### In-Game Stuff:
- `sm_classrestrict_enabled` - Enable/disable restricting classes.
- `sm_classrestrict_flags` - Admin flags for restricted classes.
- `sm_classrestrict_immunity` - Enable/disable admins being immune for restricted classes.
- `sm_classrestrict_blu_demomen` - Limit for Blu demomen.
- `sm_classrestrict_blu_engineers`- Limit for Blu engineers.
- `sm_classrestrict_blu_heavies` - Limit for Blu heavies.
- `sm_classrestrict_blu_medics` - Limit for Blu medics.
- `sm_classrestrict_blu_pyros` - Limit for Blu pyros.
- `sm_classrestrict_blu_scouts` - Limit for Blu scouts.
- `sm_classrestrict_blu_snipers` - Limit for Blu snipers.
- `sm_classrestrict_blu_soldiers` - Limit for Blu soldiers.
- `sm_classrestrict_blu_spies` - Limit for Blu spies.
- `sm_classrestrict_blu_civs` - Limit for Blu civs.
- `sm_classrestrict_blu_mercs` - Limit for Blu mercs.

*Reverse for the red team (sm_classrestrict_red...)*

### Credits
I used these 3 plugins and a bit of splicing to get everything working.
- Scag - https://github.com/Scags/Open-Fortress-Tools
- Tsunami - https://forums.alliedmods.net/showthread.php?p=642353
- luki1412 - https://forums.alliedmods.net/showthread.php?p=2518202
