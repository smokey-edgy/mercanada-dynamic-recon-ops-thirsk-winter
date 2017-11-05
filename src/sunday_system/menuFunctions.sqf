sun_missionPreset = {
	params ["_preset"];
	/*
		lbSetCurSel [2107, aoOptionSelect];		
		sliderSetPosition [2111, 1*10];	//AI COUNT	
		lbSetCurSel [2113, minesEnabled];			
		lbSetCurSel [2115, civiliansEnabled];			
		lbSetCurSel [2119, stealthEnabled];				
		lbSetCurSel [2103, timeOfDay];		
		lbSetCurSel [2106, numObjectives];
	*/
	switch (_preset) do {
		case 1: {
			lbSetCurSel [2107, 0];			
			sliderSetPosition [2111, 1*10];			
			lbSetCurSel [2113, 0];			
			lbSetCurSel [2115, 0];			
			lbSetCurSel [2119, 0];			
			lbSetCurSel [2103, 0];			
			lbSetCurSel [2106, 0];
			preferredObjectives = [];
			profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];
			{
				((findDisplay 52525) displayCtrl _x) ctrlSetTextColor [1, 1, 1, 1]
			} forEach [2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210];			
		};
		case 2: {
			lbSetCurSel [2107, 0];			
			sliderSetPosition [2111, 0.5*10];			
			lbSetCurSel [2113, 0];			
			lbSetCurSel [2115, 0];			
			lbSetCurSel [2119, 1];			
			lbSetCurSel [2103, (selectRandom [3, 4])];		
			lbSetCurSel [2106, 1];	
			preferredObjectives = ["HVT"];
			profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];
			((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [0.05, 1, 0.5, 1];
			{			
				((findDisplay 52525) displayCtrl _x) ctrlSetTextColor [1, 1, 1, 1]
			} forEach [2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210];			
		};
	};
};

