dro_addSabotageAction = {
	params ["_objects", ["_taskName", ""]];
	if (typeName _objects == "OBJECT") then {		
		_objects = [_objects];		
	};
	{
		_x setVariable ['sabotaged', false, true];
	} forEach _objects;
	if (count _taskName == 0) then {
		_taskName = (_objects select 0) getVariable "thisTask";
	};
	{
		[
			_x,
			"Sabotage",
			"\A3\ui_f\data\igui\cfg\actions\ico_OFF_ca.paa",
			"\A3\ui_f\data\igui\cfg\actions\ico_OFF_ca.paa",
			"(alive _target) && !(_target getVariable ['sabotaged', false]) && ((_this distance _target) < 4) && ('ToolKit' in (items _this + assignedItems _this))",
			"true",
			{},
			{
				if ((_this select 4) % 3 == 0) then {			
					_sound = selectRandom ["A3\Sounds_F\arsenal\weapons\Rifles\Katiba\reload_Katiba.wss", "A3\Sounds_F\arsenal\weapons\Rifles\Mk20\reload_Mk20.wss", "A3\Sounds_F\arsenal\weapons\Rifles\MX\Reload_MX.wss", "A3\Sounds_F\arsenal\weapons\Rifles\SDAR\reload_sdar.wss", "A3\Sounds_F\arsenal\weapons\SMG\Vermin\reload_vermin.wss", "A3\Sounds_F\arsenal\weapons\SMG\PDW2000\Reload_pdw2000.wss"];
					playSound3D [_sound, (_this select 1)];
					//(selectRandom ["FD_Skeet_Launch1_F", "FD_Skeet_Launch2_F"]) remoteExec ["playSound", (_this select 1)];
				};
			},
			{
				// Sabotage this object
				((_this select 0) setVariable ['sabotaged', true, true]);				
				(_this select 0) removeAllEventHandlers "Explosion";
				(_this select 0) removeAllEventHandlers "Killed";
				[(_this select 0), "ALL"] remoteExec ["disableAI", (_this select 0), true];
				[(_this select 0), "LOCKED"] remoteExec ["setVehicleLock", (_this select 0), true];
				[(_this select 0)] remoteExec ["removeAllItems", (_this select 0), true];
				[(_this select 0)] remoteExec ["removeAllWeapons", (_this select 0), true];
				{[(_this select 0), _x] remoteExec ["removeMagazine", (_this select 0), true]} forEach magazines (_this select 0);
				// Check for any other objects that might need sabotaging for task completion
				_complete = true;
				{	
					
					if !(_x getVariable ['sabotaged', false]) then {
						_complete = false;
					};
				} forEach ((_this select 3) select 0);
				// If all are sabotaged then complete the task				
				if (_complete) then {					
					if ([((_this select 3) select 1)] call BIS_fnc_taskExists) then {
						_taskState = [((_this select 3) select 1)] call BIS_fnc_taskState;				
						if !(_taskState isEqualTo "SUCCEEDED") then {
							[((_this select 3) select 1), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
						};
					};
					missionNamespace setVariable [format ['%1Completed', ((_this select 3) select 0)], 1, true];					
				};				
			},
			{},
			[_objects, _taskName],
			10,
			10,
			true,
			false
		] remoteExec ["bis_fnc_holdActionAdd", 0, true];
	} forEach _objects;
};


dro_missionName = {
	_missionNameType = selectRandom ["OneWord", "DoubleWord", "TwoWords"];
	_missionName = switch (_missionNameType) do {
		case "OneWord": {
			_nameArray = ["Garrotte", "Castle", "Tower", "Sword", "Moat", "Traveller", "Headwind", "Fountain", "Taskmaster", "Tulip", "Carnation", "Gaunt", "Goshawk", "Jasper", "Flashbulb", "Banker", "Piano", "Rook", "Knight", "Bishop", "Pyrite", "Granite", "Hearth", "Staircase"];
			format ["Operation %1", selectRandom _nameArray];
		};
		case "DoubleWord": {
			_name1Array = ["Dust", "Swamp", "Red", "Green", "Black", "Gold", "Silver", "Lion", "Bear", "Dog", "Tiger", "Eagle", "Fox", "North", "Moon", "Watch", "Under", "Key", "Court", "Palm", "Fire", "Fast", "Light", "Blind", "Spite", "Smoke", "Castle"];
			_name2Array = ["bowl", "catcher", "fisher", "claw", "house", "master", "man", "fly", "market", "cap", "wind", "break", "cut", "tree", "woods", "fall", "force", "storm", "blade", "knife", "cut", "cutter", "taker", "torch"];
			format ["Operation %1%2", selectRandom _name1Array, selectRandom _name2Array];
		};
		case "TwoWords": {		
			_name1Array = ["Midnight", "Fallen", "Turbulent", "Nesting", "Daunting", "Dogged", "Darkened", "Shallow", "Second", "First", "Third", "Blank", "Absent", "Parallel", "Restless"];		
			_useWorldName = random 1;
			_name2Array = if (_useWorldName > 0.15) then {
				["Sky", "Moon", "Sun", "Hand", "Monk", "Priest", "Viper", "Snake", "Boon", "Cannon", "Market", "Rook", "Knight", "Bishop", "Command", "Mirror", "Crisis", "Spider", "Charter", "Court", "Hearth"]
			} else {
				[worldName]
			};				
			
			format ["Operation %1 %2", selectRandom _name1Array, selectRandom _name2Array];
		};
	};
	_missionName
};

sun_addIntel = {
	_intelObject = _this select 0;
	_taskName = _this select 1;
	_intelObject setVariable ["task", _taskName];	
	_intelObject addAction [
		"Collect Intel",
		{
			[_this select 3, 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
			missionNamespace setVariable [format ["%1Completed", (_this select 3)], 1, true];
			deleteVehicle (_this select 0);
			[5, false, (_this select 1)] execVM "sunday_system\revealIntel.sqf";
		},
		_taskName,
		6,
		true,
		true				
	];	
};

dro_initLobbyCam = {
	private ["_playerPos", "_camLobbyStartPos", "_camLobbyEndPos"];
	_playerPos = [((getPos player) select 0), ((getPos player) select 1), (((getPos player) select 2)+1.2)];
	_camLobbyStartPos = [(getPos player), 5, (getDir player)-35] call dro_extendPos;
	_camLobbyStartPos = [(_camLobbyStartPos select 0), (_camLobbyStartPos select 1), (_camLobbyStartPos select 2)+1];
	camLobby = "camera" camCreate _camLobbyStartPos;
	camLobby cameraEffect ["internal", "BACK"];
	camLobby camSetPos _camLobbyStartPos;
	camLobby camSetTarget _playerPos;
	camLobby camCommit 0;
	cameraEffectEnableHUD false;
	_camLobbyEndPos = [(getPos player), 5, (getDir player)+35] call dro_extendPos;
	_camLobbyEndPos = [(_camLobbyEndPos select 0), (_camLobbyEndPos select 1), (_camLobbyEndPos select 2)+1];
	camLobby camPreparePos _camLobbyEndPos;
	camLobby camPrepareTarget _playerPos;
	camLobby camCommitPrepared 120;
};

dro_hvtCapture = {
	params ["_hostage", "_player"];		
	[_hostage] joinSilent (group _player);
	[_hostage] call sun_addResetAction;
	[_hostage, false] remoteExec ["setCaptive", _hostage, true];	
	[_hostage, 'MOVE'] remoteExec ["enableAI", _hostage, true];			
	[(_hostage getVariable 'captureTask'), 'SUCCEEDED', true] remoteExec ["BIS_fnc_taskSetState", (leader(group _player)), true];
	'mkrAOC' setMarkerAlpha 0.5;
	for "_i" from ((count taskIntel)-1) to 0 step -1 do {
		if (((taskIntel select _i) select 0) == ([(_hostage getVariable 'captureTask')] call BIS_fnc_taskParent)) then {taskIntel deleteAt _i};
	};
	publicVariable "taskIntel";
};

dro_hostageRelease = {
	params ["_hostage", "_player"];	
	_hostage setVariable ["hostageBound", false, true];
	[_hostage, "Acts_AidlPsitMstpSsurWnonDnon_out"] remoteExec ["playMoveNow", 0]; 
	[_hostage] joinSilent (group _player);
	[_hostage] call sun_addResetAction;
	[_hostage, false] remoteExec ["setCaptive", _hostage, true];	
	[_hostage, 'MOVE'] remoteExec ["enableAI", _hostage, true];			
	[(_hostage getVariable 'joinTask'), 'SUCCEEDED', true] remoteExec ["BIS_fnc_taskSetState", (leader(group _player)), true];
	'mkrAOC' setMarkerAlpha 0.5;
	for "_i" from ((count taskIntel)-1) to 0 step -1 do {
		if (((taskIntel select _i) select 0) == ([(_hostage getVariable 'joinTask')] call BIS_fnc_taskParent)) then {taskIntel deleteAt _i};
	};
	publicVariable "taskIntel";
	//missionNamespace setVariable [format ['%1Completed', ((_this select 0) getVariable 'taskName')], 1, true];	
};

dro_detectPosMP = {
	private ["_taskName", "_taskPosFake"];
	_taskName = _this select 0;
	_taskPosFake = _this select 1;
	
	_aimedPos = screenToWorld [0.5, 0.5];
	if ((alive player) && ((_aimedPos distance _taskPosFake) < 100) && ((((vehicle player) distance _taskPosFake) < 1000) || (((getConnectedUAV player) distance _taskPosFake) < 1000))) then {		
		_currentInspTime = (missionNamespace getVariable _taskName);
		_currentInspTime = _currentInspTime + 1;
		missionNamespace setVariable [_taskName, _currentInspTime, true];
	};
};