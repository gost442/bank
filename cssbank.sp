/*
#################################################
##                                             ##
##   CSS Bank (including MySQL support) v1.6   ##
##                                             ##
#################################################

Inital plugin:
	SM Bank Mod: MySQL from Nican, mateo10

Fundamental changes:
	* added new cvars
	* added auto deposit/withdraw
	* added some other features
	* reworked complete code
	* added small webinterface

Description:
	A player can deposit money to the bank, transfer it to other players or withdraw when needed.
	Also set automatic deposit and/or withdraw.
	All cvars can be configured in the cssbank.cfg
	Supports MySQL
	include small webinterface

Credits:
	Nican for his inital plugin: SM Bank Mod: MySQL
	graczu for the top10 part in his css_rank plugin
	SilentWarrior for gave mightily assistance
	svito for Slovak translation
	UncLeMax for Russian translation
	away000 for Portuguese translation
	TnTSCS for helping with bots in CSGO

Changelog:
	1.0 (2010-03-06)
		** Initial Release!
	1.1 (2010-03-07)
		** Fixed: DB storage bug
		++ Added: bank only activated for player in team
	1.1.1 (2010-03-09)
		** Fixed: percentage sign not shown in bank menu info
		** Fixed: checks whether a player is on a team, did not work properly
	1.2 (2010-03-21)
		** Fixed: Playernames now shown in right teamcolor
		++ Added: Admin menu; Command: bankadmin
		++ Added: Possibility to edit amount menu in translation file
		>> Changed: Color in chat from lightgreen to green
		>> some code improvements
	1.3 (2010-06-12)
		++ Added: Possibility to type !deposit <all/amount> and !withdraw <all/amount>
		++ Added: New CVARs: css_bank_mapprefixes, css_bank_mapmode
				to enable/disable bank according to map prefix
		++ Added: Commands to reset bank (only money or all)
		++ Added: Possibility to hide from top10
		++ Added: Possibility to reset own account
		++ Added: admin can target itself
		++ Added: Slovak translation (thanks to svito)
		>> Changed: Bankmenu (new: settings-item)
	1.3.1 (2010-06-13)
		** Fixed: with css_bank_maximum "0" (disabled), admin-Setmoney not worked
	1.3.2 (2010-06-20)
		** Fixed: problem with quotes in player names
	1.4.0 (2011-02-03)
		++ Added: Russian translation (thanks to UncLeMax)
		++ Added: French translation
		++ Added: !settings menu support
		++ Added: Bank admin menu now appears in admin menu
		++ Added: New server cmd: css_bank_cleanup (deletes redundant entries)
		++ Added: New CVAR: css_bank_autodep (Default auto deposit for new player)
		++ Added: New CVAR: css_bank_autowith (Default auto withdraw for new player)
		++ Added: New CVAR: css_bank_adminlimit (Maximun amount of money admins are allowed to have in the bank. 0 for no other limit.)
		++ Added: New CVAR: css_bank_adminflag (Set the Admin Flag)
		++ Added: New CVAR: css_bank_resetinterval (Set the number of days the bank should reset periodically, 0 for never)
		++ Added: New CVAR: css_bank_prunedb (Set the number of days after inactive players will be deleted, 0 for never)
		++ Added: late load (load plugin during map)
		++ Added: small web viewer (complete list or top10)
		>> Changed: "$16,000" now called "ALL" in menu
		>> Changed: limit of 16000 at transfer and admin add/remove to free input and new amounts specified in translations file
		>> Changed: shortened code of main plugin file (include cssbank files). no longer compiles on forum
		** Fixed: Bots for sure shouldn't appear in the DB.
		** Fixed: Banklimit not shown as money amount in "Bank Full" translation.
		** Fixed: Some players lost their money due to reconnect.
	1.4.1 (2011-02-06)
		** Fixed: spelling mistake in MySQL query
		>> Changed: Description of cvar "css_bank_adminflag": Added "Changes require to reload plugin or restart server!"
	1.4.2 (2011-03-24)
		++ Added: Portuguese translation (thanks to away000)
		++ Added: free input now available in admin set money
		>> Changed: DB action/error logging
		>> Changed: DB connection handling
		>> Changed: absolute maximum of the bank now 2,000,000,000 (even if css_bank_maximum 0)
		** Fixed: wrong menu: autodeposit/autowithdraw
		** Fixed: "No Connection" bug
	1.4.3 (2011-05-12)
		** Fixed: Bug with negative values. (!withdraw -1000)
	1.4.4 (2011-06-26)
		++ Added: New Cvar: css_bank_add_to_adminmenu (Turns On/Off the adminmenu entry)
		** Changed: "RegConsoleCmd("say", ChatInput);" to "AddCommandListener(ChatInput, "say");"
	1.4.5 (2013-01-26)
		++ Added: consider mp_maxmoney
		++ Added: consider mp_maxrounds and mp_halftime in CSGO
		** Fixed: chat color in CSGO
		** Fixed: not working after CSGO update from 2013-01-23
	1.4.6 (2013-01-27)
		** Fixed: exploit bots in CSGO (Thanks to TnTSCS)
	1.4.7 (2013-02-22)
		** Fixed: Native "GetEntData" reported: Offset -1 is invalid
	1.4.8 (2013-03-07)
		** Fixed: Plugin cssbank.smx failed to load: Native "GetUserMessageType" was not found.
	1.5.0 (2013-04-22)
		++ Added: New Cvar: css_bank_transfer_limit (Maximum amount of money players are allowed to transfer. 0 for no limit)
		++ Added: New Cvar: css_bank_default_bankmoney (Default amount of money new players get in the bank)
	1.5.1 (2013-05-29)
		** Fixed: css_bank_transfer_limit "0" not working - thanks to nvn
	1.6.0 (2013-09-04)
		++ Added: CSS/CSGO now use the same account if same database. (https://forums.alliedmods.net/showpost.php?p=1938404&postcount=430)
		++ Added: Possibility to write logs for transfer- and admin-actions.
		++ Added: New Cvar: css_bank_log_transfers (Enables transfer logging. 0 = Disable)
		++ Added: New Cvar: css_bank_log_admin_action (Enables admin action logging. 0 = Disable)
		** Fixed: Bug in amount menu: "If I try to withdraw or deposit "ALL", it will only 0$ or 1.000$ booked."
		** Fixed: Issues with Autodeposit "ALL"
		** Fixed: Bug in Admin Menu - Setmoney: Free input not working.
	1.6.1 (2013-09-14)
		** Fixed: Messages are on by default (For new players).  No longer working.
		++ Added: New server cmd: css_bank_reset_message (resets message setting to default (1) for all players)
	1.6.2 (2013-09-26)
		** Fixed: Bank not working with css_bank_mapprefixes set and workshop maps (CSGO)
	1.6.3 (2014-04-05)
		** Fixed: Players selected a team, but still no model shouldn't be regarded as in a team.
	1.6.4 (2014-04-06)
		** Fixed: Fix from v1.6.3 now working. (Players selected a team, but still no model shouldn't be regarded as in a team.)
	1.6.5 (2014-04-21)
		** Fixed: Bank won't work for dead Players since v1.6.4.
	1.6.6 (2014-05-03)
		** Fixed: Second pistolround(s) not working, with mp_halftime associated with mp_timelimit instead of mp_maxrounds.
		** Fixed: Bug in check for old data. Whereby defaults like css_bank_default_bankmoney won't work.


Cvarlist: (default value):
	If you load the plugin the first time, a config file (cssbank.cfg) will be generated in the cfg/sourmod folder.

	css_bank_enable "1"					Turns Bank On/Off
	css_bank_maximum "250000"			Maximum amount of money players are allowed to have in the bank, 0 to disable (max 2,000,000,000)
	css_bank_announce "1.0"				Turns on announcement when a player joins the server, every map or every round: 0.0 = disabled, 1.0 = every map, 2.0 = every round
	css_bank_deposit_fee "200"			Fee, the players must pay for each deposit
	css_bank_interest "2.5"				% of interest players will get per round
	css_bank_min_deposit "1000"			Min. deposit amount, 0 to disable
	css_bank_pistolrounds "1"			Set the number of pistolrounds the bank is disabled, min. 0
	css_bank_identity "CSS Bank"		Set the name of your bank
	css_bank_min_players "2"			The number of min players to activate bank, min 0
	css_bank_dbconfig "clientprefs"		Set the database configuration listed in databases.cfg
	css_bank_mapmode "0"				0 = Disable bank during listed map prefixes, 1 = disable bank during NON-listed map prefixes (only listed maps enable bank)
	css_bank_mapprefixes " "			List the map prefixes where the bank is enabled or disabled. Related to the css_bank_mapmode Cvar
	css_bank_autodep "0"				Default auto deposit for new player
	css_bank_autowith "0"				Default auto withdraw for new player
	css_bank_adminlimit "0"				Maximum amount of money admins are allowed to have in the bank. 0 for no other limit.
	css_bank_adminflag "d"				Set the Admin Flag. For mor information: http://wiki.alliedmods.net/Adding_Admins_%28SourceMod%29#Levels. Changes require to reload plugin or restart server!
	css_bank_resetinterval "0"			Set the number of days the bank should reset periodically, 0 for never
	css_bank_prunedb "0"				Set the number of days after inactive players will be deleted, 0 for never
	css_bank_add_to_adminmenu "1"		Turns On/Off the adminmenu entry
	css_bank_transfer_limit "0"			Maximum amount of money players are allowed to transfer. 0 for no limit
	css_bank_default_bankmoney "0"		Default amount of money new players get in the bank
	css_bank_log_transfers "0"			Enables transfer logging. 0 = Disable
	css_bank_log_admin_action "0"		Enables admin action logging. 0 = Disable

User commands: (chat trigger)
	bank			(!bank or /bank)				Display a menu with the Bank functions
	deposit			(!deposit or /deposit)			Display a menu with amounts to deposit
	withdraw		(!withdraw or /withdraw)		Display a menu with amounts to withdraw
	bankstatus		(!bankstatus or /bankstatus)	Prints the current bankstatus to the chat
	deposit	<all|amount>	(!deposit <all|amount> or /deposit <all|amount>)	to deposit all or typed amount
	withdraw <all|amount>	(!withdraw <all|amount> or /withdraw <all|amount>)	to withdraw all (max 16000) or typed amount

Admin commands: (chat trigger)
	bankadmin	(!bankadmin or /bankadmin)	Display a menu with the Bank functions for an admin

Server commands:
	css_bank_reset_all		resets the hole bank
	css_bank_reset_money	resets only money amounts
	css_bank_cleanup 		to clean up database (deletes redundant entries)

Installation:
	copy the contents of the "gameserver" package to your gameserver

Update from v1.3.2:
	1. backup the cssbank.cfg
	2. proceed normal installation
	3. merge config changes
	4. reload the plugin or change map or restart server
	5. execute server command "css_bank_update"
	6. and it's better to change map after update to minimize data loss

	If you are using mysql, you can instead of point 5 and 6 also run:
	"ALTER TABLE `css_bank` ADD `last_accountuse` int(64) NOT NULL;ALTER TABLE `css_bank` ADD `last_bankreset` int(64) NOT NULL;UPDATE `css_bank` SET `last_accountuse` = UNIX_TIMESTAMP();UPDATE `css_bank` SET `last_bankreset` = UNIX_TIMESTAMP();"
	in your db.


Author:
	Miraculix
*/

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#undef REQUIRE_PLUGIN
#include <adminmenu>
#define REQUIRE_PLUGIN

