timeOfDay = profileNamespace getVariable ["DRO_timeOfDay", 0];
publicVariable "timeOfDay";
month = profileNamespace getVariable ["DRO_month", 0];
publicVariable "month";
day = profileNamespace getVariable ["DRO_day", 0];
publicVariable "day";
weatherOvercast = profileNamespace getVariable ["DRO_weatherOvercast", "RANDOM"];
publicVariable "weatherOvercast";
animalsEnabled = profileNamespace getVariable ['DRO_animalsEnabled', 0];
publicVariable "animalsEnabled";
aiSkill = profileNamespace getVariable ["DRO_aiSkill", 0];
publicVariable "aiSkill";
aiMultiplier = profileNamespace getVariable ["DRO_aiMultiplier", 1];
publicVariable "aiMultiplier";
numObjectives = profileNamespace getVariable ["DRO_numObjectives", 0];
publicVariable "numObjectives";
preferredObjectives = profileNamespace getVariable ["DRO_objectivePrefs", []];
publicVariable "preferredObjectives";
aoOptionSelect = profileNamespace getVariable ["DRO_aoOptionSelect", 0];
publicVariable "aoOptionSelect";
minesEnabled = profileNamespace getVariable ["DRO_minesEnabled", 0];
publicVariable "minesEnabled";
civiliansEnabled = profileNamespace getVariable ["DRO_civiliansEnabled", 0];
publicVariable "civiliansEnabled";
stealthEnabled = profileNamespace getVariable ["DRO_stealthEnabled", 0];
publicVariable "stealthEnabled";
reviveDisabled = profileNamespace getVariable ["DRO_reviveDisabled", 0];
publicVariable "reviveDisabled";
missionPreset = profileNamespace getVariable ["DRO_missionPreset", 0];
publicVariable "missionPreset";
insertType = profileNamespace getVariable ["DRO_insertType", 0];
publicVariable "insertType";
randomSupports = profileNamespace getVariable ["DRO_randomSupports", 0];
publicVariable "randomSupports";
customSupports = profileNamespace getVariable ["DRO_supportPrefs", []];
publicVariable "customSupports";
diag_log "DRO: variables loaded from profile";

//ACE Variables
ACE_repengineerSetting_Repair = profileNamespace getVariable ["DRO_ACE_repengineerSetting_Repair", 0];
publicVariable "ACE_repengineerSetting_Repair";
ACE_repconsumeItem_ToolKit = profileNamespace getVariable ["DRO_ACE_repconsumeItem_ToolKit", 0];
publicVariable "ACE_repconsumeItem_ToolKit";
ACE_repwheelRepairRequiredItems = profileNamespace getVariable ["DRO_ACE_repwheelRepairRequiredItems", 0];
publicVariable "ACE_repwheelRepairRequiredItems";
ACE_medenableRevive = profileNamespace getVariable ["DRO_ACE_medenableRevive", 1];
publicVariable "ACE_medenableRevive";
ACE_medmaxReviveTime = profileNamespace getVariable ["DRO_ACE_medmaxReviveTime", 300];
publicVariable "ACE_medmaxReviveTime";
ACE_medamountOfReviveLives = profileNamespace getVariable ["DRO_ACE_medamountOfReviveLives", 0];
publicVariable "ACE_medamountOfReviveLives";
ACE_medLevel = profileNamespace getVariable ["DRO_ACE_medLevel", 0];
publicVariable "ACE_medLevel";
ACE_medmedicSetting = profileNamespace getVariable ["DRO_ACE_medmedicSetting", 1];
publicVariable "ACE_medmedicSetting";
ACE_medenableScreams = profileNamespace getVariable ["DRO_ACE_medenableScreams", 0];
publicVariable "ACE_medenableScreams";
ACE_medenableUnconsciousnessAI = profileNamespace getVariable ["DRO_ACE_medenableUnconsciousnessAI", 0];
publicVariable "ACE_medenableUnconsciousnessAI";
ACE_medpreventInstaDeath = profileNamespace getVariable ["DRO_ACE_medpreventInstaDeath", 1];
publicVariable "ACE_medpreventInstaDeath";
ACE_medbleedingCoefficient = profileNamespace getVariable ["DRO_ACE_medbleedingCoefficient", 2];
publicVariable "ACE_medbleedingCoefficient";
ACE_medpainCoefficient = profileNamespace getVariable ["DRO_ACE_medpainCoefficient", 10];
publicVariable "ACE_medpainCoefficient";
ACE_medenableAdvancedWounds = profileNamespace getVariable ["DRO_ACE_medenableAdvancedWounds", 0];
publicVariable "ACE_medenableAdvancedWounds";
ACE_medmedicSetting_PAK = profileNamespace getVariable ["DRO_ACE_medmedicSetting_PAK", 0];
publicVariable "ACE_medmedicSetting_PAK";
ACE_medconsumeItem_PAK = profileNamespace getVariable ["DRO_ACE_medconsumeItem_PAK", 0];
publicVariable "ACE_medconsumeItem_PAK";
ACE_medmedicSetting_SurgicalKit = profileNamespace getVariable ["DRO_ACE_medmedicSetting_SurgicalKit", 0];
publicVariable "ACE_medmedicSetting_SurgicalKit";
ACE_medconsumeItem_SurgicalKit = profileNamespace getVariable ["DRO_ACE_medconsumeItem_SurgicalKit", 0];
publicVariable "ACE_medconsumeItem_SurgicalKit";
diag_log "DRO: ACE variables loaded from profile";
