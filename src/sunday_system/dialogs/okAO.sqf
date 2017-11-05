_playersIndex = lbCurSel 2100;
_enemyIndex = lbCurSel 2101;
_civIndex = lbCurSel 2102;
_playersFaction = lbData [2100, _playersIndex];
_enemyFaction = lbData [2101, _enemyIndex];

_playersSideNum = ((configFile >> "CfgFactionClasses" >> _playersFaction >> "side") call BIS_fnc_GetCfgData);
_enemySideNum = ((configFile >> "CfgFactionClasses" >> _enemyFaction >> "side") call BIS_fnc_GetCfgData);
			
playersFaction = "";
if ((lbData [2100, _playersIndex]) == "RANDOM") then {			
	playersFaction = lbData [2100, ([1, lbSize 2100] call BIS_fnc_randomInt)];
	profileNamespace setVariable ["DRO_playersFaction", "RANDOM"];
} else {
	playersFaction = lbData [2100, _playersIndex];
	profileNamespace setVariable ["DRO_playersFaction", playersFaction];
};		
publicVariable "playersFaction";		
playersFactionAdv = [lbData [3800,  lbCurSel 3800], lbData [3801,  lbCurSel 3801], lbData [3802,  lbCurSel 3802]];
publicVariable "playersFactionAdv";			

if ((lbData [2101, _enemyIndex]) == "RANDOM") then {			
	enemyFaction = lbData [2101, ([1, lbSize 2101] call BIS_fnc_randomInt)];
	profileNamespace setVariable ["DRO_enemyFaction", "RANDOM"];
} else {
	enemyFaction = lbData [2101, _enemyIndex];
	profileNamespace setVariable ["DRO_enemyFaction", enemyFaction];
};
publicVariable "enemyFaction";		
enemyFactionAdv = [lbData [3803,  lbCurSel 3803], lbData [3804,  lbCurSel 3804], lbData [3805,  lbCurSel 3805]];
publicVariable "enemyFactionAdv";

civFaction = lbData [2102, _civIndex];
publicVariable "civFaction";		

diag_log format ["DRO: okAO.sqf: player %2 playersFaction = %1", playersFaction, player];
diag_log format ["DRO: okAO.sqf: player %2 playersFactionAdv = %1", playersFactionAdv, player];
diag_log format ["DRO: okAO.sqf: player %2 enemyFaction = %1", enemyFaction, player];
diag_log format ["DRO: okAO.sqf: player %2 enemyFactionAdv = %1", enemyFactionAdv, player];

missionNameSpace setVariable ["factionsChosen", 1, true];

diag_log format ["DRO: okAO.sqf: player %2 factionsChosen set to %1 and broadcast", (missionNameSpace getVariable ['factionsChosen', -1]), player];

aiMultiplier = (round (((sliderPosition 2111)/10) * (10 ^ 1)) / (10 ^ 1));
publicVariable "aiMultiplier";

hintSilent  "";
closeDialog 1;				
[toUpper "Please wait while mission is generated", "objectivesSpawned", 1, ""] call sun_callLoadScreen;					
	