sun_lobbyReadyButton = {
	if (player getVariable ['startReady', false]) then {
		player setVariable ['startReady', false, true];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0,0,0,1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [1,1,1,1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0,0,0,1];
	} else {
		player setVariable ['startReady', true, true];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseEnter", "(_this select 0) ctrlsettextcolor [0.04, 0.7, 0.4, 1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetEventHandler ["MouseExit", "(_this select 0) ctrlsettextcolor [0.05, 1, 0.5, 1]"];
		((findDisplay 626262) displayCtrl 1601) ctrlSetTextColor [0.05, 1, 0.5, 1];
	};
};

sun_clearInsert = {
	deleteMarker 'campMkr';
	{
		[626262, 6006, "Insertion position: RANDOM"] remoteExec ["sun_lobbyChangeLabel", _x];	
	} forEach allPlayers;
};

sun_lobbyMapPreview = {
	closeDialog 1;
	camLobby cameraEffect ["terminate","back"];
	camUseNVG false;
	camDestroy camLobby;	
	_mapOpen = openMap [true, false];
	mapAnimAdd [0, 0.05, markerPos "centerMkr"];
	mapAnimCommit;
	player switchCamera "INTERNAL";
	waitUntil {!visibleMap};	
	_handle = CreateDialog "DRO_lobbyDialog";
	[] execVM "sunday_system\dialogs\populateLobby.sqf";
};

sun_lobbyChangeLabel = {
	disableSerialization;
	params ["_display", "_idc", "_label"];		
	if ((ctrlClassName ((findDisplay _display) displayCtrl _idc) == "sundayText") OR (ctrlClassName ((findDisplay _display) displayCtrl _idc) == "sundayTextMT")) then {
		((findDisplay _display) displayCtrl _idc) ctrlSetText _label;
	};
};

sun_lobbyCamTarget = {
	params ["_target"];
	if (camLobbyTarget != _target) then {
		((findDisplay 626262) displayCtrl 1159) ctrlSetPosition [1 * safezoneW + safezoneX, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 1, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 2, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 3];
		((findDisplay 626262) displayCtrl 1159) ctrlCommit 0.1;
		((findDisplay 626262) displayCtrl 1160) ctrlSetText "";
		((findDisplay 626262) displayCtrl 1160) ctrlSetFade 1;
		((findDisplay 626262) displayCtrl 1160) ctrlCommit 0;
		camLobbyTarget = _target;		
		_camPos = [(getPos _target), 3.4, (getDir _target)] call BIS_fnc_relPos;
		_camPos set [2, 1.1];
		_camTarget = [(getPos _target), 0.4, (getDir _target)+90] call BIS_fnc_relPos;
		_camTarget set [2, 0.9];
		camLobby camSetPos _camPos;
		camLobby camSetTarget _camTarget;
		camLobby camSetFocus [3.4, 1];
		camLobby camCommit 1;
		//sleep 1;
		[_target] spawn {
			_target = _this select 0;			
			_class = (configfile >> "CfgVehicles" >> (_target getVariable "unitClass") >> "displayName") call BIS_fnc_getCfgData;		
			_weapon	= (configfile >> "CfgWeapons" >> primaryWeapon _target >> "displayName") call BIS_fnc_getCfgData;			
			_string = format ["%2%1%3%1%4%1%5", "\n", name _target, rank _target, _class, _weapon];
			sleep 0.8;
			((findDisplay 626262) displayCtrl 1159) ctrlSetPosition [0.73 * safezoneW + safezoneX, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 1, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 2, (ctrlPosition ((findDisplay 626262) displayCtrl 1159)) select 3];			
			((findDisplay 626262) displayCtrl 1159) ctrlCommit 0.1;
			sleep 0.1;
			((findDisplay 626262) displayCtrl 1160) ctrlSetText _string;
			((findDisplay 626262) displayCtrl 1160) ctrlSetFade 0;
			((findDisplay 626262) displayCtrl 1160) ctrlCommit 0.2;
		};		
	};
};

dro_menuSlider = {
	disableSerialization;
	params ["_slide", "_display"];
		
	_currentMenu = menuSliderArray select menuSliderCurrent;	
	_selectedMenu = [];
	_menuSliderTarget = 0;
	switch (_slide) do {
		case "LEFT": {
			_menuSliderTarget = if (menuSliderCurrent == 0) then {((count menuSliderArray) - 1)} else {menuSliderCurrent - 1};
			_selectedMenu = menuSliderArray select _menuSliderTarget;
		};
		case "RIGHT": {
			_menuSliderTarget = if (menuSliderCurrent == ((count menuSliderArray) - 1)) then {0} else {menuSliderCurrent + 1};
			_selectedMenu = menuSliderArray select _menuSliderTarget;
		};
	};	
	// Slide current menu out to the left
	{
		if (_forEachIndex != 0) then {
			_thisCtrl = (_display displayCtrl _x);				
			_thisCtrl ctrlSetPosition [-0.4 * safezoneW + safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
			_thisCtrl ctrlCommit 0.1;
		};
	} forEach _currentMenu;
	sleep 0.1;
	// Slide next menu in from the left
	{
		if (_forEachIndex == 0) then {
			_thisCtrl = (_display displayCtrl 1101);
			_thisCtrl ctrlSetText _x;
		} else {
			_thisCtrl = (_display displayCtrl _x);				
			_thisCtrl ctrlSetPosition [0.02 * safezoneW + safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
			_thisCtrl ctrlCommit 0.2;
		};
	} forEach _selectedMenu;			
	menuSliderCurrent = _menuSliderTarget;		
};

dro_menuMap = {
	disableSerialization;
	_map = ((findDisplay 52525) displayCtrl 2251);
	_button = ((findDisplay 52525) displayCtrl 2255);	
	/*
	_worldCenter = (configfile >> "CfgWorlds" >> worldName >> "centerPosition") call BIS_fnc_getCfgData;	
	if (!isNil "_worldCenter") then {
		_map ctrlMapAnimAdd [0, 0.1, _worldCenter];
		ctrlMapAnimCommit _map;
	};
	*/
	if (isNil "mapOpen") then {		
		_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0.59 * safezoneH];		
		_map ctrlCommit 0;
		_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0.59 * safezoneW, 0.59 * safezoneH];		
		_map ctrlCommit 0.2;
		mapOpen = true;
		_button ctrlSetText "Close Map";
		_text = composeText ["Select the Area of Operations:", lineBreak, lineBreak, "Click on the map to select the closest AO location.", lineBreak, "Alternatively ALT-click on the map to select an exact custom location."];
		((findDisplay 52525) displayCtrl 1053) ctrlSetStructuredText _text;
		[] spawn {
			disableSerialization;
			{
				_x ctrlSetFade 0;
			} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
			{
				_x ctrlCommit 0.2;
			} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
		};		
		[
			"mapStartSelect",
			"onMapSingleClick",
			{
				playSound "readoutClick";
				deleteMarker "aoSelectMkr";
				aoName = "";
				if (_alt) then {
					markerPlayerStart = createMarker ["aoSelectMkr", _pos];
					markerPlayerStart setMarkerShape "ICON";			
					markerPlayerStart setMarkerType "Select";		
					markerPlayerStart setMarkerAlpha 1;
					markerPlayerStart setMarkerColor "ColorGreen";					
					//_nearLoc = nearestLocation [_pos, ""];					
					_nearLoc = ((nearestLocations [_pos, ["NameLocal", "NameVillage", "NameCity", "NameCityCapital"], 1000, _pos]) select 0);
					if (isNil "_nearLoc") then {
						aoName = format ["Rural %1", worldName];
					} else {
						aoName = format ["Near %1", (text _nearLoc)];
					};	
					//aoName = format ["Near %1", text _nearLoc];
					selectedLocMarker setMarkerColor "ColorPink";
					selectedLocMarker = markerPlayerStart;
					selectedLocMarker setMarkerColor "ColorGreen";
				} else {
					_nearestMarker = [locMarkerArray, _pos] call BIS_fnc_nearestPosition;		
					markerPlayerStart = createMarker ["aoSelectMkr", getMarkerPos _nearestMarker];
					markerPlayerStart setMarkerShape "ICON";			
					markerPlayerStart setMarkerType "mil_dot";		
					markerPlayerStart setMarkerAlpha 0;		
					_loc = nearestLocation [getMarkerPos _nearestMarker, ""];
					aoName = text _loc;
					selectedLocMarker setMarkerColor "ColorPink";		
					selectedLocMarker = _nearestMarker;
					_nearestMarker setMarkerColor "ColorGreen";
				};				
				((findDisplay 52525) displayCtrl 2300) ctrlSetText format ["AO location: %1", aoName];
				publicVariableServer "markerPlayerStart";
				publicVariable "aoName";
				publicVariableServer "selectedLocMarker";
			},
			[]
		] call BIS_fnc_addStackedEventHandler;
	} else {
		if (mapOpen) then {
			["mapStartSelect", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0.59 * safezoneH];
			_map ctrlCommit 0.1;
			sleep 0.1;
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0];		
			_map ctrlCommit 0;
			mapOpen = false;
			_button ctrlSetText "Open Map";
			[] spawn {
				disableSerialization;
				{
					_x ctrlSetFade 1;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
				{
					_x ctrlCommit 0.2;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
			};	
		} else {
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0, 0.59 * safezoneH];		
			_map ctrlCommit 0;
			_map ctrlSetPosition [0.23 * safezoneW + safezoneX, 0.18 * safezoneH + safezoneY, 0.59 * safezoneW, 0.59 * safezoneH];		
			_map ctrlCommit 0.2;
			mapOpen = true;
			_button ctrlSetText "Close Map";
			_text = composeText ["Select the Area of Operations:", lineBreak, lineBreak, "Click on the map to select the closest AO location.", lineBreak, "Alternatively ALT-click on the map to select an exact custom location."];
			((findDisplay 52525) displayCtrl 1053) ctrlSetStructuredText _text;
			[] spawn {
				disableSerialization;
				{
					_x ctrlSetFade 0;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
				{
					_x ctrlCommit 0.2;
				} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
			};		
			[
				"mapStartSelect",
				"onMapSingleClick",
				{
					deleteMarker "aoSelectMkr";
					aoName = "";
					playSound "readoutClick";
					if (_alt) then {
						markerPlayerStart = createMarker ["aoSelectMkr", _pos];
						markerPlayerStart setMarkerShape "ICON";			
						markerPlayerStart setMarkerType "Select";		
						markerPlayerStart setMarkerAlpha 1;
						markerPlayerStart setMarkerColor "ColorGreen";
						//_nearLoc = nearestLocation [_pos, ""];					
						_nearLoc = ((nearestLocations [_pos, ["NameLocal", "NameVillage", "NameCity", "NameCityCapital"], 1000, _pos]) select 0);
						if (isNil "_nearLoc") then {
							aoName = format ["Rural %1", worldName];
						} else {
							aoName = format ["Near %1", (text _nearLoc)];
						};					
						selectedLocMarker setMarkerColor "ColorPink";
						selectedLocMarker = markerPlayerStart;
						selectedLocMarker setMarkerColor "ColorGreen";
					} else {
						_nearestMarker = [locMarkerArray, _pos] call BIS_fnc_nearestPosition;		
						markerPlayerStart = createMarker ["aoSelectMkr", getMarkerPos _nearestMarker];
						markerPlayerStart setMarkerShape "ICON";			
						markerPlayerStart setMarkerType "mil_dot";		
						markerPlayerStart setMarkerAlpha 0;		
						_loc = nearestLocation [getMarkerPos _nearestMarker, ""];
						aoName = text _loc;
						selectedLocMarker setMarkerColor "ColorPink";		
						selectedLocMarker = _nearestMarker;
						_nearestMarker setMarkerColor "ColorGreen";
					};				
					((findDisplay 52525) displayCtrl 2300) ctrlSetText format ["AO location: %1", aoName];
					publicVariableServer "markerPlayerStart";
					publicVariable "aoName";
					publicVariableServer "selectedLocMarker";
				},
				[]
			] call BIS_fnc_addStackedEventHandler;			
		};
	};	
};

sun_callLoadScreen = {
	params ["_message", "_endVar", "_endValue", "_fadeType"];		
	disableSerialization;	
	_loadDisplay = findDisplay 46 createDisplay "SUN_loadScreen";	
	_loadScreen = _loadDisplay displayCtrl 8888;
	_loadScreenText = _loadDisplay displayCtrl 8889;
	
	_loadScreen ctrlSetFade 1;
	_loadScreenText ctrlSetFade 1;
	_loadScreen ctrlCommit 0;
	_loadScreenText ctrlCommit 0;
	
	_loadScreenText ctrlSetText _message;		
	_loadScreenText ctrlSetTextColor [1, 1, 1, 0.8];
	
	if (toUpper _fadeType == "BLACK") then {
		_loadScreen ctrlSetBackgroundColor [0, 0, 0, 1];
	};	
	
	_loadScreen ctrlSetFade 0;
	_loadScreenText ctrlSetFade 0;
	_loadScreen ctrlCommit 2;
	_loadScreenText ctrlCommit 2;

	sleep 2;	
	waitUntil {missionNameSpace getVariable _endVar == _endValue};
	_loadScreen ctrlSetFade 1;
	_loadScreenText ctrlSetFade 1;
	_loadScreen ctrlCommit 0.5;
	_loadScreenText ctrlCommit 0.5;
	sleep 0.5;
	_loadDisplay closeDisplay 1;	
};

sun_randomCam = {
	params ["_var"];	
	_worldCenterVal = (worldSize/2);
	_worldCenter = [_worldCenterVal, _worldCenterVal, 0];	
	_randomPos = [] call BIS_fnc_randomPos;	
	_randomPos set [2, (random [2, 5, 20])];
	_dir = [_randomPos, _worldCenter] call BIS_fnc_dirTo;
	_targetPos = [_randomPos, 600, _dir] call BIS_fnc_relPos;	
	_cam = "camera" camCreate _randomPos;
	randomCamActive = true;
	_cam cameraEffect ["internal", "BACK"];
	_cam camSetPos _randomPos;
	_cam camSetTarget _targetPos;	
	_cam camCommit 0;	
	cameraEffectEnableHUD false;
	showCinemaBorder false;
	["Mediterranean"] call BIS_fnc_setPPeffectTemplate;	
	_end = false;
	_blackOut = false;
	while {(missionNameSpace getVariable [_var, 0]) == 0} do {
		_startTime = time;		
		while {time < (_startTime + 10)} do {
			if (sunOrMoon < 1) then {camUseNVG true} else {camUseNVG false};			
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};
		if (_end) exitWith {_blackOut = true};
		cutText ["", "BLACK OUT", 2];
		_startTime = time;
		while {time < (_startTime + 2.5)} do {
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};		
		if (_end) exitWith {};
		_randomPos = [] call BIS_fnc_randomPos;		
		_randomPos set [2, (random [2, 5, 20])];
		_dir = [_randomPos, _worldCenter] call BIS_fnc_dirTo;
		_targetPos = [_randomPos, 600, _dir] call BIS_fnc_relPos;
		_cam camSetPos _randomPos;
		_cam camSetTarget _targetPos;	
		_cam camCommit 0;
		_startTime = time;
		while {time < (_startTime + 2)} do {
			if ((missionNameSpace getVariable [_var, 0]) == 1) exitWith {_end = true};
		};
		if (_end) exitWith {};
		cutText ["", "BLACK IN", 2];
	};
	if (_blackOut) then {
		cutText ["", "BLACK OUT", 2];
		sleep 2;
	};
	_cam cameraEffect ["terminate","back"];
	camUseNVG false;
	camDestroy _cam;
	["Default"] call BIS_fnc_setPPeffectTemplate;
	randomCamActive = false;
	/*
	if (_blackOut) then {
		sleep 1;
		cutText ["", "BLACK IN", 2];		
	};
	*/
	diag_log "DRO: Closed random cam";
};
