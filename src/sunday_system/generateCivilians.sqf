// *****
// Civilians
// *****

private _AOIndex = _this select 0;
private _debug = 0;

_nearestHouses = nearestObjects [centerPos, ["House"], 500];
_buildingBlacklist = nearestObjects [centerPos, ["House_Small_F", "PowerLines_base_F", "PowerLines_Wires_base_F"], 500];

_filteredHouses = [];
{
	if !(_x in _buildingBlacklist) then {
		_filteredHouses pushBackUnique _x;
	};
} forEach _nearestHouses;

_numHouses = count _filteredHouses;

_percentToFill = 0.3;
if (_numHouses < 9) then {_percentToFill = 0.5};

_numHousesToFill = _numHouses * _percentToFill;

if (_numHousesToFill > 10) then {_numHousesToFill = 10};

for "_i" from 1 to _numHousesToFill do {

	_thisHouse = [_filteredHouses] call sun_selectRemove;			
	_buildingPositions = [_thisHouse] call BIS_fnc_buildingPositions;
	_totalGarrison = count _buildingPositions;
	if (count _buildingPositions > 3) then {
		_totalGarrison = 3;
	};
		_garrisonCounter = 0;
	{ 
		if (_garrisonCounter <= _totalGarrison) then {
			_chance = random 100;
			if (_chance > 50) then {
				_civType = selectRandom civClasses;
				_group = createGroup civilian;
				_civType createUnit [ _x, _group ];						
			};
		};
		_garrisonCounter = _garrisonCounter + 1;
	} forEach _buildingPositions;
	
	if (_debug == 1) then {		
		_garMarker = createMarker [format["garMkr%1", random 10000], getPos _thisHouse];
		_garMarker setMarkerShape "ICON";
		_garMarker setMarkerColor "ColorGreen";
		_garMarker setMarkerType "mil_dot";
		_garMarker setMarkerText format ["Civ %1", (typeOf  _thisHouse)];
	};
	
};

_patrolGroups = [];
_civPositions = travelPosPOICiv + (((AOLocations select _AOIndex) select 2) select 0) + (((AOLocations select _AOIndex) select 2) select 2);

switch (AOLocType) do {
	case "NameVillage": {
		_numCivs = [3,6] call BIS_fnc_randomInt;
		for "_x" from 1 to _numCivs do {
			_civType = selectRandom civClasses;
			_civPosition = selectRandom _civPositions;
			_group = createGroup civilian;
			_civType createUnit [_civPosition, _group];
			_patrolGroups pushBack _group;
		};
	};
	case "NameCity": {
		_numCivs = [8,12] call BIS_fnc_randomInt;
		for "_x" from 1 to _numCivs do {
			_civType = selectRandom civClasses;
			_civPosition = selectRandom _civPositions;
			_group = createGroup civilian;
			_civType createUnit [_civPosition, _group];
			_patrolGroups pushBack _group;
		};
	};
	case "NameCityCapital": {
		_numCivs = [8,12] call BIS_fnc_randomInt;
		for "_x" from 1 to _numCivs do {
			_civType = selectRandom civClasses;
			_civPosition = selectRandom _civPositions;
			_group = createGroup civilian;
			_civType createUnit [_civPosition, _group];
			_patrolGroups pushBack _group;
		};
	};
	case "NameLocal": {
		_numCivs = [3,6] call BIS_fnc_randomInt;
		for "_x" from 1 to _numCivs do {
			_civType = selectRandom civClasses;
			_civPosition = selectRandom _civPositions;
			_group = createGroup civilian;
			_civType createUnit [_civPosition, _group];
			_patrolGroups pushBack _group;
		};
	};
};

// Create market bustle
if (!isNil "marketPositions") then {
	if (count marketPositions > 0) then {
		{
			_thisMarketPositions = _x;			
			{
				for "_c" from 0 to ([0,1] call BIS_fnc_randomInt) step 1 do {
					_civType = selectRandom civClasses;					
					_group = createGroup civilian;
					_civType createUnit [_x, _group];					
					{						
						_wp = _group addWaypoint [_x, 15];
						if (_forEachIndex == ((count _thisMarketPositions)-1)) then {
							_wp setWaypointType "CYCLE";
						} else {
							_wp setWaypointType "MOVE";
						};						
						_wp setWaypointBehaviour "SAFE";
						_wp setWaypointSpeed "LIMITED";
						_wp setWaypointCompletionRadius 1.5;
						_wp setWaypointTimeout [15, 30, 40];	
					} forEach _thisMarketPositions;					
				};				
			} forEach _thisMarketPositions;
		} forEach marketPositions;
	};
};	

// Spawn civilian vehicles
if (count civCarClasses > 0) then {
	if (random 1 > 0.5) then {
		_numCivVehicles = [1,3] call BIS_fnc_randomInt;
		for "_i" from 1 to _numCivVehicles do {							
			if (count (((AOLocations select _AOIndex) select 2) select 0) > 0) then {
				_pos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;
				_veh = (selectRandom civCarClasses) createVehicle _pos;			
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
				if (random 1 > 0.75) then {
					createVehicleCrew _veh;
					waitUntil {!isNull (driver _veh)};
					if (random 1 > 0.5) then {
						_patrolGroups pushBack (group driver _veh);
					};
				};
			};			
		};		
	};
};

// Initialise waypoints
if (count _patrolGroups > 0) then {
	_travelPositions = travelPosPOICiv + (((AOLocations select _AOIndex) select 2) select 0);		
	if (count _travelPositions > 0) then {		
		{				
			_thisGroup = _x;
			_availableTravelPositions = [];
			_randI = ([0, (count _travelPositions)-1] call BIS_fnc_randomInt);			
			for "_i" from _randI to ((_randI + ([2,3] call BIS_fnc_randomInt)) min (count _travelPositions)) step 1 do {
				_availableTravelPositions pushBack (_travelPositions select _i);
			};
			
			_startPos = (getPos (leader _thisGroup));						
			// Initialise route waypoints
			_wpFirst = _thisGroup addWaypoint [_startPos, 20];
			_wpFirst setWaypointType "MOVE";
			_wpFirst setWaypointBehaviour "SAFE";
			_wpFirst setWaypointSpeed "LIMITED";			
			{
				_pos = if (typeName _x == "OBJECT") then {getPos _x} else {_x};
				_wp = _thisGroup addWaypoint [_pos, 20];
				_wp setWaypointType "MOVE";
				_wp setWaypointCompletionRadius 20;
				_wp setWaypointTimeout [60, 90, 120];					
			} forEach _availableTravelPositions;
			_wpLast = _thisGroup addWaypoint [_startPos, 20];
			_wpLast setWaypointType "CYCLE";		
			_wpLast setWaypointCompletionRadius 20;
			_wpLast setWaypointTimeout [60, 90, 120];			
		} forEach _patrolGroups;
	};	
};


