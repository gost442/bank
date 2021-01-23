ConnectToDatabase()
{
	if (db != INVALID_HANDLE)
	{
		LogMessage("[%s] Disconnecting DB connection", cvplugin_name);
		CloseHandle(db);
		db = INVALID_HANDLE;
	}

	new String:dbname[PLATFORM_MAX_PATH+1];
	GetConVarString(cvar_Bankdbconfig, dbname, sizeof(dbname));

	if (!SQL_CheckConfig( dbname ))
	{
		LogError("[%s] DB configuration '%s' does not exist, using default.", cvplugin_name, dbname);
		dbname = "clientprefs";
	}
	SQL_TConnect(OnSqlConnect, dbname);
}

public OnSqlConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[%s] Database failure: %s", cvplugin_name, error);
	}
	else
	{
		db = hndl;
		new String:buffer[1024];

		SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
		new ismysql = StrEqual(buffer,"mysql", false) ? 1 : 0;

		if (ismysql == 1)
			Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS `css_bank` (`id` int(64) NOT NULL auto_increment, `steam_id` varchar(32) NOT NULL, `amount` int(64) NOT NULL, `auto_deposit` int(5) NOT NULL, `auto_withdraw` int(5) NOT NULL, `plugin_message` int(1) NOT NULL, `player_name` varchar(128) NOT NULL, `hide_rank` int(1) NOT NULL, `last_accountuse` int(64) NOT NULL, `last_bankreset` int(64) NOT NULL, PRIMARY KEY  (`id`), UNIQUE KEY `steam_id` (`steam_id`))");
		else
			Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS css_bank(id INTEGER PRIMARY KEY AUTOINCREMENT, steam_id TEXT UNIQUE, amount INTEGER, auto_deposit INTEGER, auto_withdraw INTEGER, plugin_message INTEGER, player_name TEXT, hide_rank INTEGER, last_accountuse INTEGER, last_bankreset INTEGER);");

		if (DebugMode)
			LogMessage("[%s]: %s", cvplugin_name, buffer);

		if (!SQL_FastQuery(db, buffer))
		{
			new String:error2[255];
			SQL_GetError(db, error2, sizeof(error2));
			LogError("[%s] Query failure: %s", cvplugin_name, error2);
			LogError("[%s] Query: %s", cvplugin_name, buffer);
		}
		else
		{
			LogMessage("[%s] Connection to DB successful", cvplugin_name);
			if (cvbankprunedb > 0)
				PruneDatabase();
		}
	}
}

public NewClientConnected(client)
{
	DBid[client] = -1;
	PlugMes[client] = 1;
	HideRank[client] = 0;
	AutoDeposit[client] = cvdefaultautodep;
	AutoWithdraw[client] = cvdefaultautowith;
	BankMoney[client] = cvdefaultbank;

	if (IsFakeClient(client))
		return;

	new String:AuthStr[32], String:Name[MAX_NAME_LENGTH + 1];
	if (!GetClientAuthString(client, AuthStr, sizeof(AuthStr)))
	{
		if (!GetClientName( client, Name, sizeof(Name)))
			Format(Name, sizeof(Name), "Client(%d)", client);
		LogError("[%s] SteamID not found: %s", cvplugin_name, Name);
		return;
	}
	new String:AuthStrParts[32][32];
	ExplodeString(AuthStr, ":", AuthStrParts, 2, 32, true);

	decl String:MysqlQuery[512];
	Format(MysqlQuery, sizeof(MysqlQuery), "SELECT id, amount, auto_deposit, auto_withdraw, plugin_message, hide_rank FROM css_bank WHERE steam_id = '%s';", AuthStrParts[1]);

	if (DebugMode)
		LogMessage("[%s]: %s", cvplugin_name, MysqlQuery);

	SQL_TQuery(db, T_NewClientConnected, MysqlQuery, GetClientUserId(client));
}

