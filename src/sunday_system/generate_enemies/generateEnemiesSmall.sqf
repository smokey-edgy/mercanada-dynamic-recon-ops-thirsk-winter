// *****
// SETUP ENEMIES
// *****

fnc_selectObjects = compile preprocessFile "sunday_system\objectsLibrary.sqf";

params ["_AOIndex"];
_center = ((AOLocations select _AOIndex) select 0);
_size = ((AOLocations select _AOIndex) select 1);
diag_log format ["(AOLocations select _AOIndex) = %1", (AOLocations select _AOIndex)];
//_roadPosClose = (((AOLocations select _AOIndex) select 2) select 0);
//_roadPosFar = (((AOLocations select _AOIndex) select 2) select 1);
//_groundPosClose = (((AOLocations select _AOIndex) select 2) select 2);
//_groundPosFar = (((AOLocations select _AOIndex) select 2) select 3);
//_flatPositionsClose = (((AOLocations select _AOIndex) select 2) select 4);
//_flatPositionsFar = (((AOLocations select _AOIndex) select 2) select 5);
//_forestPositions = (((AOLocations select _AOIndex) select 2) select 6);
//_buildingPositions = (((AOLocations select _AOIndex) select 2) select 7);		
//_helipads = (((AOLocations select _AOIndex) select 2) select 8);

_debug = 0;
_patrolGroups = [];
_numPlayers = count allPlayers;

enemyAlertableGroups = [];
enemySemiAlertableGroups = [];

// Roadblocks
_numRoadblocks = [2,2] call BIS_fnc_randomInt;
switch aoOptionSelect do {
	case 1: {_numRoadblocks = _numRoadblocks - 1};
	case 3: {_numRoadblocks = _numRoadblocks + 1};
};
_numRoadblocks = round (_numRoadblocks * aiMultiplier);
for "_x" from 1 to _numRoadblocks do {
	if (count (((AOLocations select _AOIndex) select 2) select 1) > 0) then {
		_roadPosition = [(((AOLocations select _AOIndex) select 2) select 1)] call sun_selectRemove; 
		
		// Get road direction
		_roadList = _roadPosition nearRoads 50;
		_thisRoad = _roadList select 0;
		_roadConnectedTo = roadsConnectedTo _thisRoad;
		if (count _roadConnectedTo == 0) exitWith {_bunker = "Land_BagBunker_Small_F" createVehicle _roadPosition;};
		_connectedRoad = _roadConnectedTo select 0;
		_direction = [_thisRoad, _connectedRoad] call BIS_fnc_DirTo;
				
		_objectLib = ["ROADBLOCKS"] call fnc_selectObjects;
		_objects = selectRandom _objectLib;
		_spawnedObjects = [_roadPosition, _direction, _objects] call BIS_fnc_ObjectsMapper;
		
		// Collect guard positions
		_guardPositions = [];		
		{
			if (typeOf _x == "Sign_Arrow_Blue_F") then {
				_spawnPos = getPos _x;
				_dir = getDir _x;				
				_guardPositions pushBack [_spawnPos, _dir];				
				deleteVehicle _x;			
			};
		} forEach _spawnedObjects;
		
		// Spawn guards at guard positions
		_leader = nil;
		_leaderChosen = 0;		
		_totalRoadInf = round (4 * aiMultiplier);
		_roadInfCount = 0;
		{
			_spawnPos = (_x select 0) findEmptyPosition [0,10];
			if (count _spawnPos > 0) then {
				if (_roadInfCount < _totalRoadInf) then {
					_guardGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
					if (!isNil "_guardGroup") then {	
						_guardUnit = ((units _guardGroup) select 0);					
						_guardUnit setFormDir (_x select 1);
						_guardUnit setDir (_x select 1);
						
						if (_leaderChosen == 0) then {
							_leader = _guardUnit;
							_leaderChosen = 1;
						} else {
							[_guardUnit] joinSilent _leader;
							doStop _guardUnit;
						};
						_roadInfCount = _roadInfCount + 1;
					};
				};
			};
		} forEach _guardPositions;	
		
		if (count eStaticClasses > 0) then {
			if ((random 1) > 0.6) then {
				_turretClass = selectRandom eStaticClasses;
				_turretPos = _roadPosition findEmptyPosition [0, 16, _turretClass];
				if (count _turretPos > 0) then {
					_turret = _turretClass createVehicle _turretPos;
					[_turret] call sun_createVehicleCrew;
					//createVehicleCrew _turret;
				};
			};
		};
		
		// Create Marker
		_markerName = format["roadblockMkr%1", floor(random 10000)];
		_markerRoadblock = createMarker [_markerName, _roadPosition];			
		_markerRoadblock setMarkerShape "ICON";
		_markerRoadblock setMarkerType "hd_warning";
		_markerRoadblock setMarkerText "Checkpoint";		
		_markerRoadblock setMarkerColor markerColorEnemy;
		_markerRoadblock setMarkerAlpha 0;
		enemyIntelMarkers pushBack _markerRoadblock;
				
	};
};

