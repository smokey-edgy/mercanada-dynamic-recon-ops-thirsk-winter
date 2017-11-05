diag_log "DRO: Initiating supports";

// Define supports
centerSide = createCenter sideLogic;
_logicGroupRequester = createGroup centerSide;
requester = _logicGroupRequester createUnit ["SupportRequester", getPos (leader (grpNetId call BIS_fnc_groupFromNetId)), [], 0, "FORM"];

diag_log format ["DRO: requester = %1", requester];
//Setup requestor limit values
{
	[requester, _x, 0] remoteExec ["BIS_fnc_limitSupport", 0, true];
	//[requester, _x, 0] call BIS_fnc_limitSupport;
} forEach [
	"Artillery",
	"CAS_Heli",
	"CAS_Bombing",
	"UAV",
	"Drop",
	"Transport"
];

// Check whether supports are random or custom
_dropChance = random 1;
_artyChance = random 1;
_casChance = random 1;
_uavChance = random 1;
if (randomSupports == 1) then {
	if ("SUPPLY" in customSupports) then {_dropChance = 1;} else {_dropChance = 0;};
	if ("ARTY" in customSupports) then {_artyChance = 1;} else {_artyChance = 0;};
	if ("CAS" in customSupports) then {_casChance = 1;} else {_casChance = 0;};
	if ("UAV" in customSupports) then {_uavChance = 1;} else {_uavChance = 0;};	
};