public T_NewClientConnected(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client;
	if ((client = GetClientOfUserId(data)) == 0)
		return;
	if (IsFakeClient(client))
		return;

	if (hndl == INVALID_HANDLE)
	{
		LogError("[%s] Query failed! %s", cvplugin_name, error);
	}
	else if (!SQL_GetRowCount(hndl))
	{
		new String:AuthStr[32];
		if (!GetClientAuthString(client, AuthStr, sizeof(AuthStr)))
			return;

		new String:AuthStrParts[32][32];
		ExplodeString(AuthStr, ":", AuthStrParts, 2, 32, true);

		new String:Name[MAX_NAME_LENGTH+1];
		new String:SafeName[(sizeof(Name)*2)+1];
		if (!GetClientName(client, Name, sizeof(Name)))
			Format(SafeName, sizeof(SafeName), "<noname>");
		else
		{
			TrimString(Name);
			SQL_EscapeString(db, Name, SafeName, sizeof(SafeName));
		}

		new String:MysqlQuery[512];
		Format(MysqlQuery, sizeof(MysqlQuery), "INSERT INTO css_bank(steam_id, plugin_message, player_name, hide_rank) VALUES('%s', %d, '%s', %d);", AuthStrParts[1], 1, SafeName, 0);

		if (DebugMode)
			LogMessage("[%s]: %s", cvplugin_name, MysqlQuery);

		if (!SQL_FastQuery(db, MysqlQuery))
		{
			new String:error2[255];
			SQL_GetError(db, error2, sizeof(error2));
			LogError("[%s] Query failure: %s", cvplugin_name, error2);
			LogError("[%s] Query: %s", cvplugin_name, MysqlQuery);
		}

		SaveClientInfo(client);
		CheckOldData(client);

		return;
	}

	if (!SQL_FetchRow(hndl))
	{
		LogError("[%s] Query failure: Data exist but not been read!", cvplugin_name);
		return;
	}

	DBid[client] = SQL_FetchInt(hndl, 0);
	BankMoney[client] = SQL_FetchInt(hndl, 1);
	AutoDeposit[client] = SQL_FetchInt(hndl, 2);
	AutoWithdraw[client] = SQL_FetchInt(hndl, 3);
	PlugMes[client] = SQL_FetchInt(hndl, 4);
	HideRank[client] = SQL_FetchInt(hndl, 5);
}

public CheckOldData(client)
{
	new String:AuthStr[32];
	if (!GetClientAuthString(client, AuthStr, sizeof(AuthStr)))
		return;

	new String:AuthStrParts[32][32];
	ExplodeString(AuthStr, ":", AuthStrParts, 2, 32, true);

	decl String:Query[512];
	Format(Query, sizeof(Query), "SELECT amount, auto_deposit, auto_withdraw, plugin_message, hide_rank FROM css_bank WHERE steam_id LIKE '%%:%s';", AuthStrParts[1]);
	if (DebugMode)
		LogMessage("[%s] CheckOldData(client) query: %s", cvplugin_name, Query);
	SQL_TQuery(db, T_CheckOldData, Query, GetClientUserId(client));
}

public T_CheckOldData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client;
	if ((client = GetClientOfUserId(data)) == 0)
		return;

	if (hndl == INVALID_HANDLE)
	{
		LogError("[%s] Query failed! %s", cvplugin_name, error);
		return;
	}

	new i, bank[3], autodep[3], autowith[3], plugmes[3], hiderank[3];

	//if (SQL_HasResultSet(hndl)) // This will return true even if 0 results were returned.
	if (SQL_GetRowCount(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			bank[i] = SQL_FetchInt( hndl, 0);
			autodep[i] = SQL_FetchInt( hndl, 1);
			autowith[i] = SQL_FetchInt( hndl, 2);
			plugmes[i] = SQL_FetchInt( hndl, 3);
			hiderank[i] = SQL_FetchInt( hndl, 4);
			i++;
		}

		SortIntegers(autodep, 3, Sort_Descending);
		SortIntegers(autowith, 3, Sort_Descending);
		//SortIntegers(plugmes, 3, Sort_Descending); //doesn't work reasonably
		SortIntegers(hiderank, 3, Sort_Descending);

		BankMoney[client] = bank[0] + bank[1];
		AutoDeposit[client] = autodep[0];
		AutoWithdraw[client] = autowith[0];
		//PlugMes[client] = plugmes[0] == plugmes[1] ? plugmes[1] : plugmes[0]; //doesn't work reasonably
		PlugMes[client] = 1;
		HideRank[client] = hiderank[0];

		DeleteOldData(client);
	}
}

