#include <sourcemod>
#include <openfortress>

#pragma newdecls required
#pragma semicolon 1

#define PL_VERSION "0.1.0"

#define TF_CLASS_DEMOMAN		4
#define TF_CLASS_ENGINEER		9
#define TF_CLASS_HEAVY			6
#define TF_CLASS_MEDIC			5
#define TF_CLASS_PYRO				7
#define TF_CLASS_SCOUT			1
#define TF_CLASS_SNIPER			2
#define TF_CLASS_SOLDIER		3
#define TF_CLASS_SPY				8
#define TF_CLASS_UNKNOWN		0

#define TF_CLASS_CIVILIAN		11
#define TF_CLASS_MERCENARY		10
	
#define TF_TEAM_BLU					3
#define TF_TEAM_RED					2

public Plugin myinfo =
{
	name        = "Open Fortress Class Restrictions",
	author      = "Tsunami, Modified by Bryson <3",
	description = "Restrict classes in Open Fortress",
	version     = PL_VERSION,
	url         = "https://brysonscorner.info"
}

int g_iClass[MAXPLAYERS + 1];
ConVar g_hEnabled;
ConVar g_hFlags;
ConVar g_hImmunity;
ConVar g_hLimits[4][12];

public void OnPluginStart()
{
	CreateConVar("sm_classrestrict_version", PL_VERSION, "Restrict classes in TF2.", FCVAR_NOTIFY);
	g_hEnabled                                = CreateConVar("sm_classrestrict_enabled",       "1",  "Enable/disable restricting classes.");
	g_hFlags                                  = CreateConVar("sm_classrestrict_flags",         "",   "Admin flags for restricted classes.");
	g_hImmunity                               = CreateConVar("sm_classrestrict_immunity",      "0",  "Enable/disable admins being immune for restricted classes.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_DEMOMAN]  = CreateConVar("sm_classrestrict_blu_demomen",   "-1", "Limit for Blu demomen.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_ENGINEER] = CreateConVar("sm_classrestrict_blu_engineers", "-1", "Limit for Blu engineers.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_HEAVY]    = CreateConVar("sm_classrestrict_blu_heavies",   "-1", "Limit for Blu heavies.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_MEDIC]    = CreateConVar("sm_classrestrict_blu_medics",    "-1", "Limit for Blu medics.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_PYRO]     = CreateConVar("sm_classrestrict_blu_pyros",     "-1", "Limit for Blu pyros.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_SCOUT]    = CreateConVar("sm_classrestrict_blu_scouts",    "-1", "Limit for Blu scouts.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_SNIPER]   = CreateConVar("sm_classrestrict_blu_snipers",   "-1", "Limit for Blu snipers.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_SOLDIER]  = CreateConVar("sm_classrestrict_blu_soldiers",  "-1", "Limit for Blu soldiers.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_SPY]      = CreateConVar("sm_classrestrict_blu_spies",     "-1", "Limit for Blu spies.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_DEMOMAN]  = CreateConVar("sm_classrestrict_red_demomen",   "-1", "Limit for Red demomen.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_ENGINEER] = CreateConVar("sm_classrestrict_red_engineers", "-1", "Limit for Red engineers.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_HEAVY]    = CreateConVar("sm_classrestrict_red_heavies",   "-1", "Limit for Red heavies.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_MEDIC]    = CreateConVar("sm_classrestrict_red_medics",    "-1", "Limit for Red medics.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_PYRO]     = CreateConVar("sm_classrestrict_red_pyros",     "-1", "Limit for Red pyros.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_SCOUT]    = CreateConVar("sm_classrestrict_red_scouts",    "-1", "Limit for Red scouts.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_SNIPER]   = CreateConVar("sm_classrestrict_red_snipers",   "-1", "Limit for Red snipers.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_SOLDIER]  = CreateConVar("sm_classrestrict_red_soldiers",  "-1", "Limit for Red soldiers.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_SPY]      = CreateConVar("sm_classrestrict_red_spies",     "-1", "Limit for Red spies.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_CIVILIAN] = CreateConVar("sm_classrestrict_red_civs",     "-1", "Limit for Red civs.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_CIVILIAN] = CreateConVar("sm_classrestrict_blu_civs",     "-1", "Limit for Blu civs.");
	g_hLimits[TF_TEAM_RED][TF_CLASS_MERCENARY] = CreateConVar("sm_classrestrict_red_mercs",     "-1", "Limit for Red mercs.");
	g_hLimits[TF_TEAM_BLU][TF_CLASS_MERCENARY] = CreateConVar("sm_classrestrict_blu_mercs",     "-1", "Limit for Blu mercs.");

	HookEvent("player_changeclass", Event_PlayerClass);
	HookEvent("player_spawn",       Event_PlayerSpawn);
	HookEvent("player_team",        Event_PlayerTeam);
}

public void OnMapStart()
{

}