// Supply drop
if (_dropChance > 0.7) then {
	diag_log "DRO: Support selected: Supply drop";
	providerDrop = nil;
	if (count pHeliClasses > 0) then {
		_logicGroupDrop = createGroup centerSide;		
		_suppPos = [getPos trgAOC,3000,4000,0,1,1,0] call BIS_fnc_findSafePos;
		diag_log format ["DRO: _suppPos = %1", _suppPos];			
		providerDrop = _logicGroupDrop createUnit ["SupportProvider_Virtual_Drop", _suppPos, [], 0, "FORM"];			
		diag_log format ["DRO: providerDrop = %1", providerDrop];		
		//Setup provider values
		{
			providerDrop setVariable [(_x select 0),(_x select 1),true];
		} forEach [
			["BIS_SUPP_crateInit",
				"
					clearWeaponCargoGlobal _this;
					clearMagazineCargoGlobal _this;
					clearItemCargoGlobal _this;
					_this addMagazineCargoGlobal ['SatchelCharge_Remote_Mag', 2];
					_this addMagazineCargoGlobal ['DemoCharge_Remote_Mag', 4];
					_this addItemCargoGlobal ['Medikit', 1];
					_this addItemCargoGlobal ['FirstAidKit', 10];
					{
						_magazines = magazinesAmmoFull _x;
						{
							_this addMagazineCargoGlobal [(_x select 0), 2];
						} forEach _magazines;
					} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
					[_this] call sun_supplyBox;
				"],		
			["BIS_SUPP_vehicles",[(selectRandom pHeliClasses)]],		
			["BIS_SUPP_vehicleinit",""],	
			["BIS_SUPP_filter","FACTION"]		
		];
		
		[requester, "Drop", 1] remoteExec ["BIS_fnc_limitSupport", 0, true];
		//[requester, "Drop", 1] call BIS_fnc_limitSupport;
	
		{	
			//[_x, requester, providerDrop] call BIS_fnc_addSupportLink;
			[_x, requester, providerDrop] remoteExec ["BIS_fnc_addSupportLink", 0, true];
		} forEach (units (grpNetId call BIS_fnc_groupFromNetId));		
	};
};

// Artillery
if (_artyChance > 0.7) then {
	diag_log "DRO: Support selected: Artillery";
	providerArty = nil;
	_artyList = pMortarClasses + pArtyClasses;
	diag_log _artyList;
	if (count _artyList > 0) then {
		_availableArty = [];
		{
			_artyClass = (selectRandom _artyList);						
			_artyRanges = [_artyClass] call dro_getArtilleryRanges;
			_minRange = (_artyRanges select 0);
			_maxRange = (_artyRanges select 1);			
			_trgArea = triggerArea trgAOC;
			_largestSize = if ((_trgArea select 0) > (_trgArea select 1)) then {
				(_trgArea select 0)
			} else {
				(_trgArea select 1)
			};			
			_minPlacementDistance = (_largestSize + 500);			
			if (_minRange > 0) then {
				_minPlacementDistance = (_largestSize + _minRange);			
			};				
			_artyPos = [getPos trgAOC, _minPlacementDistance, _minPlacementDistance + 500, 5, 0, 0.25, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (!(_artyPos isEqualTo [0,0,0])) then {
				_availableArty pushBack [_artyClass, _artyPos];
			};
		} forEach _artyList;
		
		if (count _availableArty > 0) then {
			_logicGroupArty = createGroup centerSide;
			_artySelection = selectRandom _availableArty;
			_artyClass = _artySelection select 0;
			_artyPos = _artySelection select 1;
			_markerSupports = createMarker ["mkrSupports", _artyPos];
			_markerSupports setMarkerShape "ICON";
			_markerSupports setMarkerColor markerColorPlayers;
			_markerSupports setMarkerType "mil_marker";
			_markerSupports setMarkerText "Support Position";
			_markerSupports setMarkerSize [0.6, 0.6];
			diag_log format ["DRO: _artyPos = %1", _artyPos];	
			providerArty = _logicGroupArty createUnit ["SupportProvider_Artillery", _artyPos, [], 0, "FORM"];
			diag_log format ["DRO: providerArty = %1", providerArty];			
			_artyVeh = createVehicle [_artyClass, _artyPos, [], 0, "NONE"];
			_artyVeh setDir ([(getMarkerPos "campMkr"), trgAOC] call BIS_fnc_dirTo);			
			diag_log format ["DRO: _artyVeh = %1", _artyVeh];
			
			[_artyVeh, playersSide] call sun_createVehicleCrew;
			_artyVeh disableAI "MOVE";
			[requester, "Artillery", -1] remoteExec ["BIS_fnc_limitSupport", 0, true];			
			[providerArty, [_artyVeh]] remoteExec ["synchronizeObjectsAdd", 0, true];			
			{	
				[_x, requester, providerArty] remoteExec ["BIS_fnc_addSupportLink", 0, true];
			} forEach (units (grpNetId call BIS_fnc_groupFromNetId));					
		} else {
			diag_log "DRO: Valid artillery support position not found";
		};
	};
};

// CAS
if (_casChance > 0.7) then {
	diag_log "DRO: Support selected: CAS";
	if (count availableCASClasses > 0) then {		
		_availableCASClassesHeli = [];
		_availableCASClassesBomb = [];
		{
			_availableSupportTypes = (configfile >> "CfgVehicles" >> _x >> "availableForSupportTypes") call BIS_fnc_GetCfgData;	
			if ("CAS_Bombing" in _availableSupportTypes) then {
				_availableCASClassesBomb pushBack _x;				
			};
			if ("CAS_Heli" in _availableSupportTypes) then {
				_availableCASClassesHeli pushBack _x;				
			};
		} forEach availableCASClasses;		
		
		_chosenCASClasses = [];
		// Choose a random CAS type based on vehicles available
		_casType = "";
		_limitType = "";
		if ((count _availableCASClassesHeli > 0) && (count _availableCASClassesBomb > 0)) then {			
			_casTypeChance = [0,1] call BIS_fnc_randomInt;
			if (_casTypeChance == 0) then {
				_casType = "SupportProvider_Virtual_CAS_Heli";
				_chosenCASClasses = _availableCASClassesHeli;
				_limitType = "CAS_Heli";
			} else {
				_casType = "SupportProvider_Virtual_CAS_Bombing";
				_chosenCASClasses = _availableCASClassesBomb;
				_limitType = "CAS_Bombing";
			};
		} else {
			if (count _availableCASClassesHeli > 0) then {
				_casType = "SupportProvider_Virtual_CAS_Heli";
				_chosenCASClasses = _availableCASClassesHeli;
				_limitType = "CAS_Heli";
			} else {
				_casType = "SupportProvider_Virtual_CAS_Bombing";
				_chosenCASClasses = _availableCASClassesBomb;
				_limitType = "CAS_Bombing";
			};
		};
		
		_logicGroupCAS = createGroup centerSide;
		diag_log _chosenCASClasses;
		diag_log _casType;
		diag_log _limitType;
		
		_suppPos = [getPos trgAOC,3000,4000,0,1,1,0] call BIS_fnc_findSafePos;	
		diag_log format ["DRO: _suppPos = %1", _suppPos];
		providerCAS = _logicGroupCAS createUnit [_casType, _suppPos, [], 0, "FORM"];
		diag_log format ["DRO: providerCAS = %1", providerCAS];				
		//Setup provider values
		{
			providerCAS setVariable [(_x select 0),(_x select 1), true];
		} forEach [						
			["BIS_SUPP_vehicles",[(selectRandom _chosenCASClasses)]],		
			["BIS_SUPP_vehicleinit",""],	
			["BIS_SUPP_filter","FACTION"]		
		];
		
		[requester, _limitType, 1] remoteExec ["BIS_fnc_limitSupport", 0, true];
		//[requester, _limitType, 1] call BIS_fnc_limitSupport;
	
		{
			[_x, requester, providerCAS] remoteExec ["BIS_fnc_addSupportLink", 0, true];
			//[_x, requester, providerCAS] call BIS_fnc_addSupportLink;
		} forEach (units (grpNetId call BIS_fnc_groupFromNetId));		
				
	};
};

if (_uavChance > 0.7) then {
	[] execVM "sunday_system\uavPatrol.sqf";
};	
