diag_log "DRO: Main DRO script started";

#include "sunday_system\sundayFunctions.sqf";
#include "sunday_system\droFunctions.sqf";
#include "sunday_revive\reviveFunctions.sqf";
#include "sunday_system\generate_enemies\generateEnemiesFunctions.sqf";

[] execVM "sunday_system\objectsLibrary.sqf";

diag_log "DRO: Libraries included";

respawnTime = switch (paramsArray select 0) do {
	case 0: {20};
	case 1: {45};
	case 2: {90};
	case 3: {nil};
};
publicVariable "respawnTime";

diag_log "DRO: Waiting for player count";

waitUntil {(count ([] call BIS_fnc_listPlayers) > 0)};
_topUnit = (([] call BIS_fnc_listPlayers) select 0);

{
	[_x, false] remoteExec ["allowDamage", _x];
	[_x, "ALL"] remoteExec ["disableAI", _x];
} forEach units(group _topUnit);
topUnit = _topUnit;
publicVariable "topUnit";

diag_log format ["DRO: topUnit = %1", topUnit];

playersFaction = "";
enemyFaction = "";
civFaction = "";
pFactionIndex = 1;
publicVariable "pFactionIndex";
playersFactionAdv = [0,0,0];
publicVariable "playersFactionAdv";
eFactionIndex = 2;
publicVariable "eFactionIndex";
enemyFactionAdv = [0,0,0];
publicVariable "enemyFactionAdv";
cFactionIndex = 0;
publicVariable "cFactionIndex";
customPos = [];
publicVariable "customPos";
playerGroup = [];
civTrue = false;
startVehicles = ["", ""];
publicVariable "startVehicles";
firstLobbyOpen = true;
publicVariable "firstLobbyOpen";
enemyIntelMarkers = [];
publicVariable "enemyIntelMarkers";

extractHeliUsed = false;
reinforceChance = 0.5;
stealthActive = false;
enemyCommsActive = true;

diag_log "DRO: Variables defined";
diag_log "DRO: Compiling scripts";

fnc_generateAO = compile preprocessFile "sunday_system\generate_ao\generateAO.sqf";
fnc_generateAOLoc = compile preprocessFile "sunday_system\generate_ao\generateAOLocation.sqf";
fnc_generateCampsite = compile preprocessFile "sunday_system\generate_ao\generateCampsite.sqf";

fnc_selectObjective = compile preprocessFile "sunday_system\objSelect.sqf";
fnc_selectReactiveObjective = compile preprocessFile "sunday_system\objectives\selectReactiveTask.sqf";
fnc_defineFactionClasses = compile preprocessFile "sunday_system\defineFactionClasses.sqf";

diag_log "DRO: Compiling scripts finished";

blackList = [];

_musicIntroStings = [
	"EventTrack02_F_EPB",
	"EventTrack02a_F_EPB",
	"EventTrack01a_F_EPA"
];
musicIntroSting = selectRandom _musicIntroStings;
publicVariable "musicIntroSting";

diag_log "DRO: Music sting chosen";


// *****
// EXTRACT FACTION DATA
// *****

// Check for factions that have units
_availableFactions = [];
availableFactionsData = [];
availableFactionsDataNoInf = [];
_unavailableFactions = [];
//_factionsWithUnits = [];
_factionsWithNoInf = [];
_factionsWithUnitsFiltered = [];
// Record all factions with valid vehicles
{
	if (isNumber (configFile >> "CfgVehicles" >> (configName _x) >> "scope")) then {
		if (((configFile >> "CfgVehicles" >> (configName _x) >> "scope") call BIS_fnc_GetCfgData) == 2) then {
			_factionClass = ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData);
			//_factionsWithUnits pushBackUnique _factionClass;
			if ((configName _x) isKindOf "Man") then {
				_index = ([_factionsWithUnitsFiltered, _factionClass] call BIS_fnc_findInPairs);
				if (_index == -1) then {
					_factionsWithUnitsFiltered pushBack [_factionClass, 1];
				} else {
					_factionsWithUnitsFiltered set [_index, [((_factionsWithUnitsFiltered select _index) select 0), ((_factionsWithUnitsFiltered select _index) select 1)+1]];
				};
			};
		};
	};
} forEach ("(configName _x) isKindOf 'AllVehicles'" configClasses (configFile / "CfgVehicles"));
// Filter factions with 1 or less infantry units
/*
{
	_factionsWithUnitsFiltered pushBack [_x, 0];
} forEach _factionsWithUnits;
{
	_index = [_factionsWithUnitsFiltered, ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData)] call BIS_fnc_findInPairs;
	if (_index > -1) then {
		_factionsWithUnitsFiltered set [_index, [((_factionsWithUnitsFiltered select _index) select 0), ((_factionsWithUnitsFiltered select _index) select 1)+1]];
	};
} forEach ("(configName _x) isKindOf 'Man'" configClasses (configFile / "CfgVehicles"));
*/
diag_log format ["DRO: _factionsWithUnitsFiltered = %1", _factionsWithUnitsFiltered];

