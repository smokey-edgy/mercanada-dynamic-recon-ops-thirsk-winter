diag_log "Starting AO generation";

// *****
// SETUP AO
// *****

fnc_generateMarket = compile preprocessFile "sunday_system\generate_ao\generateMarket.sqf";

_debug = 0;

_blackList = [];
aoSize = 1200;

_randomLoc = [];

if (getMarkerColor "aoSelectMkr" == "") then {
	diag_log "DRO: No custom AO position found, will generate random.";
	{
		deleteMarker _x;
	} forEach locMarkerArray;
	// Get a random location
	_size = worldSize;
	_worldCenter = (_size/2);
	_firstLocList = nearestLocations [[_worldCenter, _worldCenter], ["NameLocal","NameVillage","NameCity","NameCityCapital"], _size];
	_randomLoc = [_firstLocList] call sun_selectRemove;
		
	while {		
		(((getPos _randomLoc) select 0) < aoSize) ||
		(((getPos _randomLoc) select 1) < aoSize) ||
		(((getPos _randomLoc) select 0) > (_size-aoSize)) ||
		(((getPos _randomLoc) select 1) > (_size-aoSize)) ||
		(((getPos _randomLoc) distance logicStartPos) < 700)
		
	} do {
		_randomLoc = [_firstLocList] call sun_selectRemove;
	};
	aoName = text _randomLoc;
	publicVariable "aoName";
} else {
	diag_log "DRO: Custom AO position found.";
	_randomLoc = nearestLocation [getMarkerPos "aoSelectMkr", ""];
	"aoSelectMkr" setMarkerAlpha 0;
	{
		deleteMarker _x;
	} forEach locMarkerArray;
};

// Add the primary location to the pool
AOLocations = [];
AOLocations pushBack [(getPos _randomLoc), aoSize];
_cityCenter = (getPos _randomLoc);

// If secondary locations are enabled then find them
if (aoOptionSelect == 0) then {	
	_secondaryLocList = nearestLocations [[_cityCenter select 0, _cityCenter select 1], ["NameLocal","NameVillage","NameCity","NameCityCapital"], 2000];
	_secondaryLocListTemp = [];
	{
		// Remove secondary locations that are too close
		if ((getPos _x) distance _cityCenter > aoSize) then {_secondaryLocListTemp pushBack _x};
	} forEach _secondaryLocList;
	_secondaryLocList = _secondaryLocListTemp;

	// Add 1 to 3 secondary locations to the pool
	if (count _secondaryLocList > 0) then {
		for "_i" from 1 to (([1, count _secondaryLocList] call BIS_fnc_randomInt) min 3) step 1 do {
			_thisLoc = [_secondaryLocList] call sun_selectRemove;
			if (((getPos _thisLoc) distance logicStartPos) < 700) then {
				_secondaryLocList pushBack _thisLoc;
			} else {
				diag_log _thisLoc;
				AOLocations pushBack [(getPos _thisLoc), 800];
			};
		};
	};
};

// Primary location/mission data
AOLocType = type _randomLoc;
missionNameSpace setVariable ["aoLocation", _randomLoc, true];
missionNameSpace setVariable ["aoLocationName", aoName, true];


_AREAMARKER_WIDTH = 200;
AOBriefingLocType = switch (AOLocType) do  {
	case "NameLocal": {""};
	case "NameVillage": {"village"};
	case "NameCity": {"city"};
	case "NameCityCapital": {"capital"};
	case default {"countryside"};
};

missionNameSpace setVariable ["aoCamPos", _cityCenter];
publicVariable "aoCamPos";

// Create center marker
_markerCenter = createMarker ["centerMkr", _cityCenter];
_markerCenter setMarkerShape "ICON";
_markerCenter setMarkerType "EmptyIcon";

// Generate position data for all locations
AO_POITypes = [];
_aoDataAll = [];
{
	_aoData = [(_x select 0), "ALL", (_x select 1)] call fnc_generateAOLoc;	
	_aoDataAll pushBack _aoData;
} forEach AOLocations;
{
	(AOLocations select _forEachIndex) pushBack _x;
} forEach _aoDataAll;

// Select special type for primary location

travelPosPOICiv = [];
travelPosPOIMil = [];