// Generate building garrisons
[6] call dro_localBuildingPatrol;
{
	_chance = (random 1);
	if (_chance > 0.3) then {
		[_x] call dro_spawnEnemyGarrison;
	};
} forEach milBuildings;

// Infantry patrols
_numInf = round (([1,3] call BIS_fnc_randomInt) * aiMultiplier);	
_numInf = _numInf + (floor(_numPlayers/2));
switch aoOptionSelect do {
	case 1: {_numInf = _numInf - 1};
	case 3: {_numInf = _numInf + 1};
};

for "_infIndex" from 1 to _numInf do {
	_infPosition = [];
	if (_infIndex <= 1) then {_infPosition = selectRandom (((AOLocations select _AOIndex) select 2) select 2)} else {_infPosition = selectRandom (((AOLocations select _AOIndex) select 2) select 3)};	
	_spawnedSquad = nil;	
	_minAI = round (3 * aiMultiplier);
	_maxAI = round (5 * aiMultiplier);
	_spawnedSquad = [_infPosition, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;					
	if (!isNil "_spawnedSquad") then {
		_patrolGroups pushBack _spawnedSquad;
		//[_spawnedSquad, _infPosition, 200] call bis_fnc_taskPatrol;	
		enemyAlertableGroups pushBack _spawnedSquad;	
		if (_debug == 1) then {
			_garMarker = createMarker [format["garMkr%1", random 10000], _infPosition];
			_garMarker setMarkerShape "ICON";
			_garMarker setMarkerColor "ColorOrange";
			_garMarker setMarkerType "mil_dot";
			_garMarker setMarkerText format ["Patrol %1", _spawnedSquad];
		};
	};
};

// Bunkers
_bunkerTypes = ["Land_BagBunker_Large_F", "Land_BagBunker_Tower_F"];
_numBunkers = round (([1,2] call BIS_fnc_randomInt) * aiMultiplier);

switch aoOptionSelect do {
	case 1: {_numBunkers = _numBunkers - 1};
	case 3: {_numBunkers = _numBunkers + 1};
};

for "_x" from 1 to _numBunkers do {	
	if (count (((AOLocations select _AOIndex) select 2) select 5) > 0) then {		
		_thisPos = [(((AOLocations select _AOIndex) select 2) select 5)] call sun_selectRemove;
		
		_bunkerPos = [_thisPos, 0, 100, 15, 0, 1, 0] call BIS_fnc_findSafePos;
		if (count _bunkerPos > 0) then {
			_startDir = random 360;
			_bunkerType = selectRandom _bunkerTypes;
			_bunker = [_bunkerType, _bunkerPos, _startDir] call dro_createSimpleObject;
			_dir = _startDir;
			_rotation = _startDir;
			for "_i" from 1 to 4 do {
				_fencePos = [_bunkerPos, 10, _dir] call dro_extendPos;
				_fence = ["Land_BagFence_Long_F", _fencePos, _rotation] call dro_createSimpleObject;				
				_fencePos1 = [_fencePos, 8.2, (_dir-90)] call dro_extendPos;				
				_fence1 = ["Land_BagFence_Long_F", _fencePos1, _rotation] call dro_createSimpleObject;
				_fencePos2 = [_fencePos, 8.2, (_dir+90)] call dro_extendPos;				
				_fence2 = ["Land_BagFence_Long_F", _fencePos2, _rotation] call dro_createSimpleObject;
				_dir = _dir + 90;
				_rotation = _rotation + 90;
			};			
			switch (_bunkerType) do {
				case "Land_BagBunker_Large_F": {					
					_numBunkerGuards = round (([3,5] call BIS_fnc_randomInt) * aiMultiplier);				
					_leader = nil;
					_leaderChosen = 0;
					for "_n" from 1 to _numBunkerGuards do {
						_dir = random 360;
						_spawnPos = [_bunkerPos, 4, _dir] call dro_extendPos;
						_group = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;												
						if (!isNil "_group") then {
							_unit = ((units _group) select 0);
							_unit setFormDir _dir;
							_unit setDir _dir;							
							if (_leaderChosen == 0) then {
								_leader = _unit;
								_leaderChosen = 1;
							} else {
								[_unit] joinSilent _leader;
								doStop _unit;
							};
						};
						
					};
				};
				case "Land_BagBunker_Tower_F": {										
					_numBunkerGuards = round (([2,4] call BIS_fnc_randomInt) * aiMultiplier);
					_leader = nil;
					_leaderChosen = 0;
					for "_n" from 1 to _numBunkerGuards do {
						_dir = random 360;						
						_spawnPos = _bunkerPos findEmptyPosition [0,20];
						_group = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;						
						if (!isNil "_group") then {
							_unit = ((units _group) select 0);
							_unit setFormDir _dir;
							_unit setDir _dir;
							if (_leaderChosen == 0) then {
								_leader = _unit;
								_leaderChosen = 1;
							} else {
								[_unit] joinSilent _leader;
								doStop _unit;
							};
						};
					};					
					_spawnPos = [(getPos _bunker select 0), (getPos _bunker select 1), (getPos _bunker select 2)];
					_group = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;					
					if (!isNil "_group") then {
						_unit = ((units _group) select 0);
						_unit setPosATL [(getPos _bunker select 0), (getPos _bunker select 1), (getPos _bunker select 2)+3.5];
						_dir = random 360;
						_unit setFormDir _dir;
						_unit setDir _dir;
					};					
				};
			};
			
			if (count eStaticClasses > 0) then {
				if ((random 1) > 0.6) then {
					_turretClass = selectRandom eStaticClasses;
					_turretPos = _bunkerPos findEmptyPosition [5, 20, _turretClass];
					if (count _turretPos > 0) then {
						_turret = _turretClass createVehicle _turretPos;
						[_turret] call sun_createVehicleCrew;
						//createVehicleCrew _turret;
					};
				};
			};
			/*
			_garMarker = createMarker [format["garMkr%1", random 10000], getPos _bunker];
			_garMarker setMarkerShape "ICON";
			_garMarker setMarkerColor "ColorOrange";
			_garMarker setMarkerType "mil_objective";
			*/			
			// Create Marker
			_markerName = format["bunkerMkr%1", floor(random 10000)];
			_markerBunker = createMarker [_markerName, _bunkerPos];			
			_markerBunker setMarkerShape "ICON";
			_markerBunker setMarkerType "hd_warning";
			_markerBunker setMarkerText "Bunker";			
			_markerBunker setMarkerColor markerColorEnemy;
			_markerBunker setMarkerAlpha 0;
			enemyIntelMarkers pushBack _markerBunker;				
		};		
	};
};

// Vehicle patrol
if (count eCarClasses > 0) then {
	if (random 1 > 0.5) then {			
		if (count (((AOLocations select _AOIndex) select 2) select 0) > 0) then {
			_vehPos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;
			_vehType = selectRandom eCarClasses;
			_veh = createVehicle [_vehType, _vehPos, [], 0, "NONE"];			
			[_veh] call sun_createVehicleCrew;
			//createVehicleCrew _veh;
			waitUntil {!isNull (driver _veh)};
			_vehSlots = [_vehType] call sun_getTrueCargo;
			if (_vehSlots > 2) then {					
				_minAI = (_vehSlots/2) * aiMultiplier;							
				_reinfGroup = [_vehPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _vehSlots]] call dro_spawnGroupWeighted;				
				waitUntil {!isNil "_reinfGroup"};
				[_reinfGroup, _veh, false] spawn sun_groupToVehicle;					
			};		
			_patrolGroups pushBack (group (driver _veh));
			//[(group(driver _veh)), _vehPos, 800] call BIS_fnc_taskPatrol;	
		};		
	};
};

