/*
	Created by Emperor.
    Patrol Boat for Escape missions.
    Debug markers added. look into Configuration section.
    Flares fired every 30s when player nearby (Optional) look into Configuration section.
    Optimized: adaptive sleep + flare randomization
	Put script to Scripts folder.
	This script uses existing PatrolBoatMarkers.sqf (a3e_patrolBoatMarkers) inside Island folder.
	UnitClasses.sqf (a3e_arr_Escape_InfantryTypes_Ind for boat crew and a3e_arr_AquaticPatrols for boat types inside of Units folder.
	Script should be executed in initServer.sqf with following code:
		call compile preprocessFileLineNumbers "Island\PatrolBoatMarkers.sqf";
		execVM "Scripts\spawnPatrolBoats.sqf";
*/

if (!isServer) exitWith {};
waitUntil { time > 0 };

// ===== CONFIGURATION =====
private _debugMarkers  = false;
private _enableFlares  = false;
private _flareType     = "F_40mm_Red";
private _flareInterval = 30;

// ===== VALIDATION =====
if (isNil "a3e_patrolBoatMarkers") exitWith {
    diag_log "[PatrolBoats] a3e_patrolBoatMarkers undefined.";
};

if (isNil "a3e_arr_AquaticPatrols" || {count a3e_arr_AquaticPatrols == 0}) exitWith {
    diag_log "[PatrolBoats] No boat classes defined.";
};

if (isNil "a3e_arr_Escape_InfantryTypes_Ind" || {count a3e_arr_Escape_InfantryTypes_Ind == 0}) exitWith {
    diag_log "[PatrolBoats] No infantry classes defined.";
};

diag_log format ["[PatrolBoats] Initializing %1 patrol zones", count a3e_patrolBoatMarkers];

