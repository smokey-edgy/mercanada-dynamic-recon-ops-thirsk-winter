_switchToHostile = {
	_leader = (_this select 0);
	_selectedWearables = (_this select 1);
	// Make hostile
	hostileCivilians pushBack _leader;
	{
		removeHeadgear _x;
		if (random 1 > 0.3) then {
			_wearable = (selectRandom _selectedWearables);
			_x addVest _wearable;
			_x addHeadgear _wearable;			
		};
		_x addMagazines ["16Rnd_9x21_Mag", 3];
		_x addItemToUniform "hgun_Rook40_F";		
	} forEach (units group _leader);		
	[_leader] spawn {
		_leader = (_this select 0);
		while {alive _leader && (side _leader == civilian)} do {
			sleep 10;
			// Check for nearby player units
			_entities = _leader nearEntities 30;
			_targets = [];
			{
				if (side _x == playersSide) then {
					_targets pushBack _x;
				};
			} forEach _entities;
			if (count _targets > 0) then {					
				while {(count (waypoints (group _leader))) > 0} do {
					deleteWaypoint ((waypoints (group _leader)) select 0);
				};	
				_leader doWatch (selectRandom _targets);						
				// Activate any nearby hostile civilians
				{
					if (_x != _leader) then {
						if (_x distance _leader < 70) then {
							while {(count (waypoints (group _x))) > 0} do {
								deleteWaypoint ((waypoints (group _x)) select 0);
							};	
							_x doWatch (selectRandom _targets);
							sleep (random [10, 15, 20]);
							_group = createGroup enemySide;					
							(units group _x) joinSilent _group;
							{
								_x remoteExec ["removeAllActions", 0, true];
								_x removeItemFromUniform "hgun_Rook40_F";
								if (random 1 > 0.65) then {
									_x removeMagazines "16Rnd_9x21_Mag";
									_x addMagazines ["30Rnd_9x21_Mag", 3]; 
									_x addWeapon "hgun_PDW2000_F";
								} else {
									_x addWeapon "hgun_Rook40_F";
								};
							} forEach (units group _x);
							[group _x, getPos (selectRandom _targets)] call BIS_fnc_taskAttack;
						};
					};
				} forEach hostileCivilians;	
										
				sleep (random [10, 15, 20]);
				
				_group = createGroup enemySide;					
				(units group _leader) joinSilent _group;
				{
					_x remoteExec ["removeAllActions", 0, true];
					_x removeItemFromUniform "hgun_Rook40_F";
					if (random 1 > 0.65) then {
						_x removeMagazines "16Rnd_9x21_Mag";
						_x addMagazines ["30Rnd_9x21_Mag", 3]; 
						_x addWeapon "hgun_PDW2000_F";
					} else {
						_x addWeapon "hgun_Rook40_F";
					};
				} forEach (units group _leader);				
			};					
		};
	};
};

