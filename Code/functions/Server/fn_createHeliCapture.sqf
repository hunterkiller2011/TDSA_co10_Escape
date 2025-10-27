if(!isserver) exitwith {};

diag_log "A3E: Creating helicopter capture objective";

private _playerCount = count ([] call A3E_fnc_GetPlayers);
private _heliTypes = missionNamespace getVariable ["a3e_arr_heli_capture", []];

private _suitableHelis = [];
{
    private _heliType = _x select 0;
    private _heliSeats = _x select 1;
    if (_heliSeats >= _playerCount) then {
        _suitableHelis pushBack _x;
    };
} forEach _heliTypes;

if (count _suitableHelis == 0) then {
    diag_log "A3E: No suitable helicopter found for player count. Falling back to largest.";
    private _largestHeli = ["", 0];
    {
        if ((_x select 1) > (_largestHeli select 1)) then {
            _largestHeli = _x;
        };
    } forEach _heliTypes;
    if ((_largestHeli select 0) != "") then {
        _suitableHelis pushBack _largestHeli;
    };
};

if (count _suitableHelis > 0) then {
    private _heliInfo = selectRandom _suitableHelis;
    private _heliToSpawn = _heliInfo select 0;
    private _spawnPos = [];
    private _spawnPositions = []; // Array to store possible spawn positions
    private _maxAttempts = 10;  // Maximum number of attempts to find a suitable position
    private _positionFound = false;

    for "_i" from 1 to _maxAttempts do {
        _spawnPos = [] call a3e_fnc_findFlatArea; // Get a potential spawn position
        _spawnPositions pushBack _spawnPos;
    };

    { _spawnPos = _x;
        private _tooClose = false;
        {
            if (_spawnPos distance _x < 1500) then { // Increased distance
                _tooClose = true;
            };
        } forEach A3E_Var_ClearedPositions;

        if (!_tooClose) then {
            _positionFound = true;
            break; // Exit the loop if a suitable position is found
        };
    } forEach _spawnPositions;

    if (_positionFound) then {
        A3E_Var_ClearedPositions pushBack _spawnPos;

        private _heli = createVehicle [_heliToSpawn, _spawnPos, [], 0, "NONE"];
        _heli setDir (random 360);
        _heli setVehicleLock "LOCKED";
        _heli setFuel 0;

        // Spawn guards with scaled difficulty
        private _guardCount = 2;
        //switch (A3E_Param_EnemyFrequency) do {
        // {2,4,6,8,-1,-2,-3} {"Few (2-3)", "Some (3-5)", "Large (5-7)", "Max (7-9)","Players 1:0.5","Players 1:1","Players 1:1.5"};
        switch (A3E_Param_EnemyGroupSize) do {
            case 2: { _guardCount = 2 + floor (random 2); }; // 2-3 guards
            case 4: { _guardCount = 4 + floor (random 2); }; // 4-5 guards
            case 6: { _guardCount = 6 + floor (random 3); }; // 6-8 guards
            case 8: { _guardCount = 8 + floor (random 3); }; // 8-10 guards
            case -1: { _guardCount = round(_numPlayers*0.5); }; // Players 1:0.5 guards
            case -2: { _guardCount = round(_numPlayers*1); }; // Players 1:1 guards
            case -3: { _guardCount = round(_numPlayers*1.5); }; // Players 1:1.5 guards
            default { _guardCount = 6 + floor (random 3); }; // 6-8 guards
        };

        private _guardGroup = createGroup A3E_VAR_Side_Ind;
        for "_i" from 1 to _guardCount do { 
            private _guardPos = [_spawnPos, 25, 60] call BIS_fnc_findSafePos;
            private _unit = _guardGroup createUnit [(selectRandom a3e_arr_Escape_InfantryTypes), _guardPos, [], 0, "FORM"];
            _unit setSkill (a3e_var_Escape_enemyMinSkill + random (a3e_var_Escape_enemyMaxSkill - a3e_var_Escape_enemyMinSkill));
        };

        // Set marker
        private _taskID = "A3E_Task_CaptureHeli_" + str (round (random 1000));
        [_taskID,_heli,"o_air"] call A3E_fnc_createLocationMarker;
        _marker = createMarkerLocal [_taskID,_heli,"o_air"];
        _marker setMarkerShapeLocal "ELLIPSE";
        _marker setMarkerAlphaLocal 0;
        _marker setMarkerSizeLocal [50, 50];

        // Trigger to complete the task
        private _trigger = createTrigger ["EmptyDetector", getPos _heli, false];
        _trigger setTriggerActivation ["ANYPLAYER", "PRESENT", true];
        _trigger setTriggerArea [20, 20, 0, false];
        _trigger setVariable ["heliToCheck", _heli];
        _trigger setTriggerStatements [
            "this && (locked (thisTrigger getVariable 'heliToCheck')) != 1",
            "(thisTrigger getVariable 'heliToCheck') setVehicleLock ""UNLOCKED""; deleteVehicle thisTrigger;",
            ""
        ];

        diag_log format ["A3E: Helicopter capture objective created at %1 with helicopter %2", _spawnPos, _heliToSpawn];
    } else {
        diag_log "A3E: Could not find a suitable spawn position for helicopter capture objective.";
    };
} else {
    diag_log "A3E: No helicopters defined for helicopter capture objective.";
}; 