/* =========================================================
    PER-MARKER AUTONOMOUS MANAGER
========================================================= */
{
    _x params ["_posATL", "_direction", "_shape", "_size"];

    if !(_shape isEqualTo "ELLIPSE") exitWith {
        diag_log "[PatrolBoats] Marker not ellipse, skipping.";
    };

    _size params ["_a", "_b"];

    [_posATL, _a, _b, _direction, _debugMarkers, _enableFlares, _flareType, _flareInterval] spawn {

        params ["_posATL", "_a", "_b", "_direction", "_debugMarkers", "_enableFlares", "_flareType", "_flareInterval"];

        private _activationRadius = 1000;
        private _despawnRadius    = 1400;
        private _despawnDelay     = 180;
        private _emptyTimer       = 0;

        private _boat  = objNull;
        private _group = grpNull;
        private _flareTimer = 0;

        /* ================= MAIN LOOP ================= */
        while {true} do {

            private _playersNear = {
                _x distance _posATL < _activationRadius
            } count allPlayers;

            /* ---------------- SPAWN ---------------- */
            if (_playersNear > 0 && {isNull _boat}) then {

                private _boatClass = selectRandom a3e_arr_AquaticPatrols;
                private _spawnPos = [];

                for "_i" from 1 to 10 do {

                    private _angle = random 360;
                    private _r = sqrt (random 1);

                    private _xLocal = (_a * _r) * cos _angle;
                    private _yLocal = (_b * _r) * sin _angle;

                    private _rotX = _xLocal * cos _direction - _yLocal * sin _direction;
                    private _rotY = _xLocal * sin _direction + _yLocal * cos _direction;

                    private _candidate = [
                        (_posATL#0) + _rotX,
                        (_posATL#1) + _rotY,
                        0
                    ];

                    _candidate = [_candidate, 0, 50, 6, 2, 0.5, 0] call BIS_fnc_findSafePos;

                    if !(_candidate isEqualTo []) exitWith {
                        _spawnPos = _candidate;
                    };
                };

                if (_spawnPos isEqualTo []) then { _spawnPos = _posATL };

                _boat = createVehicle [_boatClass, _spawnPos, [], 0, "NONE"];
                _boat setDir (random 360);
                _boat setPosASL _spawnPos;

                clearItemCargoGlobal _boat;
                clearWeaponCargoGlobal _boat;
                clearMagazineCargoGlobal _boat;
                clearBackpackCargoGlobal _boat;

                _group = createGroup independent;

                private _crewSlots = fullCrew [_boat, "", true];
                private _needed = (count _crewSlots) min 6;

                for "_i" from 1 to _needed do {
                    private _unitClass = selectRandom a3e_arr_Escape_InfantryTypes_Ind;
                    private _unit = _group createUnit [_unitClass, [0,0,100], [], 0, "NONE"];
                    _unit moveInAny _boat;
                    _unit allowFleeing 0;
                };

                if (isNull driver _boat) then {
                    private _driverClass = selectRandom a3e_arr_Escape_InfantryTypes_Ind;
                    private _driver = _group createUnit [_driverClass, [0,0,100], [], 0, "NONE"];
                    _driver moveInDriver _boat;
                };

                _group selectLeader driver _boat;
                _boat allowCrewInImmobile true;

                // IMPROVEMENT: AI engages enemies more aggressively
                _group setCombatMode "RED";
				_group enableAttack true;
				
				// AI detection improvement
				{
					_x setSkill ["spotDistance", 0.9];
					_x setSkill ["spotTime", 0.9];
				} forEach units _group;
				
                private _wpCount = 4 + floor random 4;

                for "_i" from 1 to _wpCount do {

                    private _wpPos = [];

                    for "_j" from 1 to 10 do {

                        private _angle = random 360;
                        private _r = sqrt (random 1);

                        private _xLocal = (_a * _r) * cos _angle;
                        private _yLocal = (_b * _r) * sin _angle;

                        private _rotX = _xLocal * cos _direction - _yLocal * sin _direction;
                        private _rotY = _xLocal * sin _direction + _yLocal * cos _direction;

                        private _candidate = [
                            (_posATL#0) + _rotX,
                            (_posATL#1) + _rotY,
                            0
                        ];

                        _candidate = [_candidate, 0, 80, 6, 2, 0.5, 0] call BIS_fnc_findSafePos;

                        if !(_candidate isEqualTo []) exitWith {
                            _wpPos = _candidate;
                        };
                    };

                    if (_wpPos isEqualTo []) then { _wpPos = _posATL };

                    private _wp = _group addWaypoint [_wpPos, 0];
                    _wp setWaypointType "MOVE";
                    _wp setWaypointSpeed "LIMITED";
                    _wp setWaypointBehaviour "AWARE";
                    _wp setWaypointFormation "COLUMN";
                    _wp setWaypointCompletionRadius 40;
                };

                private _cycle = _group addWaypoint [_posATL, 0];
                _cycle setWaypointType "CYCLE";

                diag_log "[PatrolBoats] Patrol boat spawned.";

                if (_debugMarkers) then {
                    private _markerName = format ["DEBUG_BOAT_%1", time];
                    private _mapMarker = createMarker [_markerName, getPos _boat];
                    _mapMarker setMarkerType "mil_unknown";
                    _mapMarker setMarkerColor "ColorRed";
                    _boat setVariable ["_debugMarker", _markerName];
                };
            };

            /* ---------------- FLARES ---------------- */
            if (!isNull _boat && {alive _boat} && {_enableFlares}) then {

                private _playersAlert = {
                    _x distance _posATL < 800
                } count allPlayers;

                if (_playersAlert > 0 && _flareTimer <= 0) then {

                    sleep random 2;

                    private _flarePos = (getPosASL _boat) vectorAdd [0,0,180];
                    private _flare = createVehicle [_flareType, _flarePos, [], 0, "NONE"];
                    _flare setVelocity [0,0,-10];

                    _flareTimer = _flareInterval;
                };

                _flareTimer = (_flareTimer - 1) max 0;
            };

            /* ---------------- DESPAWN ---------------- */
            private _loopSleep = if (isNull _boat) then {15} else {1};

            if (!isNull _boat) then {

                private _crewAlive = {alive _x} count units _group > 0;

                if (_crewAlive) then {

                    private _playersStillNear = {
                        _x distance _posATL < _despawnRadius
                    } count allPlayers;

                    if (_playersStillNear == 0) then {
                        _emptyTimer = _emptyTimer + _loopSleep;
                    } else {
                        _emptyTimer = 0;
                    };

                    if (_emptyTimer >= _despawnDelay) then {

                        if (_debugMarkers) then {
                            private _markerName = _boat getVariable ["_debugMarker", ""];
                            if (_markerName != "") then { deleteMarker _markerName; };
                        };

                        { deleteVehicle _x } forEach units _group;
                        deleteVehicle _boat;
                        deleteGroup _group;

                        _boat  = objNull;
                        _group = grpNull;
                        _emptyTimer = 0;

                        diag_log "[PatrolBoats] Patrol boat despawned.";
                    };
                };
            };

            sleep _loopSleep;
        };
    };

} forEach a3e_patrolBoatMarkers;

diag_log "[PatrolBoats] Autonomous patrol system active.";