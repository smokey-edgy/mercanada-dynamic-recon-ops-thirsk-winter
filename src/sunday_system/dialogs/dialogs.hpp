class SUN_loadScreen {
	idd = 888888;
	movingenable = false;
	class controls {
		class loadScreen: sundayText
		{
			idc = 8888;
			style = ST_CENTER;
			text = "";
			fade = 1;
			x = 0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 1 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0, 0, 0, 0 };
		};
		class loadScreenText: sundayText
		{
			idc = 8889;
			style = ST_CENTER;
			text = "";
			fade = 1;
			x = 0 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 1 * safezoneW;
			h = 0.5 * safezoneH;
			colorBackground[] = { 0, 0, 0, 0 };
			font = "RobotoCondensed";
			sizeEx = 0.035;
		};
	};
};

class DRO_facade {
	idd = 999999;
	movingenable = false;
	class controls {
		class facade: sundayText
		{
			idc = 9999;
			text = "";
			x = -2 * safezoneW + safezoneX;
			y = -2 * safezoneH + safezoneY;
			w = 2 * safezoneW;
			h = 2 * safezoneH;
			colorBackground[] = { 0, 0, 0, 1 };
			font = "RobotoCondensed";
			sizeEx = 0.033;
		};
	};
};

class DRO_lobbyDialog {
	idd = 626262;
	movingenable = false;