public DeleteOldData(client)
{
	if (db == INVALID_HANDLE)
	{
		LogError("[%s] Delete Old Data: No connection", cvplugin_name);
		return;
	}

	decl String:buffer[1024];
	SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
	new ismysql = StrEqual(buffer,"mysql", false) ? 1 : 0;

	new String:AuthStr[32];
	if (!GetClientAuthString(client, AuthStr, sizeof(AuthStr)))
		return;

	new String:AuthStrParts[32][32];
	ExplodeString(AuthStr, ":", AuthStrParts, 2, 32, true);

	if (ismysql == 1)
		Format(buffer, sizeof(buffer), "DELETE FROM `css_bank` WHERE `steam_id` LIKE '%%:%s';", AuthStrParts[1]);
	else
		Format(buffer, sizeof(buffer), "DELETE FROM css_bank WHERE steam_id LIKE '%%:%s';", AuthStrParts[1]);

	if (DebugMode)
		LogMessage("[%s] DeleteOldData(client) query: %s", cvplugin_name, buffer);

	if (!SQL_FastQuery(db, buffer))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer);
	}
	else
	{
		new String:Name[MAX_NAME_LENGTH + 1];
		GetClientName( client, Name, sizeof(Name));

		SaveClientInfo(client);
		LogMessage("[%s] Old data from %s (STEAM_x:%s) merged and deleted successfully!", cvplugin_name, Name, AuthStrParts[1]);
	}
}

SaveClientInfo(client)
{
	if (IsFakeClient(client))
		return;

	new String:MysqlQuery[512], String:Name[MAX_NAME_LENGTH+1];
	new String:SafeName[(sizeof(Name)*2)+1];

	if (!GetClientName( client, Name, sizeof(Name)))
		Format(SafeName, sizeof(SafeName), "<noname>");
	else
	{
		TrimString(Name);
		SQL_EscapeString(db, Name, SafeName, sizeof(SafeName));
	}

	if (DBid[client] < 1)
	{
		new String:AuthStr[32];
		if (!GetClientAuthString(client, AuthStr, sizeof(AuthStr)))
			return;

		new String:AuthStrParts[32][32];
		ExplodeString(AuthStr, ":", AuthStrParts, 2, 32, true);

		Format(MysqlQuery, sizeof(MysqlQuery), "UPDATE css_bank SET amount = %d, auto_deposit = %d, auto_withdraw = %d, plugin_message = %d, player_name = '%s', hide_rank = %d, last_accountuse = %d WHERE steam_id = '%s';", BankMoney[client], AutoDeposit[client], AutoWithdraw[client], PlugMes[client], SafeName, HideRank[client], GetTime(), AuthStrParts[1]);

		if (DebugMode)
			LogMessage("[%s]: %s", cvplugin_name, MysqlQuery);
	}
	else
	{
		Format(MysqlQuery, sizeof(MysqlQuery), "UPDATE css_bank SET amount = %d, auto_deposit = %d, auto_withdraw = %d, plugin_message = %d, player_name = '%s', hide_rank = %d, last_accountuse = %d WHERE id = %d;", BankMoney[client], AutoDeposit[client], AutoWithdraw[client], PlugMes[client], SafeName, HideRank[client], GetTime(), DBid[client]);

		if (DebugMode)
			LogMessage("[%s]: %s", cvplugin_name, MysqlQuery);
	}

	if (!SQL_FastQuery(db, MysqlQuery))
	{
		new String:error2[255];
		SQL_GetError(db, error2, sizeof(error2));
		LogError("[%s] Query failure: %s", cvplugin_name, error2);
		LogError("[%s] Query: %s", cvplugin_name, MysqlQuery);
	}
}

public GetTop10(client)
{
	decl String:Query[512];
	Format(Query, sizeof(Query), "SELECT player_name, amount FROM css_bank WHERE amount > 0 AND hide_rank NOT LIKE 1 ORDER BY amount DESC LIMIT 0, 10;");
	SQL_TQuery(db, T_GetTop10, Query, GetClientUserId(client));
}

public T_GetTop10(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client;
	if ((client = GetClientOfUserId(data)) == 0)
		return;

	if (hndl == INVALID_HANDLE)
	{
		LogError("[%s] Query failed! %s", cvplugin_name, error);
		return;
	}

	new String:title[128], String:title2[128];
	new Handle:panel = CreatePanel();

	Format(title, sizeof(title), "%s\n \n", cvplugin_name);
	SetPanelTitle(panel, title);

	SetPanelKeys(panel, (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9));

	Format(title2, sizeof(title2), "%T", "Top10", client);
	DrawPanelItem( panel, title2);

	new i, String:name[MAX_NAME_LENGTH+1], amount, String:player[128], String:money[32];

	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			i++;
			SQL_FetchString(hndl, 0, name, sizeof(name));
			amount = SQL_FetchInt(hndl,1);

			IntToMoney(amount, money, sizeof(money));
			if (i < 10)
				Format(player, sizeof(player), "   %d. %s  -  %s", i, money, name);
			else
				Format(player, sizeof(player), " %d. %s  -  %s", i, money, name);
			DrawPanelText( panel, player);
		}
	}
	else
	{
			DrawPanelText(panel, " ");
	}

	SendPanelToClient(panel, client, Top10PanelHandler, 20);

	CloseHandle(panel);
}