// Filter out factions that have no vehicles
{
	_thisFaction = (_x select 0);
	_thisSideNum = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "side") call BIS_fnc_GetCfgData);
	//diag_log format ["DRO: Fetching faction info for %1", _thisFaction];
	//diag_log format ["DRO: faction sideNum = %1", _thisSideNum];
	if (!isNil "_thisSideNum") then {
		if (typeName _thisSideNum == "TEXT") then {
			if ((["west", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 1;
			};
			if ((["east", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 0;
			};
			if ((["guer", _thisSideNum, false] call BIS_fnc_inString) || (["ind", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 2;
			};
		};

		if (typeName _thisSideNum == "SCALAR") then {
			if (_thisSideNum <= 3 && _thisSideNum > -1) then {

				_thisFactionName = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "displayName") call BIS_fnc_GetCfgData);
				_thisFactionFlag = ((configfile >> "CfgFactionClasses" >> _thisFaction >> "flag") call BIS_fnc_GetCfgData);

				if ((_x select 1) <= 1) then {
					if (!isNil "_thisFactionFlag") then {
						availableFactionsDataNoInf pushBack [_thisFaction, _thisFactionName, _thisFactionFlag, _thisSideNum];
					} else {
						availableFactionsDataNoInf pushBack [_thisFaction, _thisFactionName, "", _thisSideNum];
					};
				} else {
					if (!isNil "_thisFactionFlag") then {
						availableFactionsData pushBack [_thisFaction, _thisFactionName, _thisFactionFlag, _thisSideNum];
					} else {
						availableFactionsData pushBack [_thisFaction, _thisFactionName, "", _thisSideNum];
					};
				};

			};
		};
	};
} forEach _factionsWithUnitsFiltered;

publicVariable "availableFactionsData";
publicVariable "availableFactionsDataNoInf";

{
	diag_log format ["DRO: availableFactionsData %2: %1", _x, _forEachIndex];
} forEach availableFactionsData;
{
	diag_log format ["DRO: availableFactionsDataNoInf %2: %1", _x, _forEachIndex];
} forEach availableFactionsDataNoInf;

missionNameSpace setVariable ["factionDataReady", 1, true];
diag_log "DRO: factionDataReady set";

// Initialise potential AO markers
[] execVM "sunday_system\initAO.sqf";
diag_log "DRO: AO markers initialised";

// *****
// PLAYERS SETUP
// *****

diag_log "DRO: Waiting for factions to be chosen by host";
waitUntil {(missionNameSpace getVariable ["factionsChosen", 0]) == 1};
diag_log "DRO: Factions chosen";

// *****
// Just kidding; ACE SETUP
// *****

diag_log "DRO: ACE setup?";

if (isClass (configfile >> "CfgPatches" >> "ace_main")) then { //Yay, we have ACE, lets do ACE things!
	diag_log "DRO: Beginning ACE setup";
	if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then { //We have ACE Medical, lets use the medical settings.
		//Start with settings we're forcing our players to use, because we obviously hate them.
		["ace_medical_medicSetting_basicEpi", 0, true, true] call ace_common_fnc_setSetting; //We allow anyone to use Epinephrine.
		["ace_medical_increaseTrainingInLocations", true, true, true] call ace_common_fnc_setSetting; //Locations boost training.
		["ace_medical_useCondition_PAK", 0, true, true] call ace_common_fnc_setSetting; //PAKs can always be used.
		["ace_medical_useLocation_PAK", 0, true, true] call ace_common_fnc_setSetting; //PAKs can be used anywhere.
		["ace_medical_useLocation_SurgicalKit", 0, true, true] call ace_common_fnc_setSetting; //Surgical Kits can be used anywhere.

		//Settings that players can set.
		//if (ACE_medenableRevive > 0) then { //Disable Sunday Revive if we want to use ACE Revive.
			reviveDisabled = 3;
			publicVariable "reviveDisabled";
		//};
		["ace_medical_enableRevive", ACE_medenableRevive, true, true] call ace_common_fnc_setSetting;
		["ace_medical_maxReviveTime", ACE_medmaxReviveTime, true, true] call ace_common_fnc_setSetting;
		["ace_medical_amountOfReviveLives", ACE_medamountOfReviveLives, true, true] call ace_common_fnc_setSetting;
		["ace_medical_level", (ACE_medLevel + 1), true, true] call ace_common_fnc_setSetting; //Are you kidding me, ACE Team?
		["ace_medical_medicSetting", ACE_medmedicSetting, true, true] call ace_common_fnc_setSetting;
		if(ACE_medenableScreams == 0) then { //ArmA can't convert Numbers to Booleans, isn't that dandy?
			["ace_medical_enableScreams", false, true, true] call ace_common_fnc_setSetting;
		} else {
			["ace_medical_enableScreams", true, true, true] call ace_common_fnc_setSetting;
		};
		["ace_medical_enableUnconsciousnessAI", ACE_medenableUnconsciousnessAI, true, true] call ace_common_fnc_setSetting;
		if(ACE_medpreventInstaDeath == 0) then {
			["ace_medical_preventInstaDeath", false, true, true] call ace_common_fnc_setSetting;
		} else {
			["ace_medical_preventInstaDeath", true, true, true] call ace_common_fnc_setSetting;
		};
		["ace_medical_bleedingCoefficient", ACE_medbleedingCoefficient, true, true] call ace_common_fnc_setSetting;
		["ace_medical_painCoefficient", ACE_medpainCoefficient, true, true] call ace_common_fnc_setSetting;
		if(ACE_medenableAdvancedWounds == 0) then {
			["ace_medical_enableAdvancedWounds", false, true, true] call ace_common_fnc_setSetting;
		} else {
			["ace_medical_enableAdvancedWounds", true, true, true] call ace_common_fnc_setSetting;
		};
		["ace_medical_medicSetting_PAK", ACE_medmedicSetting_PAK, true, true] call ace_common_fnc_setSetting;
		["ace_medical_consumeItem_PAK", ACE_medconsumeItem_PAK, true, true] call ace_common_fnc_setSetting;
		["ace_medical_medicSetting_SurgicalKit", ACE_medmedicSetting_SurgicalKit, true, true] call ace_common_fnc_setSetting;
		["ace_medical_consumeItem_SurgicalKit", ACE_medconsumeItem_SurgicalKit, true, true] call ace_common_fnc_setSetting;
	};
	if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then { //We have ACE Repair, lets use the repair settings.
		//More settings we force our players to use, further cementing our apathy towards them.
		["ace_repair_fullRepairLocation", 0, true, true] call ace_common_fnc_setSetting; //Full repair anywhere.
		["ace_repair_engineerSetting_fullRepair", 1, true, true] call ace_common_fnc_setSetting; //Only Engineers can full repair

		//Settings that players can set.
		["ace_repair_engineerSetting_Repair", ACE_repengineerSetting_Repair, true, true] call ace_common_fnc_setSetting;
		["ace_repair_consumeItem_ToolKit", ACE_repconsumeItem_ToolKit, true, true] call ace_common_fnc_setSetting;
		["ace_repair_wheelRepairRequiredItems", ACE_repwheelRepairRequiredItems, true, true] call ace_common_fnc_setSetting;
	};
	diag_log "DRO: Ended ACE setup";
} else {
	diag_log "DRO: ACE not detected";
};

// Get player faction
playersFactionName = (configFile >> "CfgFactionClasses" >> playersFaction >> "displayName") call BIS_fnc_GetCfgData;
_playerSideNum = (configFile >> "CfgFactionClasses" >> playersFaction >> "side") call BIS_fnc_GetCfgData;
playersSide = [_playerSideNum] call sun_getCfgSide;
playersSideCfgGroups = "West";
switch (playersSide) do {
	case east: {
		playersSideCfgGroups = "East";
	};
	case west: {
		playersSideCfgGroups = "West";
	};
	case resistance: {
		playersSideCfgGroups = "Indep";
	};
	case civilian: {
		playersSide = civilian
	};
};
publicVariable "playersSide";
publicVariable "playersSideCfgGroups";
diag_log format ["DRO: playersSide = %1, playersFaction = %2", playersSide, playersFaction];

diag_log "DRO: Define player group";
playerGroup = (units(group _topUnit));
DROgroupPlayers = (group _topUnit);
groupLeader = leader DROgroupPlayers;

grpNetId = group _topUnit call BIS_fnc_netId;
publicVariable "grpNetId";
diag_log grpNetId;

publicVariable "playerGroup";
publicVariable "DROgroupPlayers";
publicVariable "groupLeader";

diag_log format ["DRO: grpNetId = %1", grpNetId];

// Keep group name assigned throughout setup process
[] spawn {
	while {(missionNameSpace getVariable ["playersReady", 0] == 0)} do {
		if (isNull (grpNetId call BIS_fnc_groupFromNetId)) then {
			grpNetId = (group(([] call BIS_fnc_listPlayers) select 0)) call BIS_fnc_netId;
			publicVariable "grpNetId";
		};
	};
};

//unitDirs = [];
{
	if (!isNull _x) then {
		_x setVariable ["startDir", (getDir _x), true];
		//unitDirs set [_forEachIndex, (getDir _x)];
	};
	removeFromRemainsCollector [_x];
	diag_log format ["DRO: %1 startDir set and removed from remains collector", _x];
} forEach playerGroup;
//publicVariable "unitDirs";

// Prepare data for player lobby
_scriptStartTime = time;
[((findDisplay 888888) displayCtrl 8889), "EXTRACTING FACTION DATA"] remoteExecCall ["ctrlSetText", 0];
diag_log "DRO: Beginning faction extraction";
[] call fnc_defineFactionClasses;

DROgroupPlayers = (group _topUnit);

publicVariable "pCarClasses";
publicVariable "pTankClasses";
publicVariable "pHeliClasses";
publicVariable "pMortarClasses";
publicVariable "pUAVClasses";
publicVariable "pArtyClasses";

enemyGVPool = [];
if (count eCarNoTurretClasses > 0) then {
	for "_gv" from 1 to ([2,3] call BIS_fnc_randomInt) step 1 do {
		enemyGVPool pushBack (selectRandom eCarNoTurretClasses);
	};
};
enemyGVTPool = [];
if (count eCarTurretClasses > 0) then {
	enemyGVTPool pushBack (selectRandom eCarTurretClasses);
};
enemyHeliPool = [];
if (count eHeliClasses > 0) then {
	for "_h" from 1 to ([1,3] call BIS_fnc_randomInt) step 1 do {
		enemyHeliPool pushBack (selectRandom eHeliClasses);
	};
};

// Get CAS options
availableCASClasses = [];
if (count pHeliClasses > 0 || count pPlaneClasses > 0) then {
	{
		_availableSupportTypes = (configfile >> "CfgVehicles" >> _x >> "availableForSupportTypes") call BIS_fnc_GetCfgData;
		if ("CAS_Bombing" in _availableSupportTypes) then {
			availableCASClasses pushBack _x;
		};
		if ("CAS_Heli" in _availableSupportTypes) then {
			availableCASClasses pushBack _x;
		};
	} forEach (pHeliClasses + pPlaneClasses);
};
publicVariable "availableCASClasses";

_pInfGroups = [];
_playersFaction = playersFaction;
if (playersFaction == "BLU_G_F") then {_playersFaction = "Guerilla"};
if (playersFaction == "BLU_GEN_F") then {_playersFaction = "Gendarmerie"};
{
	_thisCategory = _x;
	{
		_thisGroup = _x;
		if (
			!(["diver", (configName _thisGroup)] call BIS_fnc_inString) &&
			!(["support", (configName _thisGroup)] call BIS_fnc_inString)
		) then {
			_save = true;
			{
				_vehicle = ((_x >> "vehicle") call BIS_fnc_getCfgData);
				if !(_vehicle isKindOf "Man") then {_save = false};
			} forEach ([_thisGroup] call BIS_fnc_returnChildren);
			if (_save) then {_pInfGroups pushBack [_thisGroup, ((_thisGroup >> "name") call BIS_fnc_getCfgData)]};
		};
	} forEach ([_thisCategory] call BIS_fnc_returnChildren);
} forEach ([configfile >> "CfgGroups" >> playersSideCfgGroups >> _playersFaction] call BIS_fnc_returnChildren);
diag_log format ["DRO: _pInfGroups: %1", _pInfGroups];

_pInfGroups8 = [];
_pInfGroupsNon8 = [];
_startingLoadoutGroup = [];

// Use sniper preset classes
if (missionPreset == 2) then {
	_spotterClasses = [];
	_sniperClasses = [];
	{
		_thisClass = _x;
		_thisRole = ((configFile >> "CfgVehicles" >> _thisClass >> "role") call BIS_fnc_GetCfgData);
		switch (_thisRole) do {
			case "Marksman": {_sniperClasses pushBackUnique _thisClass};
			case "SpecialOperative": {_spotterClasses pushBackUnique _thisClass};
			default {};
		};
		_thisDisplayName = ((configFile >> "CfgVehicles" >> _thisClass >> "displayName") call BIS_fnc_GetCfgData);
		{
			if (([_x, _thisDisplayName, false] call BIS_fnc_inString)) exitWith {
				_sniperClasses pushBackUnique _thisClass;
			};
		} forEach ["sniper", "marksman"];
		if ((["spotter", _thisDisplayName, false] call BIS_fnc_inString)) exitWith {
			_spotterClasses pushBackUnique _thisClass;
		};
	} forEach pInfClasses;
	if (count _spotterClasses > 0) then {_startingLoadoutGroup set [1, (selectRandom _spotterClasses)]} else {
		if (count _sniperClasses > 0) then {_startingLoadoutGroup set [1, (selectRandom _sniperClasses)]};
	};
	if (count _sniperClasses > 0) then {_startingLoadoutGroup set [0, (selectRandom _sniperClasses)]};
};

if (count _startingLoadoutGroup == 0) then {
	{
		if (count ([(_x select 0)] call BIS_fnc_returnChildren) >= 8) then {
			_pInfGroups8 pushBack (_x select 0);
		} else {
			_pInfGroupsNon8 pushBack (_x select 0);
		};
	} forEach _pInfGroups;
	diag_log format ["DRO: _pInfGroups8: %1", _pInfGroups8];

	if (count _pInfGroups8 > 0) then {
		_chosenGroup = selectRandom _pInfGroups8;
		{
			_startingLoadoutGroup pushBack ((_x >> "vehicle") call BIS_fnc_getCfgData);
		} forEach ([_chosenGroup] call BIS_fnc_returnChildren);
	} else {
		if (count _pInfGroupsNon8 > 0) then {
			_chosenGroup = selectRandom _pInfGroupsNon8;
			{
				_startingLoadoutGroup pushBack ((_x >> "vehicle") call BIS_fnc_getCfgData);
			} forEach ([_chosenGroup] call BIS_fnc_returnChildren);
		};
	};
};
diag_log format ["DRO: _startingLoadoutGroup: %1", _startingLoadoutGroup];

// Define unitList for all selectable lobby classes
unitList = [];
publicVariable "unitList";
{
	_displayName = ((configfile >> "CfgVehicles" >> _x >> "displayName") call BIS_fnc_getCfgData);
	_factionClass = ((configfile >> "CfgVehicles" >> _x >> "faction") call BIS_fnc_getCfgData);
	_factionName = ((configfile >> "CfgFactionClasses" >> _factionClass >> "displayName") call BIS_fnc_getCfgData);
	unitList pushBackUnique [_x, _displayName, _factionName];
} forEach pInfClasses;
publicVariable "unitList";

{
	diag_log _x;
} forEach unitList;
//diag_log format ["DRO: unitList: %1", unitList];

diag_log format ["DRO: Player side extraction scripts run time = %1", time - _scriptStartTime];
// Init player unit lobby variables
{
	_thisUnitType = if (count _startingLoadoutGroup > 0) then {
		_desiredUnit = if (_forEachIndex < (count _startingLoadoutGroup)) then {
			_startingLoadoutGroup select _forEachIndex
		} else {
			selectRandom _startingLoadoutGroup
		};
		diag_log format ["DRO: _desiredUnit: %1", _desiredUnit];

		_index = {
			if ((_x select 0) == _desiredUnit) exitWith {_forEachIndex};
		} forEach unitList;

		if (isNil "_index") then {
			selectRandom unitList
		} else {
			unitList select _index
		};
	} else {
		selectRandom unitList
	};
	_x setVariable ['unitLoadoutIDC', (1200 + _forEachIndex), true];
	_x setVariable ['unitArsenalIDC', (1300 + _forEachIndex), true];
	_x setVariable ['unitDeleteIDC', (1500 + _forEachIndex), true];
	_x setVariable ['unitNameTagIDC', (1700 + _forEachIndex), true];

	[[_x, _thisUnitType], 'sunday_system\switchUnitLoadout.sqf'] remoteExec ["execVM", _x, false];

} forEach playerGroup;

// *****
// ENEMY SETUP
// *****

// Get enemy faction
enemyFactionName = (configFile >> "CfgFactionClasses" >> enemyFaction >> "displayName") call BIS_fnc_GetCfgData;
_enemySideNum = (configFile >> "CfgFactionClasses" >> enemyFaction >> "side") call BIS_fnc_GetCfgData;
enemySide = [_enemySideNum] call sun_getCfgSide;
enemySideCfgGroups = "Indep";
switch (enemySide) do {
	case east: {
		enemySideCfgGroups = "East";
	};
	case west: {
		enemySideCfgGroups = "West";
	};
	case resistance: {
		enemySideCfgGroups = "Indep";
	};
};
publicVariable "enemySide";
diag_log format ["DCO: Enemy side detected as %1", enemySide];

// *****
// DEFINE MARKER COLOURS
// *****

markerColorPlayers = "colorBLUFOR";
switch (playersSide) do {
	case west: {
		markerColorPlayers = "colorBLUFOR";
	};
	case east: {
		markerColorPlayers = "colorOPFOR";
	};
	case resistance: {
		markerColorPlayers = "colorIndependent";
	};
};
publicVariable "markerColorPlayers";

_colorSide = if (playersSide == enemySide) then {
	switch (enemySide) do {
		case east: {resistance};
		default {east};
	};
} else {
	enemySide
};
markerColorEnemy = "colorOPFOR";
switch (_colorSide) do {
	case west: {
		markerColorEnemy = "colorBLUFOR";
	};
	case east: {
		markerColorEnemy = "colorOPFOR";
	};
	case resistance: {
		markerColorEnemy = "colorIndependent";
	};
};
publicVariable "markerColorEnemy";

// *****
// AO SETUP
// *****

diag_log "DRO: Call AO script";
_scriptStartTime = time;
[((findDisplay 888888) displayCtrl 8889), "GENERATING AREA OF OPERATIONS"] remoteExecCall ["ctrlSetText", 0];
// Generate AO and collect data
[] call fnc_generateAO;
diag_log format ["DRO: AO script run time = %1", time - _scriptStartTime];
// Reconfigure AO markers
{
	_x setMarkerColor markerColorEnemy;
} forEach AOMarkers;


// Enemy AO flag marker
_enemyFactionFlagIcon = ((configfile >> "CfgFactionClasses" >> enemyFaction >> "flag") call BIS_fnc_GetCfgData);
_enemyFactionName = ((configfile >> "CfgFactionClasses" >> enemyFaction >> "displayName") call BIS_fnc_GetCfgData);
_enemyFactionFlag = "";
_nonBaseFaction = 0;

if (!isNil "_enemyFactionName") then {
	{
		if (((configFile >> "CfgMarkers" >> (configName _x) >> "name") call BIS_fnc_GetCfgData) == _enemyFactionName) then {
			_enemyFactionFlag = (configName _x);
		};
	} forEach ("true" configClasses (configFile / "CfgMarkers"));
};

if (count _enemyFactionFlag == 0) then {
	if (!isNil "_enemyFactionFlagIcon") then {
		{
			if ([((configFile >> "CfgMarkers" >> (configName _x) >> "icon") call BIS_fnc_GetCfgData), _enemyFactionFlagIcon, false] call BIS_fnc_inString) then {
				_enemyFactionFlag = (configName _x);
				_nonBaseFaction = 1;
			};
		} forEach ("true" configClasses (configFile / "CfgMarkers"));

		switch (enemyFaction) do {
			case "BLU_F": {
				_enemyFactionFlag = "flag_NATO";
			};
			case "BLU_G_F": {
				_enemyFactionFlag = "flag_FIA";
			};
			case "IND_F": {
				_enemyFactionFlag = "flag_AAF";
			};
			case "OPF_F": {
				_enemyFactionFlag = "flag_CSAT";
			};
		};
	};
};
if (count _enemyFactionFlag == 0) then {
	deleteMarker "mkrFlag";
} else {
	"mkrFlag" setMarkerType _enemyFactionFlag;
	if (_nonBaseFaction == 1) then {
		"mkrFlag" setMarkerSize [2, 1.3];
	};
};

if (aoOptionSelect == 0) then {
	aoOptionSelect = [1,3] call BIS_fnc_randomInt;
};

// *****
// WEATHER & TIME
// *****

if (timeOfDay == 0) then {
	timeOfDay = [1,4] call BIS_fnc_randomInt;
};
publicVariable "timeOfDay";

_year = date select 0;
_month = if (month == 0) then {
	[1, 12] call BIS_fnc_randomInt
} else {
	month
};
_day = [1, 28] call BIS_fnc_randomInt;

if (typeName weatherOvercast == "STRING") then {
	[(random [0, 0.4, 1])] call BIS_fnc_setOvercast;
};

0 setFog 0;
simulWeatherSync;

_nextOvercast = (random 1);
_nextFog = if (_nextOvercast < 0.5) then {
	[(random 0.03), 0, 0];
} else {
	[(random 0.10), 0, 0];
};

//2500 setFog _nextFog;
[5] remoteExec ["skipTime", 0, true];
[2500, _nextOvercast] remoteExec ["setOvercast", 0, true];

{[80,86400,false,200,false,false,false,true] execVM "AL_snowstorm\al_snow.sqf";} remoteExec ["bis_fnc_call", 0];

diag_log format ["DRO: time of day is %1", timeOfDay];

// *****
// INTRO SETUP
// *****

// Intro Music
_musicArrayDay = [
	"LeadTrack02_F_EXP",
	"AmbientTrack03_F",
	"LeadTrack02_F_EPA",
	"LeadTrack01_F_EPA",
	"LeadTrack03_F_EPA",
	"LeadTrack01_F_EPB",
	"LeadTrack06_F",
	"BackgroundTrack02_F_EPC",
	"LeadTrack03_F_Mark",
	"LeadTrack02_F_EPB"
];
_musicArrayNight = [
	"AmbientTrack04_F",
	"AmbientTrack04a_F",
	"AmbientTrack01_F_EPB",
	"AmbientTrack01b_F",
	"AmbientTrack01_F_EXP",
	"LeadTrack03_F_EPA",
	"LeadTrack03_F_EPC",
	"BackgroundTrack04_F_EPC",
	"EventTrack03_F_EPC"
];
musicMain = nil;
if (timeOfDay <= 2) then {
	musicMain = selectRandom _musicArrayDay;
} else {
	musicMain = selectRandom _musicArrayNight;
};

// Mission Name
_missionName = [] call dro_missionName;

missionNameSpace setVariable ["mName", _missionName];
publicVariable "mName";
missionNameSpace setVariable ["weatherChanged", 1];
publicVariable "weatherChanged";

// *****
// PLAYERS SETUP
// *****

// Setup player identities
_firstNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "FirstNames");
_firstNames = [];
for "_i" from 0 to count _firstNameClass - 1 do {
	_firstNames pushBack (getText (_firstNameClass select _i));
};
_lastNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "LastNames");
_lastNames = [];
for "_i" from 0 to count _lastNameClass - 1 do {
	_lastNames pushBack (getText (_lastNameClass select _i));
};

// Extract voice data

_speakersArray = [];
{
	_thisVoice = (configName _x);
	_scopeVar = typeName ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData);
	switch (_scopeVar) do {
		case "STRING": {
			if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == "public") then {
				{
					if (typeName _x == "STRING") then {
						if ([pLanguage, _x, false] call BIS_fnc_inString) then {
							_speakersArray pushBack _thisVoice;
						};
					};
				} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
			};
		};
		case "SCALAR": {
			if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == 2) then {
				{
					if (typeName _x == "STRING") then {
						if ([pLanguage, _x, false] call BIS_fnc_inString) then {
							_speakersArray pushBack _thisVoice;
						};
					};
				} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
			};
		};
	};
} forEach ("true" configClasses (configFile / "CfgVoice"));