	class controls {
		class menuBackground1: sundayText {
			idc = 1050;
			x = 0.0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.3 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class teamPlanningTitle: sundayHeading
		{
			idc = 1098;
			text = "TEAM PLANNING";
			x = 0 * safezoneW + safezoneX;
			y = 0.016 * safezoneH + safezoneY;
			w = 0.3 * safezoneW;
			h = 0.21 * safezoneH;
			sizeEx = 0.1;
		};
		class sundayTitleChoose: sundayHeading
		{
			idc = 1101;
			style = ST_CENTER;
			text = "SQUAD LOADOUT";
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.3 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.035;
			colorBackground[] = {0.20,0.40,0.65,1};
		};
		class menuLeft: DROBasicButton
		{
			idc = 1150;
			text = "<";
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;
			action = "['LEFT', (findDisplay 626262)] spawn dro_menuSlider";
		};
		class menuRight: DROBasicButton
		{
			idc = 1151;
			text = ">";
			x = 0.2775 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;
			action = "['RIGHT', (findDisplay 626262)] spawn dro_menuSlider";
		};
		class loadoutGroup: RscControlsGroup {
			idc = 6060;
			x = 0.02 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.6 * safezoneH;
		};
		class unitTextBG: sundayText {
			idc = 1159;
			text = "";
			x = 0.73 * safezoneW + safezoneX;
			y = 0.14 * safezoneH + safezoneY;
			w = 0.27 * safezoneW;
			h = 0.1 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
		};
		class unitText: sundayTextMT {
			idc = 1160;
			text = "";
			x = 0.74 * safezoneW + safezoneX;
			y = 0.15 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.08 * safezoneH;
			font = "RobotoCondensed";
			sizeEx = 0.02 * safezoneH;
		};
		class previewMap: DROBasicButton
		{
			idc = 1161;
			style = 48 + 2048;
			text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\map_ca.paa";
			x = 0 * safezoneW + safezoneX;
			y = 0.95 * safezoneH + safezoneY;
			w = 0.03 * safezoneW;
			h = 0.05 * safezoneH;
			action = "[] spawn sun_lobbyMapPreview";
		};
		class insertGroup: RscControlsGroup {
			idc = 6070;
			x = -0.4 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.6 * safezoneH;
			class Controls {
				class lobbySelectStartText: sundayText {
					idc = 6006;
					text = "Insertion position: RANDOM";
					x = 0;
					y = 0;
					w = 0.26 * safezoneW;
					h = 0.04 * safezoneH;
				};
				class lobbySelectStart: DROBasicButton
				{
					idc = 6004;
					text = "Set Insert Location";
					x = 0;
					y = 0.08;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;
					action = "_nil=[]ExecVM 'sunday_system\dialogs\selectStart.sqf';";
				};
				class lobbySelectStartClear: DROBasicButton
				{
					idc = 6005;
					text = "Clear Insert Location";
					x = 0.32;
					y = 0.08;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;
					action = "[] call sun_clearInsert;";
				};
				class lobbySelectInsertText: sundayText {
					idc = 6007;
					text = "Insertion type";
					x = 0;
					y = 0.2;
					w = 0.26 * safezoneW;
					h = 0.04 * safezoneH;
				};
				class lobbyComboInsert: DROCombo
				{
					idc = 6009;
					x = 0;
					y = 0.28;
					w = 0.125 * safezoneW;
					onLBSelChanged = "insertType = (_this select 1); publicVariable 'insertType'; profileNamespace setVariable ['DRO_insertType', insertType]; if (insertType > 1) then {((findDisplay 626262) displayCtrl 6021) ctrlEnable false; ((findDisplay 626262) displayCtrl 6022) ctrlEnable false;} else {((findDisplay 626262) displayCtrl 6021) ctrlEnable true; ((findDisplay 626262) displayCtrl 6022) ctrlEnable true;};";
				};
				class lobbySelectVehText: sundayText {
					idc = 6020;
					text = "Starting ground vehicle(s)";
					x = 0;
					y = 0.36;
					w = 0.26 * safezoneW;
					h = 0.04 * safezoneH;
					tooltip = "Picks a custom ground vehicle for insertion. If the chosen vehicle does not have enough room for all units additional random vehicles will be chosen.";
				};
				class lobbyComboVeh: DROCombo
				{
					idc = 6021;
					x = 0;
					y = 0.44;
					w = 0.125 * safezoneW;
					rowHeight = 0.1;
					onLBSelChanged = "startVehicles set [0, (_this select 0) lbData (_this select 1)]; publicVariable 'startVehicles'";
				};
				class lobbyComboVeh2: DROCombo
				{
					idc = 6022;
					x = 0;
					y = 0.52;
					w = 0.125 * safezoneW;
					rowHeight = 0.1;
					onLBSelChanged = "startVehicles set [1, (_this select 0) lbData (_this select 1)]; publicVariable 'startVehicles'";
				};

			};
		};
		class supportsGroup: RscControlsGroup {
			idc = 6080;
			x = -0.4 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.6 * safezoneH;
			class Controls {
				class lobbySupportCombo: DROCombo
				{
					idc = 6010;
					x = 0;
					y = 0;
					w = 0.125 * safezoneW;
					onLBSelChanged = "randomSupports = (_this select 1); publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";
				};
				class lobbySupportSupply: DROBasicButton
				{
					idc = 6011;
					text = "Supply Drop";
					x = 0;
					y = 0.08;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = 0.035;
					action = "if ('SUPPLY' in customSupports) then {customSupports = customSupports - ['SUPPLY']; ((findDisplay 626262) displayCtrl 6011) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'SUPPLY'; ((findDisplay 626262) displayCtrl 6011) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";
				};
				class lobbySupportArty: DROBasicButton
				{
					idc = 6012;
					text = "Artillery";
					x = 0;
					y = 0.16;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = 0.035;
					action = "if ('ARTY' in customSupports) then {customSupports = customSupports - ['ARTY']; ((findDisplay 626262) displayCtrl 6012) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'ARTY'; ((findDisplay 626262) displayCtrl 6012) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";
				};
				class lobbySupportCAS: DROBasicButton
				{
					idc = 6013;
					text = "CAS";
					x = 0;
					y = 0.24;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = 0.035;
					action = "if ('CAS' in customSupports) then {customSupports = customSupports - ['CAS']; ((findDisplay 626262) displayCtrl 6013) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'CAS'; ((findDisplay 626262) displayCtrl 6013) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";
				};
				class lobbySupportUAV: DROBasicButton
				{
					idc = 6014;
					text = "UAV";
					x = 0;
					y = 0.32;
					w = 0.125 * safezoneW;
					h = 0.04 * safezoneH;
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = 0.035;
					action = "if ('UAV' in customSupports) then {customSupports = customSupports - ['UAV']; ((findDisplay 626262) displayCtrl 6014) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'UAV'; ((findDisplay 626262) displayCtrl 6014) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";
				};
				/*
				class lobbySupportOptions: DROCheckBoxSupports
				{
					idc = 6011;
					x = 0;
					y = 0.08;
					w = 0.125 * safezoneW;
					onCheckBoxesSelChanged = "customSupports set [(_this select 1), (_this select 2)]; lbSetCurSel [6010, 1]; randomSupports = 1; publicVariable 'customSupports'; publicVariable 'randomSupports'";
				};
				*/
			};
		};
		class sundayStartButton: DROBigButton
		{
			idc = 1601;
			text = "READY";
			x = 0.82 * safezoneW + safezoneX;
			y = 0.945 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.055 * safezoneH;
			sizeEx = 0.05;
			action = "[] call sun_lobbyReadyButton;";
		};
		/*
		class sundayStartButton: DROBigButton
		{
			idc = 1601;
			text = "START MISSION";
			x = 0.82 * safezoneW + safezoneX;
			y = 0.945 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.055 * safezoneH;
			sizeEx = 0.05;
			action = "closeDialog 1; missionNameSpace setVariable ['lobbyComplete', 1, true]; publicVariable 'lobbyComplete';";
		};
		*/

	};
};


class sundayDialog {
	idd = 52525;
	movingenable = false;

