// *****
// SETUP PLAYER START
// *****

newUnitsReady = false;
private _center = getPos trgAOC;
_playerGroup = (units(grpNetId call BIS_fnc_groupFromNetId));
_playersPos = [];
_groundStyleSelect = "";

// Has the player edited in Zeus?
_zeus = getAssignedCuratorLogic (leader(grpNetId call BIS_fnc_groupFromNetId));
diag_log format ["Zeus = %1",_zeus];

// Delete all tasks
{
	diag_log format ["DRO: Deleting old task %1", _x];
	[_x] call BIS_fnc_deleteTask;
} forEach ([leader (grpNetId call BIS_fnc_groupFromNetId)] call BIS_fnc_tasksUnit);

{	
	if (isObjectHidden _x) then {		
		deleteVehicle _x;
		diag_log format ["DRO: Deleting unit %1", _x];
	};
} forEach _playerGroup;
diag_log _playerGroup;

if (insertType == 0) then {
	insertType = [1,3] call BIS_fnc_randomInt;		
};

_customStart = false;
_randomStartingLocation = [];
_forceSeaStart = 0;
if (count customPos == 0) then {
	diag_log "DRO: No custom start position found, will generate random.";
	_randomStartingLocation = [];
} else {
	diag_log "DRO: Custom start position found.";
	_randomStartingLocation = customPos;
	if (surfaceIsWater _randomStartingLocation) then {
		_forceSeaStart = 1;
	};
	_customStart = true;
};

_seaSpawnReal = [];
_airStartPos = [];

// Random resupply
_ResupplyOnePos = [_center, 0, 500, 2, 0, 0.4, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
if !(_ResupplyOnePos isEqualTo [0,0,0]) then {
	_resupply = "B_supplyCrate_F" createVehicle _ResupplyOnePos;

	clearWeaponCargoGlobal _resupply;
	clearMagazineCargoGlobal _resupply;
	clearItemCargoGlobal _resupply;

	_resupply addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
	_resupply addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
	_resupply addItemCargoGlobal ["Medikit", 1];
	_resupply addItemCargoGlobal ["FirstAidKit", 10];
	{
		//_magazines = magazines _x;
		_magazines = magazinesAmmoFull _x;
		
		{
			_resupply addMagazineCargoGlobal [(_x select 0), 2];
		} forEach _magazines;	
	} forEach units (grpNetId call BIS_fnc_groupFromNetId);
	
	[_resupply] spawn {
		waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
		[(_this select 0)] call sun_supplyBox;
	};
	
	markerResupply = createMarker ["resupplyMkr", _ResupplyOnePos];
	markerResupply setMarkerShape "ICON";
	markerResupply setMarkerColor markerColorPlayers;
	markerResupply setMarkerType "mil_flag";
	markerResupply setMarkerText "Resupply";
	markerResupply setMarkerSize [0.6, 0.6];
};

_carClasses = [];
_carWeights = [];
_slots = [];

if (count pCarNoTurretClasses > 0) then {
	{
		_vehicleClass = (configFile >> "CfgVehicles" >> _x >> "vehicleClass") call BIS_fnc_GetCfgData;		
		_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
		
		if (_vehicleClass != "Support") then {		
			_carClasses pushBack _x;						
			_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));						
			_slots pushBack _vehRoles;
			_weight = (1-((_vehRoles * 3)/100));		
			_carWeights pushBack _weight;		
			
		};
	} forEach pCarNoTurretClasses;
};

{
	_vehicleClass = (configFile >> "CfgVehicles" >> _x >> "vehicleClass") call BIS_fnc_GetCfgData;
	_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
	
	if (_vehicleClass != "Support") then {		
		if (_x in _carClasses) then {} else {
			_carClasses pushBack _x;				
			_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
			_slots pushBack _vehRoles;		
			_weight = (1-((_vehRoles * 7)/100));		
			_carWeights pushBack _weight;
		};		
	};		
} forEach pCarClasses;

_heliClasses = [];
_cargoRange = [100, 0];
{	
	_trueCargo = [_x] call sun_getTrueCargo;		
	if (_trueCargo >= count (units (grpNetId call BIS_fnc_groupFromNetId))) then {
		if (_forEachIndex == 0) then {
			_cargoRange set [0, _trueCargo];
			_cargoRange set [1, _trueCargo];
		};
		_heliClasses pushBack _x;
		if (_trueCargo < (_cargoRange select 0)) then {
			_cargoRange set [0, _trueCargo];
		};
		if (_trueCargo > (_cargoRange select 1)) then {
			_cargoRange set [1, _trueCargo];
		};
	};	
} forEach pHeliClasses;

_shipClasses = pShipClasses;
if (count _shipClasses == 0) then {
	_shipClasses pushBack "B_Boat_Transport_01_F";
};

