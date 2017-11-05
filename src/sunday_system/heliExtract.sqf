params ["_lzPos"];

diag_log format ["DRO: Extract pos = %1", _lzPos];

_break = false;
_heliTransports = [];
_cargoRange = [100, 0];

{
	_trueCargo = [_x] call sun_getTrueCargo;	
	if (_trueCargo >= count (units (grpNetId call BIS_fnc_groupFromNetId))) then {
		if (_forEachIndex == 0) then {
			_cargoRange set [0, _trueCargo];
			_cargoRange set [1, _trueCargo];
		};
		_heliTransports pushBack _x;
		if (_trueCargo < (_cargoRange select 0)) then {
			_cargoRange set [0, _trueCargo];
		};
		if (_trueCargo > (_cargoRange select 1)) then {
			_cargoRange set [1, _trueCargo];
		};
	};
} forEach pHeliClasses;

diag_log format ["DRO: Extract _heliTransports = %1", _heliTransports];


if (count _heliTransports > 0) then {
	
	_spawnPos = [_lzPos, 2500, ([centerPos, _lzPos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
	_spawnPos set [2, 40];

	_markerLZ = createMarker [(format ["mkrLZ%1", round(random 100000)]), _lzPos];						
	_markerLZ setMarkerShape "ICON";		
	_markerLZ setMarkerColor "ColorBlack";
	_markerLZ setMarkerType "mil_pickup_noShadow";
	_markerLZ setMarkerText "Extract LZ";
	
	// Spawn vehicle
	_cargoWeights = [];
	{
		_thisWeight = linearConversion [(_cargoRange select 0)-1, (_cargoRange select 1)+1, [_x] call sun_getTrueCargo, 1, 0, true]; 
		_cargoWeights pushBack _thisWeight;
	} forEach _heliTransports;
	diag_log format ["DRO: _heliTransports = %1", _heliTransports];
	diag_log format ["DRO: _cargoWeights = %1", _cargoWeights];
	_vehType = [_heliTransports, _cargoWeights] call BIS_fnc_selectRandomWeighted;//selectRandom _heliTransports;
		
	_heli = createVehicle [_vehType, _spawnPos, [], 0, "FLY"];
	_heli setPos _spawnPos;
	[_heli, playersSide] call sun_createVehicleCrew;		
	waitUntil {!isNull (driver _heli)};
	_heliGroup = group (driver _heli);	
	//_heli setCaptive true;
	
	[_heli] spawn {
		waitUntil {!alive (_this select 0) OR !([(_this select 0)] call sun_helicopterCanFly)};
		[] remoteExec ["sun_playRadioRandom", 0];
		[[playersSide, "HQ"], (format ["We've just lost contact with %1, you'll need to extract on your own.", (_this select 0)])] remoteExec ["sideChat", 0];	
	};
	
	[] remoteExec ["sun_playRadioRandom", 0];
	[(driver _heli), (format ["This is %1, request received. Proceeding to grid %2.", _heli, mapGridPosition _lzPos])] remoteExec ["sideChat", 0];		
	sleep 60;
	
	while {(count (waypoints (_heli) )) > 0} do {
	   deleteWaypoint ((waypoints (_heli) ) select 0);
	};
	
	[_heli, _lzPos] spawn {
		waitUntil {(_this select 0) distance (_this select 1) < 300};
		(_this select 0) setCaptive true;
	};
	
	private _wp0 = _heliGroup addWaypoint [(getPos _heli), 0];	
	_wp0 setWaypointBehaviour "CARELESS";
	//_wp0 setWaypointCombatMode "GREEN";
	_wp0 setWaypointSpeed "NORMAL";
	_wp0 setWaypointType "MOVE";	
	
	private _wpLand = _heliGroup addWaypoint [_lzPos, 0];
	_wpLand setWaypointType "MOVE";
	_wpLand setWaypointStatements ["TRUE", "vehicle this land 'GET IN'"];
	
	/*
	waitUntil {
		((_heli distance _lzPos) < 100) OR !([_heli] call sun_helicopterCanFly)
	};
	*/
	waitUntil {
		sleep 2;
		isTouchingGround _heli
		//((getPos _heli) select 2) <= 3
	};
		
	if ([_heli] call sun_helicopterCanFly) then {
		[(leader (grpNetId call BIS_fnc_groupFromNetId)), "extractLeave"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId)), true];
	};
		
	waitUntil {
		if !([_heli] call sun_helicopterCanFly) exitWith {
			_break = true;
		};
		sleep 1;
		_heli setVelocity [0, 0, 0];
		_heli disableAI "MOVE";
		if (!isNil "extractLeave") then {
			extractLeave
		};
		//({_x in _heli} count (units (grpNetId call BIS_fnc_groupFromNetId))) == count (units (grpNetId call BIS_fnc_groupFromNetId))
	};
	_heli enableAI "MOVE";
	if (!_break) then {
		[] remoteExec ["sun_playRadioRandom", 0];
		[(driver _heli), "Copy that, we're outbound."] remoteExec ["sideChat", 0];	
		private _wpExtract = _heliGroup addWaypoint [_spawnPos, 0];
		_wpExtract setWaypointType "MOVE";
		_wpExtract setWaypointStatements ["TRUE", "vehicle this land 'LAND'"];
	};
};