if (count _speakersArray == 0) then {
	switch (playersSide) do {
		case west: {
			_speakersArray = ["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG", "Male05ENG", "Male06ENG", "Male07ENG", "Male08ENG", "Male10ENG", "Male11ENG", "Male12ENG", "Male01ENGB", "Male02ENGB", "Male03ENGB", "Male04ENGB", "Male05ENGB"];
		};
		case east: {
			_speakersArray = ["Male01PER", "Male02PER", "Male03PER"];
		};
		case resistance: {
			_speakersArray = ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"];
		};
	};
};

diag_log format ["DRO: Available voices: %1", _speakersArray];

// Change units to correct ethnicity and voices
nameLookup = [];
{
	_thisUnit = _x;
	if (count _speakersArray > 0) then {
		_firstName = selectRandom _firstNames;
		_lastName = selectRandom _lastNames;
		_speaker = selectRandom _speakersArray;
		[[_thisUnit, _firstName, _lastName, _speaker], 'sun_setNameMP', true] call BIS_fnc_MP;
		nameLookup pushBack [_firstName, _lastName, _speaker];
		_thisUnit setVariable ["respawnIdentity", [_x,  _firstName, _lastName, _speaker], true];
	};
} forEach playerGroup;
publicVariable "nameLookup";

missionNameSpace setVariable ["initArsenal", 1];
publicVariable "initArsenal";