if ((count _carClasses) == 0) then {
	_carClasses pushBack "B_G_Offroad_01_F";
	_carWeights pushBack 1;
};

if ((count _heliClasses) == 0) then {
	switch (playersSide) do {
		case west: {_heliClasses pushBack "B_Heli_Transport_01_F"};
		case east: {_heliClasses pushBack "O_Heli_Light_02_F"};
		case resistance: {_heliClasses pushBack "I_Heli_Transport_02_F"};
	};
};

diag_log format ["DRO: Insert will be %1", insertType];

switch (insertType) do {

	case 1: {
		// GROUND INSERTION		
		_groundStylesAvailable = [];
		_fobPos = [];
		_seaSpawn = nil;
		
		if (_forceSeaStart == 1) then {
			_groundStylesAvailable = ["SEA"];
		} else {		
			// Check for sea start possibility
			_seaPositions = [];	
			if (!_customStart) then {
				_seaPlaces = selectBestPlaces [_center, aoSize, "(1 + sea)", 50, 5];							
				{
					_thisPos = (_x select 0);
					_zValue = getTerrainHeightASL _thisPos;
					
					if (_zValue < -10) then {
						_seaPositions pushBack [((_x select 0)select 0), ((_x select 0)select 1), _zValue];	
					};
					
				} forEach _seaPlaces;
				
				_seaPositions = [_seaPositions, [_center], {_input0 distance _x}, "DESCEND"] call BIS_fnc_sortBy;
				diag_log format ["DRO: Potential sea positions: %1", _seaPositions];
			};
			// Generate random ground start position for player group
			if (count _randomStartingLocation == 0) then {
				_randomStartingLocation = [_center, (aoSize+500), (aoSize+1500), 8, 0, 0.25, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			};
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center, (aoSize+500), (aoSize+3000), 2, 0, 0.6, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;				
			};			
			if (_forceSeaStart == 1) then {
				_groundStylesAvailable = ["SEA"];
			} else {
				if (!(_randomStartingLocation isEqualTo [0,0,0])) then {
					_groundStylesAvailable pushback "CAMP";					
					// Check for FOB possibility
					_fobPos = _randomStartingLocation findEmptyPosition [0, 100, "Land_Cargo_House_V3_F"];
					if (count _fobPos > 0) then {			
						_groundStylesAvailable pushback "FOB";
					};
				};
			};
			
		
			
			if (count _groundStylesAvailable == 0) then {			
				if ((count _seaPositions > 0) && (count _shipClasses > 0)) then {
					_seaSpawn = _seaPositions select 0;
					_groundStylesAvailable pushBackUnique "SEA";
				};		
			} else {
				_seaRand = (random 100);
				if (_seaRand > 85) then {
					if ((count _seaPositions > 0) && (count _shipClasses > 0)) then {
						_seaSpawn = _seaPositions select 0;
						_groundStylesAvailable pushBackUnique "SEA";
					};
				};
			};		
		};
		_groundStyleSelect = selectRandom _groundStylesAvailable;
		diag_log format ["DRO: Ground insert style will be %1", _groundStyleSelect];
				
		switch (_groundStyleSelect) do {
			case "FOB": {					
				// Spawn FOB				
				_objects = selectRandom compositionsFOBs;
				_spawnedObjects = [_fobPos, (random 360), _objects] call BIS_fnc_ObjectsMapper;
				
				{
					if (typeOf _x == "Sign_Arrow_Blue_F") then {
						_guardGroup = [getPos _x, playersSide, pInfClassesForWeights, pInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
						_guardUnit = ((units _guardGroup) select 0);
						_guardUnit setFormDir (getDir _x);
						_guardUnit setDir (getDir _x);
						_guardUnit disableAI "TARGET";
						_guardUnit disableAI "MOVE";
						deleteVehicle _x;
					};
				} forEach _spawnedObjects;
				
				// Move player group to that position
				_playersPos = [_fobPos, 20, (random 360)] call dro_extendPos;
				//[group u1, _extPos] call sun_moveGroup;
				[_playersPos] remoteExec ["sun_newUnits", s1];
				waitUntil {newUnitsReady};				
				_rolesFilled = 0;
				_whileAttempts = 0;
				_select = 0;
				if (count startVehicles > 0) then {
					{
						_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
						_vehLocation = _randomStartingLocation findEmptyPosition [10, 60, _x];
						diag_log format ["DRO: spawning insert vehicle %1 at %2 with %3 roles", _x, _vehLocation, _vehRoles];
						if (!isNil "_vehLocation" && count _vehLocation > 0) then {
							_veh = createVehicle [_x, _vehLocation, [], 0, "NONE"];
							_veh respawnVehicle	[-1, 0];							
							_rolesFilled = _rolesFilled + _vehRoles;
						};
					} forEach startVehicles;
				};
				while {(_rolesFilled < (count(units (grpNetId call BIS_fnc_groupFromNetId))))} do {
					_vehClass = "";
					diag_log format ["DRO: startVehicles = %1", startVehicles];
					if ((count startVehicles > 0) && _whileAttempts == 0) then {
						_vehClass = (startVehicles select _select);
						if (_select < ((count startVehicles)-1)) then {
							_select = _select + 1;
						} else {
							_select = 0;
						}; 
					} else {
						_vehClass =  [_carClasses, _carWeights] call BIS_fnc_selectRandomWeighted;
					};					
					_vehRoles = (count([_vehClass] call BIS_fnc_vehicleRoles));
					_vehLocation = _randomStartingLocation findEmptyPosition [10, 40, _vehClass];
					diag_log format ["DRO: spawning insert vehicle %1 at %2 with %3 roles", _vehClass, _vehLocation, _vehRoles];
						if (!isNil "_vehLocation" && count _vehLocation > 0) then {
							if (_vehClass isKindOf "Helicopter") then {
								_padTypes = ["Land_HelipadCircle_F", "Land_HelipadCivil_F", "Land_HelipadSquare_F"];
								_veh = createVehicle [(selectRandom _padTypes), _vehLocation, [], 0, "NONE"];
							};
							_veh = createVehicle [_vehClass, _vehLocation, [], 0, "NONE"];
							_veh respawnVehicle	[-1, 0];						
							_rolesFilled = _rolesFilled + _vehRoles;
						};
					_whileAttempts = _whileAttempts + 1;
					if (_whileAttempts >= 8) exitWith {
						diag_log "DRO: spawning insert vehicle while attempts exceeded";
					};
				};
				
				_boxLocation = _randomStartingLocation findEmptyPosition [0, 20, "B_supplyCrate_F"];
				if (count _boxLocation > 0) then {				
					_box = createVehicle ["B_supplyCrate_F", _fobPos, [], 0, "NONE"];
					_box = [_box] call sun_checkVehicleSpawn;
					clearWeaponCargoGlobal _box;
					clearMagazineCargoGlobal _box;
					clearItemCargoGlobal _box;

					_box addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
					_box addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
					_box addItemCargoGlobal ["Medikit", 1];
					_box addItemCargoGlobal ["FirstAidKit", 10];

					{
						//_magazines = magazines _x;
						_magazines = magazinesAmmoFull _x;
						
						{
							_box addMagazineCargoGlobal [(_x select 0), 2];
						} forEach _magazines;	
					} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
					
					["AmmoboxInit", [_box, true]] spawn BIS_fnc_arsenal;
					[_box] spawn {
						waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
						[(_this select 0)] call sun_supplyBox;
					};
					
				};
				// FOB marker
				deleteMarker "campMkr";
				_campNames = ["Partisan", "Shepherd", "Warden", "Stone", "Gullion", "Beech", "Elm", "Ash", "Cedar"];
				_campName = format ["FOB %1", selectRandom _campNames];
				missionNameSpace setVariable ["publicCampName", _campName];
				publicVariable "publicCampName";
				markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
				markerPlayerStart setMarkerShape "ICON";
				markerPlayerStart setMarkerColor markerColorPlayers;
				markerPlayerStart setMarkerType "loc_Bunker";
				markerPlayerStart setMarkerSize [3, 3];
				markerPlayerStart setMarkerText _campName;
				if ((paramsArray select 0) < 3 && (paramsArray select 1) < 2) then {	
					respawnFOB = [missionNamespace, "campMkr", _campName] call BIS_fnc_addRespawnPosition;
				};
				
			};
			
			case "CAMP": {
				scopeName "camp";				
				// Spawn campsite
				[_randomStartingLocation] call fnc_generateCampsite;
				
				// Move player group to that position
				_playersPos = [_randomStartingLocation, 20, (random 360)] call dro_extendPos;				
				[_playersPos] remoteExec ["sun_newUnits", s1];
				waitUntil {newUnitsReady};				
							
				// Create vehicles
				_rolesFilled = 0;
				_whileAttempts = 0;
				_select = 0;
				if (count startVehicles > 0) then {
					{
						_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
						_vehLocation = _randomStartingLocation findEmptyPosition [10, 60, _x];
						diag_log format ["DRO: spawning insert vehicle %1 at %2 with %3 roles", _x, _vehLocation, _vehRoles];
						if (!isNil "_vehLocation" && count _vehLocation > 0) then {
							_veh = createVehicle [_x, _vehLocation, [], 0, "NONE"];
							_veh respawnVehicle	[-1, 0];							
							_rolesFilled = _rolesFilled + _vehRoles;
						};
					} forEach startVehicles;
				};
				
				while {(_rolesFilled < (count(units (grpNetId call BIS_fnc_groupFromNetId))))} do {
					_vehClass = "";
					diag_log format ["DRO: startVehicles = %1", startVehicles];
					if ((count startVehicles > 0) && _whileAttempts == 0) then {
						_vehClass = (startVehicles select _select);
						if (_select < ((count startVehicles)-1)) then {
							_select = _select + 1;
						} else {
							_select = 0;
						}; 
					} else {
						_vehClass =  [_carClasses, _carWeights] call BIS_fnc_selectRandomWeighted;
					};
					_vehRoles = (count([_vehClass] call BIS_fnc_vehicleRoles));
					_vehLocation = _randomStartingLocation findEmptyPosition [10, 60, _vehClass];
					diag_log format ["DRO: spawning insert vehicle %1 at %2 with %3 roles", _vehClass, _vehLocation, _vehRoles];
						if (!isNil "_vehLocation" && count _vehLocation > 0) then {
							_veh = createVehicle [_vehClass, _vehLocation, [], 0, "NONE"];
							_veh respawnVehicle	[-1, 0];							
							_rolesFilled = _rolesFilled + _vehRoles;
						};
					_whileAttempts = _whileAttempts + 1;
					if (_whileAttempts >= 8) exitWith {
						diag_log "DRO: spawning insert vehicle while attempts exceeded";
					};
				};
				
				_boxLocation = _randomStartingLocation findEmptyPosition [0, 20, "B_supplyCrate_F"];
				if (count _boxLocation > 0) then {
					_box = createVehicle ["B_supplyCrate_F", _boxLocation, [], 0, "NONE"];
					_box = [_box] call sun_checkVehicleSpawn;
					clearWeaponCargoGlobal _box;
					clearMagazineCargoGlobal _box;
					clearItemCargoGlobal _box;

					_box addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
					_box addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
					_box addItemCargoGlobal ["Medikit", 1];
					_box addItemCargoGlobal ["FirstAidKit", 10];

					{
						//_magazines = magazines _x;
						_magazines = magazinesAmmoFull _x;
						
						{
							_box addMagazineCargoGlobal [(_x select 0), 2];
						} forEach _magazines;	
					} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
					
					["AmmoboxInit", [_box, true]] spawn BIS_fnc_arsenal;
					[_box] spawn {
						waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
						[(_this select 0)] call sun_supplyBox;
					};					
				};						
				
				// Camp marker
				deleteMarker "campMkr";
				_campNames = ["Mockingbird", "Bluejay", "Cormorant", "Heron", "Albatross", "Hornbill", "Osprey", "Kingfisher", "Nuthatch"];
				_campName = format ["Camp %1", selectRandom _campNames];
				missionNameSpace setVariable ["publicCampName", _campName];
				publicVariable "publicCampName";
				markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
				markerPlayerStart setMarkerShape "ICON";
				markerPlayerStart setMarkerColor markerColorPlayers;
				markerPlayerStart setMarkerType "loc_Bunker";
				markerPlayerStart setMarkerSize [3, 3];
				markerPlayerStart setMarkerText _campName;
				if ((paramsArray select 0) < 3 && (paramsArray select 1) < 2) then {
					respawnFOB = [missionNamespace, "campMkr", _campName] call BIS_fnc_addRespawnPosition;
				};	
				
			
			};
			
			case "SEA": {				
				_shipClass = selectRandom _shipClasses;
				
				if (getMarkerColor "campMkr" == "") then {
					_randomStartingLocation = [(_seaSpawn select 0), (_seaSpawn select 1), 0];
				} else {
					_randomStartingLocation = getMarkerPos "campMkr";					
				};
				
				[_randomStartingLocation] remoteExec ["sun_newUnits", s1];
				waitUntil {newUnitsReady};				
				sleep 2;
				// Spawn vehicles until there are enough slots for players
				_vehiclePool = [];
				_rolesFilled = 0;
				while {(_rolesFilled < (count(units(grpNetId call BIS_fnc_groupFromNetId))))} do {
				
					_shipClass = selectRandom _shipClasses;
					_vehRoles = (count([_shipClass] call BIS_fnc_vehicleRoles));
					
					_boatLoc = _randomStartingLocation findEmptyPosition [0, 10, _shipClass];
					
					_boat = createVehicle [_shipClass, _boatLoc, [], 0, "NONE"];
					
					[
						_boat,
						[
							"Nudge",  
							{  
								_dir = [(_this select 1), (_this select 0)] call BIS_fnc_dirTo;  
								_nudgePos = [(getPos (_this select 0)), 2, _dir] call dro_extendPos;  
								(_this select 0) setVelocity [(sin _dir)*3, (cos _dir)*3, 0.5];	
							},  
							nil,  
							6,  
							false,  
							false,  
							"",  
							"(_this distance _target < 8) && (vehicle _this == _this)"
						]
					] remoteExec ["addAction", 0, true];
					
					_rolesFilled = _rolesFilled + _vehRoles;
					
					_vehiclePool pushBack _boat;
					
				};	
				
				if (count _vehiclePool > 0) then {
					
					_playersLeft = (units(grpNetId call BIS_fnc_groupFromNetId));
					diag_log format ["_playersLeft = %1", _playersLeft];
					{
						if ((count _playersLeft) > 0) then {
							_thisBoat = _x;
							diag_log format ["_thisBoat = %1", _thisBoat];
							_vehRoles = (count([_thisBoat] call BIS_fnc_vehicleRoles));
							diag_log format ["_vehRoles = %1", _vehRoles];
							_playersToAssign = [];
							if (_vehRoles > (count _playersLeft)) then {_vehRoles = (count _playersLeft)};
							for "_i" from 0 to (_vehRoles - 1) do {	
								diag_log format ["_i = %1", _i];
								diag_log format ["(_playersLeft select _i) = %1", (_playersLeft select _i)];
								_thisUnit = (_playersLeft select _i);
								_playersToAssign pushBack _thisUnit;							
							};
							_playersLeft = _playersLeft - _playersToAssign;
							diag_log format ["_playersLeft = %1", _playersLeft];
							diag_log format ["_playersToAssign = %1", _playersToAssign];
							if ((count _playersToAssign) > 0) then {
								[_playersToAssign, _thisBoat] spawn sun_groupToVehicle;
							};
						};						
					} forEach _vehiclePool;
					diag_log format ["(units(group s1)) = %1", (units(grpNetId call BIS_fnc_groupFromNetId))];					
					deleteMarker "campMkr";
					missionNameSpace setVariable ["publicCampName", "Altis Ocean Territory"];
					publicVariable "publicCampName";
					markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
					markerPlayerStart setMarkerShape "ICON";
					markerPlayerStart setMarkerColor markerColorPlayers;
					markerPlayerStart setMarkerType "mil_start";
					markerPlayerStart setMarkerText "Sea Insert";
					
					{
						_x addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
						_x addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
						_x addItemCargoGlobal ["Medikit", 1];
						_x addItemCargoGlobal ["FirstAidKit", 10];
					} forEach _vehiclePool;
										
					
				};				
			};
		};		
				
		// Blacklist marker
		_markerBL = createMarker ["blacklistMkr", _randomStartingLocation];
		_markerBL setMarkerShape "ELLIPSE";
		_markerBL setMarkerSize [500, 500];
		_markerBL setMarkerAlpha 0;
		blackList = blackList + [_markerBL];
			
	};
	case 2: {
		// HALO INSERTION		
		// Generate drop position
				
		// If no insert position selected then generate a random one
		if (count _randomStartingLocation == 0) then {		
			_randomStartingLocation = [_center,(aoSize/1.8),(aoSize/1.6),0,1,1,0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center,(aoSize/1.8),(aoSize/1.6),0,0,1,0] call BIS_fnc_findSafePos;
			};			
		};
				
		_randomStartingLocation set [2, 0];
		_startHeight = (getTerrainHeightASL _randomStartingLocation) + 2000;
		_planeStartPos = [(_randomStartingLocation select 0), (_randomStartingLocation select 1), 2100];
		_airStartPos = [(_randomStartingLocation select 0), (_randomStartingLocation select 1), 2000];
		
		// Draw drop marker
		deleteMarker "campMkr";
		markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerText "Drop point";		
		
		// Spawn heli and begin insertion
		if (count pPlaneClasses > 0) then {
			_planeClass = selectRandom pPlaneClasses;			
			_planeStartPos set [2, 3050];
			_insertPlane = createVehicle [_planeClass, _planeStartPos, [], 0, "FLY"];
			[_insertPlane, playersSide] call sun_createVehicleCrew;
			//createVehicleCrew _insertPlane;
			_insertPlane setPos _planeStartPos;
			_insertPlane setDir ([_planeStartPos, _center] call BIS_fnc_dirTo);
			_insertPlane move [0,0,0];
			_insertPlane flyInHeight 3000;
			_insertPlane setBehaviour "CARELESS";			
			[_insertPlane] spawn {
				waitUntil {(_this select 0) distance [0,0,0] < 1000};
				{deleteVehicle _x} forEach (crew (_this select 0));
				deleteVehicle (_this select 0);
			};			
		};
		[_airStartPos] remoteExec ["sun_newUnits", s1];
		waitUntil {newUnitsReady};
		sleep 2;
		//[_airStartPos] call sun_newUnits;
		/*
		waitUntil {count (units (grpNetId call BIS_fnc_groupFromNetId)) == 0};
		grpNetId = _newGroup call BIS_fnc_netId;
		diag_log format ["DRO: New group with netID %1 containing %2", grpNetId, units (grpNetId call BIS_fnc_groupFromNetId)];	
		publicVariable "grpNetId";
		*/
		//[_airStartPos] remoteExec ["sun_newUnits", s1];
		//waitUntil {newUnitsReady};
		
		_lastPos = _airStartPos;
		{
			_thisPos = [_lastPos, 20, ([_airStartPos, _center] call BIS_fnc_dirTo)] call dro_extendPos;
			_x setPos [(_thisPos select 0) + (random 10), (_thisPos select 1) + (random 10), (3000 + (random 20))];			
			_lastPos = _thisPos;
		} forEach units (grpNetId call BIS_fnc_groupFromNetId);
				
		[units (grpNetId call BIS_fnc_groupFromNetId)] execVM 'sunday_system\callParadrop.sqf';
		
		// Set wind
		0 setGusts 0;
		setWind [0, 0, true];		
		diag_log "DRO: Air insert called";
		sleep 2;		
		// Blacklist marker
		_markerBL = createMarker ["blacklistMkr", _randomStartingLocation];
		_markerBL setMarkerShape "ELLIPSE";
		_markerBL setMarkerSize [500, 500];
		_markerBL setMarkerAlpha 0;
		blackList = blackList + [_markerBL];			
		missionNameSpace setVariable ["publicCampName", format ["%1 Airspace", worldName]];
		publicVariable "publicCampName";
	};
	
	case 3: {
		// HELI INSERTION		
		// Generate drop position				
		// If no insert position selected then generate a random one
		if (count _randomStartingLocation == 0) then {		
			_randomStartingLocation = [_center,(aoSize-150),(aoSize+500),0,0,0.25,0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center,aoSize,(aoSize+1500),0,0,1,0] call BIS_fnc_findSafePos;
			};			
		};				
		_randomStartingLocation set [2, 0];
		
		_dir = [_center, _randomStartingLocation] call BIS_fnc_dirTo;
		_heliPos = [_randomStartingLocation, 2000, _dir] call BIS_fnc_relPos;
		_heliPos set [2,100];
		_cargoWeights = [];
		{
			_thisWeight = linearConversion [(_cargoRange select 0)-1, (_cargoRange select 1)+1, [_x] call sun_getTrueCargo, 1, 0, true]; 
			_cargoWeights pushBack _thisWeight;
		} forEach _heliClasses;		
		diag_log format ["DRO: _heliClasses = %1", _heliClasses];
		diag_log format ["DRO: _cargoWeights = %1", _cargoWeights];
		_heliClass = [_heliClasses, _cargoWeights] call BIS_fnc_selectRandomWeighted;//selectRandom _heliTransports;
		
		_insertHeli = createVehicle [_heliClass, _heliPos, [], 0, "FLY"];
		_insertHeli allowDamage false;
		[_insertHeli, playersSide] call sun_createVehicleCrew;		
		_insertHeli setPos _heliPos;
		_insertHeli setDir (_dir + 180);		
		waitUntil {!isNull (driver _insertHeli)};		
		_insertHeli flyInHeight 40;
		_insertHeli setBehaviour "CARELESS";
		_insertHeli setCaptive true;
		(driver _insertHeli) disableAI "TARGET";		
		(driver _insertHeli) disableAI "AUTOTARGET";		
		
		_heliGroup = group (driver _insertHeli);
		while {(count (waypoints (_insertHeli) )) > 0} do {
		   deleteWaypoint ((waypoints (_insertHeli) ) select 0);
		};
		[_heliGroup, _randomStartingLocation, _insertHeli, _heliPos] spawn {
			_heliGroup = (_this select 0);
			_randomStartingLocation = (_this select 1);
			_insertHeli = (_this select 2);
			_heliPos = (_this select 3);
			private _wp0 = _heliGroup addWaypoint [(getPos _insertHeli), 0];	
			_wp0 setWaypointBehaviour "CARELESS";			
			_wp0 setWaypointSpeed "NORMAL";
			_wp0 setWaypointType "MOVE";	
			
			private _wpLand = _heliGroup addWaypoint [_randomStartingLocation, 0];
			_wpLand setWaypointType "MOVE";
			_wpLand setWaypointStatements ["TRUE", "vehicle this land 'GET OUT'"];
			
			waitUntil {
				sleep 2;
				((getPos _insertHeli) select 2) <= 3
			};		
			_insertHeli disableAI "MOVE";
			waitUntil {
				sleep 1;
				_insertHeli setVelocity [0, 0, 0];
				({_x in _insertHeli} count (units (grpNetId call BIS_fnc_groupFromNetId))) == 0;				
			};
			_insertHeli enableAI "MOVE";
			private _wpEnd = _heliGroup addWaypoint [_heliPos, 0];
			_wpEnd setWaypointType "MOVE";
			_wpEnd setWaypointStatements ["TRUE", "_heli = vehicle this; {_heli deleteVehicleCrew _x} forEach crew _heli; deleteVehicle _heli;"];			
		};
				
		// Draw drop marker
		deleteMarker "campMkr";
		markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerText "Drop point";
		
		[getPos logicStartPos] remoteExec ["sun_newUnits", s1];
		waitUntil {newUnitsReady};
		sleep 3;
		[(units(grpNetId call BIS_fnc_groupFromNetId)), _insertHeli] spawn sun_groupToVehicle;
	};	
};

