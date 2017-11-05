params ["_AOIndex"];

if (count (((AOLocations select _AOIndex) select 2) select 5) > 0) then {		
	_thisPos = [(((AOLocations select _AOIndex) select 2) select 5)] call sun_selectRemove;
	_bunkerTypes = ["Land_BagBunker_Large_F", "Land_BagBunker_Tower_F"];
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
		
		travelPosPOIMil pushBack _bunkerPos;
	};
	
};