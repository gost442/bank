DepositClientMoney(client, String:amount[])
{
	if (!IsBankOnMsg(client))
		return;

	new bankmoney = GetBankMoney(client);

	if (IsAdmin[client] && (cvbankadminlimit > 0))
	{
		if (bankmoney == cvbankadminlimit)
		{
			PrintToChat(client, "%t", "Bank Still Full", plugin_name);
			return;
		}
	}
	else if ((cvmaxbankmoney > 0) && (bankmoney == cvmaxbankmoney))
	{
		PrintToChat(client, "%t", "Bank Still Full", plugin_name);
		return;
	}

	new deposit;
	if (StrEqual(amount, "all", false))
		deposit = cvmpmaxmoney;
	else
		deposit = StringToInt(amount);

	new ingamemoney = GetIngameMoney(client);
	new deduction = deposit + cvfeeint;
	new mindeduction = cvmindepamount + cvfeeint;

	deposit = deposit < 0 ? deposit * -1 : deposit;

	if (ingamemoney == 0)
	{
		PrintToChat(client, "%t", "No Money", plugin_name);
		return;
	}

	if (deduction < mindeduction)
	{
		deposit = mindeduction - cvfeeint;
		deduction = mindeduction;

		new String:Money[32], String:MoneyGain[32];
		IntToMoney(cvmindepamount, MoneyGain, sizeof(MoneyGain));
		Format(Money, sizeof(Money), "%c%s%c", GREEN, MoneyGain, YELLOW);
		PrintToChat(client, "%t", "Min Depamount", plugin_name, Money);
	}

	if (deduction > ingamemoney)
	{
		deposit = ingamemoney - cvfeeint;
		deduction = ingamemoney;
	}

	if (deposit == 0)
	{
		PrintToChat(client, "%t", "Not Enough Money", plugin_name);
		return;
	}

	if (deduction < mindeduction)
	{
		new String:Money[32], String:MoneyGain[32];
		IntToMoney(mindeduction, MoneyGain, sizeof(MoneyGain));
		Format(Money, sizeof(Money), "%c%s%c", GREEN, MoneyGain, YELLOW);
		PrintToChat(client, "%t", "Need At Least", plugin_name, Money);
		return;
	}

	new newbankmoney = bankmoney + deposit;

	if (IsAdmin[client] && (cvbankadminlimit > 0))
	{
		if (newbankmoney > cvbankadminlimit)
		{
			decl String:Money[32], String:Moneystr[32];
			IntToMoney(cvbankadminlimit, Money, sizeof(Money));
			Format(Moneystr, sizeof(Moneystr), "%c%s%c", GREEN, Money, YELLOW);
			PrintToChat(client, "%t", "Bank Full", plugin_name, Moneystr);
			deposit = cvbankadminlimit - bankmoney;
			deduction = deposit + cvfeeint;
			bankmoney = cvbankadminlimit;
			if (deposit == 0)
				return;
		}
		else
			bankmoney = newbankmoney;
	}
	else if ((cvmaxbankmoney > 0) && (newbankmoney > cvmaxbankmoney))
	{
		decl String:Money[32], String:Moneystr[32];
		IntToMoney(cvmaxbankmoney, Money, sizeof(Money));
		Format(Moneystr, sizeof(Moneystr), "%c%s%c", GREEN, Money, YELLOW);
		PrintToChat(client, "%t", "Bank Full", plugin_name, Moneystr);
		deposit = cvmaxbankmoney - bankmoney;
		deduction = deposit + cvfeeint;
		bankmoney = cvmaxbankmoney;
		if (deposit == 0)
			return;
	}
	else
		bankmoney = newbankmoney;

	ingamemoney -= deduction;

	SetBankMoney(client, bankmoney);
	SetIngameMoney(client, ingamemoney);

	new String:feestr[32], String:depositstr[32], String:Money1[32], String:Money2[32];
	IntToMoney(cvfeeint, feestr, sizeof(feestr));
	IntToMoney(deposit, depositstr, sizeof(depositstr));
	Format(Money1, sizeof(Money1), "%c%s%c", GREEN, depositstr, YELLOW);
	Format(Money2, sizeof(Money2), "%c%s%c", GREEN, feestr, YELLOW);
	PrintToChat(client, "%t", "Deposit successfully", plugin_name, Money1, Money2);
}

WithdrawClientMoney(client, String:amount[])
{
	if (!IsBankOnMsg(client))
		return;

	new bankmoney = GetBankMoney(client);
	new ingamemoney = GetIngameMoney(client);

	new withdraw;
	if (StrEqual(amount, "all", false))
		withdraw = cvmpmaxmoney;
	else
		withdraw = StringToInt(amount);

	withdraw = withdraw < 0 ? withdraw * -1 : withdraw;

	if (ingamemoney == cvmpmaxmoney)
	{
		PrintToChat(client, "%t", "No More Money", plugin_name);
		return;
	}

	if (withdraw > bankmoney)
	{
		withdraw = bankmoney;
		if (withdraw == 0)
		{
			PrintToChat(client, "%t", "No Bank Money", plugin_name);
			return;
		}
	}

	new iBalance = ingamemoney + withdraw;
	if (iBalance > cvmpmaxmoney)
		withdraw = cvmpmaxmoney - ingamemoney;

	ingamemoney += withdraw;
	bankmoney -= withdraw;

	SetBankMoney(client, bankmoney);
	SetIngameMoney(client, ingamemoney);

	new String:WithStr[32], String:Money[32];
	IntToMoney(withdraw, WithStr, sizeof(WithStr));
	Format(Money, sizeof(Money), "%c%s%c", GREEN, WithStr, YELLOW);
	PrintToChat(client, "%t", "Withdraw successfully", plugin_name, Money);
}