#define PLUGIN_VERSION "1.6.6"

// chat colors
#define YELLOW "\x01"
#define TEAMCOLOR "\x03"
#define GREEN "\x04"

// CVAR-Handles
new Handle:cvar_Bankversion = INVALID_HANDLE;
new Handle:cvar_Bankenable = INVALID_HANDLE;
new Handle:cvar_Bankmaxbank = INVALID_HANDLE;
new Handle:cvar_Bankannounce = INVALID_HANDLE;
new Handle:cvar_Bankdepositfee = INVALID_HANDLE;
new Handle:cvar_Bankinterest = INVALID_HANDLE;
new Handle:cvar_Bankmindep = INVALID_HANDLE;
new Handle:cvar_Bankpistolround = INVALID_HANDLE;
new Handle:cvar_Bankidentity = INVALID_HANDLE;
new Handle:cvar_Bankminplayers = INVALID_HANDLE;
new Handle:cvar_Bankdbconfig = INVALID_HANDLE;
new Handle:cvar_Bankmapprefixes = INVALID_HANDLE;
new Handle:cvar_Bankmapmode = INVALID_HANDLE;
new Handle:cvar_Bankdefaultautodep = INVALID_HANDLE;
new Handle:cvar_Bankdefaultautowith = INVALID_HANDLE;
new Handle:cvar_Bankadminlimit = INVALID_HANDLE;
new Handle:cvar_Bankadminflag = INVALID_HANDLE;
new Handle:cvar_Bankresetinterval = INVALID_HANDLE;
new Handle:cvar_Bankprunedb = INVALID_HANDLE;
new Handle:cvar_Bankaddtoadminmenu = INVALID_HANDLE;
new Handle:cvar_mp_maxrounds = INVALID_HANDLE;
new Handle:cvar_mp_maxmoney = INVALID_HANDLE;
new Handle:cvar_mp_halftime = INVALID_HANDLE;
new Handle:cvar_Bankmaxtransfer = INVALID_HANDLE;
new Handle:cvar_Bankdefaultbank = INVALID_HANDLE;
new Handle:cvar_Banklogtransfers = INVALID_HANDLE;
new Handle:cvar_Banklogadmins = INVALID_HANDLE;