public void OnClientPutInServer(int client)
{
	g_iClass[client] = TF_CLASS_UNKNOWN;
}

public void Event_PlayerClass(Event event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(event.GetInt("userid")),
		iClass  = event.GetInt("class"),
		iTeam   = GetClientTeam(iClient);

	if (!(g_hImmunity.BoolValue && IsImmune(iClient)) && IsFull(iTeam, iClass))
	{
		ShowVGUIPanel(iClient, iTeam == TF_TEAM_BLU ? "class_blue" : "class_red");
		PrintToChat(iClient, "Class is full/restricted! Please choose another class!");
		TF2_SetPlayerClass(iClient, view_as<TFClassType>(g_iClass[iClient]));
	}
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(event.GetInt("userid")),
		iTeam   = GetClientTeam(iClient);

	if (!(g_hImmunity.BoolValue && IsImmune(iClient)) && IsFull(iTeam, (g_iClass[iClient] = view_as<int>(TF2_GetPlayerClass(iClient)))))
	{
		ShowVGUIPanel(iClient, iTeam == TF_TEAM_BLU ? "class_blue" : "class_red");
		PickClass(iClient);
	}
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(event.GetInt("userid")),
		iTeam   = event.GetInt("team");

	if (!(g_hImmunity.BoolValue && IsImmune(iClient)) && IsFull(iTeam, g_iClass[iClient]))
	{
		PrintToChat(iClient, "Team is full/restricted! Please choose another team!");
		ShowVGUIPanel(iClient, iTeam == TF_TEAM_BLU ? "class_blue" : "class_red");
		PickClass(iClient);
	}
}

bool IsFull(int iTeam, int iClass)
{
	// If plugin is disabled, or team or class is invalid, class is not full
	if (!g_hEnabled.BoolValue || iTeam < TF_TEAM_RED || iClass < TF_CLASS_SCOUT)
		return false;

	// Get team's class limit
	int iLimit;
	float flLimit = g_hLimits[iTeam][iClass].FloatValue;

	// If limit is a percentage, calculate real limit
	if (flLimit > 0.0 && flLimit < 1.0)
		iLimit = RoundToNearest(flLimit * IsThereEnoughSpace(iTeam));
	else
		iLimit = RoundToNearest(flLimit);

	// If limit is -1, class is not full
	if (iLimit == -1)
		return false;
	// If limit is 0, class is full
	else if (iLimit == 0)
		return true;

	// Loop through all clients
	for (int i = 1, iCount = 0; i <= MaxClients; i++)
	{
		// If client is in game, on this team, has this class and limit has been reached, class is full
		if (IsClientInGame(i) && GetClientTeam(i) == iTeam && view_as<int>(TF2_GetPlayerClass(i)) == iClass && ++iCount > iLimit)
			return true;
	}

	return false;
}

bool IsImmune(int iClient)
{
	if (!iClient || !IsClientInGame(iClient))
		return false;

	char sFlags[32];
	g_hFlags.GetString(sFlags, sizeof(sFlags));

	// If flags are specified and client has generic or root flag, client is immune
	return !StrEqual(sFlags, "") && CheckCommandAccess(iClient, "classrestrict", ReadFlagString(sFlags));
}

void PickClass(int iClient)
{
	// Loop through all classes, starting at random class
	for (int i = GetRandomInt(TF_CLASS_SCOUT, TF_CLASS_ENGINEER), iClass = i, iTeam = GetClientTeam(iClient);;)
	{
		// If team's class is not full, set client's class
		if (!IsFull(iTeam, i))
		{
			TF2_SetPlayerClass(iClient, view_as<TFClassType>(i));
			TF2_RespawnPlayer(iClient);
			g_iClass[iClient] = i;
			break;
		}
		// If next class index is invalid, start at first class
		else if (++i > TF_CLASS_ENGINEER)
			i = TF_CLASS_SCOUT;
		// If loop has finished, stop searching
		else if (i == iClass)
			break;
	}
}

bool IsThereEnoughSpace(int iTeam)
{
	int total = 0, classlimit = 0;
	
	for(int i = 1; i <= 9; i++)
	{
		classlimit = GetConVarInt(g_hLimits[iTeam][i]);
		
		if(classlimit != -1)
		{
			total += classlimit;
		}
		else
		{
			total = -1;
			break;
		}
	}
	
	if(total == -1)
	{
		return true;
	}
	else if(total == 0)
	{
		return false;
	}	
	else
	{
		int HumansCount = GetHumanClientsCount(iTeam);
		
		if(total >= HumansCount)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
int GetHumanClientsCount(int iTeam) 
{
	int clients = 0;
	
	for(int i = 1; i <= MaxClients; i++) 
	{
		if(IsPlayerHereLoop(i)) 
		{
			if(GetClientTeam(i) == iTeam)
			{
				clients++;
			}
		}
	}
	
	return clients;
}

bool IsPlayerHereLoop(int client)
{
	return (IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client));
}