TransferClientMoney(client, target, String:amount[])
{
	if (!IsValidClient(client))
		return;

	if (!IsValidClient(target))
	{
		PrintToChat(client, "%t", "False Target", plugin_name);
		return;
	}

	new deposit, clientbankmoney, targetbankmoney;

	clientbankmoney = GetBankMoney(client);
	targetbankmoney = GetBankMoney(target);

	deposit = StringToInt(amount);

	deposit = deposit < 0 ? deposit * -1 : deposit;

	if(cvmaxtransfer > 0)
		deposit = deposit > cvmaxtransfer ? cvmaxtransfer : deposit;

	if (deposit > clientbankmoney)
	{
		PrintToChat(client, "%t", "Not Enough Money", plugin_name);
		return;
	}
	if (deposit == 0)
	{
		PrintToChat(client, "%t", "No Bank Money", plugin_name);
		return;
	}

	new String:clientname[MAX_NAME_LENGTH+1], String:targetname[MAX_NAME_LENGTH+1], String:name[MAX_NAME_LENGTH + 12], String:msg[PLATFORM_MAX_PATH+1];
	new String:depositstr[32], String:depositmon[32];

	GetClientName(client , clientname, sizeof(clientname));
	GetClientName(target , targetname, sizeof(targetname));

	if (IsAdmin[client] && (cvbankadminlimit > 0))
	{
		if (targetbankmoney == cvbankadminlimit)
		{
			Format(name, sizeof(name), "%c%s%c", TEAMCOLOR, "%s1", YELLOW);
			Format(msg, sizeof(msg), "%T", "TargetTotalLimit", client, plugin_name, name);
			ChatMessage(client, target, msg, targetname);
			return;
		}
	}
	else if ((cvmaxbankmoney > 0) && (targetbankmoney == cvmaxbankmoney))
	{
		Format(name, sizeof(name), "%c%s%c", TEAMCOLOR, "%s1", YELLOW);
		Format(msg, sizeof(msg), "%T", "TargetTotalLimit", client, plugin_name, name);
		ChatMessage(client, target, msg, targetname);
		return;
	}

	targetbankmoney += deposit;
	clientbankmoney -= deposit;

	if (IsAdmin[client] && (cvbankadminlimit > 0))
	{
		if (targetbankmoney > cvbankadminlimit)
		{
			new difference = targetbankmoney - cvbankadminlimit;
			targetbankmoney = cvbankadminlimit;
			clientbankmoney += difference;
		}
	}
	else if ((cvmaxbankmoney > 0) && (targetbankmoney > cvmaxbankmoney))
	{
		new difference = targetbankmoney - cvmaxbankmoney;
		targetbankmoney = cvmaxbankmoney;
		clientbankmoney += difference;
	}

	IntToMoney(GetBankMoney(client) - clientbankmoney ,depositstr, sizeof(depositstr));

	SetBankMoney(client, clientbankmoney);
	SetBankMoney(target, targetbankmoney);

	Format(depositmon, sizeof(depositmon), "%c%s%c", GREEN, depositstr, YELLOW);
	Format(name, sizeof(name), "%c%s%c", TEAMCOLOR, "%s1", YELLOW);
	Format(msg, sizeof(msg), "%T", "TargetDeposited", target, plugin_name, name, depositmon);
	ChatMessage(target, client, msg, clientname);
	Format(msg, sizeof(msg), "%T", "ClientTargetDeposited", client, plugin_name, name, depositmon);
	ChatMessage(client, target, msg, targetname);

	if (cvlogtransfers)
	{
		new String:clientID[32], String:targetID[32];
		GetClientAuthString(client, clientID, sizeof(clientID));
		GetClientAuthString(target, targetID, sizeof(targetID));

		FormatEx(msg, sizeof(msg), "%s (%s) transfered %s to %s (%s).", clientname, clientID, depositstr, targetname, targetID);
		WriteActionLog(msg);
	}
}

