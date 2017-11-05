scopeName "objSelection";
fnc_selectObjects = compile preprocessFile "sunday_system\objectsLibrary.sqf";

params ["_AOIndex", ["_ignorePrefs", false]];
_center = ((AOLocations select _AOIndex) select 0);
_size = ((AOLocations select _AOIndex) select 1);
//_roadPosClose = (((AOLocations select _AOIndex) select 2) select 0);
//_roadPosFar = (((AOLocations select _AOIndex) select 2) select 1);
//_groundPosClose = (((AOLocations select _AOIndex) select 2) select 2);
//_groundPosFar = (((AOLocations select _AOIndex) select 2) select 3);
//_flatPositionsClose = (((AOLocations select _AOIndex) select 2) select 4);
//_flatPositionsFar = (((AOLocations select _AOIndex) select 2) select 5);
//_forestPositions = (((AOLocations select _AOIndex) select 2) select 6);
//_buildingPositions = (((AOLocations select _AOIndex) select 2) select 7);		
//_helipads = (((AOLocations select _AOIndex) select 2) select 8);

diag_log "DRO: Attempting to create new task";

_thisTask = nil;
_objectivePos = [0,0,0];

_thisObj = nil;
_heliTransports = [];
_pVehicleWreckClasses = pCarClasses + pTankClasses + pHeliClasses;

_AOStyles = [];
_AODestroyStyles = [];
_AOHVTStyles = [];
_AOPOWStyles = [];
_AOReconStyles = [];
_AOPreferredStyles = [];
_AOPreferredDestroyStyles = [];
{
	_AOStyles pushBack [];
	_AODestroyStyles pushBack [];
	_AOHVTStyles pushBack [];
	_AOPOWStyles pushBack [];
	_AOReconStyles pushBack [];
	_AOPreferredStyles pushBack [];
	_AOPreferredDestroyStyles pushBack [];
} forEach AOLocations;

