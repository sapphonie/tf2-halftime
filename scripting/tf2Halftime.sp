#pragma semicolon 1

#include <sourcemod>
#include <morecolors>
#undef REQUIRE_PLUGIN
#include <updater>

#define PLUGIN_VERSION	"1.1.0"
#define UPDATE_URL	"https://raw.githubusercontent.com/stephanieLGBT/tf2-halftime/master/updatefile.txt"



public Plugin myinfo = {
	name				= "basic halftime for 5cp and koth",
	author				= "stephanie",
	description		= "emulates esea style halves for 5cp and koth maps",
	version			= PLUGIN_VERSION,
	url					= "https://stephanie.lgbt"
};

new bluRnds;						// blu round int created here
new redRnds;						// blu round int created here
new bool:isHalf2;					// bool value for determining halftime created here
new String:mapName[128];			// holds map name value to then later check against for determining map type
new half1Limit;					// int for determining winlimit for half 1
new totalWinLimit;				// int for determining total winlimit b4 resetting tourney
new bool:tourneyRestart;			// bool value for determining if we should restart the tournament on the next round start


public void OnPluginStart()
{
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	HookEvent("teamplay_round_win", EventRoundEnd); // hooks round win events
	HookEvent("teamplay_round_start", EventRoundStart); //hooks round start events
	SetConVarInt(FindConVar("mp_winlimit"), 0, true); // finds and sets winlimit to 0, as this plugin handles it instead
}

public void OnMapStart()
{
	GetCurrentMap(mapName, sizeof(mapName)); // checks for current map name
	if (strncmp(mapName, "cp_", 3) == 0) // checks if it's cp...
	{
		half1Limit = 3;
		totalWinLimit = 5;
	}
	
	else if (strncmp(mapName, "koth_", 5) == 0) // koth... 
	{
		half1Limit = 2;
		totalWinLimit = 4;
	}
	
	else // or something else.
	{
		half1Limit = -1;
		totalWinLimit = -1;
	}
}



public void OnMapEnd() // resets score and map specific stored vars on map change
{
	bluRnds = 0;
	redRnds = 0;
	isHalf2 = false;
	half1Limit = 0;
	totalWinLimit = 0;
	tourneyRestart = false;
}


public void EventRoundEnd(Event event, const char[] name, bool dontBroadcast) // Round End Event
{
	int team = event.GetInt("team"); // gets int value of the team who won the round. 2 = red, 3 = blu, anything else is a stalemate
	int winreason = event.GetInt("winreason"); // gets winreason to prevent incrementing when a stalemate occurs

/**vvv LOGIC HERE vvv **/

// this will get refactored at some point because it's messy

	if (team == 2 && winreason == 1) // RED TEAM NON-STALEMATE WIN EVENT
	{
		redRnds++; // increments red round counter by +1
		CPrintToChatAll("{mediumpurple}[TF2Halftime] {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		if (redRnds >= half1Limit && !isHalf2) // red reaches (half1Limit) rounds before timelimit
		{
			isHalf2 = true;
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Halftime reached! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			tourneyRestart = true;
		} else if (redRnds == totalWinLimit && isHalf2) // red reaches (totalWinLimit) rounds
		{
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}The game is over, and {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			tourneyRestart = true;
		}
	} else if (team == 3 && winreason == 1) // BLU TEAM NON-STALEMATE WIN EVENT
	{
		bluRnds++; // increments blu round counter by +1
		CPrintToChatAll("{mediumpurple}[TF2Halftime] {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		if (bluRnds >= half1Limit && !isHalf2) // blu reaches (half1Limit) rounds before timelimit
		{
			isHalf2 = true;
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Halftime reached! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			tourneyRestart = true;
		} else if (bluRnds == totalWinLimit && isHalf2) // blu reaches (totalWinLimit) rounds
		{
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}The game is over, and {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			tourneyRestart = true;
		}
	} 
// THEORETICALLY this only gets called after a timelimit expires (like when 5cp match goes to timelimit in either half)
	else if (isHalf2) // is it the 2nd half?
	{
		if (redRnds < bluRnds) // does blu have more points?
		{
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Timelimit reached! The game is over, and {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds); // blu win @ timelimit in half 2
			tourneyRestart = true;
		} else if (redRnds < bluRnds) // ok, does red have more points?
		{
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Timelimit reached! The game is over, and {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			tourneyRestart = true;
		} else if (redRnds == bluRnds) // no? golden cap
		{
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Timelimit reached! Neither team has won! Exec rgl_6s_5cp_match_gc. The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			tourneyRestart = true;
		}
	} else if (redRnds < half1Limit && bluRnds < half1Limit) // handles 1st halves going to timelimit
	{
		CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Halftime reached due to timelimit! The score is {red}Red{white}:{red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		isHalf2 = true;
		tourneyRestart = true;
	} else // catch all for nonsensical scenarios
	{
		CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Something broke, somewhere. The score is {red}Red{white}:{red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Spitting out debug info: winreason %i, team %i. Score is {red}Red{white}:{red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", winreason, team, redRnds, bluRnds);
		CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}More debug info: half1Limit %i, totalWinLimit %i.", half1Limit, totalWinLimit);
		if (isHalf2) {
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}isHalf2 = true");
		} else {
			CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}isHalf2 = false");
		}
	}
}

public void EventRoundStart(Event event, const char[] name, bool dontBroadcast) // Round Start Event
{
	if (tourneyRestart)
	{
	CPrintToChatAll("{mediumpurple}[TF2Halftime] {white}Restarting tournament.");
	ServerCommand("mp_tournament_restart");
	tourneyRestart = false;
	}
}
/**^^^ LOGIC HERE ^^^ **/
