params ["_objectivePos", "_thisTask", "_extraData"];

// Set reinforcements on task completion
_trgReinforce = createTrigger ["EmptyDetector", _objectivePos, true];
_trgReinforce setTriggerArea [400, 400, 0, false];
_trgReinforce setTriggerActivation ["ANY", "PRESENT", false];
_trgReinforce setTriggerStatements [
	"
		[(thisTrigger getVariable 'thisTask')] call BIS_fnc_taskCompleted &&
		!stealthActive
	",
	"			
		_enemyArray = [];		
		{ if (side _x == enemySide) then {_enemyArray = _enemyArray + [_x]} } forEach thisList;
		{[group _x, (getPos thisTrigger)] call BIS_fnc_taskAttack} forEach _enemyArray;
	", 
	""];
_trgReinforce setVariable ["thisTask", _thisTask];

[_objectivePos, _thisTask] spawn {
	params ["_objectivePos", "_thisTask"];
	waitUntil {
		sleep 5;
		[_thisTask] call BIS_fnc_taskCompleted
	};
	reinforceChance = reinforceChance + 0.1;
	if ((random 1) < reinforceChance) then {
		if (!stealthActive && enemyCommsActive) then {
			[_objectivePos, [1,2]] execVM 'sunday_system\reinforce.sqf';
		};
	};
};

// Add cancel button to task
_taskData = [_thisTask] call BIS_fnc_taskDescription;
_taskDesc = (_taskData select 0) select 0;
_taskTitle = _taskData select 1;
_taskMarker = _taskData select 2;
_taskDescNew = format ["%1<br /><br /><execute expression='[""%2"", ""CANCELED"", true] spawn BIS_fnc_taskSetState;'>Cancel task</execute>", _taskDesc, _thisTask];

[_thisTask, [_taskDescNew, _taskTitle, _taskMarker]] call BIS_fnc_taskSetDescription;