// *****
// ENEMIES SETUP
// *****

if (playersSide == enemySide) then {
	enemySide = switch (enemySide) do {
		case east: {resistance};
		default {east};
	};
	publicVariable "enemySide";
};

_enemySides = [];
{
	if (count _x > 0) then {
		_thisSide = switch ((configFile >> "CfgFactionClasses" >> _x >> "side") call BIS_fnc_GetCfgData) do {
			case 0: {east};
			case 1: {west};
			case 2: {resistance};
			case 3: {civilian};
		};
		_enemySides pushBack _thisSide;
	};
} forEach [enemyFaction] + enemyFactionAdv;

{
	_thisSide = _x;
	if (_thisSide != playersSide) then {
		{
			if (_thisSide != _x) then {
				if (_x != playersSide) then {
					_thisSide setFriend [_x, 1];
				};
			};
		} forEach _enemySides;
	};
} forEach _enemySides;

// *****
// OBJECTIVES SETUP
// *****
_scriptStartTime = time;
// Get number of tasks
_numObjs = 1;
if (numObjectives == 0) then {
	_numObjs = [1,3] call BIS_fnc_randomInt;
} else {
	_numObjs = numObjectives;
};

// Generate task data and physical objects

allObjectives = [];
objData = [];
taskIDs = [];
taskIntel = [];
publicVariable "taskIntel";
baseReconChance = 0.15;
publicVariable "baseReconChance";
hvtCodenames = ["Condor", "Vulture", "Scorpion", "Einstein", "Pascal", "Loner", "Spearhead", "Dalton", "Damocles", "Paris", "Huxley", "Ghost", "Gaunt", "Goblin", "Reptile"];
powJoinTasks = [];
powClass = "";
powType = "";

