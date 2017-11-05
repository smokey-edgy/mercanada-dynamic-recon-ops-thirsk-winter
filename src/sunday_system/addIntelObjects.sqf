_possibleIndexes = [];
_indexWeights = [];
{		
	if (count ((_x select 2) select 7) > 0) then {
		_possibleIndexes pushBack _forEachIndex;
		_indexWeights pushBack 1;
	};
} forEach AOLocations;

for "_i" from 0 to ([0,2] call BIS_fnc_randomInt) step 1 do {	
	if (count _possibleIndexes > 0) then {
		_thisIndex = [_possibleIndexes, _indexWeights] call BIS_fnc_selectRandomWeighted;
		_indexWeights set [(_possibleIndexes find _thisIndex), 0.1];
		if (count (((AOLocations select _thisIndex) select 2) select 7) > 0) then {
			_thisBuilding = [(((AOLocations select _thisIndex) select 2) select 7)] call sun_selectRemove;
			
			_validIntel = [];
			_allIntel = [];
			_intelClass = selectRandom ["Land_SatellitePhone_F", "Land_Tablet_02_F", "Land_Laptop_F", "Land_Laptop_device_F", "Land_Laptop_unfolded_F", "Land_Laptop_02_F", "Land_Laptop_02_unfolded_F"];
			
			_buildingPositions = [_thisBuilding] call BIS_fnc_buildingPositions;
			{
				_thisIntel = _intelClass createVehicle _x;
				_bbr = boundingBoxReal _thisIntel;
				_p1 = _bbr select 0;
				_p2 = _bbr select 1;
				_maxHeight = abs ((_p2 select 2) - (_p1 select 2));
				_thisIntel setPos [(_x select 0), (_x select 1), ((_x select 2)+(_maxHeight/2))];
				_thisIntel setVelocity [0, 0, 0];
				_allIntel pushBack _thisIntel;	
				lineIntersectsSurfaces [ 
					getPosWorld _thisIntel,  
					getPosWorld _thisIntel vectorAdd [0, 0, 50],  
					_thisIntel, objNull, true, 1, 'GEOM', 'NONE' 
				] select 0 params ['','','','_thisBuilding']; 
				if (_thisBuilding isKindOf 'House') then {		
					_validIntel pushBack [_thisIntel, _x];
				};			
			} forEach _buildingPositions;
			if (count _validIntel > 0) then {
				_selectedIntel = (selectRandom _validIntel);
				_thisIntel = (_selectedIntel select 0);
				{
					if (_x != _thisIntel) then {
						deleteVehicle _x;
					};
				} forEach _allIntel;		
				diag_log format ["DRO: Intel object created: %1", _thisIntel];
				
				_markerName = format["intelMkr%1", floor(random 10000)];
				_markerBuilding = createMarker [_markerName, getPos _thisBuilding];			
				_markerBuilding setMarkerShape "ICON";
				_markerBuilding setMarkerText "Possible Intel";
				_markerBuilding setMarkerType "mil_box_noShadow";
				_markerBuilding setMarkerColor "ColorBlack";		
				_markerBuilding setMarkerSize [0.65, 0.65];		
				_markerBuilding setMarkerAlpha 1;
				_thisIntel setVariable ["markerName", _markerName, true];
				[
					_thisIntel,
					"Search for Intel",
					"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
					"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
					"((_this distance _target) < 3)",
					"((_this distance _target) < 3)",
					{},
					{
						if ((_this select 4) % 4 == 0) then {
							(selectRandom ["FD_CP_Clear_F", "FD_CP_Not_Clear_F", "FD_Timer_F"]) remoteExec ["playSound", (_this select 1)];
						};
					},
					{
						deleteMarker ((_this select 0) getVariable "markerName");
						[5, true, (_this select 1)] execVM "sunday_system\revealIntel.sqf";
						[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];
						//[5, true, (_this select 1)] call dro_revealMapIntel;		
					},
					{},
					[],
					10,
					10,
					true,
					false
				] remoteExec ["bis_fnc_holdActionAdd", 0, true];
			};
		};
	};	
};