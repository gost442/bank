RegisterCommands()
{
	AddCommandListener(ChatInput, "say");
	AddCommandListener(ChatInput, "say_team");

	RegConsoleCmd("banco", BankMenu, "Display a menu with the Bank functions");
	RegConsoleCmd("deposito", Deposit, "Display a menu with amounts to deposit / with <all|amount>: to deposit all or typed amount");
	RegConsoleCmd("retirar", WithDraw, "Display a menu with amounts to withdraw / with <all|amount>: to withdraw all (max 16000) or typed amount");
	RegConsoleCmd("bancostatus", BankStatus, "Prints the current bankstatus to the chat");

	RegServerCmd("bbresetdd", CommandResetBankAll, "resets the hole bank");
	RegServerCmd("bbresetddm", CommandResetBankMoney, "resets only money amounts");
	RegServerCmd("bbresetddsms", CommandResetBankMessage, "resets message setting to default (1) for all players");
	RegServerCmd("bbresetddu", CommandUpdateBankDatabase, "to update the bank from v1.3.2 or older to v1.4");
	RegServerCmd("bbresetddclean", CommandCleanUpDatabase, "to clean up database (deletes redundant entries)");
}

RegisterAdminCommand()
{
	if (StrEqual(cvbankadminflag, "a", false) || StrEqual(cvbankadminflag, "reservation", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_RESERVATION, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "b", false) || StrEqual(cvbankadminflag, "generic", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_GENERIC, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "c", false) || StrEqual(cvbankadminflag, "kick", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_KICK, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "d", false) || StrEqual(cvbankadminflag, "ban", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_BAN, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "e", false) || StrEqual(cvbankadminflag, "unban", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_UNBAN, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "f", false) || StrEqual(cvbankadminflag, "slay", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_SLAY, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "g", false) || StrEqual(cvbankadminflag, "changemap", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CHANGEMAP, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "h", false) || StrEqual(cvbankadminflag, "cvar", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CONVARS, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "i", false) || StrEqual(cvbankadminflag, "config", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CONFIG, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "j", false) || StrEqual(cvbankadminflag, "chat", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CHAT, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "k", false) || StrEqual(cvbankadminflag, "vote", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_VOTE, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "l", false) || StrEqual(cvbankadminflag, "password", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_PASSWORD, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "m", false) || StrEqual(cvbankadminflag, "rcon", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_RCON, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "n", false) || StrEqual(cvbankadminflag, "cheats", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CHEATS, "Display a menu with the Bank functions for an admin");
	/*else if (StrEqual(cvbankadminflag, "z", false) || StrEqual(cvbankadminflag, "root ", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_ROOT, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "o", false) || StrEqual(cvbankadminflag, "custom1", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CUSTOM1, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "p", false) || StrEqual(cvbankadminflag, "custom2", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CUSTOM2, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "q", false) || StrEqual(cvbankadminflag, "custom3", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CUSTOM3, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "r", false) || StrEqual(cvbankadminflag, "custom4", false))
		RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CUSTOM4, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "s", false) || StrEqual(cvbankadminflag, "custom5", false))
		/*RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CUSTOM5, "Display a menu with the Bank functions for an admin");
	else if (StrEqual(cvbankadminflag, "t", false) || StrEqual(cvbankadminflag, "custom6", false))*/
		//RegAdminCmd("bankadmin", BankAdminMenu, ADMFLAG_CUSTOM6, "Display a menu with the Bank functions for an admin");
}

public Action:BankMenu(client, args)
{
	if (IsBankEnable())
	{
		IsBankOnMsg(client);
		ShowBankMenu(client);
		AdminOperation[client] = false;
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:Deposit(client, args)
{
	if (IsBankOnMsg(client))
	{
		new igmoney = GetIngameMoney(client);
		new minded = cvmindepamount + cvfeeint;
		if ((igmoney < minded) || (igmoney == 0))
		{
			decl String:money[32], String:moneystr[32];
			IntToMoney(minded, money, sizeof(money));
			Format(moneystr, sizeof(moneystr), "%c%s%c", GREEN, money, YELLOW);
			PrintToChat(client, "%t", "Need At Least", plugin_name, moneystr);
			return Plugin_Handled;
		}
		else
		{
			if (args < 1)
			{
				ShowDepositMenu(client);
				AdminOperation[client] = false;
				return Plugin_Handled;
			}
			else
			{
				new String:CmdArg[32];
				GetCmdArg(1, CmdArg, sizeof(CmdArg));
				DepositClientMoney(client, CmdArg);
			}
		}
	}
	return Plugin_Handled;
}

public Action:WithDraw(client, args)
{
	if (IsBankOnMsg(client))
	{
		if (GetBankMoney(client) == 0)
		{
			PrintToChat(client, "%t", "No Bank Money", plugin_name);
			return Plugin_Handled;
		}
		else
		{
			if (args < 1)
			{
				ShowWithdrawMenu(client);
				AdminOperation[client] = false;
				return Plugin_Handled;
				}
			else
			{
				new String:CmdArg[32];
				GetCmdArg(1, CmdArg, sizeof(CmdArg));
				WithdrawClientMoney(client, CmdArg);
			}
		}
	}
	return Plugin_Handled;
}

public Action:BankStatus(client, args)
{
	if (IsBankEnable())
	{
		ShowBankStatus(client);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:BankAdminMenu(client, args)
{
	if (IsBankEnable())
	{
		AdminOperation[client] = true;
		ShowBankAdminMenu(client);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:CommandResetBankAll(args)
{
	ResetBankAll();
	return Plugin_Handled;
}

public Action:CommandResetBankMoney(args)
{
	ResetBankMoney();
	return Plugin_Handled;
}

public Action:CommandResetBankMessage(args)
{
	ResetBankMessage();
	return Plugin_Handled;
}

public Action:CommandUpdateBankDatabase(args)
{
	UpdateBankDatabase();
	return Plugin_Handled;
}

public Action:CommandCleanUpDatabase(args)
{
	CleanUpDatabase();
	return Plugin_Handled;
}

public Action:ChatInput(client, const String:command[], argc)
{
	if (IsChatInput[client])
	{
		new String:input[512], String:amount[512];

		GetCmdArg(1, input, sizeof(input));
		StripQuotes(input);
		ClientChatInput[client] = StringToInt(input);

		IsChatInput[client] = false;

		if (ClientChatInput[client] <= 0)
		{
			PrintToChat(client, "%t", "ChatInput Aborted", plugin_name);
			ClientChatInput[client] = 0;
			return Plugin_Handled;
		}
		else
		{
			IntToString(ClientChatInput[client], amount, sizeof(amount));

			switch(LastMenuAction[client])
			{
				case 2:
				{
					TransferClientMoney(client, TargetClientMenu[client], amount);
				}
				case 100:
				{
					AdminClientMoney(client, TargetClientMenu[client], amount, true);
				}
				case 101:
				{
					AdminClientMoney(client, TargetClientMenu[client], amount, _, true);
				}
				case 102:
				{
					AdminClientMoney(client, TargetClientMenu[client], amount);
				}
			}
		}

		return Plugin_Handled;
	}
	return Plugin_Continue;
}
