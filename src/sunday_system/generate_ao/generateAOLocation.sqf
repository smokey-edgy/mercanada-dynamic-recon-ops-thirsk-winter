params ["_center", "_types", "_size"];	

_debug = true;

if (typeName _types == "STRING") then {
	if (_types == "ALL") then {
		_types = ["ROADNEAR", "ROADFAR", "GROUNDNEAR", "GROUNDFAR", "FLATNEAR", "FLATFAR", "FOREST", "BUILDINGS", "HELIPADS"];
	};
};

// Create array of road positions near center
_AO_roadPosArray = [];
if ("ROADNEAR" in _types) then {		
	_roads = _center nearRoads (_size/4);
	_maxRoads = round(_size*0.014);
	if (count _roads > _maxRoads) then {	
		for "_i" from 1 to _maxRoads do {
			_randRoad = [_roads] call sun_selectRemove;
			if (typeName _randRoad == "OBJECT") then {
				_AO_roadPosArray pushBack (getPos _randRoad);
			};
		};
	};	
	if (count _AO_roadPosArray > 0) then {
		{
			if (count (_x nearObjects ["House", 30]) > 0) exitWith {
				AO_POITypes pushBackUnique "MARKET";
			};
		} forEach _AO_roadPosArray;		
	};
};

// Create array of road positions for roadblocks
_roadblockPosArray = [];
if ("ROADFAR" in _types) then {	
	_allRoadPosTop = _center nearRoads (_size/2.2);		
	//_allRoadPosCut = _center nearRoads (_size/2.8);
	_allRoadPosValid = [];
	{
		//if !(_x in _allRoadPosCut) then {
		if ((_x distance _center) > (_size/2.8)) then {
			_allRoadPosValid pushBackUnique _x;
		};
	} forEach _allRoadPosTop;				
	_maxRoads = round(_size*0.012);
	if (count _allRoadPosValid > 0) then {
		for "_i" from 1 to (_maxRoads min (count _allRoadPosValid)) do {
			_randRoad = [_allRoadPosValid] call sun_selectRemove;
			if (typeName _randRoad == "OBJECT") then {
				_roadblockPosArray pushBack (getPos _randRoad);
			};
		};
	};
	if (count _roadblockPosArray > 0) then {		
		AO_POITypes pushBackUnique "ROADBLOCK";	
	};
};

// Create arrays of ground positions
_AO_groundPosClose = [];
if ("GROUNDNEAR" in _types) then {		
	for "_i" from 1 to round(_size*0.016) do {	
		_thisPos = [_center, 0, (_size/4), 2, 0, 0.4, 0] call BIS_fnc_findSafePos;			
		_AO_groundPosClose pushBack _thisPos;	
	};	
};
_AO_groundPosFar = [];
if ("GROUNDFAR" in _types) then {		
	for "_i" from 1 to round(_size*0.016) do {
		_thisPos = [_center, (_size/2.8), (_size/2.1), 2, 0, 0.4, 0] call BIS_fnc_findSafePos;			
		_AO_groundPosFar pushBack _thisPos;
	};	
};

// Create array of flat empty positions
_AO_flatPositions = [];
if ("FLATNEAR" in _types) then {		
	_bestPlacesFlat = selectBestPlaces [_center, (_size/4), "(2*meadow) - houses - forest - trees - sea - hills", 30, round(_size*0.014)];
	{
		_pos = _x select 0;		
		_flatPos = _pos isFlatEmpty [10, -1, 0.15, 20, 0, false];	
		if (count _flatPos > 0) then {	
			if (count _AO_flatPositions > 0) then {			
				_save = 1;
				{				
					_dist = _x distance _flatPos;			
					if (_dist < 50) then {_save = 0};				
				} forEach _AO_flatPositions;			
				if (_save == 1) then {_AO_flatPositions pushBack _flatPos};			
			} else {
				_AO_flatPositions pushBack _flatPos;
			};
		};
	} forEach _bestPlacesFlat;
	if (count _AO_flatPositions > 0) then {		
		AO_POITypes pushBackUnique "EMPLACEMENT";	
	};
	//_AO_flatPositions = [_AO_flatPositions, [_center], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;
};