public GetLastResetTimestamp()
{
	decl String:Query[512];
	Format(Query, sizeof(Query), "SELECT last_bankreset FROM css_bank WHERE last_bankreset > 0 LIMIT 0, 1;");
	SQL_TQuery(db, T_GetLastResetTimestamp, Query);
}

public T_GetLastResetTimestamp(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	bankresettimestamp = 0;

	if (hndl == INVALID_HANDLE)
	{
		LogError("[%s] Query failed! %s", cvplugin_name, error);
		return;
	}

	if (SQL_HasResultSet(hndl))
	{
		if (SQL_FetchRow(hndl))
			bankresettimestamp = SQL_FetchInt(hndl,0);
	}
}

public PruneDatabase()
{
	if (db == INVALID_HANDLE)
	{
		LogError("[%s] Prune Database: No connection", cvplugin_name);
		return;
	}

	new maxlastaccuse;
	maxlastaccuse = GetTime() - (cvbankprunedb * 86400);

	decl String:buffer[1024];
	SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
	new ismysql = StrEqual(buffer,"mysql", false) ? 1 : 0;

	if (ismysql == 1)
		Format(buffer, sizeof(buffer), "DELETE FROM `css_bank` WHERE `last_accountuse`<'%d' AND `last_accountuse`>'0';", maxlastaccuse);
	else
		Format(buffer, sizeof(buffer), "DELETE FROM css_bank WHERE last_accountuse<'%d' AND last_accountuse>'0';", maxlastaccuse);

	if (!SQL_FastQuery(db, buffer))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer);
	}
	else
		LogMessage("[%s] Prune Database successful", cvplugin_name);
}

public ResetBankAll()
{
	if (db == INVALID_HANDLE)
	{
		LogError("[%s] Reset Bank All: No connection", cvplugin_name);
		return;
	}

	decl String:buffer[1024];
	Format(buffer, sizeof(buffer), "DROP TABLE css_bank;");

	if (!SQL_FastQuery(db, buffer))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer);
	}

	SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
	new ismysql = StrEqual(buffer,"mysql", false) ? 1 : 0;

	if (ismysql == 1)
		Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS `css_bank` (`id` int(64) NOT NULL auto_increment, `steam_id` varchar(32) NOT NULL, `amount` int(64) NOT NULL, `auto_deposit` int(5) NOT NULL, `auto_withdraw` int(5) NOT NULL, `plugin_message` int(1) NOT NULL, `player_name` varchar(128) NOT NULL, `hide_rank` int(1) NOT NULL, `last_accountuse` int(64) NOT NULL, `last_bankreset` int(64) NOT NULL, PRIMARY KEY  (`id`), UNIQUE KEY `steam_id` (`steam_id`))");
	else
		Format(buffer, sizeof(buffer), "CREATE TABLE IF NOT EXISTS css_bank(id INTEGER PRIMARY KEY AUTOINCREMENT, steam_id TEXT UNIQUE, amount INTEGER, auto_deposit INTEGER, auto_withdraw INTEGER, plugin_message INTEGER, player_name TEXT, hide_rank INTEGER, last_accountuse INTEGER, last_bankreset INTEGER);");

	if (!SQL_FastQuery(db, buffer))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer);
	}
	else
	{
		CreateTimer(0.2, ReConnectClients);
		LogMessage("[%s] Complete reset successful", cvplugin_name);
	}
}

public ResetBankMoney()
{
	if (db == INVALID_HANDLE)
	{
		LogError("[%s] Reset Bank Money: No connection", cvplugin_name);
		return;
	}

	decl String:Query[512];

	Format(Query, sizeof(Query), "UPDATE css_bank SET amount = %d", 0);

	if (!SQL_FastQuery(db, Query))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, Query);
	}

	Format(Query, sizeof(Query), "UPDATE css_bank SET last_bankreset = %d", GetTime());

	if (!SQL_FastQuery(db, Query))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, Query);
	}
	else
		LogMessage("[%s] Money reset successful", cvplugin_name);

	for (new i = 1; i <= maxclients ; i++)
	{
		BankMoney[i] = 0;
	}
}

