/*################################################################
##																##
##							Handler								##
##																##
################################################################*/

public BankMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		if (!found)
			return;

		LastMenuAction[client] = param2;

		switch(param2)
		{
			case 0:
			{
				new igmoney = GetIngameMoney(client);
				new minded = cvmindepamount + cvfeeint;
				if ((igmoney < minded) || (igmoney == 0))
				{
					new String:money[32], String:moneystr[32];
					IntToMoney(minded, money, sizeof(money));
					Format(moneystr, sizeof(moneystr), "%c%s%c", GREEN, money, YELLOW);
					PrintToChat(client, "%t", "Need At Least", plugin_name, moneystr);
					return;
				}
				else
				{
					ShowDepositMenu(client);
				}
			}
			case 1:
			{
				if (GetBankMoney(client) == 0)
				{
					PrintToChat(client, "%t", "No Bank Money", plugin_name);
					return;
				}
				else
				{
					ShowWithdrawMenu(client);
				}
			}
			case 2:
			{
				ShowPlayerMenu(client);
			}
			case 3:
			{
				ShowSettingsMenu(client);
			}
			case 4:
			{
				GetTop10(client);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public PlayerMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		if (!found)
			return;

		TargetClientMenu[client] = StringToInt(info);

		if (!IsValidClient(TargetClientMenu[client]))
		{
			PrintToChat(client, "%t", "False Target", plugin_name);
			CloseHandle(menu);
			return;
		}

		GetClientName(TargetClientMenu[client], info, sizeof(info));

		new Handle:menu2 = CreateMenu(AmountMenuHandler);
		SetMenuTitle(menu2, "%s\n \n%s:", cvplugin_name, info);
		BuildAmountMenu(Handle:menu2, client);
		SetMenuExitBackButton(menu2, true);
		DisplayMenu(menu2, client, 20);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == -6)
		{
			if (AdminOperation[client])
				ShowBankAdminMenu(client);
			else
				ShowBankMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public AmountMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		if (!found)
			return;

		switch(LastMenuAction[client])
		{
			case 0:
			{
				DepositClientMoney(client, info);
			}
			case 1:
			{
				WithdrawClientMoney(client, info);
			}
			case 2:
			{
				if (StrEqual (info, "Free Input", false))
				{
					IsChatInput[client] = true;
					PrintToChat(client, "%t", "Amount Chat Input", plugin_name);
					return;
				}
				else
					TransferClientMoney(client, TargetClientMenu[client], info);
			}
			case 10:
			{
				new amount = StringToInt(info);
				SetAutoDeposit(client, amount);
			}
			case 11:
			{
				new amount = StringToInt(info);
				SetAutoWithdraw(client, amount);
			}
			case 100:
			{
				if (StrEqual (info, "Free Input", false))
				{
					IsChatInput[client] = true;
					PrintToChat(client, "%t", "Amount Chat Input", plugin_name);
					return;
				}
				else
					AdminClientMoney(client, TargetClientMenu[client], info, true);
			}
			case 101:
			{
				if (StrEqual (info, "Free Input", false))
				{
					IsChatInput[client] = true;
					PrintToChat(client, "%t", "Amount Chat Input", plugin_name);
					return;
				}
				else
					AdminClientMoney(client, TargetClientMenu[client], info, _, true);
			}
			case 102:
			{
				if (StrEqual (info, "Free Input", false))
				{
					IsChatInput[client] = true;
					PrintToChat(client, "%t", "Amount Chat Input", plugin_name);
					return;
				}
				else
					AdminClientMoney(client, TargetClientMenu[client], info);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == -6)
			switch(LastMenuAction[client])
			{
				case 0,1,10,11:
				{
					ShowBankMenu(client);
				}
				case 2,100,101,102:
				{
					ShowPlayerMenu(client);
				}
			}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public BuildAmountMenu(Handle:menu2, client)
{
	decl String:dummy[32], String:money[PLATFORM_MAX_PATH+1];
	new String:amounts[32][32];
	new menumoney;

	// admin set amounts
	if (LastMenuAction[client] == 102)
	{
		Format(dummy, sizeof(dummy), "%T", "Amount Free Input", LANG_SERVER);
		AddMenuItem(menu2, "Free Input", dummy);

		Format(money, sizeof(money), "%T", "Admin Setmoney Amounts", LANG_SERVER);
		new count = ExplodeString(money, ",", amounts, 32, 32);
		for (new i = 0; i < count; i++)
		{
			menumoney = StringToInt(amounts[i]);
			IntToMoney(menumoney, dummy , sizeof(dummy));
			AddMenuItem(menu2, amounts[i], dummy);
		}
	}
	// deposit/withdraw amounts
	else if ((LastMenuAction[client] == 0) || (LastMenuAction[client] == 1) || (LastMenuAction[client] == 10) || (LastMenuAction[client] == 11))
	{
		Format(money, sizeof(money), "%T", "Amount Menu Amounts", LANG_SERVER);
		new count = ExplodeString(money, ",", amounts, 32, 32);
		for (new i = 0; i < count; i++)
		{
			if (!StringToInt(amounts[i]))
			{
				dummy = amounts[i];
				IntToString(cvmpmaxmoney, amounts[i], 32);
			}
			else
			{
				menumoney = StringToInt(amounts[i]);
				IntToMoney(menumoney, dummy , sizeof(dummy));
			}
			AddMenuItem(menu2, amounts[i], dummy);
		}
	}
	// transfer amounts + admin add/remove
	// should be free input or sth else in future <- done
	else
	{
		Format(dummy, sizeof(dummy), "%T", "Amount Free Input", LANG_SERVER);
		AddMenuItem(menu2, "Free Input", dummy);

		Format(money, sizeof(money), "%T", "Amounts Transfer AddRemove", LANG_SERVER);
		new count = ExplodeString(money, ",", amounts, 32, 32);
		for (new i = 0; i < count; i++)
		{
			if (StringToIntEx(amounts[i], menumoney))
			{
				IntToMoney(menumoney, dummy , sizeof(dummy));
				AddMenuItem(menu2, amounts[i], dummy);
			}
		}
	}
}

public BankSettingsMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		if (!found)
			return;

		LastMenuAction[client] = param2 + 10;

		switch(param2)
		{
			case 0,1:
			{
				new Handle:menu2 = CreateMenu(AmountMenuHandler);
				decl String:buffer[PLATFORM_MAX_PATH+1];
				switch(param2)
				{
					case 0:
					{
						Format(buffer, sizeof(buffer), "%T", "Bank Menu AutoDeposit", client);
						SetMenuTitle(menu2, "%s\n \n%s:", cvplugin_name, buffer);
					}
					case 1:
					{
						Format(buffer, sizeof(buffer), "%T", "Bank Menu AutoWithdraw", client);
						SetMenuTitle(menu2, "%s\n \n%s:", cvplugin_name, buffer);
					}
				}
				AddMenuItem(menu2, "0", "Off");
				BuildAmountMenu(Handle:menu2, client);
				SetMenuExitBackButton(menu2, true);
				DisplayMenu(menu2, client, 20);
			}
			case 2:
			{
				if (GetHideRank(client) == 0)
					SetHideRank(client, 1);
				else
					SetHideRank(client, 0);

				ShowSettingsMenu(client);
			}
			case 3:
			{
				if (GetPlugMes(client) == 0)
					SetPlugMes(client, 1);
				else
					SetPlugMes(client, 0);

				ShowSettingsMenu(client);
			}
			case 4:
			{
				new Handle:menu2 = CreateMenu(SecurityMenuHandler);
				decl String:buffer[PLATFORM_MAX_PATH+1];
				Format(buffer, sizeof(buffer), "%T", "Bank Menu Reset", client);
				SetMenuTitle(menu2, "%s\n \n%s:", cvplugin_name, buffer);
				AddMenuItem(menu2, "0", "Yes");
				AddMenuItem(menu2, "1", "No");
				DisplayMenu(menu2, client, 20);
			}
		}
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == -6)
		{
			ShowBankMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public SecurityMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		if (!found)
			return;

		switch(param2)
		{
			case 0:
			{
				BankMoney[client] = 0;
				SaveClientInfo(client);
				PrintToChat(client, "%t", "BankResetSuccessfully", plugin_name);
			}
			case 1:
			{
				ShowSettingsMenu(client);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Top10PanelHandler(Handle:panel, MenuAction:action, client, param2){}

public BankAdminMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		if (!found)
			return;

		LastMenuAction[client] = param2 + 100;

		switch(param2)
		{
			case 0,1,2:
			{
				ShowPlayerMenu(client);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

/*################################################################
##																##
##							Shows								##
##																##
################################################################*/

ShowBankMenu(client)
{
	decl String:balance[64], String:fee[64], String:intstr[64], String:autodepo[64], String:autowithdr[64];
	decl String:Title[1024], String:TitleInfo[1024];

	IntToMoney(GetBankMoney(client), balance, sizeof(balance));
	IntToMoney(GetAutoDeposit(client), autodepo, sizeof(autodepo));
	IntToMoney(GetAutoWithdraw(client), autowithdr, sizeof(autowithdr));
	IntToMoney(cvfeeint, fee, sizeof(fee));
	Format(intstr, sizeof(intstr), "%s%c%c", cvintereststr, 0x25, 0x25);

	Format(TitleInfo, sizeof(TitleInfo), "%T", "Bank Menu Info", client, balance, intstr, fee, autodepo, autowithdr);
	Format(Title, sizeof(Title), "%s\n \n%s\n \n", cvplugin_name, TitleInfo);

	new Handle:menu = CreateMenu(BankMenuHandler);
	SetMenuTitle(menu, Title);

	new style:item;
	if (!IsBankOn(client))
		item = style:ITEMDRAW_DISABLED;
	else
		item = style:ITEMDRAW_DEFAULT;

	decl String:buffer[PLATFORM_MAX_PATH+1];

	Format(buffer, sizeof(buffer), "%T", "Bank Menu Deposit", client);
	AddMenuItem(menu, "deposit", buffer, item);
	Format(buffer, sizeof(buffer), "%T", "Bank Menu Withdraw", client);
	AddMenuItem(menu, "withdraw", buffer, item);
	Format(buffer, sizeof(buffer), "%T", "Bank Menu Transfer", client);
	AddMenuItem(menu, "transfer", buffer, item);
	Format(buffer, sizeof(buffer), "%T", "Bank Menu Settings", client);
	AddMenuItem(menu, "settings", buffer);
	Format(buffer, sizeof(buffer), "%T", "Bank Menu Top10", client);
	AddMenuItem(menu, "top10", buffer);

	DisplayMenu(menu, client, 20);
}

ShowDepositMenu(client)
{
	decl String:buffer[PLATFORM_MAX_PATH+1];
	LastMenuAction[client] = 0;
	new Handle:menu2 = CreateMenu(AmountMenuHandler);
	Format(buffer, sizeof(buffer), "%T", "Bank Menu Deposit", client);
	SetMenuTitle(menu2, "%s\n \n%s:", cvplugin_name, buffer);
	BuildAmountMenu(Handle:menu2, client);
	SetMenuExitBackButton(menu2, true);
	DisplayMenu(menu2, client, 20);
}

ShowWithdrawMenu(client)
{
	decl String:buffer[PLATFORM_MAX_PATH+1];
	LastMenuAction[client] = 1;
	new Handle:menu2 = CreateMenu(AmountMenuHandler);
	Format(buffer, sizeof(buffer), "%T", "Bank Menu Withdraw", client);
	SetMenuTitle(menu2, "%s\n \n%s:", cvplugin_name, buffer);
	BuildAmountMenu(Handle:menu2, client);
	SetMenuExitBackButton(menu2, true);
	DisplayMenu(menu2, client, 20);
}

ShowPlayerMenu(client)
{
	new Handle:menu = CreateMenu(PlayerMenuHandler);
	new String:name[MAX_NAME_LENGTH+1], String:id[32], String:buffer[PLATFORM_MAX_PATH+1];

	Format(buffer, sizeof(buffer), "%T", "Choose Player", client);
	SetMenuTitle(menu, "%s\n \n%s:", cvplugin_name, buffer);

	if (LastMenuAction[client] >= 100)
	{
		GetClientName(client, name, sizeof(name));
		IntToString(client, id, sizeof(id));
		AddMenuItem(menu, id, name);
	}
	if (GetPlayerCount() > 1)
	{
		new j;
		for (new i = 1; i <= maxclients; i++)
		{
			j = i;
			if (!IsValidClient(j)) continue;
			if (client == j) continue;

			GetClientName(j, name, sizeof(name));
			IntToString(j, id, sizeof(id));
			AddMenuItem(menu, id, name);
		}
	}
	else if (LastMenuAction[client] >= 100)
	{
		PrintToChat(client, "%t", "No Other Player", plugin_name);
	}
	else
	{
		PrintToChat(client, "%t", "No Other Player", plugin_name);
		CloseHandle(menu);
		return;
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, 20);
}

ShowSettingsMenu(client)
{
	decl String:buffer[PLATFORM_MAX_PATH+1];

	new Handle:menu = CreateMenu(BankSettingsMenuHandler);

	Format(buffer, sizeof(buffer), "%T", "Bank Menu Settings", client);
	SetMenuTitle(menu, "%s\n \n%s:", cvplugin_name, buffer);

	Format(buffer, sizeof(buffer), "%T", "Bank Menu AutoDeposit", client);
	AddMenuItem(menu, "autodep", buffer);
	Format(buffer, sizeof(buffer), "%T", "Bank Menu AutoWithdraw", client);
	AddMenuItem(menu, "autowith", buffer);
	if (GetHideRank(client) == 0)
	{
		Format(buffer, sizeof(buffer), "%T", "Bank Menu HideRank", client);
		AddMenuItem(menu, "hiderank", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "Bank Menu ShowRank", client);
		AddMenuItem(menu, "showrank", buffer);
	}
	if (GetPlugMes(client) == 0)
	{
		Format(buffer, sizeof(buffer), "%T", "Bank Menu MessagesOn", client);
		AddMenuItem(menu, "messages", buffer);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "Bank Menu MessagesOff", client);
		AddMenuItem(menu, "messages", buffer);
	}
	Format(buffer, sizeof(buffer), "%T", "Bank Menu Reset", client);
	AddMenuItem(menu, "reset", buffer);

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, 20);
}

ShowBankStatus(client)
{
	decl String:money[32], String:moneystr[32];
	new bankmoney;
	bankmoney = GetBankMoney(client);
	IntToMoney( bankmoney , money, sizeof(money));
	Format(moneystr, sizeof(moneystr), "%c%s%c", GREEN, money, YELLOW);
	PrintToChat(client, "%t", "Bankstatus", plugin_name, moneystr);
}

ShowBankAdminMenu(client)
{
	decl String:buffer[PLATFORM_MAX_PATH+1];

	new Handle:menu = CreateMenu(BankAdminMenuHandler);

	Format(buffer, sizeof(buffer), "%T", "Admin Menu Title", client);
	SetMenuTitle(menu, "%s\n \n%s:", cvplugin_name, buffer);

	Format(buffer, sizeof(buffer), "%T", "Admin Menu Add", client);
	AddMenuItem(menu, "add", buffer);
	Format(buffer, sizeof(buffer), "%T", "Admin Menu Remove", client);
	AddMenuItem(menu, "remove", buffer);
	Format(buffer, sizeof(buffer), "%T", "Admin Menu Setmoney", client);
	AddMenuItem(menu, "setmoney", buffer);

	DisplayMenu(menu, client, 20);
}

/*################################################################
##																##
##							Adminmenu							##
##																##
################################################################*/

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "adminmenu"))
		hAdminMenu = INVALID_HANDLE;
}

public OnAdminMenuReady(Handle:topmenu)
{
	// Block us from being called twice
	if (topmenu == hAdminMenu)
		return;

	// Do not call if admin menu entry is not enabled
	if (GetConVarInt(cvar_Bankaddtoadminmenu) != 1)
		return;

	hAdminMenu = topmenu;

	new TopMenuObject:player_commands = FindTopMenuCategory(hAdminMenu, "cssbank");

	if (player_commands == INVALID_TOPMENUOBJECT)
	{
		player_commands = AddToTopMenu(
		hAdminMenu,		// Menu
		"cssbank",		// Name
		TopMenuObject_Category,	// Type
		Handle_Category,	// Callback
		INVALID_TOPMENUOBJECT	// Parent
		);
	}

	AddToTopMenu(hAdminMenu, "bankadmin_add", TopMenuObject_Item, AdminMenu_Bank_Add, player_commands, "", ADMFLAG_GENERIC);
	AddToTopMenu(hAdminMenu, "bankadmin_rem", TopMenuObject_Item, AdminMenu_Bank_Rem, player_commands, "", ADMFLAG_GENERIC);
	AddToTopMenu(hAdminMenu, "bankadmin_set", TopMenuObject_Item, AdminMenu_Bank_Set, player_commands, "", ADMFLAG_GENERIC);
}

public Handle_Category( Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength )
{
	switch(action)
	{
		case TopMenuAction_DisplayTitle:
			Format(buffer, maxlength, "%T", "Admin Menu Title", param);
		case TopMenuAction_DisplayOption:
			Format(buffer, maxlength, "%T", "Admin Menu Title", param);
	}
}

public AdminMenu_Bank_Add(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Admin Menu Add", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		if (IsAdmin[param])
		{
			AdminOperation[param] = true;
			LastMenuAction[param] = 100;
			ShowPlayerMenu(param);
		}
		else
			PrintToChat(param, "[SM] You do not have access to this command.");
	}
}

public AdminMenu_Bank_Rem(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Admin Menu Remove", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		if (IsAdmin[param])
		{
			AdminOperation[param] = true;
			LastMenuAction[param] = 101;
			ShowPlayerMenu(param);
		}
		else
			PrintToChat(param, "[SM] You do not have access to this command.");
	}
}

public AdminMenu_Bank_Set(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Admin Menu Setmoney", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		if (IsAdmin[param])
		{
			AdminOperation[param] = true;
			LastMenuAction[param] = 102;
			ShowPlayerMenu(param);
		}
		else
			PrintToChat(param, "[SM] You do not have access to this command.");
	}
}
