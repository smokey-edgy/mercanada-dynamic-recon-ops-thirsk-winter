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


if (count _leaders > 0) then {
	// Test for civilians near enemies
	_invalidCivs = [];
	{
		_civilian = _x;
		{		
			if (side _x == enemySide) exitWith {
				_invalidCivs pushBack _civilian;
			};
		} forEach (_x nearEntities ["Man", 170]);
	} forEach _leaders;
	_leaders = _leaders - _invalidCivs;
	
	if (count _leaders > 0) then {
		_contactCiv = selectRandom _leaders;

		_taskName = format ["civContactTask%1", (round(random 100000))];
		_taskDesc = format ["We have a local informant in the area who is willing to supply us with information. Meet with %1 and question him.", name _contactCiv];
		_taskTitle = "Optional: Contact Informant";
		_task = [_taskName, true, [_taskDesc, _taskTitle, ""], [_contactCiv, true], "CREATED", 0.5, false, true, "talk", true] call BIS_fnc_setTask;

		_contactCiv allowFleeing 0;
		_contactCiv setVariable ["taskName", _taskName, true];

		[
			_contactCiv,
			"Question",
			"\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa",
			"\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa",
			"(alive _target) && ((_this distance _target) < 3)",
			"(alive _target) && ((_this distance _target) < 3)",
			{
				[(_this select 0), true] remoteExec ["stop", (_this select 0)];		
				_dir = [(_this select 0), (_this select 1)] call BIS_fnc_dirTo;
				[(_this select 0), _dir] remoteExec ["setFormDir", (_this select 0)];
				[(_this select 0), _dir] remoteExec ["setDir", (_this select 0)];
				[(_this select 0), true] remoteExec ["setRandomLip", 0];		
			},
			{
				[(_this select 0), false] remoteExec ["setRandomLip", (_this select 0)];
			},
			{
				[5, true, (_this select 1)] execVM "sunday_system\revealIntel.sqf";
				//[5, true, (_this select 1), (_this select 0)] call dro_revealMapIntel;
				[(_this select 0) getVariable "taskName", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
				[(_this select 0), false] remoteExec ["stop", (_this select 0)];
				[(_this select 0), false] remoteExec ["setRandomLip", 0];
				[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];
				[(_this select 0), 0.5] remoteExec ["allowFleeing", (_this select 0)];		
			},
			{
				[(_this select 0), false] remoteExec ["stop", (_this select 0)];
				[(_this select 0), false] remoteExec ["setRandomLip", 0];		
			},
			[],
			10,
			10,
			true,
			false
		] remoteExec ["bis_fnc_holdActionAdd", 0, true];
				
		[_contactCiv, _taskName, _taskDesc, _taskTitle] spawn {
			params ["_contactCiv", "_taskName", "_taskDesc", "_taskTitle"];
			// Reassign task after loadout phase
			waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
			_task = [_taskName, true, [_taskDesc, _taskTitle, ""], [_contactCiv, true], "CREATED", 0.5, false, true, "talk", true] call BIS_fnc_setTask;
			
			// Check for informant death
			waitUntil {!alive (_this select 0)};
			if !([((_this select 0) getVariable "taskName")] call BIS_fnc_taskCompleted) then {
				[((_this select 0) getVariable "taskName"), "FAILED", true] spawn BIS_fnc_taskSetState;
			};
		};
	};
};