if (random 1 > 0.4) then {
	_soldierType = [0,2] call BIS_fnc_randomInt;
	if (_soldierType < 2) then {
		switch (_soldierType) do {
			case 0: {
				// Helicopter crew
				_heliCrewClasses = [];
				{
					if (["heli", _x, false] call BIS_fnc_inString) then {
						_heliCrewClasses pushBack _x;
					};
				} forEach pInfClasses;
				if (count _heliCrewClasses > 0) then {
					powClass = selectRandom _heliCrewClasses;
					powType = "HELICREW";
				} else {
					powClass = selectRandom pInfClasses;
					powType = "INFANTRY";
				};
			};
			case 1: {
				// Engineers
				_engineerClasses = [];
				{
					if (["engineer", _x, false] call BIS_fnc_inString OR ["repair", _x, false] call BIS_fnc_inString) then {
						_engineerClasses pushBack _x;
					};
				} forEach pInfClasses;
				if (count _engineerClasses > 0) then {
					powClass = selectRandom _engineerClasses;
					powType = "ENGINEERS";
				} else {
					powClass = selectRandom pInfClasses;
					powType = "INFANTRY";
				};
			};
		};
	} else {
		powClass = selectRandom pInfClasses;
		powType = "INFANTRY";
	};
} else {
	powClass = selectRandom ["C_journalist_F", "C_scientist_F"];
	powType	= switch (powClass) do {
		case "C_journalist_F": {"JOURNALISTS"};
		case "C_scientist_F": {"SCIENTISTS"};
	};
};
reconPatrolUnused = true;
for "_i" from 1 to (_numObjs) do {
	[((findDisplay 888888) displayCtrl 8889), (format ["GENERATING OBJECTIVE %1", _i])] remoteExecCall ["ctrlSetText", 0];
	if (_i == 1) then {
		[0] call fnc_selectObjective;
	} else {
		[(AOLocations call BIS_fnc_randomIndex)] call fnc_selectObjective;
	};
};
waitUntil {count allObjectives == _numObjs};
{
	diag_log format ["DRO: objData %1 = %2", _forEachIndex, objData select _forEachIndex];
} forEach objData;