new Handle:db = INVALID_HANDLE;
new Handle:hAdminMenu = INVALID_HANDLE;

// CVARS
new String:cvplugin_name[128];
new String:cvintereststr[32];
new String:cvbankadminflag[64];
new Float:cvinterestflt;
new cvbankenable;
new cvfeeint;
new cvmaxbankmoney;
new cvbankannounce;
new cvmindepamount;
new cvpistolround;
new cvminrealplayers;
new cvdefaultautodep;
new cvdefaultautowith;
new cvbankadminlimit;
new cvbankresetinterval;
new cvbankprunedb;
new cvmpmaxmoney;
new cvmpmaxrounds;
new cvmphalftime;
new cvmaxtransfer;
new cvdefaultbank;
new cvlogtransfers;
new cvlogadmins;

new String:plugin_name[128];
new maxclients;
new bankresettimestamp;
new pistolroundsleft = -1;

new bool:IHateFloods[MAXPLAYERS + 1];
new bool:AdminOperation[MAXPLAYERS + 1];
new bool:IsChatInput[MAXPLAYERS + 1] = false;
new bool:IsBankMap;
new bool:IsAdmin[MAXPLAYERS + 1] = false;
new bool:lateLoaded = false;
new bool:IsLastHalftimeRound = false;
new bool:IsGameCsgo = false;

new PlugMes[MAXPLAYERS + 1];
new HideRank[MAXPLAYERS + 1];
new LastMenuAction[MAXPLAYERS + 1];
new AutoDeposit[MAXPLAYERS + 1];
new AutoWithdraw[MAXPLAYERS + 1];
new BankMoney[MAXPLAYERS + 1];
new DBid[MAXPLAYERS + 1];
new TargetClientMenu[MAXPLAYERS + 1];
new ClientChatInput[MAXPLAYERS + 1];

new g_iAccount = -1;
new g_bIsControllingBot = -1;

new bool:DebugMode = false;