public ResetBankMessage()
{
	if (db == INVALID_HANDLE)
	{
		LogError("[%s] Reset Bank Message: No connection", cvplugin_name);
		return;
	}

	decl String:Query[512];

	Format(Query, sizeof(Query), "UPDATE css_bank SET plugin_message = %d", 1);

	if (!SQL_FastQuery(db, Query))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, Query);
	}
	else
		LogMessage("[%s] Message reset successful", cvplugin_name);

	for (new i = 1; i <= maxclients ; i++)
	{
		PlugMes[i] = 1;
	}
}

public CleanUpDatabase()
{
	if (db == INVALID_HANDLE)
	{
		LogError("[%s] Clean Up Database: No connection", cvplugin_name);
		return;
	}

	decl String:buffer[1024];
	SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
	new ismysql = StrEqual(buffer,"mysql", false) ? 1 : 0;

	if (ismysql == 1)
		Format(buffer, sizeof(buffer), "DELETE FROM `css_bank` WHERE `amount`='0' AND `auto_deposit`='0' AND `auto_withdraw`='0' AND `hide_rank`='0' AND `plugin_message`='1';");
	else
		Format(buffer, sizeof(buffer), "DELETE FROM css_bank WHERE amount='0' AND auto_deposit='0' AND auto_withdraw='0' AND hide_rank='0' AND plugin_message='1';");

	if (!SQL_FastQuery(db, buffer))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer);
	}
	else
		LogMessage("[%s] Database clean up successfully!", cvplugin_name);
}

public UpdateBankDatabase()
{
	if (db == INVALID_HANDLE)
	{
		LogError("[%s] Update Bank Database: No connection", cvplugin_name);
		return;
	}


	decl String:buffer[1024], String:buffer2[1024], String:buffer3[1024], String:buffer4[1024];
	SQL_GetDriverIdent(SQL_ReadDriver(db), buffer, sizeof(buffer));
	new ismysql = StrEqual(buffer,"mysql", false) ? 1 : 0;

	if (ismysql == 1)
	{
		Format(buffer, sizeof(buffer), "ALTER TABLE `css_bank` ADD `last_accountuse` int(64) NOT NULL;");
		Format(buffer2, sizeof(buffer2), "ALTER TABLE `css_bank` ADD `last_bankreset` int(64) NOT NULL;");
		Format(buffer3, sizeof(buffer3), "UPDATE `css_bank` SET `last_accountuse` = '%d';", GetTime());
		Format(buffer4, sizeof(buffer4), "UPDATE `css_bank` SET `last_bankreset` = '%d';", GetTime());
	}
	else
	{
		Format(buffer, sizeof(buffer), "ALTER TABLE css_bank ADD last_accountuse INTEGER");
		Format(buffer2, sizeof(buffer2), "ALTER TABLE css_bank ADD last_bankreset INTEGER");
		Format(buffer3, sizeof(buffer3), "UPDATE css_bank SET last_accountuse = %d", GetTime());
		Format(buffer4, sizeof(buffer4), "UPDATE css_bank SET last_bankreset = %d", GetTime());
	}

	if (!SQL_FastQuery(db, buffer))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		if (StrContains(error, "Duplicate column name", false) != -1)
			LogMessage("[%s] Database already up to date!", cvplugin_name);
		else
		{
			LogError("[%s] Query failure: %s", cvplugin_name, error);
			LogError("[%s] Query: %s", cvplugin_name, buffer);
		}
	}
	else if (!SQL_FastQuery(db, buffer2))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer2);
	}
	else if (!SQL_FastQuery(db, buffer3))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer3);
	}
	else if (!SQL_FastQuery(db, buffer4))
	{
		new String:error[255];
		SQL_GetError(db, error, sizeof(error));
		LogError("[%s] Query failure: %s", cvplugin_name, error);
		LogError("[%s] Query: %s", cvplugin_name, buffer4);
	}
	else
	{
		CreateTimer(0.2, ReConnectClients);
		LogMessage("[%s] Update successful to v%s", cvplugin_name, PLUGIN_VERSION);
	}
}