AdminClientMoney(client, target, String:amount[], add = false, remove = false)
{
	if (!IsValidClient(client))
		return;

	if (!IsValidClient(target))
	{
		PrintToChat(client, "%t", "False Target", plugin_name);
		return;
	}

	new money = StringToInt(amount);
	new bankmoney = GetBankMoney(target);

	money = money < 0 ? money * -1 : money;

	new String:clientname[MAX_NAME_LENGTH+1], String:targetname[MAX_NAME_LENGTH+1], String:name[MAX_NAME_LENGTH + 12],
		String:msg[PLATFORM_MAX_PATH+1], String:NewMoney[32], String:NewMoneyStr[32];

	GetClientName(client , clientname, sizeof(clientname));
	GetClientName(target , targetname, sizeof(targetname));

	Format(name, sizeof(name), "%c%s%c", TEAMCOLOR, "%s1", YELLOW);

	if (add)
	{
		if (IsAdmin[client] && (cvbankadminlimit > 0))
		{
			if ((bankmoney + money) > cvbankadminlimit)
				money = cvbankadminlimit - bankmoney;
		}
		else if ((cvmaxbankmoney > 0) && ((bankmoney + money) > cvmaxbankmoney))
			money = cvmaxbankmoney - bankmoney;

		bankmoney += money;

		IntToMoney(money, NewMoney, sizeof(NewMoney));
		Format(NewMoneyStr, sizeof(NewMoneyStr), "%c%s%c", GREEN, NewMoney, YELLOW);
		Format(msg, sizeof(msg), "%T", "AdminAdd", target, plugin_name, name, NewMoneyStr);
		ChatMessage(target, client, msg, clientname);
		Format(msg, sizeof(msg), "%T", "AdminTargetAdd", client, plugin_name, name, NewMoneyStr);
		ChatMessage(client, target, msg, targetname);

		if (cvlogadmins)
		{
			new String:clientID[32], String:targetID[32];
			GetClientAuthString(client, clientID, sizeof(clientID));
			GetClientAuthString(target, targetID, sizeof(targetID));

			FormatEx(msg, sizeof(msg), "Admin %s (%s) added %s to %s (%s).", clientname, clientID, NewMoney, targetname, targetID);
			WriteActionLog(msg);
		}
	}
	else if (remove)
	{
		if (bankmoney < money)
			money = bankmoney;
		bankmoney -= money;

		IntToMoney(money, NewMoney, sizeof(NewMoney));
		Format(NewMoneyStr, sizeof(NewMoneyStr), "%c%s%c", GREEN, NewMoney, YELLOW);
		Format(msg, sizeof(msg), "%T", "AdminRemove", target, plugin_name, name, NewMoneyStr);
		ChatMessage(target, client, msg, clientname);
		Format(msg, sizeof(msg), "%T", "AdminTargetRemove", client, plugin_name, name, NewMoneyStr);
		ChatMessage(client, target, msg, targetname);

		if (cvlogadmins)
		{
			new String:clientID[32], String:targetID[32];
			GetClientAuthString(client, clientID, sizeof(clientID));
			GetClientAuthString(target, targetID, sizeof(targetID));

			FormatEx(msg, sizeof(msg), "Admin %s (%s) removed %s from %s (%s).", clientname, clientID, NewMoney, targetname, targetID);
			WriteActionLog(msg);
		}
	}
	else
	{
		if (IsAdmin[client] && (cvbankadminlimit != 0))
		{
			if (money > cvbankadminlimit)
				money = cvbankadminlimit;
		}
		else if ((cvmaxbankmoney != 0) && (money > cvmaxbankmoney))
			money = cvmaxbankmoney;

		bankmoney = money;

		IntToMoney(money, NewMoney, sizeof(NewMoney));
		Format(NewMoneyStr, sizeof(NewMoneyStr), "%c%s%c", GREEN, NewMoney, YELLOW);
		Format(msg, sizeof(msg), "%T", "AdminSet", target, plugin_name, name, NewMoneyStr);
		ChatMessage(target, client, msg, clientname);
		Format(msg, sizeof(msg), "%T", "AdminTargetSet", client, plugin_name, name, NewMoneyStr);
		ChatMessage(client, target, msg, targetname);

		if (cvlogadmins)
		{
			new String:clientID[32], String:targetID[32];
			GetClientAuthString(client, clientID, sizeof(clientID));
			GetClientAuthString(target, targetID, sizeof(targetID));

			FormatEx(msg, sizeof(msg), "Admin %s (%s) set %s (%s) bank to %s.", clientname, clientID, targetname, targetID, NewMoney);
			WriteActionLog(msg);
		}
	}

	SetBankMoney(TargetClientMenu[client], bankmoney);
}

// returns a money amount from an integer eg: 5300 -> $5,300
IntToMoney(theint, String:result[], maxlen)
{
	new slen, pointer, bool:negative;
	new String:intstr[maxlen];

	negative = theint < 0;
	if (negative) theint *= -1;

	IntToString(theint, intstr, maxlen);
	slen = strlen(intstr);

	theint = slen % 3;
	if (theint == 0) theint = 3;
	Format(result,theint + 1, "%s", intstr);

	slen -= theint;
	pointer = theint + 1;
	for (new i = theint; i <= slen ; i += 3)
	{
		pointer += 4;
		Format(result, pointer, "%s,%s",result, intstr[i]);
	}

	if (negative)
		Format(result, maxlen, "$-%s", result);
	else
		Format(result, maxlen, "$%s", result);
}