_switchToAmbush = {
	_leader = (_this select 0);
	_selectedWearables = (_this select 1);
	hostileCivilians pushBack _leader;
	{
		removeHeadgear _x;
		if (random 1 > 0.3) then {
			_wearable = (selectRandom _selectedWearables);
			_x addVest _wearable;
			_x addHeadgear _wearable;			
		};
		_x addMagazines ["16Rnd_9x21_Mag", 3];
		_x addItemToUniform "hgun_Rook40_F";		
	} forEach (units group _leader);
		
	[_leader] spawn {
		_leader = (_this select 0);
		while {alive _leader && (side _leader == civilian)} do {
			sleep 10;
			// Check for nearby player units
			_entities = _leader nearEntities 50;
			_targets = [];
			{
				if (side _x == playersSide) then {
					_targets pushBack _x;
				};
			} forEach _entities;
			if (count _targets > 0) then {				
				_leader doWatch (selectRandom _targets);						
				// Activate any nearby hostile civilians
				{
					if (_x != _leader) then {
						if (_x distance _leader < 70) then {
							while {(count (waypoints (group _x))) > 0} do {
								deleteWaypoint ((waypoints (group _x)) select 0);
							};
							
							{
								_pos = [[[(getPos (selectRandom _targets)), 10]], ["water"]] call BIS_fnc_randomPos;
								_x doMove _pos;
							} forEach (units group _x);
							
							sleep (random [10, 15, 20]);
							_group = createGroup enemySide;					
							(units group _x) joinSilent _group;
							{
								_x remoteExec ["removeAllActions", 0, true];
								_x removeItemFromUniform "hgun_Rook40_F";
								if (random 1 > 0.65) then {
									_x removeMagazines "16Rnd_9x21_Mag";
									_x addMagazines ["30Rnd_9x21_Mag", 3]; 
									_x addWeapon "hgun_PDW2000_F";
								} else {
									_x addWeapon "hgun_Rook40_F";
								};
							} forEach (units group _x);
							[group _x, getPos (selectRandom _targets)] call BIS_fnc_taskAttack;							
						};
					};
				} forEach hostileCivilians;	
				
				{
					_pos = [[[(getPos (selectRandom _targets)), 10]], ["water"]] call BIS_fnc_randomPos;
					_x doMove _pos;
				} forEach (units group _leader);				
				sleep (random [10, 15, 20]);
				
				_group = createGroup enemySide;					
				(units group _leader) joinSilent _group;
				{
					_x remoteExec ["removeAllActions", 0, true];
					_x removeItemFromUniform "hgun_Rook40_F";
					if (random 1 > 0.65) then {
						_x removeMagazines "16Rnd_9x21_Mag";
						_x addMagazines ["30Rnd_9x21_Mag", 3]; 
						_x addWeapon "hgun_PDW2000_F";
					} else {
						_x addWeapon "hgun_Rook40_F";
					};
				} forEach (units group _leader);				
			};					
		};
	};
};

hostileCivilians = [];
_wearables = [
	["H_Shemag_olive", "H_ShemagOpen_tan", "H_ShemagOpen_khk"],
	["H_Bandanna_gry", "H_Bandanna_blu", "H_Bandanna_cbr", "H_Bandanna_khk", "H_Bandanna_sgg", "H_Bandanna_sand", "H_Bandanna_camo", "H_Bandanna_mcamo"],
	["V_BandollierB_khk", "V_BandollierB_cbr", "V_BandollierB_rgr", "V_BandollierB_blk", "V_BandollierB_oli"]
];
_selectedIndex = [0, (count _wearables - 1)] call BIS_fnc_randomInt;
_selectedWearables = _wearables select _selectedIndex;
hostileCivIntel = "Some of the civilian militia may be wearing similar clothing. Check and ID your targets visually.";
	
publicVariable "hostileCivIntel";

_leaders = [];
{	
	if (side _x == civilian) then {
		if (((leader _x) isKindOf "Man") && ((leader _x) distance logicStartPos > 200)) then {
			if !((leader _x) isKindOf "Animal") then {
				_leaders pushBack (leader _x);
			};
		};
	};	
} forEach allGroups;

// Chance to create some loitering hostile groups
_numExtraGroups = if (random 1 > 0.3) then {
	[1,4] call BIS_fnc_randomInt
} else {
	0
};
if (count _leaders > 0) then {
	{
		if (random 1 > 0.4 && count (_x getVariable ['taskName', '']) == 0) then {
			[_x, _selectedWearables] call _switchToHostile;		
		};
		if (_numExtraGroups > 0) then {
			_pos = [[[(getPos _x), 30]], ["water"]] call BIS_fnc_randomPos;
			_civilians = [];
			for "_c" from 1 to ([3,5] call BIS_fnc_randomInt) step 1 do {
				_civilians pushBack (selectRandom civClasses);
			};
			_group = [_pos, civilian, _civilians] call BIS_fnc_spawnGroup;
			{
				_dir = ([(getPos _x), _pos] call BIS_fnc_dirTo);
				_x setFormDir _dir;
				_x setDir _dir;
			} forEach units _group;
			[leader _group, _selectedWearables] call _switchToAmbush;
			_numExtraGroups = _numExtraGroups - 1;
		};
	} forEach _leaders;
};