if (count AO_POITypes > 0) then {
	AO_POIs = [];
	for "_p" from 1 to (([2,4] call BIS_fnc_randomInt) min (count AO_POITypes)) step 1 do {
		AO_POIs pushBack ([AO_POITypes] call sun_selectRemove);
	};	
	{
		switch (_x) do {
			case "MARKET": {
				// Find AO locations with valid market indexes
				marketPositions = [];
				_totalGroundPositions = 0;
				{
					if (count ((_x select 2) select 0) > 0) then {_totalGroundPositions = _totalGroundPositions + (count ((_x select 2) select 0))};
				} forEach AOLocations;
				if (_totalGroundPositions > 0) then {					
					_numMarkets = (([1, (count AOLocations)] call BIS_fnc_randomInt) min _totalGroundPositions);							
					{
						if (_numMarkets > 0) then {
							if (count ((_x select 2) select 0) > 0) then {
								_marketPos = [((_x select 2) select 0)] call sun_selectRemove;
								_thisMarketPositions = ([_marketPos] call fnc_generateMarket);
								if (count _thisMarketPositions > 0) then {				
									_markerName = format["marketMkr%1", floor(random 10000)];
									_markerMarket = createMarker [_markerName,  selectRandom _thisMarketPositions];			
									_markerMarket setMarkerShape "ICON";
									_markerMarket setMarkerType "mil_flag_noShadow";
									_markerMarket setMarkerText "Market";			
									_markerMarket setMarkerColor "ColorBlack";
									_markerMarket setMarkerAlpha 1;				
									_markerMarket setMarkerSize [0.65, 0.65];				
									{
										travelPosPOIMil pushBack _x;
										travelPosPOICiv pushBack _x;
									} forEach _thisMarketPositions;
									marketPositions pushBack _thisMarketPositions;
								};
								_numMarkets = _numMarkets - 1;
							};
						};
					} forEach AOLocations;
				};				
			};			
			case "HOUSE": {
				// Find AO locations with valid house indexes
				_houseIndexes = [];							
				{
					_thisAOIndex = _forEachIndex;
					if (count ((_x select 2) select 7) > 0) then {						
						_houseIndexes pushBack [_thisAOIndex, _forEachIndex];												
					};
				} forEach AOLocations;
				_numHouses = (([3, 6] call BIS_fnc_randomInt) min (count _houseIndexes));
				for "_i" from 1 to _numHouses step 1 do {					
					_index = [0, (count _houseIndexes - 1)] call BIS_fnc_randomInt;
					_houseSelect = _houseIndexes select _index;
					_AOIndex = _houseSelect select 0;
					_houseIndex = _houseSelect select 1;
					if (count (((AOLocations select _AOIndex) select 2) select 7) > 0) then {
						_housePos = getPos ((((AOLocations select _AOIndex) select 2) select 7) select _houseIndex);
						(((AOLocations select _AOIndex) select 2) select 7) deleteAt _houseIndex;
						_houseIndexes deleteAt _index;
						travelPosPOICiv pushBack _housePos;
					};
				};
			};
		};
	} forEach AO_POIs;
};

// Visual markers
_markerFlag = createMarker ["mkrFlag", [(_cityCenter select 0),((_cityCenter select 1)+150)]];
_markerFlag setMarkerShape "ICON";
_markerFlag setMarkerType "flag_AAF";
_markerFlag setMarkerSize [2,2];

_aoPoints = [];
{
	_pos = (_x select 0);
	_dist = (_x select 1);
	_dir = 45;
	for "_i" from 0 to 3 step 1 do {
		_aoPoints pushBack ([_pos, _dist, _dir] call BIS_fnc_relPos);
		_dir = _dir + 90;
	};
} forEach AOLocations;

_leftmostPoints = [_aoPoints, [], {_x select 0}, "ASCEND"] call BIS_fnc_sortBy;
_leftmostPoint = _leftmostPoints select 0;
_rightmostPoint = _leftmostPoints select ((count _leftmostPoints)-1);
_topmostPoints = [_aoPoints, [], {_x select 1}, "DESCEND"] call BIS_fnc_sortBy;
_topmostPoint = _topmostPoints select 0;
_bottommostPoint = _topmostPoints select ((count _topmostPoints)-1);
_xDist =  (_rightmostPoint select 0) - (_leftmostPoint select 0);
_yDist = (_topmostPoint select 1) - (_bottommostPoint select 1);
_centerTrue = [(_rightmostPoint select 0)- (_xDist/2), (_topmostPoint select 1) - (_yDist/2)];

_markerAOC = createMarker ["mkrAOC", _centerTrue];
_markerAOC setMarkerShape "RECTANGLE";
_markerAOC setMarkerSize [_xDist/1.5, _yDist/1.5];
_markerAOC setMarkerBrush "FDiagonal";		
_markerAOC setMarkerColor "ColorRed";
_markerAOC setMarkerAlpha 0;

trgAOC = createTrigger ["EmptyDetector", _centerTrue];
trgAOC setTriggerArea [_xDist/1.5, _yDist/1.5, 0, true];
if (!isMultiplayer) then {	
	trgAOC setTriggerActivation ["ANY", "PRESENT", false];
	trgAOC setTriggerStatements ["(vehicle player in thisList)", "saveGame", ""];
};

AOMarkers = [];
{
	_pos = (_x select 0);	
	if (_forEachIndex > 0) then {
		_mkrName = format ["mkrSecondaryLoc%1", _forEachIndex];
		_markerWarning = createMarker [_mkrName, _pos];
		_markerWarning setMarkerShape "ICON";
		_markerWarning setMarkerType "mil_warning";
		_markerWarning setMarkerColor "ColorRed";
		AOMarkers pushBack _mkrName;		
	};	
} forEach AOLocations;

// Check for water between each location
{
	_thisAOPos = _x select 0;
	_otherAOLocations = AOLocations - [_x];
	_returns = [];
	{		
		_return = [_thisAOPos, _x select 0, true] call sun_checkRouteWater;
		diag_log format ["DRO: Water on route? Checked %2 against %1: %3", _thisAOPos,  _x select 0, _return];
		_returns pushBack _return;
	} forEach _otherAOLocations;
	if (false in _returns) then {
		(AOLocations select _forEachIndex) pushBack "ROUTE";
	} else {
		(AOLocations select _forEachIndex) pushBack (_returns select _forEachIndex);
	};	
} forEach AOLocations;

{
	diag_log format ["AOLocation %1 position: %2", _forEachIndex, _x select 0];
	diag_log format ["AOLocation %1 size: %2", _forEachIndex, _x select 1];
	diag_log format ["AOLocation %1 data: %2", _forEachIndex, _x select 2];
	diag_log format ["AOLocation %1 route: %2", _forEachIndex, _x select 3];
} forEach AOLocations;

centerPos = _cityCenter;
publicVariable "centerPos";
diag_log "DRO: Completed AO generation";