// Check for UAV terminals and spawn random UAV if possible
_uavSpawned = 0;
_spawnUAVPatrol = false;
if (count pUAVClasses > 0) then {
	{
		_itemsPresent = assignedItems _x;
		{
			if ((["UavTerminal", _x] call BIS_fnc_inString) && (_uavSpawned == 0)) then {
				_availableUAVs = [];
				{
					if (_x isKindOf "Car" || _x isKindOf "Helicopter") then {
						_availableUAVs pushBack _x;
					};
					
				} forEach pUAVClasses;
				if (count _availableUAVs > 0) then {
					if (insertType == 1) then {
						if (_groundStyleSelect == "FOB" || _groundStyleSelect == "CAMP") then {
							_uavClass = selectRandom _availableUAVs;
							_uavLocation = _randomStartingLocation findEmptyPosition [10, 30, _uavClass];
							if (count _uavLocation > 0) then {
								_uav = createVehicle [_uavClass, _uavLocation, [], 0, "NONE"];
								_uavSpawned = 1;
							};
						};
					};
				};								
			};
		} forEach _itemsPresent;
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));	
};

// Create transport boat if any routes are blocked by water
diag_log "DRO: Searching for water";
_waterReturn = [_randomStartingLocation, _center, true] call sun_checkRouteWater;
_waterPositions = [];
if (typeName _waterReturn == "ARRAY") then {
	_waterPositions pushBack _waterReturn;
} else {
	{
		if (typeName (_x select 3) == "ARRAY") then {
			_waterPositions pushBack (_x select 3);
		};
	} forEach AOLocations;
};
if (count _waterPositions > 0) then {
	diag_log "DRO: Found water for extra boat spawn";
	_closestWaterPositions = [_waterPositions, [_randomStartingLocation], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;
	_checkPos = (_closestWaterPositions select 0);					
	_waterPlaces = selectBestPlaces [_checkPos, 200, "sea - waterDepth + (waterDepth factor [0.25, 0.5])", 20, 5];					
	diag_log format ["DRO: _waterPlaces = %1", _waterPlaces];
	_deepestPos = ((_waterPlaces select 0) select 0);
	_deepestHeight = getTerrainHeightASL ((_waterPlaces select 0) select 0);					
	{
		_height = getTerrainHeightASL (_x select 0);
		if (_height < _deepestHeight) then {
			_deepestHeight = _height;
			_deepestPos = (_x select 0);
		};
	} forEach _waterPlaces;					
	
	_boatPos = [(_deepestPos select 0), (_deepestPos select 1), 0];
	diag_log format ["DRO: _boatPos = %1", _boatPos];
	// Spawn boats until there are enough slots for players
	_rolesFilled = 0;
	while {_rolesFilled < (count(units(grpNetId call BIS_fnc_groupFromNetId)))} do {
	
		_shipClass = selectRandom _shipClasses;
		_vehRoles = (count([_shipClass] call BIS_fnc_vehicleRoles));
		_dir = [_checkPos, _boatPos] call BIS_fnc_dirTo;
		_boat = createVehicle [_shipClass, _boatPos, [], 0, "NONE"];
		_boat setDir _dir;
		
		[
			_boat,
			[
				"Nudge",  
				{  
				   _dir = [(_this select 1), (_this select 0)] call BIS_fnc_dirTo;  
				   _nudgePos = [(getPos (_this select 0)), 2, _dir] call dro_extendPos;  
					(_this select 0) setVelocity [(sin _dir)*3, (cos _dir)*3, 0.5];	
				},  
				nil,  
				6,  
				false,  
				false,  
				"",  
				"(_this distance _target < 8) && (vehicle _this == _this)"
			]
		] remoteExec ["addAction", 0, true];						
		_rolesFilled = _rolesFilled + _vehRoles;						
	};						
	_markerName = format["boatMkr%1", floor(random 10000)];
	_markerBoat = createMarker [_markerName, _boatPos];			
	_markerBoat setMarkerShape "ICON";
	_markerBoat setMarkerType "mil_pickup";							
	_markerBoat setMarkerColor markerColorPlayers;						
	_markerBoat setMarkerText "Sea transport";	
};		

diag_log units (grpNetId call BIS_fnc_groupFromNetId);
// Recreate tasks
if (count objData > 0) then {
	{	
		if ((_x select 6) > baseReconChance) then {
			// Create task for task data
			[_x] call sun_assignTask;		
		} else {		
			// Create recon addition
			diag_log "DRO: Creating a recon task";
			[_x, true] execVM "sunday_system\objectives\reconTask.sqf";	
		};		
	} forEach objData;
};
publicVariable "taskIDs";

[[musicMain, 0 ,1],"bis_fnc_playmusic", true] call BIS_fnc_MP;

sleep 3;

// Redefine grpNetId in case any mods cause groups to change
//if ((configfile >> "CfgPatches" >> "CCOREM") call BIS_fnc_getCfgIsClass) then {		
	//grpNetId = (group u1) call BIS_fnc_netId;
	//publicVariable "grpNetId";
//};

// Add supports
[] execVM "sunday_system\addSupports.sqf";

diag_log units (grpNetId call BIS_fnc_groupFromNetId);

(leader (grpNetId call BIS_fnc_groupFromNetId)) createDiarySubject ["reset", "Reset AI units"];
(leader (grpNetId call BIS_fnc_groupFromNetId)) createDiaryRecord ["reset", ["Reset AI units", "<br /><font size='20' face='PuristaBold'>Reset AI Units</font><br /><br />Reset AI functions have moved! They can now be found by selecting the stuck unit using F1-10 and opening command menu 6."]];

missionNameSpace setVariable ["startPos", _randomStartingLocation, true];

playerGroup = _playerGroup;

if (isMultiplayer) then {
	// If respawn is enabled add the dynamic team respawn position
	if ((paramsArray select 0) < 3) then {
		if ((paramsArray select 1) == 0 OR (paramsArray select 1) == 2) then {
			[] execVM 'sunday_system\teamRespawnPos.sqf';			
		};		
		diag_log format ["DRO: Respawn time = %1", respawnTime];
		{		
			respawnTime remoteExec ["setPlayerRespawnTime", _x, true];				
		} forEach allPlayers;
	};		
	{
		if (!isPlayer _x) then {		
			// Add eventhandlers to govern respawning in MP games				
			if ((paramsArray select 0) == 3) then {
				// Respawn disabled
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x, true];
			} else {
				// Respawn enabled
				[_x, ["killed", {[(_this select 0)] execVM "sunday_system\fakeRespawn.sqf"}]] remoteExec ["addEventHandler", _x, true];
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x, true];				
			};			
		};		
		// Add player's side to spectator whitelist
		_x setVariable ["WhitelistedSides", [playersSideCfgGroups], true];		
		_x setVariable ["AllowFreeCamera", true, true];
		_x setVariable ["AllowAi", true, true];
		_x setVariable ["Allow3PPCamera", true, true];
		_x setVariable ["ShowFocusInfo", true, true];
		_x setVariable ["ShowCameraButtons", true, true];
		// Add respawn weapon loss failsafes		
		//_x setVariable ["respawnLoadout", (getUnitLoadout _x), true];
		//_x setVariable ["respawnPWeapon", [(primaryWeapon  _x), primaryWeaponItems _x], true];
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
};
{
	[_x, true] remoteExec ["allowDamage", _x, true];	
	_x enableGunLights "forceon";
	if (!isPlayer _x) then {
		[_x] call sun_addResetAction;
	};	
} forEach (units (grpNetId call BIS_fnc_groupFromNetId));