#include "cssbank/database.sp"
#include "cssbank/commands.sp"
#include "cssbank/money.sp"
#include "cssbank/menus.sp"

// Plugin definitions
public Plugin:myinfo =
{
	name = "Banco editado por Leandro",
	author = "Miraculix",
	description = "A player can deposit money to the bank, transfer it to other players or withdraw when needed.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1109391"
};

// if the plugin was loaded late we have a bunch of initialization that needs to be done
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	// Backwards compatibility pre csgo/sm1.5
	MarkNativeAsOptional("GetUserMessageType");

	lateLoaded = late;
	return APLRes_Success;
}

public OnPluginStart()
{
	LoadTranslations("cssbank.phrases");

	// ConVars
	cvar_Bankversion = CreateConVar("css_bank_version", PLUGIN_VERSION, "CSS Bank Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cvar_Bankenable = CreateConVar("css_bank_enable","1","Turns Bank On/Off",FCVAR_PLUGIN);
	cvar_Bankmaxbank = CreateConVar("css_bank_maximum","50000","Maximun amount of money players are allowed to have in the bank, 0 to disable (max 2,000,000,000)",FCVAR_PLUGIN);
	cvar_Bankannounce = CreateConVar("css_bank_announce","0","Turns on announcement when a player joins the server, every map or every round:\n0.0 = disabled, 1.0 = every map, 2.0 = every round",FCVAR_PLUGIN, true, 0.0, true, 2.0);
	cvar_Bankdepositfee = CreateConVar("css_bank_deposit_fee","200","Fee, the players must pay for each deposit",FCVAR_PLUGIN);
	cvar_Bankinterest = CreateConVar("css_bank_interest","2.5","% of interest players will get per round",FCVAR_PLUGIN);
	cvar_Bankmindep = CreateConVar("css_bank_min_deposit","1000","Min. deposit amount, 0 to disable",FCVAR_PLUGIN);
	cvar_Bankpistolround = CreateConVar("css_bank_pistolrounds","1","Set the number of pistolrounds the bank is disabled, min. 0",FCVAR_PLUGIN);
	cvar_Bankidentity = CreateConVar("css_bank_identity","CSS Bank","Set the name of your bank",FCVAR_PLUGIN);
	cvar_Bankminplayers = CreateConVar("css_bank_min_players","2","The number of min players to activate bank, min 0",FCVAR_PLUGIN);
	cvar_Bankdbconfig = CreateConVar("css_bank_dbconfig","clientprefs","Set the database configuration listed in databases.cfg",FCVAR_PLUGIN);
	cvar_Bankmapprefixes = CreateConVar("css_bank_mapprefixes"," ","List the map prefixes where the bank is enabled or disabled. Related to the css_bank_mapmode Cvar\nSeparate with commas. e.g.: css_bank_mapprefixes \"gg_,fy_,aim_\"",FCVAR_PLUGIN);
	cvar_Bankmapmode = CreateConVar("css_bank_mapmode","0","0 = Disable bank during listed map prefixes, 1 = disable bank during NON-listed map prefixes (only listed maps enable bank)",FCVAR_PLUGIN);
	cvar_Bankdefaultautodep = CreateConVar("css_bank_autodep","0","Default auto deposit for new player",FCVAR_PLUGIN);
	cvar_Bankdefaultautowith = CreateConVar("css_bank_autowith","0","Default auto withdraw for new player",FCVAR_PLUGIN);
	cvar_Bankadminlimit = CreateConVar("css_bank_adminlimit","0","Maximun amount of money admins are allowed to have in the bank. 0 for no other limit.",FCVAR_PLUGIN);
	cvar_Bankadminflag = CreateConVar("css_bank_adminflag","t","Set the Admin Flag.\nFor mor information: http://wiki.alliedmods.net/Adding_Admins_%28SourceMod%29#Levels\nChanges require to reload plugin or restart server!",FCVAR_PLUGIN);
	cvar_Bankresetinterval = CreateConVar("css_bank_resetinterval","0","Set the number of days the bank should reset periodically, 0 for never",FCVAR_PLUGIN);
	cvar_Bankprunedb = CreateConVar("css_bank_prunedb","0","Set the number of days after inactive players will be deleted, 0 for never",FCVAR_PLUGIN);
	cvar_Bankaddtoadminmenu = CreateConVar("css_bank_add_to_adminmenu","1","Turns the adminmenu On/Off",FCVAR_PLUGIN);
	cvar_Bankmaxtransfer = CreateConVar("css_bank_transfer_limit","0","Maximum amount of money players are allowed to transfer. 0 for no limit",FCVAR_PLUGIN);
	cvar_Bankdefaultbank = CreateConVar("css_bank_default_bankmoney","0","Default amount of money new players get in the bank",FCVAR_PLUGIN);
	cvar_Banklogtransfers = CreateConVar("css_bank_log_transfers","0","Enables transfer logging. 0 = Disable",FCVAR_PLUGIN);
	cvar_Banklogadmins = CreateConVar("css_bank_log_admin_action","0","Enables admin action logging. 0 = Disable",FCVAR_PLUGIN);

	// create config file
	AutoExecConfig(true, "cssbank");

	// commands to use
	RegisterCommands();

	// add to !settings menu
	SetCookieMenuItem(PrefBankMenu, 0, "Bank Menu");

	//For late load
	if (LibraryExists("adminmenu"))
	{
		new Handle:topmenu;
		topmenu = GetAdminTopMenu();

		if (topmenu != INVALID_HANDLE)
			OnAdminMenuReady(topmenu);
	}

	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");

	if (g_iAccount == -1)
		SetFailState("Could not find m_iAccount");

	HookEvent("round_start", EventRoundStart);

	decl String:GameName[32];
	GetGameFolderName(GameName, sizeof(GameName));
	if (StrContains(GameName, "csgo", false) != -1) {
		IsGameCsgo = true;
		g_bIsControllingBot  = FindSendPropInfo("CCSPlayer", "m_bIsControllingBot");
		if (g_bIsControllingBot == -1)
			SetFailState("Unable to locate m_bIsControllingBot");

		HookEvent("announce_phase_end", EventAnnouncePhaseEnd);
	}

	// Update the Plugin Version cvar
	SetConVarString(cvar_Bankversion, PLUGIN_VERSION);

	if (lateLoaded)
	{
		maxclients = MaxClients;
		GetCvars();
		CheckIsBankMap();
	}
}

public OnMapStart()
{
	maxclients = MaxClients;
	IsBankMap = true;
	pistolroundsleft = -1;
}

public OnMapEnd()
{
	IsBankMap = true;

	//UnhookConVarChange(cvar_Bankdbconfig, BankConVarChangedDB);
	//UnhookConVarChange(cvar_Bankenable, BankConVarChangedEn);
}

public OnConfigsExecuted()
{
	GetCvars();
	CheckIsBankMap();

	if (db == INVALID_HANDLE)
		ConnectToDatabase();

	new Flags = GetCommandFlags("bankadmin");
	if (Flags == INVALID_FCVAR_FLAGS)
		RegisterAdminCommand();

	if (lateLoaded)
		CreateTimer(0.2, ReConnectClients);

	HookConVarChange(cvar_Bankdbconfig, BankConVarChangedDB);
	HookConVarChange(cvar_Bankenable, BankConVarChangedEn);

	if (cvbankresetinterval > 0)
		CreateTimer(0.3, ResetBankInterval);
}

public BankConVarChangedEn(Handle:convar, const String:oldValue[], const String:newValue[])
{
	cvbankenable = GetConVarInt(cvar_Bankenable);
}

public BankConVarChangedDB(Handle:convar, const String:oldValue[], const String:newValue[])
{
	ConnectToDatabase();
}

public OnClientAuthorized(client)
{
	if (IsFakeClient(client))
		return;

	IsAdmin[client] = false;
	IsChatInput[client] = false;
	ClientChatInput[client] = 0;

	if (cvbankannounce > 0)
		IHateFloods[client] = true;
}

public OnClientPostAdminCheck(client)
{
	if (IsFakeClient(client))
		return;

	new AdminId:aid = GetUserAdmin(client);
	if (aid != INVALID_ADMIN_ID)
	{
		if (StrEqual(cvbankadminflag, "a", false) || StrEqual(cvbankadminflag, "reservation", false))
		{
			if (GetAdminFlag(aid, Admin_Reservation, Access_Effective))	IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "b", false) || StrEqual(cvbankadminflag, "generic", false))
		{
			if (GetAdminFlag(aid, Admin_Generic, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "c", false) || StrEqual(cvbankadminflag, "kick", false))
		{
			if (GetAdminFlag(aid, Admin_Kick, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "d", false) || StrEqual(cvbankadminflag, "ban", false))
		{
			if (GetAdminFlag(aid, Admin_Ban, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "e", false) || StrEqual(cvbankadminflag, "unban", false))
		{
			if (GetAdminFlag(aid, Admin_Unban, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "f", false) || StrEqual(cvbankadminflag, "slay", false))
		{
			if (GetAdminFlag(aid, Admin_Slay, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "g", false) || StrEqual(cvbankadminflag, "changemap", false))
		{
			if (GetAdminFlag(aid, Admin_Changemap, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "h", false) || StrEqual(cvbankadminflag, "cvar", false))
		{
			if (GetAdminFlag(aid, Admin_Convars, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "i", false) || StrEqual(cvbankadminflag, "config", false))
		{
			if (GetAdminFlag(aid, Admin_Config, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "j", false) || StrEqual(cvbankadminflag, "chat", false))
		{
			if (GetAdminFlag(aid, Admin_Chat, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "k", false) || StrEqual(cvbankadminflag, "vote", false))
		{
			if (GetAdminFlag(aid, Admin_Vote, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "l", false) || StrEqual(cvbankadminflag, "password", false))
		{
			if (GetAdminFlag(aid, Admin_Password, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "m", false) || StrEqual(cvbankadminflag, "rcon", false))
		{
			if (GetAdminFlag(aid, Admin_RCON, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "n", false) || StrEqual(cvbankadminflag, "cheats", false))
		{
			if (GetAdminFlag(aid, Admin_Cheats, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "z", false) || StrEqual(cvbankadminflag, "root ", false))
		{
			if (GetAdminFlag(aid, Admin_Root, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "o", false) || StrEqual(cvbankadminflag, "custom1", false))
		{
			if (GetAdminFlag(aid, Admin_Custom1, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "p", false) || StrEqual(cvbankadminflag, "custom2", false))
		{
			if (GetAdminFlag(aid, Admin_Custom2, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "q", false) || StrEqual(cvbankadminflag, "custom3", false))
		{
			if (GetAdminFlag(aid, Admin_Custom3, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "r", false) || StrEqual(cvbankadminflag, "custom4", false))
		{
			if (GetAdminFlag(aid, Admin_Custom4, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "s", false) || StrEqual(cvbankadminflag, "custom5", false))
		{
			if (GetAdminFlag(aid, Admin_Custom5, Access_Effective)) IsAdmin[client] = true;
		}
		else if (StrEqual(cvbankadminflag, "t", false) || StrEqual(cvbankadminflag, "custom6", false))
		{
			if (GetAdminFlag(aid, Admin_Custom6, Access_Effective)) IsAdmin[client] = true;
		}
	}

	NewClientConnected(client);
}

public OnClientDisconnect(client)
{
	/* for testing disabled (its not really used. probably caused the money-lost bug)
	if (IsClientInGame(client))
		SaveClientInfo(client);
	*/

	IsAdmin[client] = false;
	IsChatInput[client] = false;
	ClientChatInput[client] = 0;
}

// checks player not spectator
IsPlayerInTeam(client)
{
	new Team = GetClientTeam(client);

	if ((Team < 2) || (Team > 3))
		return false;
	// players selected a team, but still no model shouldn't be regarded as in a team
	/*
	// Very bad thing at this position. Moved to round start.
	else if (!IsPlayerAlive(client))
		return false;
	*/

	return true;
}

// checks client
IsValidClient(client)
{
	if (client == 0)
		return false;

	else if (!IsClientConnected(client))
		return false;

	else if (IsFakeClient(client))
		return false;

	else if (!IsClientInGame(client))
		return false;

	return true;
}

// For CSGO
/**
 * Check if a player is controlling a bot
 * @param    client    Player's ClientID
 * @return 1 if player is controlling a bot or 0 if player is not controlling a bot
 */
IsPlayerControllingBot(client)
{
	if (IsGameCsgo)
		return GetEntData(client, g_bIsControllingBot , 1);

	return 0;
}

// counts real player
GetPlayerCount()
{
	new clients = 0;
	for (new i = 1; i <= maxclients; i++)
	{
		if (IsValidClient(i))
			clients++;
	}
	return clients;
}

ChatMessage(player_to, player_from, const String:text[], const String:name[])
{
	new Handle:hMessage = INVALID_HANDLE;

	hMessage = StartMessageOne("SayText2", player_to);

	/*
	BfWrite not working since CSGO update from 2013-01-23
	GetFeatureStatus for backwards compatibility pre csgo/sm1.5
	*/
	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) {
		PbSetInt(hMessage, "ent_idx", player_from);
		PbSetBool(hMessage, "chat", false);
		PbSetString(hMessage, "msg_name", text);

		PbAddString(hMessage, "params", name);
		PbAddString(hMessage, "params", "");
		PbAddString(hMessage, "params", "");
		PbAddString(hMessage, "params", "");
	} else {
		BfWriteByte(hMessage, player_from);
		BfWriteByte(hMessage, 0);
		BfWriteString(hMessage, text);
		BfWriteString(hMessage, name);
	}

	EndMessage();
}

GetCvars()
{
	cvbankenable = GetConVarInt(cvar_Bankenable);
	cvmaxbankmoney = GetConVarInt(cvar_Bankmaxbank);
	cvmaxbankmoney = cvmaxbankmoney == 0 ? 2000000000 : cvmaxbankmoney;
	GetConVarString(cvar_Bankidentity, cvplugin_name, sizeof(cvplugin_name));
	GetConVarString(cvar_Bankinterest, cvintereststr, sizeof(cvintereststr));
	cvfeeint = GetConVarInt(cvar_Bankdepositfee);
	cvinterestflt = GetConVarFloat(cvar_Bankinterest);
	cvbankannounce = GetConVarInt(cvar_Bankannounce);
	cvmindepamount = GetConVarInt(cvar_Bankmindep);
	cvpistolround = GetConVarInt(cvar_Bankpistolround);
	cvminrealplayers = GetConVarInt(cvar_Bankminplayers);
	cvdefaultautodep = GetConVarInt(cvar_Bankdefaultautodep);
	cvdefaultautowith = GetConVarInt(cvar_Bankdefaultautowith);
	cvbankadminlimit = GetConVarInt(cvar_Bankadminlimit);
	cvbankadminlimit = cvbankadminlimit == 0 ? 2000000000 : cvbankadminlimit;
	GetConVarString(cvar_Bankidentity, cvplugin_name, sizeof(cvplugin_name));
	GetConVarString(cvar_Bankadminflag, cvbankadminflag, sizeof(cvbankadminflag));
	cvbankresetinterval = GetConVarInt(cvar_Bankresetinterval);
	cvbankprunedb = GetConVarInt(cvar_Bankprunedb);
	cvmaxtransfer = GetConVarInt(cvar_Bankmaxtransfer);
	cvdefaultbank = GetConVarInt(cvar_Bankdefaultbank);
	cvlogtransfers = GetConVarInt(cvar_Banklogtransfers);
	cvlogadmins = GetConVarInt(cvar_Banklogadmins);

	if (FindConVar("mp_maxmoney")) {
		cvar_mp_maxmoney = FindConVar("mp_maxmoney");
		cvmpmaxmoney = GetConVarInt(cvar_mp_maxmoney);
	} else
		cvmpmaxmoney = 16000;

	cvar_mp_maxrounds = FindConVar("mp_maxrounds");
	cvmpmaxrounds = GetConVarInt(cvar_mp_maxrounds);

	if (FindConVar("mp_halftime")) {
		cvar_mp_halftime = FindConVar("mp_halftime");
		cvmphalftime = GetConVarInt(cvar_mp_halftime);
	} else
		cvmphalftime = 0;

	Format(plugin_name, sizeof(plugin_name), "%c\x0B%c[%s]%c", YELLOW, GREEN, cvplugin_name, YELLOW);
}

bool:IsBankEnable()
{
	if (!cvbankenable) return false;
	else if (!IsBankMap) return false;

	return true;
}

CheckIsBankMap()
{
	new String:cvmapprefixes[128];
	GetConVarString(cvar_Bankmapprefixes, cvmapprefixes, sizeof(cvmapprefixes));

	if (strlen(cvmapprefixes) > 2)
	{
		decl String:curMap[PLATFORM_MAX_PATH+1], String:curMapPre[8];
		new String:curMapEx[3][128];
		GetCurrentMap(curMap, sizeof(curMap));
		new cvbankmode = GetConVarInt(cvar_Bankmapmode);

		// CSGO -> workshop maps
		if (ExplodeString(curMap, "/", curMapEx, 3, 128) > 2)
			strcopy(curMap, sizeof(curMap), curMapEx[2]);

		SplitString(curMap, "_", curMapPre, sizeof(curMapPre));

		if (cvbankmode == 0)
			IsBankMap = StrContains(cvmapprefixes, curMapPre, false) < 0 ? true : false;
		else if (cvbankmode == 1)
			IsBankMap = StrContains(cvmapprefixes, curMapPre, false) < 0 ? false : true;
	}
	else
		IsBankMap = true;
}

WriteActionLog(const String:LogMassage[], any:...)
{
	decl String:sDate[16];
	decl String:sPath[PLATFORM_MAX_PATH];

	decl String:sBuffer[1024];

	FormatTime(sDate, sizeof(sDate), "%Y%m%d");
	VFormat(sBuffer, sizeof(sBuffer), LogMassage, 2);


	BuildPath(Path_SM, sPath, sizeof(sPath), "logs/cssbank_%s.log", sDate);
	LogToFileEx(sPath, sBuffer);
}

bool:IsBankOn(client)
{
	new actrealplayers;
	actrealplayers = GetPlayerCount();

	if (!IsBankEnable()) return false;
	else if (!IsPlayerInTeam(client)) return false;
	else if (actrealplayers < cvminrealplayers) return false;
	else if (IsPistolRound()) return false;
	else if (IsPlayerControllingBot(client)) return false;

	return true;
}

bool:IsBankOnMsg(client)
{
	new actrealplayers;
	actrealplayers = GetPlayerCount();

	if (!IsBankEnable()) return false;
	else if (!IsPlayerInTeam(client)) return false;
	else if (actrealplayers < cvminrealplayers) {
		decl String:minplayers[8], String:minplayersstr[8], String:actualplayers[8];

		IntToString(cvminrealplayers, minplayers, sizeof(minplayers));
		IntToString(actrealplayers, actualplayers, sizeof(actualplayers));

		Format(minplayersstr, sizeof(minplayersstr), "%c%s%c", GREEN, minplayers, YELLOW);
		PrintToChat(client, "%t", "Not enough Players", plugin_name, actualplayers, minplayersstr, minplayers);
		return false;
	} else if (IsPistolRound()) {
		if (cvpistolround == 1)
			PrintToChat(client, "%t", "PistolRoundBlocked", plugin_name);
		else
			PrintToChat(client, "%t", "PistolRoundsBlocked", plugin_name);
		return false;
	} else if (IsPlayerControllingBot(client)) return false;

	return true;
}

bool:IsPistolRound()
{
	if (cvpistolround == 0)
		return false;

	if ((cvmphalftime == 1) && (cvmpmaxrounds == 0) && (pistolroundsleft > -1) && (!IsLastHalftimeRound))
		return true;

	new halfrounds;
	new teamscore_sum;

	teamscore_sum = GetTeamScore(2) + GetTeamScore(3);

	if ((cvmphalftime == 1) && (cvmpmaxrounds > 0))
	{
		halfrounds = cvmpmaxrounds/2;

		if (teamscore_sum >= halfrounds)
			teamscore_sum -= halfrounds;
	}

	if ((cvpistolround <= teamscore_sum) || (IsLastHalftimeRound))
		return false;

	return true;
}

// add to !settings menu
public PrefBankMenu(client, CookieMenuAction:action, any:info, String:buffer[], maxlen)
{
	if (action == CookieMenuAction_SelectOption)
		ShowBankMenu(client);
}

public Action:ReConnectClients(Handle:timer)
{
	for (new i = 1; i <= maxclients ; i++)
	{
		if (!IsValidClient(i)) continue;

		if (cvbankannounce > 0)
			IHateFloods[i] = true;

		new AdminId:aid = GetUserAdmin(i);
		if ((aid != INVALID_ADMIN_ID) && GetAdminFlag(aid, Admin_Generic, Access_Effective))
			IsAdmin[i] = true;
		else
			IsAdmin[i] = false;

		NewClientConnected(i);
	}
}

public Action:ResetBankInterval(Handle:timer)
{
	GetLastResetTimestamp();
	new nextreset = bankresettimestamp + (cvbankresetinterval * 86400);
	if (bankresettimestamp != 0 && GetTime() > nextreset )
		ResetBankMoney();
}

public EventRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!IsBankEnable())
		return;

	IsLastHalftimeRound = false;
	pistolroundsleft--;

	new bankmoney, ingamemoney, autodeposit, autowithdraw;
	new String:MoneyGain[32], String:Money[32];
	new PluginMes;
	for (new i = 1; i <= maxclients ; i++)
	{
		if (!IsValidClient(i)) continue;

		PluginMes = GetPlugMes(i);

		if (IHateFloods[i] && (PluginMes == 1))
		{
			PrintToChat(i, "%t", "Available commands", plugin_name, GREEN, YELLOW, GREEN);
			if (cvbankannounce < 2)
				IHateFloods[i] = false;
		}

		if (!IsBankOn(i)) continue;
		// Players selected a team, but still no model shouldn't be regarded as in a team.
		// If player is not alive, he has not selected a model.
		if (!IsPlayerAlive(i)) continue;

		bankmoney = GetBankMoney(i);
		bankmoney += RoundFloat(FloatMul( float(bankmoney) , cvinterestflt / 100.0 ));

		if (IsAdmin[i] && (cvbankadminlimit > 0))
		{
			if (bankmoney > cvbankadminlimit)
				bankmoney = cvbankadminlimit;
		}
		else if ((cvmaxbankmoney > 0) && (bankmoney > cvmaxbankmoney))
			bankmoney = cvmaxbankmoney;

		if (bankmoney != GetBankMoney(i))
		{
			IntToMoney(bankmoney - GetBankMoney(i), MoneyGain, sizeof(MoneyGain));
			Format(Money, sizeof(Money), "%c%s%c", GREEN, MoneyGain, YELLOW);
			SetBankMoney(i, bankmoney);

			if (PluginMes == 1)
				PrintToChat(i, "%t", "Interested gained", plugin_name, Money);
		}

		ingamemoney = GetIngameMoney(i);
		autodeposit = GetAutoDeposit(i);
		autowithdraw = GetAutoWithdraw(i);

		new String:buffer[32];
		if (autodeposit >= cvmpmaxmoney)
		{
			new autodep = ingamemoney - cvfeeint;
			if (autodep > cvmindepamount)
			{
				IntToString(autodep, buffer, sizeof(buffer));
				DepositClientMoney(i, buffer);
			}
		}
		else if ((autodeposit != 0) && (ingamemoney > autodeposit))
		{
			new autodep = ingamemoney - autodeposit - cvfeeint;
			if (autodep > cvmindepamount)
			{
				IntToString(autodep, buffer, sizeof(buffer));
				DepositClientMoney(i, buffer);
			}
		}
		else if ((autowithdraw != 0) && (ingamemoney < autowithdraw))
		{
			new autowith = autowithdraw - ingamemoney;
			IntToString(autowith, buffer, sizeof(buffer));
			WithdrawClientMoney(i, buffer);
		}
	}
}

public Action:EventAnnouncePhaseEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	IsLastHalftimeRound = true;

	pistolroundsleft = cvpistolround;
}
/*################################################################
##																##
##						Setter/Getter							##
##																##
################################################################*/

SetIngameMoney(client, amount)
{
	if (amount > cvmpmaxmoney)
		amount = cvmpmaxmoney;
	if (amount < 0)
		amount = 0;
	SetEntData(client, g_iAccount, amount, 4, true);
}

GetIngameMoney(client)
{
	return GetEntData(client, g_iAccount, 4);
}

SetBankMoney(client, amount)
{
	if (IsAdmin[client] && (cvbankadminlimit > 0))
	{
		if (amount > cvbankadminlimit)
			amount = cvbankadminlimit;
	}
	else if ((cvmaxbankmoney > 0) && (amount > cvmaxbankmoney))
		amount = cvmaxbankmoney;

	if (amount < 0)
		amount = 0;
	BankMoney[client] = amount;
	SaveClientInfo(client);
}

GetBankMoney(client)
{
	return BankMoney[client];
}

SetAutoDeposit(client, amount)
{
	AutoDeposit[client] = amount;
	SaveClientInfo(client);
}

GetAutoDeposit(client)
{
	return AutoDeposit[client];
}

SetAutoWithdraw(client, amount)
{
	AutoWithdraw[client] = amount;
	SaveClientInfo(client);
}

GetAutoWithdraw(client)
{
	return AutoWithdraw[client];
}

SetHideRank(client, value)
{
	HideRank[client] = value;
	SaveClientInfo(client);
}

GetHideRank(client)
{
	return HideRank[client];
}

SetPlugMes(client, value)
{
	PlugMes[client] = value;
	SaveClientInfo(client);
}

GetPlugMes(client)
{
	return PlugMes[client];
}