_missionName = _this select 0;

// Mission name diary entry
_missionText = "";
if (count _missionName > 0) then {
	//_missionName = [_missionName, 15] call BIS_fnc_trimString;
	_missionText = format ["<font size='20' face='PuristaBold'>%1</font>",_missionName];	
};

// Insertion diary entry
_textLocation = "";
if (count "campMkr" > 0) then {
	_markerText = markerText "campMkr";
	if (getMarkerType "campMkr" == "loc_Bunker") then {
		if (AOLocType == "NameLocal") then {
			_textLocation = format ["From their rendezvous point at <marker name=%4>%5</marker> fireteam Alpha will perform a patrol into <marker name=%3>%1</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr",_markerText];
		} else {	
			_textLocation = format ["From their rendezvous point at <marker name=%4>%5</marker> fireteam Alpha will perform a patrol into the %2 of <marker name=%3>%1.</marker> Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr",_markerText];
		};
	} else {	
		if (getMarkerType "campMkr" == "mil_start") then {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["Fireteam Alpha will insert via boat starting from the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into %1 at <marker name=%3>this location</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr"];
			} else {	
				_textLocation = format ["Fireteam Alpha will insert via boat starting from the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into the %2 of <marker name=%3>%1</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr"];
			};
		} else {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["Fireteam Alpha will insert via HALO at the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into %1 at <marker name=%3>this location</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr"];
			} else {	
				_textLocation = format ["Fireteam Alpha will insert via HALO at the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into the %2 of <marker name=%3>%1</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr"];
			};
		};
	};	
};

// Enemy makeup diary entry
_textEnemies = "";
_numEnemies = 0;
{
	if (side _x == enemySide) then {
		_numEnemies = _numEnemies + 1;
	};
} forEach allUnits;



if (_numEnemies < 60) then {
	_textEnemies = format ["%1 have a weak occupying force in the region. ", enemyFactionName];
};
if (_numEnemies >= 60 && _numEnemies < 80) then {
	_textEnemies = format ["%1 have a moderate occupying force in the region. ", enemyFactionName];
};
if (_numEnemies >= 80) then {
	_textEnemies = format ["%1 have a strong occupying force in the region; expect heavy resistance. ", enemyFactionName];
};

_textSecondaryLocs = "";
if (count AOLocations > 1) then {
	aoNames = [];	
	{
		if (_forEachIndex > 0) then {
			_secondaryLoc = nearestLocation [_x select 0, ""];
			_mkrName = format ["mkrSecondaryLoc%1", _forEachIndex];							
			aoNames pushBack (format ["<marker name=%2>%1</marker>", (text _secondaryLoc), _mkrName]);			
		};
	} forEach AOLocations;
	aoNamesCommas = "";
	diag_log format ["aoNames %1", aoNames];
	aoNamesLast = "";
	if (count aoNames > 1) then {
		aoNamesLast = aoNames call BIS_fnc_arrayPop;
		aoNamesCommas = aoNames joinString ", ";		
	} else {
		aoNamesCommas = aoNames select 0;
	};
	aoNamesFull = if (count aoNamesLast > 0) then {
		format ["%1 and %2", aoNamesCommas, aoNamesLast];
	} else {
		aoNamesCommas
	};
	
	_reportText = selectRandom ["received reports of", "detected"];
	if (count AOLocations > 2) then {		
		_textSecondaryLocs = format ["We have also %3 %1 occupying forces in %2.", enemyFactionName, aoNamesFull, _reportText];
	} else {
		_textSecondaryLocs = format ["We have also %3 a %1 occupying force in %2.", enemyFactionName, aoNamesFull, _reportText];
	};	
} else {
	_textSecondaryLocs = "";
};

// Civilians present diary entry
_textCivs = "";
if (!isNil "civTrue") then {	
	if (civTrue) then {
		_textCivs = "You can expect to encounter civilians in the area of operations. Check your targets and exercise extreme caution before using ordnance. Command considers any collateral damage to be unacceptable and ROE violations may result in severe punishment.";		
		if (!isNil "hostileCivIntel") then {
			_randHostileCivs = selectRandom [
				"We have reason to believe that a hostile militia is operating in the region and are hiding themselves among the civilian population.",
				"Intel shows that a number of civilians have banded together to form a militia hostile to our forces.",
				"Recent reports show that a hostile militia has sprung up to support the enemy forces."
			];
			_textCivs = format ["%1 %2 %3 You will be going into a complex situation that will require close attention to apparent non-combatants. Keep this in mind and ensure collateral damage is kept to a bare minimum.", _textCivs, _randHostileCivs, hostileCivIntel];
		};
	} else {
		_textCivs = "The area of operations is clear of civilians. You are cleared to use any tools at your disposal to complete objectives.";
	};	
};

_textResupply = format ["A <marker name=%1>resupply point</marker> has been prepared by a guerilla element. It contains a basic selection of arms for you to use in the field including explosives to deal with any objectives that may require them.", "resupplyMkr"];

_textCancel = "If at any time you find yourself unable to complete an objective you have the option to cancel that task under its task listing.";

_textStealth = if (stealthEnabled == 1) then {
	format ["The %1 forces will not be expecting %2 operations near %3, a fact which you can use to your advantage. Keep a low profile and eliminate enemies before they can raise the alarm and you'll stay undetected.", enemyFactionName, playersFactionName, aoName]
} else {
	""
};

_briefingString = format["%1<br /><br />%2<br /><br />%7%4<br />%3<br /><br />%5<br /><br />%8<br /><br />%6", _missionText, _textLocation, _textSecondaryLocs, _textCivs, _textResupply, _textCancel, _textEnemies, _textStealth];
{
	[_x, ["Diary", ["Briefing", _briefingString]]] remoteExec ["createDiaryRecord", _x, true];
} forEach allPlayers;

[[], "sun_playRadioRandom", true] call BIS_fnc_MP;
[[[playersSide, "HQ"], "Check your briefing notes for updated info."], "sideChat", true] call BIS_fnc_MP;