// Remove arsenal backdrop objects
sleep 2;
_backdropList = (getPos logicStartPos) nearObjects 20;
_backdropList = _backdropList - (units(grpNetId call BIS_fnc_groupFromNetId));
{
	if !(_x isKindOf "Module_F") then {
		deleteVehicle _x;
	};		
} forEach _backdropList;

if (reviveDisabled < 3) then {
	diag_log "DRO: Revive enabled";
	_reviveHandle = [(grpNetId call BIS_fnc_groupFromNetId)] execVM "sunday_revive\initRevive.sqf";
	waitUntil {scriptDone _reviveHandle};
};

if (stealthEnabled == 1) then {
	[] execVM "sunday_system\stealth.sqf";	
}; 

// If MCC4 is present re-initialise it for new players
if (isClass (configFile >> "CfgPatches" >> "mcc_sandbox")) then {
	[] execVM "\mcc_sandbox_mod\init.sqf";
};

// If Zeus is present re-initialise it for new players
diag_log _zeus;
if (!isNull _zeus) then {
	(leader(grpNetId call BIS_fnc_groupFromNetId)) assignCurator _zeus;
};

// Chance to reveal some intel at start
if (random 1 > 0.35) then {
	[([1,3] call BIS_fnc_randomInt), false] execVM "sunday_system\revealIntel.sqf";	
};

missionNameSpace setVariable ["playersReady", 1, true];