// Get a selection of possible new travel locations if chance allows
if (count _patrolGroups > 0) then {
	diag_log format ["DRO: _patrolGroups = %1", _patrolGroups];
	_travelPositions = [];			
	_possibleLocsMaxIndex = (count AOLocations)-1;
	if (_possibleLocsMaxIndex > 0) then {
		for "_i" from 0 to _possibleLocsMaxIndex step 1 do {		
			_possibleLocTypes = [];
			if (_i != _AOIndex) then {			
				if (((AOLocations select _i) select 3) isEqualTo "ROUTE") then {
					diag_log "Location route found";
					if (count (((AOLocations select _i) select 2) select 0) > 0) then {_possibleLocTypes pushBack 0};
					if (count (((AOLocations select _i) select 2) select 1) > 0) then {_possibleLocTypes pushBack 1};				
				};
			};
			diag_log format ["_possibleLocTypes = %1", _possibleLocTypes];		
			if (count _possibleLocTypes > 0) then {			
				_selectedPosArray = ((((AOLocations select _i) select 2) select (selectRandom _possibleLocTypes)));					
				_selectedPos = [_selectedPosArray] call sun_selectRemove;					
				_travelPositions pushBack _selectedPos;			
			};		
		};
	};
	if (count _travelPositions > 0) then {
		{			
			_thisGroup = _x;
			_startPos = (getPos (leader _thisGroup));
			if (random 1 > 0.5) then {				
				// Initialise route waypoints
				_wpFirst = _thisGroup addWaypoint [_startPos, 0];
				_wpFirst setWaypointType "MOVE";
				_wpFirst setWaypointBehaviour "SAFE";
				_wpFirst setWaypointSpeed "LIMITED";			
				{
					_pos = if (typeName _x == "OBJECT") then {getPos _x} else {_x};
					_wp = _thisGroup addWaypoint [_pos, 0];
					_wp setWaypointType "MOVE";
					_wp setWaypointCompletionRadius 20;
					_wp setWaypointTimeout [20, 30, 45];					
				} forEach _travelPositions;
				_wpLast = _thisGroup addWaypoint [_startPos, 0];
				_wpLast setWaypointType "CYCLE";		
				_wpLast setWaypointCompletionRadius 20;
				_wpLast setWaypointTimeout [20, 30, 45];				
			} else {
				if (vehicle (leader _thisGroup) == (leader _thisGroup)) then {
					[_thisGroup, _startPos, 100] call BIS_fnc_taskPatrol;	
				} else {
					[_thisGroup, _startPos, 800] call BIS_fnc_taskPatrol;	
				};
			};
		} forEach _patrolGroups;		
	};
};

publicVariable "enemyIntelMarkers";