// Create array of flat empty positions further from center
_AO_flatPositionsFar = [];
if ("FLATFAR" in _types) then {		
	_bestPlacesFlat = selectBestPlaces [_center, (_size/2), "(2*meadow) - houses - forest - trees - sea - hills", 30, round(_size*0.012)];
	{
		_pos = _x select 0;		
		_flatPos = _pos isFlatEmpty [10, 150, 0.4, 20, 0, false];	
		if (count _flatPos > 0) then {
			_distCenter = _flatPos distance _center;
			if (_distCenter > (_size/4)) then {
				if (count _AO_flatPositionsFar > 0) then {				
					_save = 1;
					{				
						_dist = _x distance _flatPos;			
						if (_dist < 50) then {_save = 0};					
					} forEach _AO_flatPositionsFar;				
					if (_save == 1) then {_AO_flatPositionsFar pushBack _flatPos};					
				} else {
					_AO_flatPositionsFar pushBack _flatPos;
				};
			};
		};
	} forEach _bestPlacesFlat;
	if (count _AO_flatPositionsFar > 0) then {		
		AO_POITypes pushBackUnique "BUNKER";	
	};
};

// Create array of forested positions
_AO_forestPositions = [];
if ("FOREST" in _types) then {
	_bestPlacesForest = selectBestPlaces [_center, (_size/2.5), "forest + trees - sea", 40, round(_size*0.012)];
	{
		_AO_forestPositions pushBack (_x select 0);			
	} forEach _bestPlacesForest;
	if (count _AO_forestPositions > 0) then {		
		AO_POITypes pushBackUnique "CAMP";	
	};
	//_AO_forestPositions = [_AO_forestPositions, [_center], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;
};

// Create array of valid buildings
_AO_buildingPositions = [];
if ("BUILDINGS" in _types) then {	
	_buildings = _center nearObjects ["House", (_size*0.4)];
	if (count _buildings > 0) then {
		for "_b" from 1 to ((_size*0.015) min (count _buildings)) step 1 do {
			_building = [_buildings] call sun_selectRemove;
			_buildingClass = typeOf _building;		
			_continue = true;
			if (((configFile >> "CfgVehicles" >> _buildingClass >> "destrType") call BIS_fnc_GetCfgData) == "DestructNo") then {_continue = false};
			if (!alive _building) then {_continue = false};
			if ((count([_building] call BIS_fnc_buildingPositions)) < 2) then {_continue = false};			
			if ((_building distance _center) > (_size*0.3)) then {_continue = false};		
			if (_continue) then {
				_AO_buildingPositions pushBackUnique _building;			
			};
		};
	};
	
	/*
	_bestPlacesBuildings = [_center, round(_size*0.007), round(_size*0.007), (_size/40)] call sun_defineGrid;
	{		
		_building = nearestBuilding _x;	
		_buildingClass = typeOf _building;		
		_continue = true;
		if (((configFile >> "CfgVehicles" >> _buildingClass >> "destrType") call BIS_fnc_GetCfgData) == "DestructNo") then {_continue = false};
		if (!alive _building) then {_continue = false};
		if ((count([_building] call BIS_fnc_buildingPositions)) < 2) then {_continue = false};			
		if ((_building distance _center) > (_size*0.3)) then {_continue = false};		
		if (_continue) then {
			_AO_buildingPositions pushBackUnique _building;			
		};
	} forEach _bestPlacesBuildings;
	*/
	if (count _AO_buildingPositions > 0) then {		
		AO_POITypes pushBackUnique "HOUSE";	
	};
	//_AO_buildingPositions = [_AO_buildingPositions, [_center], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;
};

// Locate any helipads
_AO_helipads = [];
if ("HELIPADS" in _types) then {
	_AO_helipads = nearestObjects [_center, ["HeliH"], (_size/4)];
};
/*
// Create array of overwatch positions
_overwatchPositions = [];
for "_i" from 0 to (round(_size*0.008)) do {			
	_thisOverwatchPos = [_center, (aoSize/2), 250, 30] call BIS_fnc_findOverwatch;
	if (!isNil "_thisOverwatchPos") then {
		_overwatchPositions pushBack _thisOverwatchPos;
		if (_debug) then {
			_markerDebug = createMarker [(format ["debugMkr%1", round(random 100000)]), _thisOverwatchPos];
			_markerDebug setMarkerShape "ICON";
			_markerDebug setMarkerType "loc_Tree";
			_markerDebug setMarkerColor "ColorOrange";
		};
	};	
};
if (count _overwatchPositions > 0) then {		
	AO_POITypes pushBackUnique "CAMP";	
};
*/
[_AO_roadPosArray, _roadblockPosArray, _AO_groundPosClose, _AO_groundPosFar, _AO_flatPositions, _AO_flatPositionsFar, _AO_forestPositions, _AO_buildingPositions, _AO_helipads]