	class controls {
		class menuBackground1: sundayText {
			idc = 1050;
			x = 0.23 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.59 * safezoneW;
			h = 0.1 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class menuBackground2: sundayText {
			idc = 1051;
			x = 0.0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class sundayTitlePic: RscPicture
		{
			idc = 1098;
			text = "images\recon_icon.paa";
			x = 0.025 * safezoneW + safezoneX;
			y = 0.0 * safezoneH + safezoneY;
			w = 0.13 * safezoneW;
			h = 0.21 * safezoneH;
		};
		class sundayWarningBox: sundayText
		{
			idc = 1052;
			text = "";
			fade = 1;
			x = 0.82 * safezoneW + safezoneX;
			y = 0.18 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.18 * safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
		};
		class sundayWarningText: sundayText
		{
			idc = 1053;
			type = CT_STRUCTURED_TEXT;
			text = "";
			fade = 1;
			x = 0.83 * safezoneW + safezoneX;
			y = 0.19 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.16 * safezoneH;
			size = 0.033;
			class Attributes {
				color = "#ffffff";
				valign = "middle";
			};
		};
		class sundayTitleChoose: sundayHeading
		{
			idc = 1101;
			style = ST_CENTER;
			text = "INFO"; //--- ToDo: Localize;
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.035;
			colorBackground[] = {0.20,0.40,0.65,1};
		};

		class menuLeft: DROBasicButton
		{
			idc = 1150;
			text = "<";
			x = 0 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;
			action = "['LEFT', (findDisplay 52525)] spawn dro_menuSlider";
		};
		class menuRight: DROBasicButton
		{
			idc = 1151;
			text = ">";
			x = 0.1576 * safezoneW + safezoneX;
			y = 0.22 * safezoneH + safezoneY;
			w = 0.0225 * safezoneW;
			h = 0.045 * safezoneH;
			sizeEx = 0.06;
			action = "['RIGHT', (findDisplay 52525)] spawn dro_menuSlider";
		};

		class mapBox: RscMapControl
		{
			idc = 2251;
			x = 0.22 * safezoneW + safezoneX;
			y = 0.18 * safezoneH + safezoneY;
			w = 0;
			h = 0;
		};

		class sundayTitlePlayer: sundayText
		{
			idc = 1102;
			text = "Player faction"; //--- ToDo: Localize;
			x = 0.25 * safezoneW + safezoneX;
			y = 0.007 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboPlayerFactions: DROCombo
		{
			idc = 2100;
			x = 0.254 * safezoneW + safezoneX;
			y = 0.042 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.035 * safezoneH;
			sizeEx = 0.045;
			rowHeight = 0.05;
			wholeHeight = 5 * 0.10;
			onLBSelChanged = "pFactionIndex = (_this select 1); publicVariable 'pFactionIndex'";
		};

		class sundayTitleEnemy: sundayText
		{
			idc = 1103;
			text = "Enemy faction"; //--- ToDo: Localize;
			x = 0.44 * safezoneW + safezoneX;
			y = 0.007 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboEnemyFactions: DROCombo
		{
			idc = 2101;
			x = 0.444 * safezoneW + safezoneX;
			y = 0.042 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.035 * safezoneH;
			sizeEx = 0.045;
			rowHeight = 0.05;
			wholeHeight = 5 * 0.10;
			onLBSelChanged = "eFactionIndex = (_this select 1); publicVariable 'eFactionIndex'";
		};
		class sundayTitleCivilians: sundayText
		{
			idc = 1104;
			text = "Civilian faction"; //--- ToDo: Localize;
			x = 0.63 * safezoneW + safezoneX;
			y = 0.007 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboCivFactions: DROCombo
		{
			idc = 2102;
			x = 0.634 * safezoneW + safezoneX;
			y = 0.042 * safezoneH + safezoneY;
			w = 0.16 * safezoneW;
			h = 0.035 * safezoneH;
			sizeEx = 0.045;
			rowHeight = 0.05;
			wholeHeight = 5 * 0.10;
			onLBSelChanged = "cFactionIndex = (_this select 1); publicVariable 'cFactionIndex'";
		};
		class sundayStartButton: DROBigButton
		{
			idc = 1601;
			text = "START";
			x = 0.82 * safezoneW + safezoneX;
			y = 0.945 * safezoneH + safezoneY;
			w = 0.18 * safezoneW;
			h = 0.055 * safezoneH;
			sizeEx = 0.05;
			action = "_nil=[]ExecVM 'sunday_system\dialogs\okAO.sqf';";
		};

		// INFO
		class welcomeHeading: sundayHeading
		{
			idc = 1140;
			text = "Welcome";
			x = 0.02 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
		};
		class welcomeText: sundayTextMT
		{
			idc = 1141;
			text = "Dynamic Recon Ops is a randomised, replayable scenario that generates an enemy occupied area with a selection of tasks to complete within.\n\nYou can press the START button at the bottom right to immediately play a random scenario or use the arrow buttons above to scroll through the available customisation options.\n\nThanks for playing and have fun!";
			x = 0.02 * safezoneW + safezoneX;
			y = 0.35 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.4 * safezoneH;
		};
		class clearData: DROBasicButton
		{
			idc = 1142;
			text = "Reset Default Options";
			x = 0.02 * safezoneW + safezoneX;
			y = 0.9 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			action = "[] call dro_clearData";
		};

		// ENVIRONMENT
		class sundayTitleTime: sundayText
		{
			idc = 1105;
			text = "Time of day"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayTBTime: DROCombo
		{
			idc = 2103;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "timeOfDay = (_this select 1); publicVariable 'timeOfDay'; [(_this select 1)] remoteExec ['sun_randomTime', 0, true]; profileNamespace setVariable ['DRO_timeOfDay', (_this select 1)];";
		};
		class sundayTitleMonth: sundayText
		{
			idc = 1106;
			text = "Month"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.36 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBMonth: DROCombo
		{
			idc = 2104;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.4 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "month = (_this select 1); publicVariable 'month'; ['MONTH', (_this select 1)] remoteExec ['sun_setDateMP', 0, true]; [1301] call dro_inputDaysData; profileNamespace setVariable ['DRO_month', (_this select 1)];";
		};
		class sundayTitleDay: sundayText
		{
			idc = 1300;
			text = "Day"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBDay: DROCombo
		{
			idc = 1301;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.46 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "day = (_this select 1); publicVariable 'day'; ['DAY', (_this select 1)] remoteExec ['sun_setDateMP', 0, true]; profileNamespace setVariable ['DRO_day', (_this select 1)];";
		};
		class sundayTitleWeather: sundayText
		{
			idc = 1112;
			text = "Weather";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBWeather: DROCombo
		{
			idc = 2116;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.52 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "if ((_this select 1) == 0) then {weatherOvercast = 'RANDOM'} else {weatherOvercast = (round (((sliderPosition 2109)/10) * (10 ^ 3)) / (10 ^ 3))}; publicVariable 'weatherOvercast'; if (typeName weatherOvercast isEqualTo 'SCALAR') then {[weatherOvercast] call BIS_fnc_setOvercast;}; profileNamespace setVariable ['DRO_weatherOvercast', weatherOvercast];";		
		};
		class sundaySliderWeatherFair: sundayText
		{
			idc = 1113;
			text = "Fair";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundaySliderWeatherBad: sundayText
		{
			idc = 1114;
			style = ST_RIGHT;
			text = "Bad";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundaySliderWeather: sundaySlider
		{
			idc = 2109;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.58 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 3)) / (10 ^ 3); lbSetCurSel [2116, 1]; weatherOvercast = _rounded; publicVariable 'weatherOvercast';";
		};
		class sundayTitleAnimals: sundayText
		{
			idc = 1115;
			text = "Animals";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.6 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayCBAnimals: DROCombo
		{
			idc = 2117;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.64 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "animalsEnabled = (_this select 1); publicVariable 'animalsEnabled'; profileNamespace setVariable ['DRO_animalsEnabled', (_this select 1)];";
		};


		// SCENARIO
		class ScenarioGroup: RscControlsGroup {
			idc = 2300;
			x = -0.4 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.7 * safezoneH;
			class Controls {
				class sundayTitlePreset: sundayText
				{
					idc = 1400;
					text = "Mission Preset"; //--- ToDo: Localize;
					x = 0;
					y = 0;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					sizeEx = 0.04;
					tooltip = "";
				};
				class sundayTBPreset: DROCombo
				{
					idc = 1401;
					x = 0;
					y = 0.08;
					w = 0.14 * safezoneW;
					h = 0.035 * safezoneH;
					sizeEx = 0.04;
					onLBSelChanged = "[(_this select 1)] call sun_missionPreset; missionPreset = (_this select 1); publicVariable 'missionPreset'; profileNamespace setVariable ['DRO_missionPreset', (_this select 1)];";
				};
				class droSelectAOText: sundayText {
					idc = 2301;
					text = "AO location: RANDOM";
					x = 0;
					y = 0.16;
					w = 0.14 * safezoneW;
					h = 0.04 * safezoneH;
					sizeEx = 0.04;
				};
				class droSelectAONew: DROBasicButton
				{
					idc = 2255;
					text = "Open Map";
					x = 0;
					y = 0.24;
					w = 0.14 * safezoneW;
					h = 0.04 * safezoneH;
					action = "[] spawn dro_menuMap";
				};
				class droSelectAOClear: DROBasicButton
				{
					idc = 2256;
					text = "Clear AO Location";
					x = 0;
					y = 0.32;
					w = 0.14 * safezoneW;
					h = 0.04 * safezoneH;
					action = "deleteMarker 'aoSelectMkr'; aoName = nil; ctrlSetText [2300, 'AO location: RANDOM']; selectedLocMarker setMarkerColor 'ColorPink';";
				};
				class sundayTitleAO: sundayText
				{
					idc = 1109;
					text = "Expanded AO"; //--- ToDo: Localize;
					x = 0;
					y = 0.4;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					tooltip = "When enabled up to three extra locations will be chosen in addition to the selected AO location to make a larger area for the mission.";
				};
				class sundayTBAO: DROCombo
				{
					idc = 2107;
					x = 0;
					y = 0.46;
					w = 0.14 * safezoneW;
					onLBSelChanged = "aoOptionSelect = (_this select 1); publicVariable 'aoOptionSelect'";
				};
				class sundayTitleAI: sundayText
				{
					idc = 1107;
					text = "Enemy skill"; //--- ToDo: Localize;
					x = 0;
					y = 0.50;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					tooltip = "Action - Normal reduces the AI's aiming ability dramatically while leaving their strategic skills almost unchanged. Action - Hard is similar but with slightly better aiming skills. Realism makes no changes to any AI skills and leaves them as set in your Arma options menu.";
				};
				class sundayTBAI: DROCombo
				{
					idc = 2105;
					x = 0;
					y = 0.56;
					w = 0.14 * safezoneW;
					onLBSelChanged = "aiSkill = (_this select 1); publicVariable 'aiSkill'; profileNamespace setVariable ['DRO_aiSkill', (_this select 1)];";
				};
				class sundayTitleAISize: sundayText
				{
					idc = 2110;
					text = "Enemy force size multiplier: x1.0";
					x = 0;
					y = 0.6;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					tooltip = "Allows you to fine tune the size of the force you'll be facing.";
				};
				class sundaySliderAISize: sundaySlider
				{
					idc = 2111;
					x = 0;
					y = 0.67;
					w = 0.14 * safezoneW;
					onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 1)) / (10 ^ 1); ((findDisplay 52525) displayCtrl 2110) ctrlSetText format ['Enemy force size multiplier: x%1', _rounded]; aiMultiplier = _rounded; publicVariable 'aiMultiplier'; profileNamespace setVariable ['DRO_aiMultiplier', _rounded];";
				};
				class sundayTitleMines: sundayText
				{
					idc = 2112;
					text = "Minefields"; //--- ToDo: Localize;
					x = 0;
					y = 0.7;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					tooltip = "Enable the possibility for minefields to be present or disable them altogether";
				};
				class sundayCBMines: DROCombo
				{
					idc = 2113;
					x = 0;
					y = 0.76;
					w = 0.14 * safezoneW;
					onLBSelChanged = "minesEnabled = (_this select 1); publicVariable 'minesEnabled'; profileNamespace setVariable ['DRO_minesEnabled', (_this select 1)];";
				};
				class sundayTitleCivOption: sundayText
				{
					idc = 2114;
					text = "Civilians"; //--- ToDo: Localize;
					x = 0;
					y = 0.8;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					tooltip = "Enable the possibility for civilians to be present or disable them altogether.";
				};
				class sundayCBCivOption: DROCombo
				{
					idc = 2115;
					x = 0;
					y = 0.86;
					w = 0.14 * safezoneW;
					onLBSelChanged = "civiliansEnabled = (_this select 1); publicVariable 'civiliansEnabled'; profileNamespace setVariable ['DRO_civiliansEnabled', (_this select 1)];";
				};
				class sundayTitleStealthOption: sundayText
				{
					idc = 2118;
					text = "Stealth"; //--- ToDo: Localize;
					x = 0;
					y = 0.9;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					tooltip = "Enable or disable player stealth tracking throughout the mission. 'Random' only has a chance to enable stealth on dusk or night starts.";
				};
				class sundayCBStealthOption: DROCombo
				{
					idc = 2119;
					x = 0;
					y = 0.96;
					w = 0.14 * safezoneW;
					onLBSelChanged = "stealthEnabled = (_this select 1); publicVariable 'stealthEnabled'; profileNamespace setVariable ['DRO_stealthEnabled', (_this select 1)];";
				};
				class sundayTitleRevive: sundayText
				{
					idc = 1110;
					text = "Revive"; //--- ToDo: Localize;
					x = 0;
					y = 1;
					w = 0.14 * safezoneW;
					h = 0.044 * safezoneH;
					tooltip = "Enable or disable the built in revive script.";
				};
				class sundayTBRevive: DROCombo
				{
					idc = 2108;
					x = 0;
					y = 1.06;
					w = 0.14 * safezoneW;
					onLBSelChanged = "reviveDisabled = (_this select 1); publicVariable  'reviveDisabled'; profileNamespace setVariable ['DRO_reviveDisabled', (_this select 1)];";
				};

			};

		};


		// OBJECTIVES
		class sundayTitleObjs: sundayText
		{
			idc = 1108;
			text = "Number of objectives"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayTBObjs: DROCombo
		{
			idc = 2106;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "numObjectives = (_this select 1); publicVariable 'numObjectives'; profileNamespace setVariable ['DRO_numObjectives', (_this select 1)];";
		};
		class objPrefTitle: sundayText
		{
			idc = 2211;
			text = "Objective preferences";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.38 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class objPrefText: sundayTextMT
		{
			idc = 2212;
			text = "Please note that it may not always be possible to give the selected preferences depending on the location and available faction assets.";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.05 * safezoneH;
			colorText[] = {1,1,1,0.7};
		};

		class objPrefHVT: DROBasicButton
		{
			idc = 2200;
			text = "Eliminate HVT";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('HVT' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['HVT']; ((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'HVT'; ((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefPOW: DROBasicButton
		{
			idc = 2201;
			text = "Rescue Hostage";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.52 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('POW' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['POW']; ((findDisplay 52525) displayCtrl 2201) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'POW'; ((findDisplay 52525) displayCtrl 2201) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefIntel: DROBasicButton
		{
			idc = 2202;
			text = "Retrieve Intel";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.56 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('INTEL' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['INTEL']; ((findDisplay 52525) displayCtrl 2202) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'INTEL'; ((findDisplay 52525) displayCtrl 2202) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefCache: DROBasicButton
		{
			idc = 2203;
			text = "Destroy Cache";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.6 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('CACHE' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['CACHE']; ((findDisplay 52525) displayCtrl 2203) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'CACHE'; ((findDisplay 52525) displayCtrl 2203) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefMortar: DROBasicButton
		{
			idc = 2204;
			text = "Destroy Mortar";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.64 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('MORTAR' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['MORTAR']; ((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'MORTAR'; ((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefWreck: DROBasicButton
		{
			idc = 2205;
			text = "Destroy Wreck";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.68 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('WRECK' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['WRECK']; ((findDisplay 52525) displayCtrl 2205) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'WRECK'; ((findDisplay 52525) displayCtrl 2205) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefVehicle: DROBasicButton
		{
			idc = 2206;
			text = "Destroy Vehicle";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.72 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('VEHICLE' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['VEHICLE']; ((findDisplay 52525) displayCtrl 2206) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'VEHICLE'; ((findDisplay 52525) displayCtrl 2206) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefVehicleSteal: DROBasicButton
		{
			idc = 2207;
			text = "Steal Vehicle";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.76 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('VEHICLESTEAL' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['VEHICLESTEAL']; ((findDisplay 52525) displayCtrl 2207) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'VEHICLESTEAL'; ((findDisplay 52525) displayCtrl 2207) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefArty: DROBasicButton
		{
			idc = 2208;
			text = "Destroy Artillery";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.8 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('ARTY' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['ARTY']; ((findDisplay 52525) displayCtrl 2208) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'ARTY'; ((findDisplay 52525) displayCtrl 2208) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefHeli: DROBasicButton
		{
			idc = 2209;
			text = "Destroy Helicopter";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.84 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('HELI' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['HELI']; ((findDisplay 52525) displayCtrl 2209) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'HELI'; ((findDisplay 52525) displayCtrl 2209) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};
		class objPrefClear: DROBasicButton
		{
			idc = 2210;
			text = "Clear Area";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.88 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.04 * safezoneH;
			onMouseEnter = "";
			onMouseExit = "";
			sizeEx = 0.035;
			action = "if ('CLEARLZ' in preferredObjectives) then {preferredObjectives = preferredObjectives - ['CLEARLZ']; ((findDisplay 52525) displayCtrl 2210) ctrlSetTextColor [1, 1, 1, 1]} else {preferredObjectives pushBackUnique 'CLEARLZ'; ((findDisplay 52525) displayCtrl 2210) ctrlSetTextColor [0.05, 1, 0.5, 1]}; publicVariable 'preferredObjectives'; profileNamespace setVariable ['DRO_objectivePrefs', preferredObjectives];";
		};

		// ADDITIONAL FACTIONS
		class sundayTextAdvPlayer: sundayTextMT
		{
			idc = 3712;
			text = "These options allow you to add additional factions to your currently selected side. Each extra selection made will add that faction's full complement of units and vehicles to the usable pool."; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.15 * safezoneH;
		};
		class sundayTitleAdvPlayer: sundayText
		{
			idc = 3704;
			text = "Player faction"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.38 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboAdvPlayerFactionsG: DROCombo
		{
			idc = 3800;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "playersFactionAdv set [0, (_this select 1)]; publicVariable 'playersFactionAdv'";
		};
		class sundayComboAdvPlayerFactionsA: DROCombo
		{
			idc = 3801;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.45 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "playersFactionAdv set [1, (_this select 1)]; publicVariable 'playersFactionAdv'";
		};
		class sundayComboAdvPlayerFactionsS: DROCombo
		{
			idc = 3802;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "playersFactionAdv set [2, (_this select 1)]; publicVariable 'playersFactionAdv'";
		};
		class sundayTitleAdvEnemy: sundayText
		{
			idc = 3708;
			text = "Enemy faction"; //--- ToDo: Localize;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class sundayComboAdvEnemyFactionsG: DROCombo
		{
			idc = 3803;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "enemyFactionAdv set [0, (_this select 1)]; publicVariable 'enemyFactionAdv'";
		};
		class sundayComboAdvEnemyFactionsA: DROCombo
		{
			idc = 3804;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.57 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "enemyFactionAdv set [1, (_this select 1)]; publicVariable 'enemyFactionAdv'";
		};
		class sundayComboAdvEnemyFactionsS: DROCombo
		{
			idc = 3805;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.6 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "enemyFactionAdv set [2, (_this select 1)]; publicVariable 'enemyFactionAdv'";
		};
		// ACE
		class sundayACE_RepWho_Text: sundayText
		{
			idc = 6000;
			text = "Allow Repair";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Let everyone repair vehicles or limit it to Engineer classes only. Will not be used if ACE Repair is not installed.";
		};
		class sundayACE_RepWho_Select: DROCombo
		{
			idc = 6001;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_repengineerSetting_Repair = (_this select 1); publicVariable 'ACE_repengineerSetting_Repair'; profileNamespace setVariable ['DRO_ACE_repengineerSetting_Repair', (_this select 1)];";
		};
		class sundayACE_RepConsume_Text: sundayText
		{
			idc = 6002;
			text = "Consume Toolkit";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.36 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should toolkits be consumed on use? Will not be used if ACE Repair is not installed.";
		};
		class sundayACE_RepConsume_Select: DROCombo
		{
			idc = 6003;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.4 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_repconsumeItem_ToolKit = (_this select 1); publicVariable 'ACE_repconsumeItem_ToolKit'; profileNamespace setVariable ['DRO_ACE_repconsumeItem_ToolKit', (_this select 1)];";
		};
		class sundayACE_RepWheel_Text: sundayText
		{
			idc = 6004;
			text = "Wheel repair requirements";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should toolkits be needed to work on wheels? Will not be used if ACE Repair is not installed.";
		};
		class sundayACE_RepWheel_Select: DROCombo
		{
			idc = 6005;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.46 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_repwheelRepairRequiredItems = (_this select 1); publicVariable 'ACE_repwheelRepairRequiredItems'; profileNamespace setVariable ['DRO_ACE_repwheelRepairRequiredItems', (_this select 1)];";
		};
		class sundayACE_MedRevive_Text: sundayText
		{
			idc = 6006;
			text = "Enable revive?";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Enable ACE revive system? This will disable the revive system included in the mission. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedRevive_Select: DROCombo
		{
			idc = 6007;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.52 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medenableRevive = (_this select 1); publicVariable 'ACE_medenableRevive'; profileNamespace setVariable ['DRO_ACE_medenableRevive', (_this select 1)];";
		};
		class sundayACE_MedTime_Text: sundayText
		{
			idc = 6008;
			text = "Bleedout Time: 120 Seconds";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Time you can be unconscious before dying. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedTime_Slider: sundaySlider
		{
			idc = 6009;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.58 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_rounded = round(_this select 1); ((findDisplay 52525) displayCtrl 6008) ctrlSetText format ['Bleedout Time: %1 Seconds', _rounded]; ACE_medmaxReviveTime = _rounded; publicVariable 'ACE_medmaxReviveTime'; profileNamespace setVariable ['DRO_ACE_medmaxReviveTime', _rounded];";
		};
		class sundayACE_MedLives_Text: sundayText
		{
			idc = 6010;
			text = "Revive Lives: 0";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.60 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Amount of times you can be revived before dying. 0 will give an infinite amount of revives. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedLives_Slider: sundaySlider
		{
			idc = 6011;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.64 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_rounded = round(_this select 1); ((findDisplay 52525) displayCtrl 6010) ctrlSetText format ['Revive Lives: %1', _rounded]; ACE_medamountOfReviveLives = _rounded; publicVariable 'ACE_medamountOfReviveLives'; profileNamespace setVariable ['DRO_ACE_medamountOfReviveLives', _rounded];";
		};
		class sundayACE_MedLevel_Text: sundayText
		{
			idc = 6012;
			text = "Player Medical Level";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.66 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "ACE Medical Level used by non-medics. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedLevel_Select: DROCombo
		{
			idc = 6013;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.70 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medLevel = (_this select 1); publicVariable 'ACE_medLevel'; profileNamespace setVariable ['DRO_ACE_medLevel', (_this select 1)];";
		};
		class sundayACE_MedMLevel_Text: sundayText
		{
			idc = 6014;
			text = "Medic Medical Level";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.72 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "ACE Medical Level used by medics. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedMLevel_Select: DROCombo
		{
			idc = 6015;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.76 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medmedicSetting = (_this select 1); publicVariable 'ACE_medmedicSetting'; profileNamespace setVariable ['DRO_ACE_medmedicSetting', (_this select 1)];";
		};
		class sundayACE_MedScreams_Text: sundayText
		{
			idc = 6016;
			text = "Enable Screams";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.78 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should injured units scream? Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedScreams_Select: DROCombo
		{
			idc = 6017;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.82 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medenableScreams = (_this select 1); publicVariable 'ACE_medenableScreams'; profileNamespace setVariable ['DRO_ACE_medenableScreams', (_this select 1)];";
		};
		class sundayACE_MedAIUncon_Text: sundayText
		{
			idc = 6018;
			text = "AI Unconsciousness";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.84 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should AI units fall unconscious? Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedAIUncon_Select: DROCombo
		{
			idc = 6019;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.88 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medenableUnconsciousnessAI = (_this select 1); publicVariable 'ACE_medenableUnconsciousnessAI'; profileNamespace setVariable ['DRO_ACE_medenableUnconsciousnessAI', (_this select 1)];";
		};
		class sundayACE_MedDeath_Text: sundayText
		{
			idc = 6020;
			text = "Allow Instant Death";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.90 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should instant death be allowed, or should players fall unconscious first? Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedDeath_Select: DROCombo
		{
			idc = 6021;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.94 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medpreventInstaDeath = (_this select 1); publicVariable 'ACE_medpreventInstaDeath'; profileNamespace setVariable ['DRO_ACE_medpreventInstaDeath', (_this select 1)];";
		};
		class sundayACE_MedBleeding_Text: sundayText
		{
			idc = 6022;
			text = "Bleeding Coefficient: 0.2";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.3 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Sets the speed at which blood is lost. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedBleeding_Slider: sundaySlider
		{
			idc = 6023;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.34 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 1)) / (10 ^ 1); ((findDisplay 52525) displayCtrl 6022) ctrlSetText format ['Bleeding Coefficient: %1', _rounded]; ACE_medbleedingCoefficient = _rounded; publicVariable 'ACE_medbleedingCoefficient'; profileNamespace setVariable ['DRO_ACE_medbleedingCoefficient', _rounded];";
		};
		class sundayACE_MedPain_Text: sundayText
		{
			idc = 6024;
			text = "Pain Coefficient: 1";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.36 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Sets the speed at which pain is gained. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedPain_Slider: sundaySlider
		{
			idc = 6025;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.4 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onSliderPosChanged = "_mult = ((_this select 1)/10); _rounded = round (_mult * (10 ^ 1)) / (10 ^ 1); ((findDisplay 52525) displayCtrl 6024) ctrlSetText format ['Pain Coefficient: %1', _rounded]; ACE_medpainCoefficient = _rounded; publicVariable 'ACE_medpainCoefficient'; profileNamespace setVariable ['DRO_ACE_medpainCoefficient', _rounded];";
		};
		class sundayACE_MedWounds_Text: sundayText
		{
			idc = 6026;
			text = "Advanced Wounds";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.42 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should wounds reopen and require stitching? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedWounds_Select: DROCombo
		{
			idc = 6027;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.46 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medenableAdvancedWounds = (_this select 1); publicVariable 'ACE_medenableAdvancedWounds'; profileNamespace setVariable ['DRO_ACE_medenableAdvancedWounds', (_this select 1)];";
		};
		class sundayACE_MedPAK_Text: sundayText
		{
			idc = 6028;
			text = " Who can use PAKs";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.48 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should PAKs be available to everyone or just Medics? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedPAK_Select: DROCombo
		{
			idc = 6029;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.52 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medmedicSetting_PAK = (_this select 1); publicVariable 'ACE_medmedicSetting_PAK'; profileNamespace setVariable ['DRO_ACE_medmedicSetting_PAK', (_this select 1)];";
		};
		class sundayACE_MedPAKConsume_Text: sundayText
		{
			idc = 6030;
			text = "Consume PAK on use";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.54 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should PAKs be consumed on use? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedPAKConsume_Select: DROCombo
		{
			idc = 6031;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.58 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medconsumeItem_PAK = (_this select 1); publicVariable 'ACE_medconsumeItem_PAK'; profileNamespace setVariable ['DRO_ACE_medconsumeItem_PAK', (_this select 1)];";
		};
		class sundayACE_MedSKit_Text: sundayText
		{
			idc = 6032;
			text = " Who can use Surgical Kits";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.6 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should Surgical Kits be available to everyone or just Medics? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedSKit_Select: DROCombo
		{
			idc = 6033;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.64 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medmedicSetting_SurgicalKit = (_this select 1); publicVariable 'ACE_medmedicSetting_SurgicalKit'; profileNamespace setVariable ['DRO_ACE_medmedicSetting_SurgicalKit', (_this select 1)];";
		};
		class sundayACE_MedSKitConsume_Text: sundayText
		{
			idc = 6034;
			text = "Consume Surgical Kits on use";
			x = -0.2 * safezoneW + safezoneX;
			y = 0.66 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 0.044 * safezoneH;
			tooltip = "Should Surgical Kits be consumed on use? Applies to Advanced Medical only. Will not be used if ACE Medical is not installed.";
		};
		class sundayACE_MedSKitConsume_Select: DROCombo
		{
			idc = 6035;
			x = -0.2 * safezoneW + safezoneX;
			y = 0.7 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			onLBSelChanged = "ACE_medconsumeItem_SurgicalKit = (_this select 1); publicVariable 'ACE_medconsumeItem_SurgicalKit'; profileNamespace setVariable ['DRO_ACE_medconsumeItem_SurgicalKit', (_this select 1)];";
		};
	};

};