{
	//_roadPosClose
	if (count ((_x select 2) select 0) > 0) then {
		if (count eCarClasses > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "VEHICLE";			
			(_AOStyles select _forEachIndex) pushBackUnique "VEHICLESTEAL";			
		};		
		if (count _pVehicleWreckClasses > 0) then { 
			(_AODestroyStyles select _forEachIndex) pushBackUnique "WRECK";
		};
		(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";
	};
	//_groundPosClose
	if (count ((_x select 2) select 2) > 0) then {
		(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";
	};
	//_groundPosFar
	if (count ((_x select 2) select 3) > 0) then {
		(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";
	};
	//_flatPositionsClose
	if (count ((_x select 2) select 4) > 0) then {
		if (count eArtyClasses > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "ARTY";
		};
		if (count eAAClasses > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "ARTY";
		};
		if (count eMortarClasses > 0) then {				
			(_AODestroyStyles select _forEachIndex) pushBackUnique "MORTAR";
		};
		if (count eHeliClasses > 0) then {	
			(_AOStyles select _forEachIndex) pushBackUnique "HELI";
		};
		if (count _pVehicleWreckClasses > 0) then { 
			(_AODestroyStyles select _forEachIndex) pushBackUnique "WRECK";
		};
		(_AOStyles select _forEachIndex) pushBackUnique "CLEARLZ";
		(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";		
		(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDE";
		//(_AODestroyStyles select _forEachIndex) pushBackUnique "POWER";	
	};
	//_forestPositions
	if (count ((_x select 2) select 6) > 0) then {
		(_AOPOWStyles select _forEachIndex) pushBackUnique "OUTSIDE";
		(_AOStyles select _forEachIndex) pushBackUnique "CLEARLZ";
		(_AODestroyStyles select _forEachIndex) pushBackUnique "CACHE";
	};
	//_buildingPositions
	if (count ((_x select 2) select 7) > 0) then {
		(_AOStyles select _forEachIndex) pushBackUnique "CACHEBUILDING";
		(_AOStyles select _forEachIndex) pushBackUnique "INTEL";
		(_AOHVTStyles select _forEachIndex) pushBackUnique "INSIDE";
		(_AOPOWStyles select _forEachIndex) pushBackUnique "INSIDE";
	};
	//_helipads
	if (count ((_x select 2) select 8) > 0) then {	
		if (count eHeliClasses > 0) then {	
			(_AOStyles select _forEachIndex) pushBackUnique "HELI";
		};	
	};
	
	if (count eOfficerClasses > 0 && count (_AOHVTStyles select _forEachIndex) > 0) then {
		(_AOStyles select _forEachIndex) pushBackUnique "HVT";
	};
	if (count (_AODestroyStyles select _forEachIndex) > 0) then {
		(_AOStyles select _forEachIndex) pushBackUnique "DESTROY";
	};
	if (count (_AOPOWStyles select _forEachIndex) > 0) then {
		(_AOStyles select _forEachIndex) pushBackUnique "POW";
	};	
	(_AOStyles select _forEachIndex) pushBack "RECON";
	(_AOReconStyles select _forEachIndex) pushBack "RECONRANGE";
	(_AOReconStyles select _forEachIndex) pushBack "RECONFOOT";	
} forEach AOLocations;

diag_log format ["DRO: _ignorePrefs = %1", _ignorePrefs];
diag_log format ["DRO: preferredObjectives = %1", preferredObjectives];
// Find preferred styles
if (!_ignorePrefs) then {
	if (count preferredObjectives > 0) then {
		{
			_thisPref = _x;
			{
				if (_thisPref in _x) then {
					(_AOPreferredStyles select _forEachIndex) pushBackUnique _thisPref;
				} 				
			} forEach _AOStyles;
			{				
				if (_thisPref in _x) then {
					(_AOPreferredStyles select _forEachIndex) pushBackUnique "DESTROY";
					(_AOPreferredDestroyStyles select _forEachIndex) pushBackUnique _thisPref;
				};
			} forEach _AODestroyStyles;			
		} forEach preferredObjectives;
	};
};
diag_log format ["DRO: _AOStyles = %1", _AOStyles];
diag_log format ["DRO: _AOPreferredStyles = %1", _AOPreferredStyles];

_select = [];
// Check for preferred styles within the requested AO
if (count (_AOPreferredStyles select _AOIndex) > 0) then {
	_select = [_AOIndex, selectRandom (_AOPreferredStyles select _AOIndex)];
} else {
	// Expand the search for preferred styles within all other AOs
	for "_i" from 0 to (count _AOPreferredStyles - 1) step 1 do {
		if (count (_AOPreferredStyles select _i) > 0) exitWith {
			_select = [_i, selectRandom (_AOPreferredStyles select _i)];
		};
	};
	// If no preference is found start looking for any styles in the requested AO
	if (count _select == 0) then {
		if (count (_AOStyles select _AOIndex) > 0) then {
			_select = [_AOIndex, selectRandom (_AOStyles select _AOIndex)];
		} else {		
			// Expand the search for any styles within all other AOs
			for "_i" from 0 to (count _AOStyles - 1) step 1 do {
				if (count (_AOStyles select _i) > 0) exitWith {
					_select = [_i, selectRandom (_AOStyles select _i)];
				};
			};			
		};	
	};
};

diag_log format ["DRO: New task will be %1", _select];
_scriptHandle = nil;

switch (_select select 1) do {
	case "HVT": {
		_hvtInterrogate = if (missionPreset == 2) then {"HVTREGULAR"} else {
			if (random 1 > 0.75) then {"HVTINTERROGATE"} else {"HVTREGULAR"};
		};
		switch (_hvtInterrogate) do {		
			case "HVTREGULAR": {_scriptHandle = [(_select select 0), (_AOHVTStyles select (_select select 0))] execVM "sunday_system\objectives\hvt.sqf";};
			case "HVTINTERROGATE": {_scriptHandle = [(_select select 0), (_AOHVTStyles select (_select select 0))] execVM "sunday_system\objectives\hvtInterrogate.sqf";};
		};
				
	};
	case "DESTROY": {
		_destroySelect = if (count (_AOPreferredDestroyStyles select (_select select 0)) > 0) then {
			selectRandom (_AOPreferredDestroyStyles select (_select select 0))
		} else {
			selectRandom (_AODestroyStyles select (_select select 0))
		};		
		switch (_destroySelect) do {
			case "MORTAR": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\destroyMortar.sqf";	
			};
			case "WRECK": {				
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\destroyWreck.sqf";					
			};
			case "CACHE": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\cache.sqf";					
			};
			case "POWER": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\destroyPower.sqf";				
			};
		};
	};	
	case "POW": {
		_scriptHandle = [(_select select 0), (_AOPOWStyles select (_select select 0))] execVM "sunday_system\objectives\pow.sqf";			
	};
	case "VEHICLE": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\vehicle.sqf";			
	};
	case "VEHICLESTEAL": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\vehicleSteal.sqf";			
	};
	case "ARTY": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\artillery.sqf";		
	};
	case "CACHEBUILDING": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\cacheBuilding.sqf";				
	};
	case "HELI": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\heli.sqf";	
	};
	case "CLEARLZ": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\clearArea.sqf";		
	};
	case "CLEARBASE": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\clearBase.sqf";				
	};
	case "INTEL": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\intel.sqf";		
	};
	case "RECON": {
		_reconSelect = selectRandom (_AOReconStyles select (_select select 0));
		switch (_reconSelect) do {
			case "RECONRANGE": {
				[(_select select 0)] execVM "sunday_system\objectives\reconRange.sqf";
				_scriptHandle = 0 spawn {};
			};
			case "RECONFOOT": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\reconFoot.sqf";		
			};
		};
	};	
};
waitUntil {scriptDone _scriptHandle};