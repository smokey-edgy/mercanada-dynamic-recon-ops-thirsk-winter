#include "sunday_system\sundayFunctions.sqf"

if (isClass (configfile >> "CfgPatches" >> "ace_weather")) then { //We have ACE Weather, oh god, we've gotta turn it off before it breaks everything!
	["ace_weather_useACEWeather", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_enableServerController", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_syncRain", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_syncWind", false, true, true] call ace_common_fnc_setSetting;
	["ace_weather_syncMisc", false, true, true] call ace_common_fnc_setSetting;	
};

missionNameSpace setVariable ["factionDataReady", 0, true];
missionNameSpace setVariable ["weatherChanged", 0, true];
missionNameSpace setVariable ["factionsChosen", 0, true];
missionNameSpace setVariable ["arsenalComplete", 0, true];
missionNameSpace setVariable ["aoCamPos", [], true];
missionNameSpace setVariable ["briefingReady", 0, true];
missionNameSpace setVariable ["playersReady", 0, true];
missionNameSpace setVariable ["publicCampName", "", true];
missionNameSpace setVariable ["startPos", [], true];
missionNameSpace setVariable ["initArsenal", 0, true];
missionNameSpace setVariable ["allArsenalComplete", 0, true];
missionNameSpace setVariable ["aoComplete", 0, true];
missionNameSpace setVariable ["objectivesSpawned", 0, true];
missionNameSpace setVariable ["aoLocationName", "", true];
missionNameSpace setVariable ["aoLocation", "", true];
missionNameSpace setVariable ["lobbyComplete", 0, true];

[] execVM "start.sqf";




