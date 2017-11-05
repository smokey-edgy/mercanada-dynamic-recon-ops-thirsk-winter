dro_localBuildingPatrol = {
	params [["_maxSpawns", 6]];
	_return = [];
	private _spawns = 0;
	{
		_thisBuildingCollection = _x;
		// Create patrol points	
		{
			if (!isNil "_maxSpawns") then {
				if (_spawns < _maxSpawns) then {
					_thisBuilding = _x;
					diag_log format ["_thisBuilding = %1", _thisBuilding];					
					_houseOuterPos = [(getPos _thisBuilding), 20, 50, 2, 0, 1, 0] call BIS_fnc_findSafePos;
					_garrisonGroup = [_houseOuterPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1, 2]] call dro_spawnGroupWeighted;	
					_spawnTime = time;
					waitUntil {(!isNil "_garrisonGroup") || (time >= (_spawnTime + 5))};					
					diag_log format ["_garrisonGroup = %1", _garrisonGroup];
					/*
					_garMarker = createMarker [format["garMkr%1", random 10000], _thisBuilding];
					_garMarker setMarkerShape "ICON";
					_garMarker setMarkerColor "ColorOrange";
					_garMarker setMarkerType "mil_dot";
					*/
					
					_patrol = random 1;							
					if (!isNil "_garrisonGroup") then {
						_spawns = _spawns + 1;
						_garrisonGroup setBehaviour "SAFE";
						
						deleteWaypoint [_garrisonGroup, currentWaypoint _garrisonGroup];
						
						[_garrisonGroup, 0] setWaypointBehaviour "SAFE";
						
						_wpStart = _garrisonGroup addWaypoint[(getPos (leader _garrisonGroup)), 0];
						_wpStart setWaypointBehaviour "ALERT";
						_wpStart setWaypointSpeed "LIMITED";
						_wpStart setWaypointType "MOVE";	
						
						if (_patrol > 0.65) then {
							{						
								_wpHouse = _garrisonGroup addWaypoint[(getPos _x), 10];						
								_wpHouse setWaypointType "MOVE";					
								
								_buildingPositions = [_x] call BIS_fnc_buildingPositions;
								
								_wpInt1 = _garrisonGroup addWaypoint[(selectRandom _buildingPositions), 0];	
								_wpInt1 setWaypointBehaviour "ALERT";						
								_wpInt1 setWaypointType "MOVE";
								_wpInt1 setWaypointTimeout [120, 125, 130];
								
								_wpInt2 = _garrisonGroup addWaypoint[(selectRandom _buildingPositions), 0];					
								_wpInt2 setWaypointType "MOVE";
								_wpInt1 setWaypointBehaviour "SAFE";
								//_wpInt2 setWaypointTimeout [120, 125, 130];
								
							} forEach _thisBuildingCollection;
											
							_wpCycle = _garrisonGroup addWaypoint[(getPos _x), 10];
							_wpCycle setWaypointBehaviour "SAFE";
							_wpCycle setWaypointType "CYCLE";	
						} else {					
							_wpHouse = _garrisonGroup addWaypoint[_thisBuilding, 10];						
							_wpHouse setWaypointType "MOVE";					
							
							_buildingPositions = [_thisBuilding] call BIS_fnc_buildingPositions;
							
							_wpInt1 = _garrisonGroup addWaypoint[(selectRandom _buildingPositions), 0];					
							_wpInt1 setWaypointType "MOVE";					
						};
														
						_return	pushBack _garrisonGroup;
					};
				};
			};
		} forEach _x;
	} forEach taskBuildings;
	_return
};

dro_spawnEnemyGarrison = {
	_thisBuilding = _this select 0;	
	/*
	_garMarker = createMarker [format["garMkr%1", random 10000], getPos _thisBuilding];
	_garMarker setMarkerShape "ICON";
	_garMarker setMarkerColor "ColorOrange";
	_garMarker setMarkerType "mil_dot";
	*/
	_buildingPositions = [_thisBuilding] call BIS_fnc_buildingPositions;	
	_totalGarrison = [0, ((count _buildingPositions) min 2)] call BIS_fnc_randomInt;
	
	_garrisonCounter = 0;
	_leader = nil;
	{
		if (_garrisonCounter <= _totalGarrison) then {
			_group = [_x, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;			
			if (!isNil "_group") then {
				_unit = ((units _group) select 0);
				_unit setUnitPos "UP";
				if (_garrisonCounter == 0) then {
					_leader = _unit;
				} else {
					[_unit] joinSilent _leader;
					//doStop _unit;
				};
			};
		};
		_garrisonCounter = _garrisonCounter + 1;
	} forEach _buildingPositions;
	
	if (!isNil "_leader") then {
		enemySemiAlertableGroups pushBack (group _leader);
	};
	group _leader	
};

