#include <sdktools>
#include <PTaH>
#include <clientprefs>

#define MAXPATCHES 1337

int PatchOffset;
int g_Set[MAXPLAYERS +1];

Handle TTPatch1;
Handle TTPatch2;
Handle TTPatch3;

Handle CTPatch1;
Handle CTPatch2;
Handle CTPatch3;

char iPnum[22][] = {"0","4550","4551","4552","4553","4554","4555","4556","4557","4558","4559","4560","4561","4562","4563","4564","4565","4566","4567","4568","4569","4570"};
char iPname[22][] = {"移除当前布章","Crazy Banana","The Boss","Chicken Lover","Welcome to the Clutch","Dragon","Easy Peasy","Rage","Howl","Koi","Longevity","Wildfire","Vigilance","Bloodhound","Bravo","Breakout","Danger Zone","Hydra","Payback","Phoenix","Shattered Web","Vanguard"};

public Plugin myinfo = {

    name = "change player patches",
    author = "neko aka bklol",
    description = "change player patches",
    version = "0.1",
    url = "https://github.com/bklol"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_patch", Patch);
	
	TTPatch1 = RegClientCookie("TPslot1", "", CookieAccess_Private);
	TTPatch2 = RegClientCookie("TPslot2", "", CookieAccess_Private);
	TTPatch3 = RegClientCookie("TPslot3", "", CookieAccess_Private);
	CTPatch1 = RegClientCookie("CTPslot1", "", CookieAccess_Private);
	CTPatch2 = RegClientCookie("CTPslot2", "", CookieAccess_Private);
	CTPatch3 = RegClientCookie("CTPslot3", "", CookieAccess_Private);
	
	PatchOffset = FindSendPropInfo("CCSPlayer", "m_vecPlayerPatchEconIndices");
	
	HookEvent("player_spawn", iPlayerSpawn);
}

public Action Patch(int client,int a)
{
	if(IsValidClient(client)&& IsPlayerAlive(client))
		OPP(client);
	else
		PrintToChat(client,"只能在存活时设置");
}

void OPP(int client)
{
	Menu hmenu = new Menu(Handler_MainMenu);
	hmenu.SetTitle("玩家布章[槽位选择]");
	
	hmenu.AddItem("0", "槽位1");
	hmenu.AddItem("1", "槽位2");
	hmenu.AddItem("2", "槽位3");
	hmenu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_MainMenu(Menu hmenu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		g_Set[client] = itemNum + 1;
		PatchMenu(client);
	}
}

void PatchMenu(int client)
{
	int islot = g_Set[client];
	Menu menu = new Menu(Handler_SMenu);
	menu.SetTitle("玩家布章[槽位%i]",islot);
	for(int i = 0;i < 22; ++i)
	{
		menu.AddItem(iPnum[i],iPname[i]);
	}
	g_Set[client] = islot;
	menu.Display(client, MENU_TIME_FOREVER);	
}

public int Handler_SMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	char buffer[32];
	switch(action)
	{
		case MenuAction_Select:
		{
			if(!IsPlayerAlive(client))
			{
				PrintToChat(client,"只能在存活时设置");
				return;
			}
			menu.GetItem(itemNum, buffer, sizeof(buffer));
			int index = StringToInt(buffer);
			if(GetClientTeam(client) != 3)
			{
				switch(g_Set[client])
				{
					case 1:
					{
						SetClientCookie(client, TTPatch1, buffer);
					}
					case 2:
					{
						SetClientCookie(client, TTPatch2, buffer);
					}
					case 3:
					{
						SetClientCookie(client, TTPatch3, buffer);
					}
				}
				PrintToChat(client,"你为 \x03T\x01 槽位 \x03%i\x01 选择了:\x03%s",g_Set[client],iPname[itemNum]);
				
			}
			else
			{
				switch(g_Set[client])
				{
					case 1:
					{
						SetClientCookie(client, CTPatch1, buffer);
					}
					case 2:
					{
						SetClientCookie(client, CTPatch2, buffer);
					}
					case 3:
					{
						SetClientCookie(client, CTPatch3, buffer);
					}
				}
				PrintToChat(client,"你为 \x03CT\x01 槽位 \x03%i\x01 选择了:\x03%s",g_Set[client],iPname[itemNum]);
				
			}
			
			TY(client, g_Set[client], index);
			if(IsPlayerAlive(client))
				OPP(client);
		}
	}
}

public Action iPlayerSpawn(Event iEvent, const char[] Name, bool DontBroadcast)
{
	int client = GetClientOfUserId(iEvent.GetInt("userid"));

	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		for(int i = 1; i <= 3; i++)
		{
			int DefIndex = GetPatchId(client, i);
			TY( client, i, DefIndex);
		}
	}
}

int GetPatchId(int client,int slot)
{
	int iTeam = GetClientTeam(client);
	char buffer[12];
	if(iTeam != 3)
	{
		switch(slot)
		{
			case 1:
			{
				GetClientCookie(client, TTPatch1, buffer, sizeof(buffer));
			}
			case 2:
			{
				GetClientCookie(client, TTPatch2, buffer, sizeof(buffer));
			}
			case 3:
			{
				GetClientCookie(client, TTPatch3, buffer, sizeof(buffer));
			}
		}
	}
	else
	{
		switch(slot)
		{
			case 1:
			{
				GetClientCookie(client, CTPatch1, buffer, sizeof(buffer));
			}
			case 2:
			{
				GetClientCookie(client, CTPatch2, buffer, sizeof(buffer));
			}
			case 3:
			{
				GetClientCookie(client, CTPatch3, buffer, sizeof(buffer));
			}
		}
	}
	int index = StringToInt(buffer);
	return index;
}

void TY(int iClient, int slots ,int DefIndex)
{
	if(!IsValidClient(iClient) || !IsPlayerAlive(iClient))
		return;
	SetEntData(iClient, PatchOffset + (slots - 1) * 4, DefIndex);
	PTaH_ForceFullUpdate(iClient);
}

stock bool IsValidClient( int client )
{
	if ( client < 1 || client > MaxClients ) return false;
	if ( !IsClientConnected( client )) return false;
	if ( !IsClientInGame( client )) return false;
	if ( IsFakeClient( client )) return false;
	return true;
}