_objGroupingHandle = [] execVM "sunday_system\objectives\objGrouping.sqf";
waitUntil {scriptDone _objGroupingHandle};

// Based on task data, assign tasks to players or assign recon tasks instead
{
	diag_log format ["DRO: %1 recon chance %2 checked against %3", (_x select 0), (_x select 6), baseReconChance];
	if ((_x select 6) > baseReconChance) then {
		// Create task from task data
		diag_log "DRO: Creating regular task";
		[_x, false, false] call sun_assignTask;
	} else {
		// Create recon addition
		diag_log "DRO: Creating a recon task";
		[_x, false] execVM "sunday_system\objectives\reconTask.sqf";
	};
} forEach objData;

diag_log format ["DRO: Objective scripts run time = %1", time - _scriptStartTime];

// *****
// CIVILIAN SETUP
// *****

// Collect civilian classes
civClasses = [];
civCarClasses = [];
if (civiliansEnabled == 0) then {
	civiliansEnabled = (selectRandom [1,2]);
};
if (civiliansEnabled == 1) then {
	[((findDisplay 888888) displayCtrl 8889), "SPAWNING CIVILIANS"] remoteExecCall ["ctrlSetText", 0];
	{
		if (((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData) == civFaction) then {
			if ( ((configFile >> "CfgVehicles" >> (configName _x) >> "scope") call BIS_fnc_GetCfgData) == 2) then {
				if (configName _x isKindOf 'Man') then {
					if (
						(["_vr_", (configName _x), false] call BIS_fnc_inString) ||
						(["driver", (configName _x), false] call BIS_fnc_inString) ||
						(count ((configFile >> "CfgVehicles" >> (configName _x) >> "weapons") call BIS_fnc_GetCfgData) > 2)
					) then {

					} else {
						civClasses pushBack (configName _x);
					};
				} else {
					if (configName _x isKindOf 'Car') then {
						civCarClasses pushBack (configName _x);
					};
				};
			};
		};
	} forEach ("true" configClasses (configFile / "CfgVehicles"));
	// Civilians only spawned if time of day is not nighttime
	if (timeOfDay <= 3) then {
		civTrue = true;
		_civSpawn = [0] execVM "sunday_system\generateCivilians.sqf";
		waitUntil {scriptDone _civSpawn};
		if (random 1 > 0.5) then {
			[] execVM "sunday_system\hostileCivilians.sqf";
		};
		if (random 1 > 0.3) then {
			[] execVM "sunday_system\addCivilianIntel.sqf";
		};
	};
};

missionNameSpace setVariable ["objectivesSpawned", 1, true];

// *****
// GENERATE ENEMIES
// *****

[((findDisplay 888888) displayCtrl 8889), "SPAWNING ENEMIES"] remoteExecCall ["ctrlSetText", 0];

_garrisionScriptHandle = [] execVM "sunday_system\findGarrisonBuildings.sqf";
waitUntil {scriptDone _garrisionScriptHandle};

_enemyScripts = [];
_enemyScripts pushBack ([0, "REGULAR"] execVM "sunday_system\generate_enemies\generateEnemies.sqf");
{
	if (_forEachIndex > 0) then {
		_enemyScripts pushBack ([_forEachIndex, "SMALL"] execVM "sunday_system\generate_enemies\generateEnemies.sqf");
	};
} forEach AOLocations;

waitUntil {({!scriptDone _x} count _enemyScripts) == 0};
[] execVM "sunday_system\addIntelObjects.sqf";

// Generate power units
if (stealthEnabled == 1) then {
	_maxPowerUnits = ([1,3] call BIS_fnc_randomInt);
	_p = 0;
	while {_p <= _maxPowerUnits} do {
		_AOIndexes = [];
		{
			_AOIndexes pushBack _forEachIndex;
		} forEach AOLocations;
		_AOIndexesShuffled = _AOIndexes call BIS_fnc_arrayShuffle;
		{
			if (count (((AOLocations select _x) select 2) select 7) > 0) exitWith {
				_building = [(((AOLocations select _x) select 2) select 7)] call sun_selectRemove;
				[_building] execVM "sunday_system\objectives\destroyPowerUnit.sqf";
			};
		} forEach _AOIndexesShuffled;
		_p = _p + 1;
	};
};
if (random 1 > 0) then {
	[] execVM "sunday_system\objectives\destroyCommsTower.sqf";
};

// *****
// WAIT FOR LOBBY COMPLETION
// *****
_scriptStartTime = time;
waitUntil {(missionNameSpace getVariable "lobbyComplete") == 1};

if (stealthEnabled == 0) then {
	if (timeOfDay >= 3) then {
		stealthEnabled = selectRandom [1,2];
	} else {
		stealthEnabled = 2;
	};
};
publicVariable "stealthEnabled";

_setupPlayersHandle = [] execVM "sunday_system\setupPlayersFaction.sqf";
waitUntil {scriptDone _setupPlayersHandle};

missionNameSpace setVariable ["playersReady", 1];
publicVariable "playersReady";

diag_log "DRO: setupPlayersFaction completed";
diag_log format ["DRO: Player setup script run time = %1", time - _scriptStartTime];

// *****
// MISC EXTRAS
// *****

// Create a few empty enemy vehicles for use in escape
if (random 1 > 0.4) then {
	_numEscapeVehicles = [1,2] call BIS_fnc_randomInt;
	for "_i" from 1 to _numEscapeVehicles do {
		_vehClass = "";
		if (count eCarNoTurretClasses > 0) then {
			_vehClass = selectRandom eCarNoTurretClasses;
		} else {
			if (count eCarClasses > 0) then {
				_vehClass = selectRandom eCarClasses;
			};
		};
		if (count _vehClass > 0) then {
			if (count (((AOLocations select 0) select 2) select 0) > 0) then {
				_pos = [(((AOLocations select 0) select 2) select 0)] call sun_selectRemove;
				_veh = _vehClass createVehicle _pos;
				_roadList = _pos nearRoads 10;
				if (count _roadList > 0) then {
					_thisRoad = _roadList select 0;
					_roadConnectedTo = roadsConnectedTo _thisRoad;
					_direction = 0;
					if (count _roadConnectedTo == 0) then {
						_direction = 0;
					} else {
						_connectedRoad = _roadConnectedTo select 0;
						_direction = [_thisRoad, _connectedRoad] call BIS_fnc_DirTo;
					};
					_veh setDir _direction;
					_newPos = [_pos, 4, (_direction + 90)] call BIS_fnc_relPos;
					_veh setPos _newPos;
				};
			};
		};
	};
};

// Ambient flyover setup
_ambientFlyByChance = random 1;
if (_ambientFlyByChance > 0.65) then {
	_flyerClasses = (eHeliClasses + ePlaneClasses);
	if (count _flyerClasses > 0) then {
		[centerPos, _flyerClasses] execVM "sunday_system\ambientFlyBy.sqf";
	};
};

if (animalsEnabled == 0) then {
	[centerPos] execVM "sunday_system\generateAnimals.sqf";
};
[] execVM "sunday_system\civMoveAction.sqf";

// Add intel items
[] execVM "sunday_system\addEnemyIntel.sqf";



// Briefing init
[_missionName] execVM "briefing.sqf";

if (minesEnabled == 0) then {
	[centerPos] execVM "sunday_system\generateMinefield.sqf";
};
[] call sun_removeEnemyNVG;

// *****
// SEQUENCING
// *****

// Reinforcement trigger
_trgReinf = createTrigger ["EmptyDetector", centerPos, true];
_trgReinf setTriggerArea [400, 400, 0, false];
_trgReinf setTriggerActivation ["ANY", "PRESENT", false];
_trgReinf setTriggerStatements ["
	(({alive _x && side _x == enemySide} count thisList) < (({alive _x && group _x == (thisTrigger getVariable 'DROgroupPlayers')} count thisList)*4.5)) &&
	enemyCommsActive &&
	!stealthActive

", "diag_log 'DRO: Reinforcing due to player incursion'; [getPos thisTrigger, [1,2]] execVM 'sunday_system\reinforce.sqf';", ""];
_trgReinf setVariable ["DROgroupPlayers", (grpNetId call BIS_fnc_groupFromNetId)];

// Wait until all basic tasks are complete
diag_log format ["DRO: taskIDs = %1", taskIDs];
waituntil {
	sleep 10;
	_completeReturn = true;
	{
		_complete = [_x] call BIS_fnc_taskCompleted;
		if (!_complete) then {
			_completeReturn = false;
		};
	} forEach taskIDs;
	_completeReturn
};

reinforceChance = reinforceChance + 0.1;

// Once all basic tasks are complete wait until any reactive tasks are also complete
_airStrikeChance = random 1;
if ({vehicle _x inArea trgAOC} count allPlayers > 0) then {
	_reactiveChance = random 1;
	if (_reactiveChance > 0.75) then {
		diag_log "DRO: Creating reactive task";
		_thisObj = [] call fnc_selectReactiveObjective;
		waituntil {
			sleep 10;
			_completeReturn = true;
			{
				_complete = [_x] call BIS_fnc_taskCompleted;
				if (!_complete) then {
					_completeReturn = false;
				};
			} forEach taskIDs;
			_completeReturn
		};
	} else {
		// Random mission end with friendly airstrikes
		if (_airStrikeChance > 0.85) then {
			[] spawn {
				[] remoteExec ["sun_playRadioRandom", 0];
				[[playersSide, "HQ"], "Word has just come from command that they have authorized air strikes on the AO with immediate effect. Three minutes to splash, get yourselves out of there ASAP!"] remoteExec ["sideChat", 0];
				sleep 180;
				for "_i" from 0 to (round(random [50, 100, 60])) step 1 do {
					_thisLocation = selectRandom AOLocations;
					_thisPos = _thisLocation select 0;
					_strikePos = [_thisPos, 300] call BIS_fnc_randomPosTrigger;
					_strikePos set [2, 200];
					_bomb = "Bo_GBU12_LGB" createVehicle _strikePos;
					sleep (random [0.8, 2, 1.5]);
				};
			};
		};
	};
};

reinforceChance = reinforceChance + 0.1;

// Filter available helicopters for transportation space
_numPassengers = count (units (grpNetId call BIS_fnc_groupFromNetId));
_heliTransports = [];
{
	if ([_x] call sun_getTrueCargo >= _numPassengers) then {
		_heliTransports pushBack _x;
	};
} forEach pHeliClasses;
diag_log format ["DRO: _heliTransports = %1", _heliTransports];

// Create extract task
if (((count _heliTransports) > 0) && !extractHeliUsed) then {
	_taskCreated = ["taskExtract", true, ["Extract from the AO. A helicopter transport is available to support. Alternatively leave the AO by any means available.", "Extract", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;
	diag_log format ["DRO: Extract task created: %1", _taskCreated];
	[(leader (grpNetId call BIS_fnc_groupFromNetId)), "heliExtract"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
} else {
	_taskCreated = ["taskExtract", true, ["Leave the AO by any means to extract. Helicopter transport is unavailable.", "Extract", ""], objNull, "CREATED", 5, true, true, "exit", true] call BIS_fnc_setTask;
	diag_log format ["DRO: Extract task created: %1", _taskCreated];
};

"mkrAOC" setMarkerAlpha 0.5;

// Extraction success trigger
trgExtract = createTrigger ["EmptyDetector", getPos trgAOC, true];
trgExtract setTriggerArea [(triggerArea trgAOC) select 0, (triggerArea trgAOC) select 1, 0, true];
trgExtract setTriggerActivation ["ANY", "PRESENT", false];
trgExtract setTriggerStatements [
	"
		({vehicle _x in thisList} count allPlayers == 0) &&
		({alive _x} count allPlayers > 0)
	",
	"
		[] execVM 'sunday_system\endMission.sqf';
	",
	""
];
trgExtract setVariable ["groupPlayers", (grpNetId call BIS_fnc_groupFromNetId)];

// Send new enemies to chase players if stealth is not maintained
if (!stealthActive) then {
	if (enemyCommsActive) then {
		diag_log 'DRO: Reinforcing due to mission completion';
		[(leader (grpNetId call BIS_fnc_groupFromNetId)), [2,4]] execVM 'sunday_system\reinforce.sqf';
	};
	// Make existing enemies close in on players
	diag_log "DRO: Init staggered attack";
	[30] execVM 'sunday_system\staggeredAttack.sqf';
};
// Music
[["LeadTrack02_F_Mark",0,1],"bis_fnc_playmusic",true] call BIS_fnc_MP;
