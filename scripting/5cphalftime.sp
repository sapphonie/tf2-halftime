#pragma semicolon 1

#include <sourcemod>
#include <morecolors>

public Plugin myinfo = {
	name			= "basic halftime for 5cp",
	author			= "stephanie",
	description	= "emulates esea style halves for 5cp",
	version		= "1.0.1",
	url				= "https://stephanie.lgbt"
};

new bluRnds;					// blu round int created here
new redRnds;					// blu round int created here
new bool:isHalf2;				// bool value for determining halftime created here

public void OnPluginStart()
{
	HookEvent("teamplay_round_win", EventRoundEnd); // hooks round win events (duh?)
	SetConVarInt(FindConVar("mp_winlimit"), 0, true); // finds and sets winlimit to 0, as this plugin handles it instead
}

public void OnMapEnd() // resets score on map change
{
	bluRnds = 0;
	redRnds = 0;
	isHalf2 = false;
}

public void EventRoundEnd(Event event, const char[] name, bool dontBroadcast) // who fucking knows what this does
{
	int team = event.GetInt("team"); // gets int value of the team who won the round. 2 = red, 3 = blu, anything else is a stalemate

/**VVV LOGIC HERE VVV **/

	if (team == 2) // RED TEAM WIN EVENT
		{
		redRnds++; // increments red round counter by +1
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		if (redRnds >= 3 && !isHalf2)
			{
			isHalf2 = true;
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Halftime reached! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
			}
		else if (redRnds == 5 && isHalf2)
			{
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}The game is over, and {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
			}
		}
	else if (team == 3) // BLU TEAM WIN EVENT
		{
		bluRnds++; // increments blu round counter by +1
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		if (bluRnds >= 3 && !isHalf2)
			{
			isHalf2 = true;
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Halftime reached! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
			}
		else if (bluRnds == 5 && isHalf2)
			{
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}The game is over, and {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
			}
		}
	else // catch-all
		{
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Stalemate! The score is {red}Red{white}:{red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
	}

/**^^^ LOGIC HERE ^^^ **/

}
