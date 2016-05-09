private['_ZCP_CDG_minDefenderLaunchers','_ZCP_CDG_launchers','_ZCP_CDG_minWaveLaunchers','_ZCP_CDG_aiType','_ZCP_CDG_spawnAIPos','_ZCP_CDG_unitsPerGroup','_ZCP_CDG_dificulty',
'_ZCP_CDG_solierType','_ZCP_CDG_side', '_ZCP_CDG_groupAI','_ZCP_CDG_launcherType','_ZCP_CDG_maxDefenderLaunchers','_ZCP_CDG_maxWaveLaunchers'];
_ZCP_CDG_spawnAIPos = _this select 0;
_ZCP_CDG_unitsPerGroup = _this select 1;
_ZCP_CDG_dificulty = _this select 2;
_ZCP_CDG_solierType = _this select 3;
_ZCP_CDG_side = _this select 4;
_ZCP_CDG_minDefenderLaunchers = _this select 5;
_ZCP_CDG_maxDefenderLaunchers = _this select 6;
_ZCP_CDG_minWaveLaunchers = _this select 7;
_ZCP_CDG_maxWaveLaunchers = _this select 8;
_ZCP_CDG_aiType = _this select 9;

_ZCP_CDG_minLaunchers = 0;
_ZCP_CDG_maxLaunchers = 0;

switch (_ZCP_CDG_aiType) do {
    case 'WAVE': {
        _ZCP_CDG_minLaunchers = _ZCP_CDG_minWaveLaunchers;
        _ZCP_CDG_maxLaunchers = _ZCP_CDG_maxWaveLaunchers;
    };
    case 'DEFEND': {
        _ZCP_CDG_minLaunchers = _ZCP_CDG_minDefenderLaunchers;
        _ZCP_CDG_maxLaunchers = _ZCP_CDG_maxDefenderLaunchers;
    };
};

diag_log format['ZCP: Spawning %1 AI for cappoint.', _ZCP_CDG_unitsPerGroup];

_ZCP_CDG_groupAI = createGroup _ZCP_CDG_side;

_ZCP_CDG_groupAI setVariable ["DMS_LockLocality",nil];
_ZCP_CDG_groupAI setVariable ["DMS_SpawnedGroup",true];
_ZCP_CDG_groupAI setVariable ["DMS_Group_Side", EAST];


for "_i" from 1 to _ZCP_CDG_unitsPerGroup do {
  [_ZCP_CDG_groupAI, _ZCP_CDG_spawnAIPos, _ZCP_CDG_dificulty, _ZCP_CDG_solierType] call ZCP_fnc_createDMSSoldier;
};

// An AI will definitely spawn with a launcher if you define type
if (_ZCP_CDG_minLaunchers > 0) then
{
    _ZCP_CDG_launcherType = "AT";

	_ZCP_CDG_units = units _ZCP_CDG_groupAI;

	for "_i" from 0 to (((_ZCP_CDG_maxLaunchers min _ZCP_CDG_unitsPerGroup)-1) max 0) do
	{
		if ( _i < _ZCP_CDG_minLaunchers || ((random 100) < ZCP_AI_useLaunchersChance)) then
		{
			_ZCP_CDG_unit = _ZCP_CDG_units select _i;

			_ZCP_CDG_launcher = (selectRandom (missionNamespace getVariable [format ["DMS_AI_wep_launchers_%1",_ZCP_CDG_launcherType],["launch_NLAW_F"]]));

			removeBackpackGlobal _ZCP_CDG_unit;
			_ZCP_CDG_unit addBackpack "B_Carryall_mcamo";
			_ZCP_CDG_rocket = _ZCP_CDG_launcher call DMS_fnc_selectMagazine;

			[_ZCP_CDG_unit, _ZCP_CDG_launcher, DMS_AI_launcher_ammo_count,_ZCP_CDG_rocket] call BIS_fnc_addWeapon;

			_ZCP_CDG_unit setVariable ["DMS_AI_Launcher",_ZCP_CDG_launcher];

			//(format["SpawnAIGroup :: Giving %1 a %2 launcher with %3 %4 rockets",_ZCP_CDG_unit,_ZCP_CDG_launcher,DMS_AI_launcher_ammo_count,_ZCP_CDG_rocket]) call DMS_fnc_DebugLog;
		};
	};
};

_ZCP_CDG_groupAI selectLeader ((units _ZCP_CDG_groupAI) select 0);
_ZCP_CDG_groupAI setFormation "WEDGE";
_ZCP_CDG_groupAI setBehaviour "COMBAT";
_ZCP_CDG_groupAI setCombatMode "RED";

_ZCP_CDG_groupAI
