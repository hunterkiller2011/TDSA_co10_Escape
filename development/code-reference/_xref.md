# Code Reference — Caller Cross-Reference Index (`_xref.md`)
_Last updated: 2026-06-30 (local)_ · _Status: generated (regenerable)_

> **Generated mechanical index** — for filling the **Called by** / **Calls** fields. For each
> function it lists every line where its `*_fnc_<Name>` token appears (direct calls *and*
> string registrations / trigger statements). Regenerate with `_tools/gen_xref.py`. Not hand-edited.

**How to read:** a function with **no references** is likely an entry point (auto-run via
postInit, scheduler, trigger, or event — see appendices) or dead code; verify. Names that map to
**multiple files** are flagged below — references can't be attributed to one file by this index.
Note: dynamic dispatch (`call compile format`, `call (missionNamespace getVariable ...)`) is
invisible here — see risks-tech-debt RD-006.

## Duplicate function names (same name, multiple files)

- `getsidecolor` -> `Code/functions/Common/fn_getSideColor.sqf`, `Code/functions/Helper/fn_getSideColor.sqf`
- `initvillagemarkers` -> `Code/functions/Common/fn_InitVillageMarkers.sqf`, `Code/functions/DRN/fn_InitVillageMarkers.sqf`, `Code/functions/Server/fn_InitVillageMarkers.sqf`
- `militarytraffic` -> `Code/functions/DRN/fn_MilitaryTraffic.sqf`, `Code/functions/Spawning/fn_MilitaryTraffic.sqf`

## AI

### AddStaticGunner  (`Code/functions/AI/fn_AddStaticGunner.sqf`)
- `Code/functions/Server/fn_RoadBlocks.sqf:95` - private _unit = ([_static,_side] call A3E_fnc_AddStaticGunner);
- `Code/functions/Templates/fn_AmmoDepot.sqf:183` - [_object,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot.sqf:214` - [_object,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:79` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:119` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:57` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:70` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:80` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:57` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:70` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:80` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:56` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:69` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:79` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_spe1.sqf:55` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_spe1.sqf:65` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_spe2.sqf:55` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_spe3.sqf:55` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_spe3.sqf:65` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:55` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:65` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:71` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:59` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:74` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:84` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter.sqf:269` - [_static,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter.sqf:276` - [_static,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter2.sqf:83` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter3.sqf:70` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter3.sqf:74` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter4.sqf:46` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter4.sqf:50` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter5.sqf:46` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter5.sqf:50` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_spe1.sqf:101` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_spe1.sqf:105` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_spe1.sqf:109` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_spe1.sqf:113` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_spe_ger1.sqf:97` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_spe_ger1.sqf:101` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_spe_ger1.sqf:105` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_nva1.sqf:52` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_nva1.sqf:56` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_nva2.sqf:56` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_nva2.sqf:60` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_us1.sqf:80` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_us1.sqf:84` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_us2.sqf:130` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildComCenter_vn_us2.sqf:134` - [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildMotorPool.sqf:47` - [_aaemplacement,east] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildMotorPool.sqf:568` - [_static,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildMotorPool_SPE.sqf:146` - [_static,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildMotorPool_SPE.sqf:156` - [_static,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_BuildMotorPool_VN.sqf:161` - [_static,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_MortarSite.sqf:39` - _gunner = [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_MortarSite2.sqf:39` - _gunner = [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_MortarSite_spe1.sqf:112` - _gunner = [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_MortarSite_vn_nva1.sqf:32` - _gunner = [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;
- `Code/functions/Templates/fn_MortarSite_vn_us1.sqf:32` - _gunner = [_obj,A3E_VAR_Side_Opfor] spawn A3E_fnc_AddStaticGunner;

### AquaticPatrol  (`Code/functions/AI/fn_AquaticPatrol.sqf`)
- `Code/functions/DRN/fn_PopulateAquaticPatrol.sqf:37` - _script = [_group, _markerName] spawn A3E_fnc_AquaticPatrol;

### CallCAS  (`Code/functions/AI/fn_CallCAS.sqf`)
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:87` - _strikesuccess = [_strikePos] call a3e_fnc_CallCAS;
- `Code/Scripts/Escape/SearchLeader.sqf:288` - _strikesuccess = [getpos (_list select 0)] call a3e_fnc_CallCAS;

### CivilianCommuter  (`Code/functions/AI/fn_CivilianCommuter.sqf`)
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:62` - [_group] spawn A3E_fnc_CivilianCommuter;

### EngageReportedGroup  (`Code/functions/AI/fn_EngageReportedGroup.sqf`)
- `Code/functions/AI/fn_RandomPatrolRoute.sqf:51` - _handle = [_group,_nearestPosition,A3E_Debug] spawn a3e_fnc_EngageReportedGroup;
- `Code/functions/AI/fn_RandomPatrolRoute.sqf:66` - _handle = [_group,_nearestPosition,A3E_Debug] spawn a3e_fnc_EngageReportedGroup;

### ExtractionBoat  (`Code/functions/AI/fn_ExtractionBoat.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### ExtractionCar  (`Code/functions/AI/fn_ExtractionCar.sqf`)
- `Code/functions/Server/fn_RunExtractionBoat.sqf:41` - [_boat1, getMarkerPos _extractionMarkerName,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionCar;
- `Code/functions/Server/fn_RunExtractionBoat.sqf:42` - [_boat2, getMarkerPos _extractionMarkerName2,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionCar;
- `Code/functions/Server/fn_RunExtractionCar.sqf:31` - [_car1, getMarkerPos _extractionMarkerName,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionCar;
- `Code/functions/Server/fn_RunExtractionCar.sqf:32` - [_car2, getMarkerPos _extractionMarkerName2,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionCar;

### ExtractionChopper  (`Code/functions/AI/fn_ExtractionChopper.sqf`)
- `Code/functions/Server/fn_RunExtraction.sqf:31` - [_boat1, getMarkerPos _extractionMarkerName,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionChopper;
- `Code/functions/Server/fn_RunExtraction.sqf:32` - [_boat2, getMarkerPos _extractionMarkerName2,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionChopper;
- `Code/functions/Server/fn_RunExtractionHeli.sqf:31` - [_boat1, getMarkerPos _extractionMarkerName,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionChopper;
- `Code/functions/Server/fn_RunExtractionHeli.sqf:32` - [_boat2, getMarkerPos _extractionMarkerName2,(_spawnVector vectorMultiply 5)] spawn A3E_fnc_ExtractionChopper;

### FireArtillery  (`Code/functions/AI/fn_FireArtillery.sqf`)
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:84` - _strikesuccess = [_strikePos] call a3e_fnc_FireArtillery;
- `Code/Scripts/Escape/SearchLeader.sqf:282` - //_strikesuccess = [getpos (_list select 0)] call a3e_fnc_FireArtillery;
- `Code/Scripts/Escape/SearchLeader.sqf:285` - _strikesuccess = [getpos (_list select 0)] call a3e_fnc_FireArtillery;

### Flee  (`Code/functions/AI/fn_Flee.sqf`)
- `Code/functions/AI/fn_CallCAS.sqf:25` - [_group,_fleepos] spawn a3e_fnc_Flee;
- `Code/functions/AI/fn_FireArtillery.sqf:40` - [_group,_fleepos] spawn a3e_fnc_Flee;

### GetTaskState  (`Code/functions/AI/fn_GetTaskState.sqf`)
- `Code/functions/AI/fn_OrderSearch.sqf:8` - _state = [_group] call a3e_fnc_GetTaskState;
- `Code/functions/Debug/fn_TrackGroup.sqf:19` - _text = [_group] call a3e_fnc_GetTaskState;
- `Code/functions/Debug/fn_TrackGroup_Update.sqf:29` - private _state = [_group] call a3e_fnc_GetTaskState;
- `Code/functions/Zones/fn_SerializeZoneGroups.sqf:60` - _ser set ["_taskstate",[_x] call A3E_fnc_GetTaskState];

### Guard  (`Code/functions/AI/fn_Guard.sqf`)
- `Code/functions/AI/fn_GuardBuilding.sqf:13` - _oncomplete = format["if(isserver) then {[group this,""%1""] spawn A3E_FNC_Guard;};",_markerName];
- `Code/functions/AI/fn_GuardBuilding.sqf:38` - [_group,_markerName] spawn A3E_fnc_Guard;
- `Code/functions/Spawning/fn_populateLocationZone.sqf:56` - [_grp, _marker] call A3E_fnc_Guard;

### GuardBuilding  (`Code/functions/AI/fn_GuardBuilding.sqf`)
- `Code/functions/AI/fn_Guard.sqf:18` - [_group,_markerName] spawn A3E_fnc_GuardBuilding;
- `Code/functions/Spawning/fn_populateLocationZone.sqf:58` - [_grp, _marker] call A3E_fnc_GuardBuilding;

### InCombat  (`Code/functions/AI/fn_InCombat.sqf`)
- `Code/functions/AI/fn_EngageReportedGroup.sqf:33` - if(!([_group] call A3E_fnc_InCombat)) then {
- `Code/functions/AI/fn_RandomPatrolRoute.sqf:35` - _in_combat = [_group] call A3E_fnc_InCombat;

### LeafletDrone  (`Code/functions/AI/fn_LeafletDrone.sqf`)
- `Code/Scripts/Escape/EscapeSurprises.sqf:314` - [_chopper, drn_searchAreaMarkerName, (5 + random 15), (5 + random 15), A3E_Debug] spawn A3E_fnc_LeafletDrone;

### Loiter  (`Code/functions/AI/fn_Loiter.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### MilitaryTrafficPatrol  (`Code/functions/AI/fn_MilitaryTrafficPatrol.sqf`)
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:59` - [_group] spawn A3E_fnc_MilitaryTrafficPatrol;

### move  (`Code/functions/AI/fn_move.sqf`)
- `Code/functions/AI/fn_AquaticPatrol.sqf:27` - _waypoint = [_group,_destinationPos,"MOVE","COLUMN","NORMAL","AWARE",_oncomplete] call a3e_fnc_move;
- `Code/functions/AI/fn_CivilianCommuter.sqf:17` - private _waypoint = [_group,_movePos,"MOVE","COLUMN","NORMAL","AWARE","[group this] spawn A3E_fnc_CivilianCommuter;"] call A3E_FNC_Move;
- `Code/functions/AI/fn_EngageReportedGroup.sqf:18` - [_group,_position] call a3e_fnc_move;
- `Code/functions/AI/fn_EngageReportedGroup.sqf:39` - [_group,_position] call a3e_fnc_move;
- `Code/functions/AI/fn_Flee.sqf:18` - _waypoint = [_group,_targetposition,"MOVE","LINE","FULL","AWARE",_oncomplete] call a3e_fnc_move;
- `Code/functions/AI/fn_Guard.sqf:43` - _waypoint = [_group,_destinationPos,"MOVE","COLUMN","LIMITED","SAFE",_oncomplete] call a3e_fnc_move;
- `Code/functions/AI/fn_GuardBuilding.sqf:31` - _waypoint = [_group,_movePos,"MOVE","COLUMN","LIMITED","SAFE",_oncomplete] call a3E_fnc_move;
- `Code/functions/AI/fn_MilitaryTrafficPatrol.sqf:17` - private _waypoint = [_group,_movePos,"MOVE","COLUMN","LIMITED","AWARE","[group this] spawn A3E_fnc_MilitaryTrafficPatrol;"] call A3E_FNC_Move;
- `Code/functions/AI/fn_Occupy.sqf:30` - _waypoint = [_group,_movePos,"MOVE","LINE","LIMITED","SAFE",_oncomplete] call a3E_fnc_move;
- `Code/functions/AI/fn_Patrol.sqf:55` - _waypoint = [_group,_destinationPos,"MOVE","COLUMN","LIMITED","SAFE",_oncomplete] call a3e_fnc_move;
- `Code/functions/AI/fn_PatrolBuildings.sqf:30` - _waypoint = [_group,_movePos,"MOVE","COLUMN","LIMITED","SAFE",_oncomplete] call a3E_fnc_move;
- `Code/functions/AI/fn_RandomPatrolRoute.sqf:94` - [_group,_destinationPos] call a3e_fnc_move;
- `Code/functions/AI/fn_Search.sqf:16` - _waypoint = [_group,_targetposition,"SAD","LINE","FULL","COMBAT",_oncomplete] call a3e_fnc_move;
- `Code/functions/AI/fn_Stroll.sqf:39` - _waypoint = [_group,_destinationPos,"MOVE","LINE","LIMITED","SAFE",_oncomplete] call a3e_fnc_move;

### MoveInBuilding  (`Code/functions/AI/fn_MoveInBuilding.sqf`)
- `Code/functions/AI/fn_GuardBuilding.sqf:28` - _waypoint = [_group,position _BuildingObject,_BuildingObject,_positionIndex,"MOVE","COLUMN","LIMITED","SAFE",_oncomplete] call A3E_fnc_MoveInBuilding;
- `Code/functions/AI/fn_Occupy.sqf:27` - _waypoint = [_group,position _BuildingObject,_BuildingObject,_positionIndex,"MOVE","LINE","LIMITED","SAFE",_oncomplete] call A3E_fnc_MoveInBuilding;
- `Code/functions/AI/fn_PatrolBuildings.sqf:27` - _waypoint = [_group,position _BuildingObject,_BuildingObject,_positionIndex,"MOVE","COLUMN","LIMITED","SAFE",_oncomplete] call A3E_fnc_MoveInBuilding;

### Occupy  (`Code/functions/AI/fn_Occupy.sqf`)
- `Code/functions/AI/fn_Stroll.sqf:18` - [_group,_markerName] spawn A3E_fnc_Occupy;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:87` - [_grp] call A3E_FNC_OCCUPY;

### onEnemyDetected  (`Code/functions/AI/fn_onEnemyDetected.sqf`)
- `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf:6` - _group addEventHandler ["EnemyDetected", {_this call A3E_fnc_onEnemyDetected;}];
- `Code/functions/Spawning/fn_onEnemyGroupSpawn.sqf:5` - _grp addEventHandler ["EnemyDetected", {_this call A3E_fnc_onEnemyDetected;}];

### OrderSearch  (`Code/functions/AI/fn_OrderSearch.sqf`)
- `Code/functions/SearchLeader/fn_createKnownPosition.sqf:18` - //[_knownPosition] spawn a3e_fnc_OrderSearch;
- `Code/Scripts/Escape/SearchLeader.sqf:259` - [_knownPosition] spawn a3e_fnc_OrderSearch;

### Patrol  (`Code/functions/AI/fn_Patrol.sqf`)
- `Code/functions/AI/fn_Flee.sqf:14` - _oncomplete = "if(isserver) then {[group this] spawn a3e_fnc_Patrol;};";
- `Code/functions/AI/fn_Guard.sqf:40` - [_group] call A3E_fnc_Patrol;
- `Code/functions/AI/fn_PatrolBuildings.sqf:13` - _oncomplete = format["if(isserver) then {[group this,""%1""] spawn A3E_FNC_Patrol;};",_markerName];
- `Code/functions/AI/fn_PatrolBuildings.sqf:36` - [_group,_markerName] spawn A3E_fnc_Patrol;
- `Code/functions/AI/fn_Search.sqf:12` - _oncomplete = format["if(isserver) then {[group this] spawn a3e_fnc_Patrol;};"];
- `Code/functions/DRN/fn_AmbientInfantry.sqf:160` - _script = [_group, nil] spawn A3E_fnc_Patrol;
- `Code/functions/DRN/fn_PopulateLocation.sqf:65` - _script = [_group, _markerName] spawn A3E_fnc_Patrol;
- `Code/functions/DRN/fn_PopulateVillage.sqf:52` - _script = [_newGroup, _markerName] spawn A3E_fnc_Patrol;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:13` - [_x] call A3E_fnc_Patrol;
- `Code/functions/Server/fn_initServer.sqf:578` - [_guardGroup, _marker] spawn A3E_fnc_Patrol;
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:57` - [_grp, _marker] call A3E_fnc_Patrol;
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:79` - [_grp, _marker] call A3E_fnc_Patrol;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:58` - [_group] spawn A3E_fnc_Patrol;
- `Code/functions/Spawning/fn_populateVillageZone.sqf:48` - [_grp, _marker] call A3E_fnc_Patrol;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:75` - [_grp] call A3E_FNC_Patrol;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:79` - [_grp] call A3E_FNC_Patrol;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:95` - [_grp] call A3E_FNC_Patrol;

### PatrolBuildings  (`Code/functions/AI/fn_PatrolBuildings.sqf`)
- `Code/functions/AI/fn_Patrol.sqf:18` - [_group,_markerName] spawn A3E_fnc_PatrolBuildings;

### RandomPatrolRoute  (`Code/functions/AI/fn_RandomPatrolRoute.sqf`)
- `Code/functions/DRN/fn_PopulateLocation.sqf:62` - //_script = [_soldier, _markerName,false] spawn A3E_fnc_RandomPatrolRoute;

### resumeTask  (`Code/functions/AI/fn_resumeTask.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Search  (`Code/functions/AI/fn_Search.sqf`)
- `Code/functions/AI/fn_OrderSearch.sqf:19` - [_group,getposATL _position] spawn a3e_fnc_Search;
- `Code/functions/AI/fn_OrderSearch.sqf:23` - [_group,getposATL _position] spawn a3e_fnc_Search;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:48` - [_grp,getpos _kpos] call A3E_fnc_Search;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:107` - [_send,_pos] call A3E_fnc_Search;

### SearchDrone  (`Code/functions/AI/fn_SearchDrone.sqf`)
- `Code/Scripts/Escape/EscapeSurprises.sqf:288` - [_chopper, drn_searchAreaMarkerName, (5 + random 15), (5 + random 15), A3E_Debug] spawn A3E_fnc_SearchDrone;

### SeekShelter  (`Code/functions/AI/fn_SeekShelter.sqf`)
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:91` - [_grp] call A3E_FNC_SeekShelter;

### SetTaskState  (`Code/functions/AI/fn_SetTaskState.sqf`)
- `Code/functions/AI/fn_AquaticPatrol.sqf:9` - [_group,"PATROL"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_CivilianCommuter.sqf:23` - [_group,"COMMUTE"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_Flee.sqf:10` - [_group,"FLEE"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_Guard.sqf:23` - [_group,"GUARD"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_GuardBuilding.sqf:35` - [_group,"GARRISONED"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_MilitaryTrafficPatrol.sqf:23` - [_group,"VEHICLEPATROL"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_Occupy.sqf:33` - [_group,"OCCUPY"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_Patrol.sqf:23` - [_group,"PATROL"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_PatrolBuildings.sqf:33` - [_group,"PATROL BUILDINGS"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_Search.sqf:10` - [_group,"SAD"] call a3e_fnc_SetTaskState;
- `Code/functions/AI/fn_Stroll.sqf:23` - [_group,"STROLL"] call a3e_fnc_SetTaskState;

### spawnGarisson  (`Code/functions/AI/fn_spawnGarisson.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Stroll  (`Code/functions/AI/fn_Stroll.sqf`)
- `Code/functions/AI/fn_Occupy.sqf:13` - _oncomplete = format["if(isserver) then {[group this,""%1""] spawn A3E_FNC_STROLL;};",_markerName];
- `Code/functions/AI/fn_Occupy.sqf:36` - [_group,_markerName] spawn A3E_fnc_Stroll;
- `Code/functions/Spawning/fn_populateVillageZone.sqf:66` - [_grp, _marker] call A3E_fnc_Stroll;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:83` - [_grp] call A3E_FNC_Stroll;

## Chronos

### Chronos_Dispatch  (`Code/functions/Chronos/fn_Chronos_Dispatch.sqf`)
- `Code/functions/Chronos/fn_Chronos_Run.sqf:17` - [_x,_foreachindex] call a3e_fnc_chronos_dispatch;
- `Code/functions/Chronos/fn_Chronos_Run.sqf:20` - [_x,_foreachindex] call a3e_fnc_chronos_dispatch;

### Chronos_Init  (`Code/functions/Chronos/fn_Chronos_Init.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Chronos_Register  (`Code/functions/Chronos/fn_Chronos_Register.sqf`)
- `Code/functions/Server/fn_initServer.sqf:678` - //["A3E_FNC_AmbientAISpawn"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:679` - ["A3E_FNC_RoadBlocks"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:680` - ["A3E_FNC_AmbientPatrols"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:681` - ["A3E_FNC_MilitaryTraffic"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:682` - ["A3E_FNC_CivilianCommuters"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:683` - ["A3E_FNC_TrackGroup_Update"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initTraps.sqf:3` - ["A3E_fnc_updateTraps","call",5,false] call A3E_fnc_Chronos_Register;

### Chronos_Run  (`Code/functions/Chronos/fn_Chronos_Run.sqf`)
- `Code/functions/Chronos/fn_Chronos_Init.sqf:24` - _trigger setTriggerStatements["A3E_CronTick", "A3E_CronTick = false; [] call a3e_fnc_chronos_run;", "A3E_CronTick = true;"];

## Common

### addUserActions  (`Code/functions/Common/fn_addUserActions.sqf`)
- `Code/functions/Common/fn_initLocalPlayer.sqf:21` - [] call A3E_fnc_addUserActions;

### bootstrapEscape  (`Code/functions/Common/fn_bootstrapEscape.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### briefing  (`Code/functions/Common/fn_briefing.sqf`)
- `Code/functions/Common/fn_initLocalPlayer.sqf:7` - call A3E_FNC_Briefing;

### callRandomFunction  (`Code/functions/Common/fn_callRandomFunction.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:89` - [[_x, a3e_arr_Escape_AmmoDepot_StaticWeaponClasses, a3e_arr_Escape_AmmoDepot_ParkedVehicleClasses],_AmmoDepotTemplates] call A3E_fnc_callRandomFunction;
- `Code/functions/Server/fn_createComCenters.sqf:46` - [[_pos, _dir, a3e_arr_ComCenStaticWeapons, a3e_arr_ComCenParkedVehicles], _ComCenterTemplates] call A3E_fnc_callRandomFunction;
- `Code/functions/Server/fn_createMortarSites.sqf:95` - [[_x],_mortarSiteTemplates] call A3E_fnc_callRandomFunction;
- `Code/functions/Server/fn_createMotorPools.sqf:83` - a3e_arr_ComCenDefence_lightArmorClasses + a3e_arr_ComCenDefence_heavyArmorClasses],_MotorPoolTemplates] call A3E_fnc_callRandomFunction;

### CheckCampDistance  (`Code/functions/Common/fn_CheckCampDistance.sqf`)
- `Code/functions/Server/fn_SelectExtractionZone.sqf:16` - private _clear = [_pos,250,"all"] call A3E_fnc_CheckCampDistance;

### checkUnitClasses  (`Code/functions/Common/fn_checkUnitClasses.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### cleanupTerrain  (`Code/functions/Common/fn_cleanupTerrain.sqf`)
- `Code/functions/Templates/fn_AmmoDepot2.sqf:12` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot_spe1.sqf:20` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot_spe2.sqf:20` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot_spe3.sqf:20` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:20` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:20` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter.sqf:13` - [_centerPos,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter2.sqf:14` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter3.sqf:14` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter4.sqf:15` - [_center,40] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter5.sqf:15` - [_center,40] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter_spe1.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter_spe_ger1.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter_vn_nva1.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter_vn_nva2.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter_vn_us1.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildComCenter_vn_us2.sqf:17` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildMotorPool.sqf:75` - [_centerPos,50] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildMotorPool_SPE.sqf:52` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildMotorPool_VN.sqf:52` - [_center,50] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildPrison.sqf:10` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildPrison1.sqf:11` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildPrison2.sqf:12` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildPrison3.sqf:12` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildPrison4.sqf:12` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_BuildPrison5.sqf:12` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_Roadblock.sqf:7` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_Roadblock2.sqf:8` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_Roadblock3.sqf:8` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_Roadblock4.sqf:8` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_Roadblock_vn1.sqf:10` - [_center,25] call a3e_fnc_cleanupTerrain;
- `Code/functions/Templates/fn_Roadblock_vn2.sqf:10` - [_center,25] call a3e_fnc_cleanupTerrain;

### CompileGroupVar  (`Code/functions/Common/fn_CompileGroupVar.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### expandProbabilities  (`Code/functions/Common/fn_expandProbabilities.sqf`)
- `Code/functions/Server/fn_getRndEntryFromFaction.sqf:5` - _entries = _entry call a3e_fnc_expandProbabilities;

### findControl  (`Code/functions/Common/fn_findControl.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### findFlatArea  (`Code/functions/Common/fn_findFlatArea.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:22` - _pos = call A3E_fnc_findFlatArea;
- `Code/functions/Server/fn_CreateCrashSites.sqf:3` - private _pos = [] call A3E_fnc_findFlatArea;
- `Code/functions/Server/fn_createMortarSites.sqf:29` - _pos = call A3E_fnc_findFlatArea;
- `Code/functions/Server/fn_initServer.sqf:190` - A3E_StartPos = [] call a3e_fnc_findFlatArea;
- `Code/functions/Server/fn_initServer.sqf:192` - A3E_StartPos = [] call a3e_fnc_findFlatArea;
- `Code/functions/Server/fn_initServer.sqf:434` - private _pos = [] call A3E_fnc_findFlatArea;

### findFlatAreaNear  (`Code/functions/Common/fn_findFlatAreaNear.sqf`)
- `Code/functions/Common/fn_findFlatArea.sqf:56` - _final_pos =  _arg_vector call A3E_fnc_findFlatAreaNear;

### FireSmokeFX  (`Code/functions/Common/fn_FireSmokeFX.sqf`)
- `Code/functions/Templates/fn_CrashSite.sqf:40` - _fx remoteExec ["A3E_fnc_FireSmokeFX",0,true];

### getAssocArrayEntry  (`Code/functions/Common/fn_getAssocArrayEntry.sqf`)
- `Code/functions/Server/fn_getRndEntryFromFaction.sqf:12` - _allUnits append ([_factionArr,_x] call a3e_fnc_getAssocArrayEntry);
- `Code/functions/Server/fn_selectFaction.sqf:69` - if([_x,"FactionName"] call A3E_fnc_getAssocArrayEntry == _special) exitwith {_faction = _x;};

### GetEnemyCount  (`Code/functions/Common/fn_GetEnemyCount.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### getPlayerGroup  (`Code/functions/Common/fn_getPlayerGroup.sqf`)
- `Code/functions/Server/fn_createComCenters.sqf:71` - [[] call A3E_fnc_GetPlayerGroup, _comCenPositions, A3E_Param_EnemySpawnDistance, A3E_Param_EnemyFrequency] call drn_fnc_Escape_InitializeComCenArmor;
- `Code/functions/Server/fn_createMotorPools.sqf:78` - private _playergroup = [] call A3E_fnc_getPlayerGroup;
- `Code/functions/Server/fn_FindSpawnRoad.sqf:1` - private _referenceGroup = call A3E_fnc_getPlayerGroup;
- `Code/functions/Server/fn_firedNearExtraction.sqf:35` - private _pgrp = [] call A3E_fnc_getPlayerGroup;
- `Code/functions/Server/fn_initServer.sqf:211` - _playerGroup = [] call A3E_fnc_GetPlayerGroup;
- `Code/functions/Server/fn_initServer.sqf:258` - _playerGroup = [] call A3E_fnc_GetPlayerGroup;
- `Code/functions/Spawning/fn_initPatrolZone.sqf:47` - private _playerGroup = [] call a3e_fnc_getPlayerGroup;
- `Code/functions/Zones/fn_initZone.sqf:47` - private _playerGroup = [] call a3e_fnc_getPlayerGroup;
- `Code/Scripts/Escape/EscapeSurprises.sqf:350` - [call A3E_fnc_GetPlayerGroup, getPos _spawnSegment, A3E_VAR_Side_Opfor, a3e_arr_Escape_EnemyCivilianCarTypes, A3E_arr_recon_InfantryTypes, _enemyFrequency] e...
- `Code/Scripts/Escape/SearchLeader.sqf:116` - if (_enemyUnit == _nearestEnemy && _enemyUnit in (units (call A3E_fnc_GetPlayerGroup))) then {

### GetPlayers  (`Code/functions/Common/fn_GetPlayers.sqf`)
- `Code/functions/AI/fn_LeafletDrone.sqf:83` - if (({(_x distance _chopper)<200} count ([] call A3E_fnc_GetPlayers))>0) then {
- `Code/functions/AI/fn_onEnemyDetected.sqf:5` - if(!(_newTarget in ([]call A3E_Fnc_GetPlayers))) exitwith {};
- `Code/functions/AI/fn_Patrol.sqf:41` - _players = [] call A3E_fnc_GetPlayers;
- `Code/functions/Common/fn_getPlayerGroup.sqf:10` - } foreach (call A3E_fnc_GetPlayers);
- `Code/functions/Common/fn_getRandomPlayer.sqf:1` - private _players = call A3E_FNC_GetPlayers;
- `Code/functions/DRN/fn_MilitaryTraffic.sqf:218` - private _referenceUnits = [] call A3E_FNC_GetPlayers;
- `Code/functions/DRN/fn_MilitaryTraffic.sqf:405` - private _players = [] call A3E_FNC_GetPlayers;
- `Code/functions/Helper/fn_GetCircularSpawnPos.sqf:2` - private _list = [] call A3E_fnc_GetPlayers;
- `Code/functions/SearchLeader/fn_ReportToHQ.sqf:14` - private _players = [] call A3E_fnc_GetPlayers;
- `Code/functions/Server/fn_createLocationMarker.sqf:35` - _trigger triggerAttachVehicle [([] call A3E_FNC_getPlayers) select 0];
- `Code/functions/Server/fn_initPlayer.sqf:25` - private _players = [] call A3E_fnc_GetPlayers;
- `Code/functions/Server/fn_initServer.sqf:209` - waituntil{uisleep 1; count([] call A3E_FNC_GetPlayers)>0};
- `Code/functions/Server/fn_initServer.sqf:587` - } foreach call A3E_fnc_GetPlayers;
- `Code/functions/Server/fn_initServer.sqf:623` - } foreach call A3E_FNC_GetPlayers;
- `Code/functions/Server/fn_initServer.sqf:629` - //} foreach call A3E_fnc_GetPlayers;
- `Code/functions/Server/fn_initServer.sqf:644` - } foreach call A3E_fnc_GetPlayers;
- `Code/functions/Server/fn_initServer.sqf:668` - } foreach call A3E_fnc_GetPlayers;
- `Code/functions/Server/fn_initServer.sqf:673` - } foreach call A3E_fnc_GetPlayers;
- `Code/functions/Server/fn_missionFlow.sqf:51` - ((([] call A3E_fnc_GetPlayers) findIf {!(_x getVariable ["AT_Revive_isUnconscious",false]);}) == -1)
- `Code/functions/Server/fn_missionFlow.sqf:52` - OR 	((([] call A3E_fnc_GetPlayers) findIf {!(_x getVariable ["ACE_Revive_isUnconscious",false]);}) == -1)
- `Code/functions/Server/fn_RunExtraction.sqf:106` - while {{(_x in  _boat1) || (_x in _boat2)} count (call A3E_fnc_GetPlayers) != count(call A3E_fnc_GetPlayers)} do {
- `Code/functions/Server/fn_RunExtraction.sqf:130` - if({vehicle _x == _boat1 || vehicle _x == _boat2} count (call A3E_fnc_GetPlayers) == count (call A3E_fnc_GetPlayers)) then {
- `Code/functions/Server/fn_RunExtractionBoat.sqf:112` - while {{(_x in  _boat1) || (_x in _boat2) || (_x in _boat3)} count (call A3E_fnc_GetPlayers) != count(call A3E_fnc_GetPlayers)} do {
- `Code/functions/Server/fn_RunExtractionBoat.sqf:136` - if({vehicle _x == _boat1 || vehicle _x == _boat2 || vehicle _x == _boat3} count (call A3E_fnc_GetPlayers) == count (call A3E_fnc_GetPlayers)) then {
- `Code/functions/Server/fn_RunExtractionCar.sqf:102` - while {{(_x in  _car1) || (_x in _car2) || (_x in _car3)} count (call A3E_fnc_GetPlayers) != count(call A3E_fnc_GetPlayers)} do {
- `Code/functions/Server/fn_RunExtractionCar.sqf:126` - if({vehicle _x == _car1 || vehicle _x == _car2 || vehicle _x == _car3} count (call A3E_fnc_GetPlayers) == count (call A3E_fnc_GetPlayers)) then {
- `Code/functions/Server/fn_RunExtractionHeli.sqf:106` - while {{(_x in  _boat1) || (_x in _boat2)} count (call A3E_fnc_GetPlayers) != count(call A3E_fnc_GetPlayers)} do {
- `Code/functions/Server/fn_RunExtractionHeli.sqf:130` - if({vehicle _x == _boat1 || vehicle _x == _boat2} count (call A3E_fnc_GetPlayers) == count (call A3E_fnc_GetPlayers)) then {
- `Code/functions/Server/fn_updateTraps.sqf:1` - private _players = [] call A3E_fnc_getPlayers;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:7` - private _plist = [] call A3E_fnc_GetPlayers;
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:8` - private _plist = [] call A3E_fnc_GetPlayers;
- `Code/functions/Spawning/fn_getDynamicSquadsize.sqf:12` - private _numPlayers = count([] call A3E_fnc_GetPlayers);
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:8` - private _plist = [] call A3E_fnc_GetPlayers;
- `Code/functions/Statistics/fn_PingStatistics.sqf:7` - private _uri = "http://escape.anzp.de/track.php?event=ping&players="+str count(call A3E_fnc_getPlayers)+"&server="+serverName;
- `Code/Scripts/Escape/Functions.sqf:145` - } foreach call A3E_fnc_GetPlayers;
- `Code/Scripts/Escape/Functions.sqf:423` - private _players = [] call A3E_fnc_getPlayers;
- `Code/Scripts/Escape/SearchLeader.sqf:68` - if (side _x == civilian && {_x distance ((call A3E_fnc_GetPlayers) select 0) <300}) exitWith {
- `Code/Scripts/Escape/SearchLeader.sqf:135` - } foreach (call A3E_fnc_GetPlayers);
- `Code/Scripts/Escape/SearchLeader.sqf:148` - _detectedUnit = (call A3E_fnc_GetPlayers) select 0;

### getRandomPlayer  (`Code/functions/Common/fn_getRandomPlayer.sqf`)
- `Code/functions/AI/fn_LeafletDrone.sqf:91` - _position = getpos ([] call A3E_fnc_GetRandomPlayer);
- `Code/functions/Server/fn_FindSpawnRoad.sqf:7` - private _refUnit = vehicle (call A3E_fnc_getRandomPlayer);

### getSideColor  (`Code/functions/Common/fn_getSideColor.sqf`)
- `Code/functions/Debug/fn_TrackGroup.sqf:13` - _marker setmarkercolor ([side leader _group] call a3e_fnc_getSideColor);
- `Code/functions/Debug/fn_TrackGroup_Update.sqf:57` - //_umarker setmarkercolor ([side leader _group] call a3e_fnc_getSideColor);

### groupChat  (`Code/functions/Common/fn_groupChat.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### handleRating  (`Code/functions/Common/fn_handleRating.sqf`)
- `Code/functions/Common/fn_initLocalPlayer.sqf:39` - player addeventhandler["HandleRating","_this call A3E_FNC_handleRating;"];

### handleScore  (`Code/functions/Common/fn_handleScore.sqf`)
- `Code/functions/Server/fn_initPlayer.sqf:14` - _player addeventhandler["HandleScore","_this call A3E_FNC_handleScore;"];

### healAtBuilding  (`Code/functions/Common/fn_healAtBuilding.sqf`)
- `Code/functions/Common/fn_addUserActions.sqf:52` - "_this call A3E_fnc_HealAtBuilding;",

### hijack  (`Code/functions/Common/fn_hijack.sqf`)
- `Code/functions/Common/fn_addUserActions.sqf:41` - "_this call A3E_fnc_Hijack;",

### initArsenal  (`Code/functions/Common/fn_initArsenal.sqf`)
- `Code/functions/Templates/fn_AmmoDepot.sqf:315` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot.sqf:317` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:282` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:284` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:205` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:207` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:205` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:207` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:289` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:291` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_spe1.sqf:188` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_spe1.sqf:190` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_spe2.sqf:171` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_spe2.sqf:173` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_spe3.sqf:188` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_spe3.sqf:190` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:200` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:202` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:230` - _box call A3E_fnc_initArsenal;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:232` - _box call A3E_fnc_initArsenal;

### initLocalPlayer  (`Code/functions/Common/fn_initLocalPlayer.sqf`)
- `Code/functions/Common/fn_bootstrapEscape.sqf:42` - [] call a3e_fnc_initLocalPlayer;

### InitVillageMarkers  (`Code/functions/Common/fn_InitVillageMarkers.sqf`)
- `Code/functions/Server/fn_initServer.sqf:205` - [true] call A3E_fnc_InitVillageMarkers;

### KeyDown  (`Code/functions/Common/fn_KeyDown.sqf`)
- `Code/functions/Common/fn_initLocalPlayer.sqf:83` - (findDisplay 46) displayAddEventHandler ["keyDown", "_this call a3e_fnc_KeyDown"];
- `Code/Revive/functions/HSC/fn_createCam.sqf:34` - ATHSC_KeyDownHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call ATHSC_FNC_keydown;"];

### loadLocalClasses  (`Code/functions/Common/fn_loadLocalClasses.sqf`)
- `Code/functions/Server/fn_initServer.sqf:65` - call a3e_fnc_loadLocalClasses;

### RandomPatrolPos  (`Code/functions/Common/fn_RandomPatrolPos.sqf`)
- `Code/functions/AI/fn_Patrol.sqf:42` - _destinationPos = [_players,_searchRange] call a3e_fnc_RandomPatrolPos;
- `Code/functions/AI/fn_Patrol.sqf:49` - _destinationPos = [_players,_searchRange] call a3e_fnc_RandomPatrolPos;

### RandomSpawnPos  (`Code/functions/Common/fn_RandomSpawnPos.sqf`)
- `Code/functions/DRN/fn_AmbientInfantry.sqf:111` - _spawnPos = [units _referenceGroup, _minDistance, _maxSpawnDistance] call a3e_fnc_RandomSpawnPos;
- `Code/functions/Server/fn_updateTraps.sqf:30` - private _rndPos = [_players,_minSpawnDistance,_spawnDistance] call A3E_fnc_RandomSpawnPos;

### RotatePosition  (`Code/functions/Common/fn_RotatePosition.sqf`)
- `Code/functions/Templates/fn_AmmoDepot2.sqf:22` - _pos = [_center,_center vectorAdd [-10.2106,4.54272,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:28` - _pos = [_center,_center vectorAdd [-9.78967,6.03186,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:34` - _pos = [_center,_center vectorAdd [-5.52759,6.67126,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:40` - _pos = [_center,_center vectorAdd [4.57214,6.7522,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:46` - _pos = [_center,_center vectorAdd [-10.314,-6.51233,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:52` - _pos = [_center,_center vectorAdd [-10.6722,-1.05103,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:73` - _pos = [_center,_center vectorAdd [-2.90967,3.92102,0.000301838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:82` - _pos = [_center,_center vectorAdd [-11.0073,-8.27209,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:88` - _pos = [_center,_center vectorAdd [-12.5851,-5.17175,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:94` - _pos = [_center,_center vectorAdd [-11.0167,-4.33191,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:102` - _pos = [_center,_center vectorAdd [-12.5383,-7.54541,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:114` - _pos = [_center,_center vectorAdd [-11.7528,-6.52271,0.0750003],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:124` - _pos = [_center,_center vectorAdd [-5.54004,-9.3822,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:132` - _pos = [_center,_center vectorAdd [7.77478,-2.05566,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:138` - _pos = [_center,_center vectorAdd [9.48694,4.03503,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:144` - _pos = [_center,_center vectorAdd [9.79907,-3.88293,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:150` - _pos = [_center,_center vectorAdd [3.01978,-8.02002,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:157` - _pos = [_center,_center vectorAdd [4.15967,-5.37695,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:168` - //_pos = [_center,_center vectorAdd [-0.278687,-7.39478,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:208` - _pos = [_center,_center vectorAdd [-4.62939,-4.94458,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:260` - _pos = [_center,_center vectorAdd [-1.5481,-4.83618,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:319` - _pos = [_center,_center vectorAdd [-8.66211,-7.44202,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:390` - _pos = [_center,_center vectorAdd [-7.50476,-5.06494,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:440` - _pos = [_center,_center vectorAdd [-5.63904,-7.51245,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:487` - _pos = [_center,_center vectorAdd [-2.97229,-7.60938,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:508` - _pos = [_center,_center vectorAdd [4.53369,-9.31958,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:32` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot3.sqf:51` - _pos = [_center,_center vectorAdd [-5.27795,-15.8394,0.5],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:65` - _pos = [_center,_center vectorAdd [6.0531,12.4585,-0.00143909],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:75` - _pos = [_center,_center vectorAdd [3.42651,-6.48389,-0.00143814],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:129` - _pos = [_center,_center vectorAdd [0.276978,-2.48975,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:183` - /*_pos = [_center,_center vectorAdd [-0.655273,0.352539,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:244` - _pos = [_center,_center vectorAdd [0.492188,2.66211,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:317` - _pos = [_center,_center vectorAdd [-2.34912,-1.99658,-0.133212],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:369` - _pos = [_center,_center vectorAdd [-2.5105,2.38525,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:418` - _pos = [_center,_center vectorAdd [-0.764404,-4.57227,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:32` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot4.sqf:51` - _pos = [_center,_center vectorAdd [-7.52502,-19.5674,0.5],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:65` - _pos = [_center,_center vectorAdd [-14.3452,-5.09326,-0.00143909],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:75` - _pos = [_center,_center vectorAdd [15.0289,10.7007,-0.00143814],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:129` - /*		_pos = [_center,_center vectorAdd [-4.68042,-5.16992,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:183` - /*		_pos = [_center,_center vectorAdd [-4.46521,-0.0180664,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:243` - /*		_pos = [_center,_center vectorAdd [-5.61267,-2.32764,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:316` - _pos = [_center,_center vectorAdd [-7.30652,-4.67676,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:367` - /*		_pos = [_center,_center vectorAdd [-7.4679,-0.294922,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:415` - /*		_pos = [_center,_center vectorAdd [-5.82874,2.37256,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:31` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot5.sqf:50` - _pos = [_center,_center vectorAdd [26.1731,0.00830078,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:64` - _pos = [_center,_center vectorAdd [-7.66699,-5.83887,-0.00143909],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:74` - _pos = [_center,_center vectorAdd [-13.532,13.2534,-0.00143814],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:213` - /*		_pos = [_center,_center vectorAdd [1.90552,-0.259277,3.12652],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:267` - /*		_pos = [_center,_center vectorAdd [-15.1067,1.13428,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:327` - /*		_pos = [_center,_center vectorAdd [4.58655,-8.20313,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:399` - /*		_pos = [_center,_center vectorAdd [4.37134,-10.7197,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:450` - /*		_pos = [_center,_center vectorAdd [6.86023,-9.09326,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:499` - //_pos = [_center,_center vectorAdd [-14.5537,-1.21094,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot_spe1.sqf:34` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot_spe2.sqf:34` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot_spe3.sqf:34` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:34` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:34` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:53` - _pos = [_center,_center vectorAdd [3.81812,-15.0552,0.0258894],_rotation,89.9946] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:69` - _pos = [_center,_center vectorAdd [-12.8831,20.0786,0.262558],_rotation,319.998] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:79` - _pos = [_center,_center vectorAdd [8,-5.17139,2.10607],_rotation,90.03] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildComCenter.sqf:25` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1)], _rotateDir] call a3e_fnc_RotateP...
- `Code/functions/Templates/fn_BuildComCenter.sqf:43` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1)], _rotateDir] call a3e_fnc_RotateP...
- `Code/functions/Templates/fn_BuildComCenter2.sqf:20` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1), (_relativePos select 2)], _rotate...
- `Code/functions/Templates/fn_BuildComCenter3.sqf:20` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter4.sqf:21` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter5.sqf:21` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter_spe1.sqf:23` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter_spe_ger1.sqf:23` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter_vn_nva1.sqf:23` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter_vn_nva2.sqf:23` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter_vn_us1.sqf:23` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildComCenter_vn_us2.sqf:23` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_BuildMotorPool.sqf:37` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1)], _rotateDir] call a3e_fnc_RotateP...
- `Code/functions/Templates/fn_BuildMotorPool.sqf:68` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1)], _rotateDir] call a3e_fnc_RotateP...
- `Code/functions/Templates/fn_BuildMotorPool_SPE.sqf:27` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_centerPos select 2)], _rotateDir...
- `Code/functions/Templates/fn_BuildMotorPool_SPE.sqf:44` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1)], _rotateDir] call a3e_fnc_RotateP...
- `Code/functions/Templates/fn_BuildMotorPool_VN.sqf:27` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_centerPos select 2)], _rotateDir...
- `Code/functions/Templates/fn_BuildMotorPool_VN.sqf:44` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1)], _rotateDir] call a3e_fnc_RotateP...
- `Code/functions/Templates/fn_BuildPrison.sqf:12` - _pos = [_center,_center vectorAdd [random 2.0 - 1, random 2.0 -1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:16` - _pos = [_center,_center vectorAdd [-6.79578,8.24268,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:26` - _pos = [_center,_center vectorAdd [3.08691,7.09082,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:40` - _pos = [_center,_center vectorAdd [4,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:45` - _pos = [_center,_center vectorAdd [-4,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:50` - _pos = [_center,_center vectorAdd [0,4,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:55` - _pos = [_center,_center vectorAdd [0,-4,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:60` - _pos = [_center,_center vectorAdd [-6.69727,-3.16309,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:66` - _pos = [_center,_center vectorAdd [6.2594,6.38867,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:72` - _pos = [_center,_center vectorAdd [6.32532,2.89893,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:78` - _pos = [_center,_center vectorAdd [6.42505,-0.589844,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:84` - _pos = [_center,_center vectorAdd [-6.68982,-0.773926,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:91` - _pos = [_center,_center vectorAdd [6.57373,8.39502,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:98` - _pos = [_center,_center vectorAdd [-6.74756,2.68604,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:104` - _pos = [_center,_center vectorAdd [-6.78992,6.13916,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:110` - _pos = [_center,_center vectorAdd [-4.37268,7.43896,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:116` - _pos = [_center,_center vectorAdd [-6.92676,7.2876,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:122` - _pos = [_center,_center vectorAdd [-5.16956,7.34766,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:128` - _pos = [_center,_center vectorAdd [-6.68286,4.83301,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:134` - _pos = [_center,_center vectorAdd [-6.6814,1.29395,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:140` - _pos = [_center,_center vectorAdd [-2.61975,7.38037,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:146` - _pos = [_center,_center vectorAdd [-0.138062,7.29297,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:152` - _pos = [_center,_center vectorAdd [-2.60461,12.8789,-0.0299988],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:162` - _pos = [_center,_center vectorAdd [-1.12219,14.3564,0.244108],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:168` - _pos = [_center,_center vectorAdd [-3.68799,11.499,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:174` - _pos = [_center,_center vectorAdd [-3.63342,11.6113,0.513469],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:180` - _pos = [_center,_center vectorAdd [-1.24951,11.5718,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:186` - _pos = [_center,_center vectorAdd [-0.903931,7.43994,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:192` - _pos = [_center,_center vectorAdd [6.10034,7.51563,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:198` - _pos = [_center,_center vectorAdd [6.26306,5.08643,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:204` - _pos = [_center,_center vectorAdd [6.30688,1.56104,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:210` - _pos = [_center,_center vectorAdd [6.4397,-1.90332,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:216` - _pos = [_center,_center vectorAdd [-6.75391,-2.18457,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:222` - _pos = [_center,_center vectorAdd [-3.79163,-5.37305,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:228` - _pos = [_center,_center vectorAdd [-6.33545,-4.78223,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:234` - _pos = [_center,_center vectorAdd [-5.49976,-5.08545,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:240` - _pos = [_center,_center vectorAdd [-6.2915,-4.79785,2.65993],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:246` - _pos = [_center,_center vectorAdd [-5.9801,-6.18262,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:252` - _pos = [_center,_center vectorAdd [3.2251,-5.22949,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:258` - _pos = [_center,_center vectorAdd [-0.3125,-5.33887,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:264` - _pos = [_center,_center vectorAdd [1.40027,-5.37744,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:270` - _pos = [_center,_center vectorAdd [-1.9823,-5.39307,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:276` - _pos = [_center,_center vectorAdd [5.71082,-4.50049,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:282` - _pos = [_center,_center vectorAdd [4.8855,-5.01807,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:288` - _pos = [_center,_center vectorAdd [6.46252,-3.00098,1.33838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:294` - _pos = [_center,_center vectorAdd [5.85583,-4.71143,2.65993],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison.sqf:300` - _pos = [_center,_center vectorAdd [6.50574,-5.33691,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:13` - _pos = [_center,_center vectorAdd [4.0293,4.16406,0.173401],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:22` - _pos = [_center,_center vectorAdd [-3.67871,-0.154297,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:31` - _pos = [_center,_center vectorAdd [random 2.0 - 1, random 2.0 -1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:40` - _pos = [_center,_center vectorAdd [0.931641,5.20703,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:46` - _pos = [_center,_center vectorAdd [-0.561523,3.66406,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:52` - _pos = [_center,_center vectorAdd [3.58105,3.80859,0.887205],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:59` - _pos = [_center,_center vectorAdd [2.24414,5.75977,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:65` - _pos = [_center,_center vectorAdd [3.74707,4.28906,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:71` - _pos = [_center,_center vectorAdd [-4.00781,-4.13281,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:78` - _pos = [_center,_center vectorAdd [-0.22168,0.210938,-0.109428],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:85` - _pos = [_center,_center vectorAdd [2,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:90` - _pos = [_center,_center vectorAdd [-2,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:95` - _pos = [_center,_center vectorAdd [0,2,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:100` - _pos = [_center,_center vectorAdd [0,-2,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:106` - _pos = [_center,_center vectorAdd [-2.0166,2.1875,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:112` - _pos = [_center,_center vectorAdd [-5.49023,-1.12109,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:118` - _pos = [_center,_center vectorAdd [-5.58984,-2.23242,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:124` - _pos = [_center,_center vectorAdd [-3.7207,-3.66406,0.969697],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:131` - _pos = [_center,_center vectorAdd [0.390625,-3.39258,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:137` - _pos = [_center,_center vectorAdd [-1.17969,-4.92578,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:143` - _pos = [_center,_center vectorAdd [-4.20898,-3.9668,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:149` - _pos = [_center,_center vectorAdd [-2.62891,-5.40234,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:155` - _pos = [_center,_center vectorAdd [1.9043,-1.91211,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:161` - _pos = [_center,_center vectorAdd [3.46777,-0.371094,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:167` - _pos = [_center,_center vectorAdd [4.99512,1.15039,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:173` - _pos = [_center,_center vectorAdd [5.21094,2.78125,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison1.sqf:179` - _pos = [_center,_center vectorAdd [6.52441,1.85352,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:13` - _pos = [_center,_center vectorAdd [-0.40625,0.394531,-0.130976],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:22` - _pos = [_center,_center vectorAdd [4.6416,0.886719,0.173401],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:31` - _pos = [_center,_center vectorAdd [random 2.0 - 1, random 2.0 -1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:37` - _pos = [_center,_center vectorAdd [2,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:42` - _pos = [_center,_center vectorAdd [-2,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:47` - _pos = [_center,_center vectorAdd [0,2,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:52` - _pos = [_center,_center vectorAdd [0,-2,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:57` - _pos = [_center,_center vectorAdd [1.20801,-2.19336,0.372054],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:64` - _pos = [_center,_center vectorAdd [0.500977,4.58984,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:70` - _pos = [_center,_center vectorAdd [-3.74023,0.224609,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:76` - _pos = [_center,_center vectorAdd [3.70605,-0.212891,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:82` - _pos = [_center,_center vectorAdd [-0.59668,3.36328,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:88` - _pos = [_center,_center vectorAdd [1.82422,3.44531,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:94` - _pos = [_center,_center vectorAdd [3.40527,1.92383,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:100` - _pos = [_center,_center vectorAdd [2.17578,2.21875,0.372054],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:107` - _pos = [_center,_center vectorAdd [-5.06738,-1.04297,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:114` - _pos = [_center,_center vectorAdd [2.38574,-1.92578,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:120` - _pos = [_center,_center vectorAdd [-3.28711,-1.79688,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:126` - _pos = [_center,_center vectorAdd [-2.18652,-2.2207,0.434343],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:132` - _pos = [_center,_center vectorAdd [-1.67578,-3.29102,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:138` - _pos = [_center,_center vectorAdd [-0.424805,-4.54297,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison2.sqf:144` - _pos = [_center,_center vectorAdd [0.693359,-3.39453,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:14` - _pos = [_center,_center vectorAdd [-1.49219,1.73438,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:23` - _pos = [_center,_center vectorAdd [6.80078,2.24219,0.173401],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:32` - _pos = [_center,_center vectorAdd [random 2.0 - 1, random 2.0 -1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:40` - _pos = [_center,_center vectorAdd [0.0830078,3.98438,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:46` - _pos = [_center,_center vectorAdd [-3.7832,-0.046875,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:52` - _pos = [_center,_center vectorAdd [-1.08496,1.14844,-0.180135],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:59` - _pos = [_center,_center vectorAdd [1,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:64` - _pos = [_center,_center vectorAdd [-1,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:69` - _pos = [_center,_center vectorAdd [0,1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:74` - _pos = [_center,_center vectorAdd [0,-1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:79` - _pos = [_center,_center vectorAdd [1.63184,5.52539,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:85` - _pos = [_center,_center vectorAdd [2.96387,5.19141,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:91` - _pos = [_center,_center vectorAdd [1.9209,7.00195,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:97` - _pos = [_center,_center vectorAdd [4.33887,3.79297,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:103` - _pos = [_center,_center vectorAdd [5.70605,2.40234,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:110` - _pos = [_center,_center vectorAdd [5.03711,0.808594,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:116` - _pos = [_center,_center vectorAdd [1.90137,-2.31055,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:122` - _pos = [_center,_center vectorAdd [-5.30078,-1.60547,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:128` - _pos = [_center,_center vectorAdd [-5.33008,-2.66992,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:134` - _pos = [_center,_center vectorAdd [-6.90527,-2.63086,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:141` - _pos = [_center,_center vectorAdd [0.40332,-3.78906,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:147` - _pos = [_center,_center vectorAdd [-3.95605,-4.04102,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:153` - _pos = [_center,_center vectorAdd [-2.57715,-5.4043,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:159` - _pos = [_center,_center vectorAdd [-1.0957,-5.26367,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:165` - _pos = [_center,_center vectorAdd [-1.67676,-6.93164,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison3.sqf:171` - _pos = [_center,_center vectorAdd [3.42969,-0.777344,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:13` - _pos = [_center,_center vectorAdd [-4.59277,-1.16406,-0.334344],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:22` - _pos = [_center,_center vectorAdd [0.275391,-1.38867,-0.0868696],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:32` - _pos = [_center,_center vectorAdd [random 2.0 - 1, random 2.0 -1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:41` - _pos = [_center,_center vectorAdd [-2.47168,-2.63281,0.207744],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:48` - _pos = [_center,_center vectorAdd [-3.55273,-2.10352,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:54` - _pos = [_center,_center vectorAdd [-2.70313,0.755859,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:60` - _pos = [_center,_center vectorAdd [-4.22168,-0.585938,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:67` - _pos = [_center,_center vectorAdd [1.28223,5.04492,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:74` - _pos = [_center,_center vectorAdd [1,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:79` - _pos = [_center,_center vectorAdd [-1,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:84` - _pos = [_center,_center vectorAdd [0,1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:89` - _pos = [_center,_center vectorAdd [0,-1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:94` - _pos = [_center,_center vectorAdd [-1.27832,2.25391,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:100` - _pos = [_center,_center vectorAdd [0.262695,3.81445,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:106` - _pos = [_center,_center vectorAdd [4.47852,0.705078,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:112` - _pos = [_center,_center vectorAdd [2.25098,3.69531,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:118` - _pos = [_center,_center vectorAdd [3.7334,2.18945,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:124` - _pos = [_center,_center vectorAdd [0.635742,-2.53125,0.680808],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:131` - _pos = [_center,_center vectorAdd [1.55078,-2.13672,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:137` - _pos = [_center,_center vectorAdd [3.0498,-0.957031,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:144` - _pos = [_center,_center vectorAdd [-2.02734,-3.68945,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:150` - _pos = [_center,_center vectorAdd [0.192383,-3.68555,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison4.sqf:156` - _pos = [_center,_center vectorAdd [-1.01465,-4.86914,-0.0161617],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:14` - _pos = [_center,_center vectorAdd [-1.7373,0.169922,-0.138047],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:23` - _pos = [_center,_center vectorAdd [0.420898,4.25977,-0.318182],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:32` - _pos = [_center,_center vectorAdd [random 2.0 - 1, random 2.0 -1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:40` - _pos = [_center,_center vectorAdd [-1.97363,1.90625,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:46` - _pos = [_center,_center vectorAdd [1,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:51` - _pos = [_center,_center vectorAdd [-1,0,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:56` - _pos = [_center,_center vectorAdd [0,1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:61` - _pos = [_center,_center vectorAdd [0,-1,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:67` - _pos = [_center,_center vectorAdd [1.72363,3.03906,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:73` - _pos = [_center,_center vectorAdd [-3.30664,0.273438,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:79` - _pos = [_center,_center vectorAdd [2.96289,-0.701172,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:85` - _pos = [_center,_center vectorAdd [3.10449,1.62109,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:91` - _pos = [_center,_center vectorAdd [4.22461,0.443359,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:97` - _pos = [_center,_center vectorAdd [-1.73633,-3.25,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:103` - _pos = [_center,_center vectorAdd [-0.151367,-3.79297,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:109` - _pos = [_center,_center vectorAdd [-0.351563,-4.73633,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:116` - _pos = [_center,_center vectorAdd [-2.76563,-2.06055,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_BuildPrison5.sqf:122` - _pos = [_center,_center vectorAdd [1.42285,-2.27148,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_isoTemplateRestore.sqf:65` - private _realPos = [_center,_center vectorAdd _pos,_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_isoTemplateRestore.sqf:68` - _realPos = [_parpos,_parpos vectorAdd _pos,_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock.sqf:12` - _pos = [_center,_center vectorAdd [-1.19421,-9.90234,0.000301838],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock.sqf:20` - _pos = [_center,_center vectorAdd [6.06116,-3.30908,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock.sqf:29` - _pos = [_center,_center vectorAdd [6.75,-1.3,2.75],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock.sqf:37` - _pos = [_center,_center vectorAdd [-4.17871,-2.42529,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock.sqf:44` - _pos = [_center,_center vectorAdd [-4.18518,-2.42969,1.29559],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock.sqf:51` - _pos = [_center,_center vectorAdd [-4.33887,4.98438,-0.200378],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock.sqf:59` - _pos = [_center,_center vectorAdd [3.70532,5.08203,-0.222816],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock2.sqf:13` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_Roadblock2.sqf:48` - private _pos = [_center,_center vectorAdd [6.15918,0.396851,-0.0121169],_rotation] call A3E_FNC_RotatePosition;
- `Code/functions/Templates/fn_Roadblock2.sqf:53` - private _pos = [_center,_center vectorAdd [-9.58679,0.108887,0.0323153],_rotation] call A3E_FNC_RotatePosition;
- `Code/functions/Templates/fn_Roadblock3.sqf:14` - _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], _rotateD...
- `Code/functions/Templates/fn_Roadblock3.sqf:53` - private _pos = [_center,_center vectorAdd [6.4,2.8,2.7],_rotation] call A3E_FNC_RotatePosition;
- `Code/functions/Templates/fn_Roadblock3.sqf:60` - private _pos = [_center,_center vectorAdd [-7.81958,3.0061,0.0331655],_rotation] call A3E_FNC_RotatePosition;
- `Code/functions/Templates/fn_Roadblock4.sqf:12` - private _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], ...
- `Code/functions/Templates/fn_Roadblock4.sqf:73` - _pos = [_center,_center vectorAdd [13.554,-11.0762,2.78144],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock4.sqf:81` - private _pos = [_center,_center vectorAdd [3.79742,36.481,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock4.sqf:121` - _pos = [_center,_center vectorAdd [-11.7788,3.81836,0],_rotation] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock_vn1.sqf:14` - private _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], ...
- `Code/functions/Templates/fn_Roadblock_vn1.sqf:37` - _pos = [_center,_center vectorAdd [8.46472,-1.87305,2.6839],_rotation,179.999] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock_vn1.sqf:44` - private _pos = [_center,_center vectorAdd [-7.31128,-0.212402,0.0184898],_rotation,180.257] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock_vn2.sqf:14` - private _realPos = ([_centerPos, [(_centerPos select 0) + (_relativePos select 0), (_centerPos select 1) + (_relativePos select 1),(_relativePos select 2)], ...
- `Code/functions/Templates/fn_Roadblock_vn2.sqf:35` - _pos = [_center,_center vectorAdd [-7.47192,1.7417,4.32537],_rotation,180.002] call A3E_fnc_rotatePosition;
- `Code/functions/Templates/fn_Roadblock_vn2.sqf:42` - private _pos = [_center,_center vectorAdd [8.37781,3.98389,0.0170741],_rotation,188.858] call A3E_fnc_rotatePosition;

### systemChat  (`Code/functions/Common/fn_systemChat.sqf`)
- `Code/functions/Debug/fn_logMessage.sqf:22` - ["Log: "+ _msg + " "+str _types+" "+str _data] call a3e_fnc_systemChat;

### toggleEarplugs  (`Code/functions/Common/fn_toggleEarplugs.sqf`)
- `Code/functions/Common/fn_initLocalPlayer.sqf:115` - ["A3E Earplugs", "toggle_earplugs_key", localize "STR_A3E_initLocalPlayer_toggleEarplugs", {_this call A3E_fnc_toggleEarplugs}, ""] call CBA_fnc_addKeybind;

### WriteParamBriefing  (`Code/functions/Common/fn_WriteParamBriefing.sqf`)
- `Code/functions/Server/fn_initPlayer.sqf:10` - //paramsArray call A3E_fnc_WriteParamBriefing;
- `Code/functions/Server/fn_parameterInit.sqf:65` - _paramsBriefing remoteExec ["A3E_fnc_WriteParamBriefing", 0, true];

## DRN

### AmbientInfantry  (`Code/functions/DRN/fn_AmbientInfantry.sqf`)
- `Code/functions/Server/fn_initServer.sqf:347` - [_playerGroup, A3E_VAR_Side_Opfor, a3e_arr_Escape_InfantryTypes, _infantryGroupsCount, _enemySpawnDistance + 200, _enemySpawnDistance + 500, _minEnemiesPerGr...

### DepopulateAquaticPatrol  (`Code/functions/DRN/fn_DepopulateAquaticPatrol.sqf`)
- `Code/functions/DRN/fn_InitAquaticPatrols.sqf:65` - _trigger setTriggerStatements["this", "_nil = [a3e_arr_aquaticPatrols_Markers select " + str _aquaticPatrolZoneNo + ", " + str _debug + "] spawn drn_fnc_Popu...

### DepopulateLocation  (`Code/functions/DRN/fn_DepopulateLocation.sqf`)
- `Code/functions/DRN/fn_InitGuardedLocations.sqf:101` - _trigger setTriggerStatements["this", "_nil = [a3e_var_guardedLocations" + str _instanceNo + " select " + str _locationNo + ", " + str _side + ", " + str _ma...

### DepopulateVillage  (`Code/functions/DRN/fn_DepopulateVillage.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### GarrisonUnits  (`Code/functions/DRN/fn_GarrisonUnits.sqf`)
- `Code/functions/DRN/fn_PopulateLocation.sqf:78` - _garrison = [_side, _soldiertype, _markername, _locationObject] spawn drn_fnc_GarrisonUnits;

### InitAquaticPatrolMarkers  (`Code/functions/DRN/fn_InitAquaticPatrolMarkers.sqf`)
- `Code/functions/Server/fn_initServer.sqf:206` - //[true] call drn_fnc_InitAquaticPatrolMarkers;

### InitAquaticPatrols  (`Code/functions/DRN/fn_InitAquaticPatrols.sqf`)
- `Code/functions/Server/fn_initServer.sqf:285` - [(units _playerGroup) select 0, A3E_VAR_Side_Opfor, a3e_arr_Escape_InfantryTypes, _minEnemiesPerGroup, _maxEnemiesPerGroup, 500000, _enemyMinSkill, _enemyMax...

### InitGuardedLocations  (`Code/functions/DRN/fn_InitGuardedLocations.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### InitVillageMarkers  (`Code/functions/DRN/fn_InitVillageMarkers.sqf`)
- `Code/functions/Server/fn_initServer.sqf:205` - [true] call A3E_fnc_InitVillageMarkers;

### InsertionTruck  (`Code/functions/DRN/fn_InsertionTruck.sqf`)
- `Code/Scripts/Escape/CreateReinforcementTruck.sqf:77` - [_vehicle, _cargoGroup, drn_searchAreaMarkerName, true, _fnc_OnDroppingGroup, _debug] spawn drn_fnc_InsertionTruck;

### MilitaryTraffic  (`Code/functions/DRN/fn_MilitaryTraffic.sqf`)
- `Code/functions/Server/fn_initServer.sqf:399` - [A3E_VAR_Side_Opfor, [], _vehiclesCount/2, _enemySpawnDistance, _radius, _enemyMinSkill, _enemyMaxSkill, drn_fnc_Escape_TrafficSearch, A3E_Debug] spawn drn_f...
- `Code/functions/Server/fn_initServer.sqf:400` - [A3E_VAR_Side_Ind, [], _vehiclesCount/2, _enemySpawnDistance, _radius, _enemyMinSkill, _enemyMaxSkill, drn_fnc_Escape_TrafficSearch, A3E_Debug] spawn drn_fnc...
- `Code/functions/Server/fn_initServer.sqf:681` - ["A3E_FNC_MilitaryTraffic"] call A3E_FNC_Chronos_Register;

### MonitorEmptyGroups  (`Code/functions/DRN/fn_MonitorEmptyGroups.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### MotorizedSearchGroup  (`Code/functions/DRN/fn_MotorizedSearchGroup.sqf`)
- `Code/Scripts/Escape/CreateMotorizedSearchGroup.sqf:66` - [_vehicle, _searchAreaMarker, _debug] spawn drn_fnc_MotorizedSearchGroup;

### MoveInfantryGroup  (`Code/functions/DRN/fn_MoveInfantryGroup.sqf`)
- `Code/functions/DRN/fn_AmbientInfantry.sqf:158` - //[((units _group) select 0), A3E_Debug] spawn drn_fnc_MoveInfantryGroup;

### MoveVehicle  (`Code/functions/DRN/fn_MoveVehicle.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### PopulateAquaticPatrol  (`Code/functions/DRN/fn_PopulateAquaticPatrol.sqf`)
- `Code/functions/DRN/fn_InitAquaticPatrols.sqf:65` - _trigger setTriggerStatements["this", "_nil = [a3e_arr_aquaticPatrols_Markers select " + str _aquaticPatrolZoneNo + ", " + str _debug + "] spawn drn_fnc_Popu...

### PopulateLocation  (`Code/functions/DRN/fn_PopulateLocation.sqf`)
- `Code/functions/DRN/fn_InitGuardedLocations.sqf:101` - _trigger setTriggerStatements["this", "_nil = [a3e_var_guardedLocations" + str _instanceNo + " select " + str _locationNo + ", " + str _side + ", " + str _ma...

### PopulateVillage  (`Code/functions/DRN/fn_PopulateVillage.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### SearchChopper  (`Code/functions/DRN/fn_SearchChopper.sqf`)
- `Code/Scripts/Escape/CreateSearchChopper.sqf:79` - [_chopper, _searchAreaMarker, _searchTimeMin, _refuelTimeMin, _debug] spawn drn_fnc_SearchChopper;
- `Code/Scripts/Escape/EscapeSurprises.sqf:264` - [_chopper, drn_searchAreaMarkerName, (5 + random 15), (5 + random 15), A3E_Debug] spawn DRN_fnc_SearchChopper;

### SearchGroup  (`Code/functions/DRN/fn_SearchGroup.sqf`)
- `Code/functions/Server/fn_initServer.sqf:312` - _scriptHandle = [_this, drn_searchAreaMarkerName, (getPos _enemyUnit), A3E_Debug] spawn drn_fnc_searchGroup;
- `Code/Scripts/Escape/CreateCivilEnemy.sqf:41` - [_this, "drn_searchAreaMarker", [0, 0, 0]] spawn drn_fnc_SearchGroup;
- `Code/Scripts/Escape/CreateReinforcementTruck.sqf:74` - [_this, "drn_searchAreaMarker", [0, 0, 0]] spawn drn_fnc_SearchGroup;
- `Code/Scripts/Escape/EscapeSurprises.sqf:172` - [_group, drn_searchAreaMarkerName, _dropPos, A3E_Debug] spawn DRN_fnc_SearchGroup;
- `Code/Scripts/Escape/EscapeSurprises.sqf:218` - [_group, drn_searchAreaMarkerName, _dropPos, A3E_Debug] spawn DRN_fnc_SearchGroup;

## Debug

### DebugMsg  (`Code/functions/Debug/fn_DebugMsg.sqf`)
- `Code/functions/AI/fn_SetTaskState.sqf:7` - //[format["Ambient AI: %1 is now in state %2",_group,_state]] call a3e_fnc_debugmsg;
- `Code/functions/Common/fn_expandProbabilities.sqf:17` - ["Unknown type in probability array"] call a3e_fnc_debugmsg;
- `Code/functions/Common/fn_getAssocArrayEntry.sqf:3` - if(typename _arr != "ARRAY" || count _arr != 2) exitwith {["Array is not Assoc Array"] call a3e_fnc_debugmsg;_return;};
- `Code/functions/DRN/fn_SearchChopper.sqf:17` - [_message] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:25` - ["Starting search chopper script..."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:29` - ["Search chopper must have a name. Script exiting."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:68` - ["Search chopper state: MOVING OUT."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:95` - ["Search chopper state: SEARCHING."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:117` - ["Search chopper state: RETURNING."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:141` - ["Search chopper state: LANDING."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:149` - ["Search chopper state: DEAD."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:152` - ["ERROR IN SearchChopper.sqf: Case " + _state + " not taken care of (1st switch)!"] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:177` - ["ERROR IN SearchChopper.sqf: Case " + _state + " not taken care of (2nd switch)!"] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:185` - ["Search chopper state: REFUELING."] call A3E_fnc_DebugMsg;
- `Code/functions/DRN/fn_SearchChopper.sqf:215` - ["Search chopper unable to continue. Script exiting."] call A3E_fnc_DebugMsg;
- `Code/functions/Server/fn_initPlayer.sqf:8` - //[format["%1 joined the Game!",name _player]] spawn a3e_fnc_debugmsg;
- `Code/functions/Server/fn_initServer.sqf:3` - ["Server started."] spawn a3e_fnc_debugmsg;
- `Code/functions/Server/fn_initServer.sqf:20` - ["Debug mode active!."] spawn a3e_fnc_debugmsg;
- `Code/functions/Server/fn_initServer.sqf:24` - ["Warning! Debug was set to true because of missing param!."] spawn a3e_fnc_debugmsg;
- `Code/functions/Server/fn_initServer.sqf:36` - ["Debug mode active!."] spawn a3e_fnc_debugmsg;
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:2` - ["Activating zone " + str _zoneIndex] call a3e_fnc_debugmsg;
- `Code/functions/Spawning/fn_deactivatePatrolZone.sqf:39` - ["Group deleted"] call a3e_fnc_debugmsg;
- `Code/functions/Spawning/fn_deactivatePatrolZone.sqf:48` - [format ["Zone %1 deleted",_zoneIndex]] call a3e_fnc_debugmsg;

### drawMapLine  (`Code/functions/Debug/fn_drawMapLine.sqf`)
- `Code/functions/Debug/fn_TrackGroup_Update.sqf:45` - [getposASL (units _group select 0),waypointPosition ((waypoints _group) select 1),_linemarker] call A3E_FNC_DrawMapLine;

### getDebugMessages  (`Code/functions/Debug/fn_getDebugMessages.sqf`)
- `Code/functions/Debug/fn_startDebugView.sqf:8` - private _messages = [] call a3e_fnc_getDebugMessages;

### log  (`Code/functions/Debug/fn_log.sqf`)
- `Code/functions/AI/fn_ExtractionBoat.sqf:9` - ["Extraction boats created.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionBoat.sqf:18` - ["Extraction boats switch to approach.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionBoat.sqf:27` - ["Extraction boats are landing.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionBoat.sqf:35` - ["Extraction boats are awaiting players.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionBoat.sqf:43` - ["Extraction boats are moving out for evac.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionCar.sqf:9` - ["Extraction vehicles created.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionCar.sqf:18` - ["Extraction vehicles switch to approach.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionCar.sqf:27` - ["Extraction vehicles are parking.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionCar.sqf:35` - ["Extraction vehicles are awaiting players.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionCar.sqf:43` - ["Extraction vehicles are moving out for evac.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionChopper.sqf:9` - ["Extraction choppers created.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionChopper.sqf:18` - ["Extraction choppers switch to approach.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionChopper.sqf:29` - ["Extraction choppers are landing.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionChopper.sqf:37` - ["Extraction choppers are awaiting players.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_ExtractionChopper.sqf:45` - ["Extraction choppers are moving out for evac.",["Extraction"],[_extractPos]] call A3E_fnc_Log;
- `Code/functions/AI/fn_Guard.sqf:39` - ["A group tasked with guarding has no home marker. Going on patrol.",["AI","Spawning"]] call A3E_fnc_Log;
- `Code/functions/AI/fn_onEnemyDetected.sqf:3` - ["Grp "+str _grp+" spotted enemy "+name _newTarget,["AI","SearchLeader"]] call A3E_fnc_log;
- `Code/functions/Common/fn_bootstrapEscape.sqf:18` - ["WorldConfig seems to be missing.",["ERROR","Missing"]] call A3E_fnc_log;
- `Code/functions/Common/fn_bootstrapEscape.sqf:23` - ["Villagemarker seem to be missing.",["ERROR","Missing"]] call A3E_fnc_log;
- `Code/functions/Common/fn_bootstrapEscape.sqf:28` - ["ComCentermarker seem to be missing.",["ERROR","Missing"]] call A3E_fnc_log;
- `Code/functions/Common/fn_getAssocArrayEntry.sqf:7` - if(_index == -1) exitwith {["Error","Key "+_key+" not found"] call a3e_fnc_log;_return;};
- `Code/functions/Debug/fn_DebugMsg.sqf:3` - [_msg] call A3E_fnc_Log;
- `Code/functions/Debug/fn_TrackGroup_Add.sqf:10` - ["Group "+str _group+" added for debug tracking",["Debugging"]] call a3e_fnc_log;
- `Code/functions/SearchLeader/fn_SearchLeaderRadio.sqf:3` - [_message,["SearchLeader"]] call A3E_fnc_Log;
- `Code/functions/Server/fn_RoadBlocks.sqf:10` - if(count(_roadBlocks)>=_maxNumberOfRoadBlocks) exitwith {["Max number of roadblocks reached",["Roadblocks"]] call A3E_fnc_Log;};
- `Code/functions/Server/fn_RoadBlocks.sqf:16` - if(count(_pos)<3) exitwith {["Unable to find a suitable position for Roadblock. Skipping.",["Roadblocks"]] call A3E_fnc_Log;};
- `Code/functions/Server/fn_RoadBlocks.sqf:18` - if({_pos distance _x < _minDistanceBetweenRoadBlocks} count _roadBlocks > 0) exitwith {["Roadblock too near to other roadblock. Skipping.",["Roadblocks"]] ca...
- `Code/functions/Server/fn_RoadBlocks.sqf:22` - if(count(_roads)==0) exitwith {["No road at position. Skipping.",["Roadblocks"]] call A3E_fnc_Log;};
- `Code/functions/Server/fn_RoadBlocks.sqf:28` - if(count(_roadConnectedTo) == 0) exitwith {["RoadSegment is has no connected roads. Skipping.",["Roadblocks"]] call A3E_fnc_Log;};
- `Code/functions/Server/fn_RoadBlocks.sqf:43` - ["No roadblocks spawned because there are no templates defined/loaded.",["Roadblocks"]] call A3E_fnc_Log;
- `Code/functions/Server/fn_RoadBlocks.sqf:108` - ["Roadblock created.",["Roadblocks"],[_pos,_templatePositions]] call A3E_fnc_Log;
- `Code/functions/Server/fn_selectFaction.sqf:28` - ["Error",str _side +" is an unknown side"] call a3e_fnc_log;
- `Code/functions/Server/fn_selectFaction.sqf:34` - if(count _sideArr == 0) exitwith {["Error",_side + " doesn't have any factions."] call a3e_fnc_log;_faction;};
- `Code/functions/Server/fn_selectFaction.sqf:73` - ["Error","Unable to find faction "+_special+" on side "+_side] call A3E_fnc_log;
- `Code/functions/Server/fn_updateTraps.sqf:85` - [format["Spawned a Trap at %1 in %2m",_trapPos, _trapPos distance player],["Traps"]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:20` - [format["Empty Group %1 deleted",_group],["AmbientAI","Spawning"]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:39` - [format["Group %1 deleted (too far)",_group],["AmbientAI","Spawning"],[["NearestPlayer",_nearest]]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:56` - ["Ambient AI group created",["AmbientAI","Spawning"],[_group,_spawnpos,count(units _group)]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:20` - [format["Empty Group %1 deleted",_group],["AmbientAI","Spawning"]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:39` - [format["Group (Civilian Commuter) %1 deleted (too far)",_group],["CivilianCommuters","Spawning"],[["NearestPlayer",_nearest]]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:60` - ["Military Traffic created",["CivilianCommuters","Spawning"],[_group,_spawnpos,count(units _group)]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:20` - [format["Empty Group %1 deleted",_group],["AmbientAI","Spawning"]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:39` - [format["Group (Military Patrol) %1 deleted (too far)",_group],["MilitaryTraffic","Spawning"],[["NearestPlayer",_nearest]]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:57` - ["Military Traffic created",["MilitaryTraffic","Spawning"],[_group,_spawnpos,count(units _group)]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_populateLocationZone.sqf:33` - [format["Found %1 enterable Buildings... in Zone %2",count(_buildingsPositions),_zoneIndex],["Spawning","Garisson"],[_buildingsPositions]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_populateLocationZone.sqf:66` - //["Zone "+str _zoneIndex+" populated with "+str count(_groups)+" groups",["Zones","Spawning"]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_populateVillageZone.sqf:74` - //["Zone "+str _zoneIndex+" populated with "+str count(_groups)+" groups",["Zones","Spawning"]] call A3E_fnc_Log;
- `Code/functions/Spawning/fn_spawnCivilianStroller.sqf:7` - ["Escape warning: Infantry array for village initialization is empty. A3E_UNITS_civilian_InfantryTypes may contain an error.",["Spawning","ERROR"]] call a3e_...
- `Code/functions/Spawning/fn_spawnCivilianStroller.sqf:15` - ["Creating civ group.",["Spawning"],[_side, _group]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_spawnCivilianStroller.sqf:21` - ["Creating civ group with "+str (_count) +" units.",["Spawning"],[_side, units _group]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:7` - ["No civilian vehicle defined.",["Spawning","CivilianCommuters"]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:18` - ["Spawning vehicle.",["Spawning","CivilianCommuters"],[_pos, _direction, _vehicleType, civilian]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:58` - ["Creating group.",["Spawning","CivilianCommuters"]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf:21` - ["Spawning vehicle.",["Spawning","MilitaryTraffic"],[_pos, _direction, _vehicleType, _side]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf:35` - ["Creating group.",["Spawning","MilitaryTraffic"]] call a3e_fnc_log;
- `Code/functions/Spawning/fn_spawnPatrol.sqf:13` - ["Escape warning: Infantry array for village initialization is empty. a3e_arr_Escape_InfantryTypes may contain an error.",["Spawning","ERROR"]] call a3e_fnc_...
- `Code/functions/Spawning/fn_spawnPatrol.sqf:23` - ["Creating group with "+str (_count+1) +" units.",[]] call a3e_fnc_log;
- `Code/functions/Templates/fn_isoTemplateStore.sqf:5` - if(_areaIndex < 0) exitWith {[("Can't find a trigger with name "+_exportName),["ERROR","Templates","Missing"]] call A3E_fnc_Log;};
- `Code/functions/Templates/fn_LoadTemplates.sqf:34` - ["No valid templates for roadblocks found!",["ERROR","Templates","Roadblocks"],[]] call A3E_fnc_Log;
- `Code/functions/Templates/fn_LoadTemplates.sqf:36` - [str _added + " Roadblock templates loaded.",["Templates","Roadblocks"],[_roadblocks]] call A3E_fnc_Log;
- `Code/functions/Zones/fn_activateZone.sqf:2` - ["Activating zone " + str _zoneIndex,["Zones","Spawning"]] call a3e_fnc_log;
- `Code/functions/Zones/fn_deactivateZone.sqf:24` - [format ["Zone %1 deleted",_zoneIndex],["Zones"]] call a3e_fnc_log;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:8` - ["Starting deserialization of zone "+str _zoneIndex,["Zones","Spawning","Serialization"]] call a3e_fnc_log;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:100` - ["Group "+str(_grp)+" deserialized",["Zones","Spawning","Serialization"]] call a3e_fnc_log;
- `Code/functions/Zones/fn_SerializeZoneGroups.sqf:3` - //["Starting serialization of zone "+str _zoneIndex,["Zones","Spawning","Serialization"]] call a3e_fnc_log;
- `Code/functions/Zones/fn_SerializeZoneGroups.sqf:71` - ["Group serialized and deleted",["Zones","Spawning","Serialization"]] call a3e_fnc_log;
- `Code/Scripts/Escape/CreateDropChopper.sqf:18` - ["Creating drop chopper...",["Info","DropChopper"]] call A3E_fnc_Log;

### logMessage  (`Code/functions/Debug/fn_logMessage.sqf`)
- `Code/functions/Debug/fn_log.sqf:4` - [_msg,_types,_data] remoteExec ["a3e_fnc_logMessage", 0, false];

### rptLog  (`Code/functions/Debug/fn_rptLog.sqf`)
- `Code/functions/Common/fn_loadLocalClasses.sqf:3` - "parsing local classes" call a3e_fnc_rptLog;
- `Code/functions/Common/fn_loadLocalClasses.sqf:74` - format ["found classes %1: %2", _x, _modArrays] call a3e_fnc_rptLog;
- `Code/functions/Common/fn_loadLocalClasses.sqf:79` - ("found bad array " + _arrayName) call a3e_fnc_rptLog;
- `Code/functions/Debug/fn_logMessage.sqf:23` - ["Escape Log: "+ _msg+" "+str _data] call a3e_fnc_rptLog;
- `Code/functions/Server/fn_parameterInit.sqf:12` - ["Saving parameters."] call a3e_fnc_rptLog;
- `Code/functions/Server/fn_parameterInit.sqf:18` - "Using CBA settings" call a3e_fnc_rptLog;
- `Code/functions/Server/fn_parameterInit.sqf:30` - ["No parameters found or params were updated, loading default."] call a3e_fnc_rptLog;
- `Code/functions/Server/fn_parameterInit.sqf:32` - ["Parameters loaded"] call a3e_fnc_rptLog;
- `Code/functions/Server/fn_parameterInit.sqf:39` - "Using manual parameters." call a3e_fnc_rptLog;

### startDebugView  (`Code/functions/Debug/fn_startDebugView.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### TrackGroup  (`Code/functions/Debug/fn_TrackGroup.sqf`)
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:58` - [_grp] spawn A3E_fnc_TrackGroup;
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:80` - [_grp] spawn A3E_fnc_TrackGroup;

### TrackGroup_Add  (`Code/functions/Debug/fn_TrackGroup_Add.sqf`)
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:59` - [_group] spawn A3E_fnc_TrackGroup_Add;
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:63` - [_group] spawn A3E_fnc_TrackGroup_Add;
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:60` - [_group] spawn A3E_fnc_TrackGroup_Add;
- `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf:3` - [_grp] call A3E_fnc_TrackGroup_Add;
- `Code/functions/Spawning/fn_onEnemyGroupSpawn.sqf:3` - [_grp] call A3E_fnc_TrackGroup_Add;
- `Code/functions/Spawning/fn_populateVillageZone.sqf:49` - [_grp] call A3E_fnc_TrackGroup_Add;
- `Code/functions/Spawning/fn_populateVillageZone.sqf:67` - [_grp] call A3E_fnc_TrackGroup_Add;
- `Code/functions/Zones/fn_DeserializeZoneGroups.sqf:98` - [_grp] call A3E_fnc_TrackGroup_Add;

### TrackGroup_Update  (`Code/functions/Debug/fn_TrackGroup_Update.sqf`)
- `Code/functions/Server/fn_initServer.sqf:683` - ["A3E_FNC_TrackGroup_Update"] call A3E_FNC_Chronos_Register;

### unit_debug_marker  (`Code/functions/Debug/fn_unit_debug_marker.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

## Garrison

### getBuildingPositions  (`Code/functions/Garrison/fn_getBuildingPositions.sqf`)
- `Code/functions/Garrison/fn_getRndBuildingWithPositions.sqf:10` - _positions = [_x,_isIndoor] call A3E_fnc_getBuildingPositions;

### getBuildingPositionsInMarker  (`Code/functions/Garrison/fn_getBuildingPositionsInMarker.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### getRndBuilding  (`Code/functions/Garrison/fn_getRndBuilding.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### getRndBuildingPosition  (`Code/functions/Garrison/fn_getRndBuildingPosition.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### getRndBuildingWithPositions  (`Code/functions/Garrison/fn_getRndBuildingWithPositions.sqf`)
- `Code/functions/AI/fn_GuardBuilding.sqf:16` - _Building = [(getpos leader _group)] call A3E_fnc_getRndBuildingWithPositions;
- `Code/functions/AI/fn_Occupy.sqf:16` - _Building = [(getpos leader _group)] call A3E_fnc_getRndBuildingWithPositions;
- `Code/functions/AI/fn_PatrolBuildings.sqf:16` - _Building = [(getpos leader _group)] call A3E_fnc_getRndBuildingWithPositions;
- `Code/functions/Garrison/fn_getRndBuildingPosition.sqf:3` - private _Building = [_pos,_radius,_isIndoor] call A3E_fnc_getRndBuildingWithPositions;
- `Code/functions/Spawning/fn_onCivilianSpawn.sqf:59` - private _building = [_unit] call A3E_fnc_getRndBuildingWithPositions;

## Helper

### calcMarkerArea  (`Code/functions/Helper/fn_calcMarkerArea.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### getBuildingsInMarker  (`Code/functions/Helper/fn_getBuildingsInMarker.sqf`)
- `Code/functions/Spawning/fn_populateLocationZone.sqf:32` - private _buildingsPositions = [_x] call a3e_fnc_getBuildingsInMarker;

### GetCircularSpawnPos  (`Code/functions/Helper/fn_GetCircularSpawnPos.sqf`)
- `Code/functions/Server/fn_RoadBlocks.sqf:14` - private _pos = [_minSpawnDistance,_maxSpawnDistance,"ROAD"] call a3e_fnc_getCircularSpawnPos;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:52` - private _spawnpos = [_MinSpawnCircleDistance,_MaxSpawnCircleDistance] call A3E_fnc_GetCircularSpawnPos;
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:56` - private _spawnpos = [_MinSpawnCircleDistance,_MaxSpawnCircleDistance,"ROAD"] call A3E_fnc_GetCircularSpawnPos;
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:53` - private _spawnpos = [_MinSpawnCircleDistance,_MaxSpawnCircleDistance,"ROAD"] call A3E_fnc_GetCircularSpawnPos;

### GetRandomCirclePosition  (`Code/functions/Helper/fn_GetRandomCirclePosition.sqf`)
- `Code/functions/AI/fn_CivilianCommuter.sqf:8` - private _movePos = [getpos (leader _group), 500,_MaxSpawnCircleDistance,"ROAD"] call A3E_fnc_GetRandomCirclePosition;
- `Code/functions/AI/fn_MilitaryTrafficPatrol.sqf:8` - private _movePos = [getpos (leader _group), 500,_MaxSpawnCircleDistance,"ROAD"] call A3E_fnc_GetRandomCirclePosition;
- `Code/functions/Helper/fn_GetCircularSpawnPos.sqf:14` - private _pos = [_reference,_minDis,_maxDis,_mode] call A3E_fnc_GetRandomCirclePosition;

### getSideColor  (`Code/functions/Helper/fn_getSideColor.sqf`)
- `Code/functions/Debug/fn_TrackGroup.sqf:13` - _marker setmarkercolor ([side leader _group] call a3e_fnc_getSideColor);
- `Code/functions/Debug/fn_TrackGroup_Update.sqf:57` - //_umarker setmarkercolor ([side leader _group] call a3e_fnc_getSideColor);

### NearestObjectDis  (`Code/functions/Helper/fn_NearestObjectDis.sqf`)
- `Code/functions/Helper/fn_GetCircularSpawnPos.sqf:16` - private _nearestPlayerDis = [_pos,_list] call A3E_fnc_NearestObjectDis;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:25` - private _nearest = [getpos _leader,_plist] call A3E_fnc_NearestObjectDis;
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:25` - private _nearest = [getpos _leader,_plist] call A3E_fnc_NearestObjectDis;
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:25` - private _nearest = [getpos _leader,_plist] call A3E_fnc_NearestObjectDis;

### RandomMarkerPos  (`Code/functions/Helper/fn_RandomMarkerPos.sqf`)
- `Code/functions/AI/fn_AquaticPatrol.sqf:14` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_AquaticPatrol.sqf:17` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_Guard.sqf:29` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_Guard.sqf:31` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_Patrol.sqf:29` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_Patrol.sqf:31` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_RandomPatrolRoute.sqf:76` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_RandomPatrolRoute.sqf:78` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_Stroll.sqf:29` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/AI/fn_Stroll.sqf:31` - _destinationPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/DRN/fn_PopulateAquaticPatrol.sqf:23` - _spawnPos = [_markerName] call a3e_fnc_RandomMarkerPos;
- `Code/functions/DRN/fn_PopulateAquaticPatrol.sqf:25` - _spawnPos = [_markerName] call a3e_fnc_RandomMarkerPos;

## Intel

### addIntel  (`Code/functions/Intel/fn_addIntel.sqf`)
- `Code/functions/Spawning/fn_onEnemySoldierSpawn.sqf:130` - [_unit] call A3E_fnc_AddIntel;

### collectIntel  (`Code/functions/Intel/fn_collectIntel.sqf`)
- `Code/functions/Common/fn_initLocalPlayer.sqf:41` - player addeventhandler["InventoryClosed","_this call A3E_FNC_collectIntel;"];

### RevealPOI  (`Code/functions/Intel/fn_RevealPOI.sqf`)
- `Code/functions/Intel/fn_collectIntel.sqf:6` - [count _intels] remoteExec ["A3E_fnc_RevealPOI", 2];

## SearchLeader

### createKnownPosition  (`Code/functions/SearchLeader/fn_createKnownPosition.sqf`)
- `Code/functions/SearchLeader/fn_recordSighting.sqf:4` - [(_knowledge select 6),(_knowledge select 5)] call A3E_fnc_CreateKnownPosition;

### onPlayerSpotted  (`Code/functions/SearchLeader/fn_onPlayerSpotted.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### PlayerDetection  (`Code/functions/SearchLeader/fn_PlayerDetection.sqf`)
- `Code/functions/SearchLeader/fn_recordSighting.sqf:7` - [] call A3E_fnc_PlayerDetection;
- `Code/functions/SearchLeader/fn_ReportToHQ.sqf:18` - [] call A3E_fnc_PlayerDetection; //Refresh triggers
- `Code/functions/SearchLeader/fn_ReportToHQ.sqf:67` - [] call A3E_fnc_PlayerDetection; //Refresh triggers
- `Code/functions/SearchLeader/fn_ReportToHQ.sqf:80` - [] call A3E_fnc_PlayerDetection; //Refresh triggers
- `Code/functions/SearchLeader/fn_ReportToHQ.sqf:96` - [] call A3E_fnc_PlayerDetection;
- `Code/functions/Server/fn_initServer.sqf:240` - [] call A3E_fnc_PlayerDetection;

### recordSighting  (`Code/functions/SearchLeader/fn_recordSighting.sqf`)
- `Code/functions/AI/fn_onEnemyDetected.sqf:50` - [_reporter,_player] call A3E_fnc_recordSighting;
- `Code/functions/AI/fn_onEnemyDetected.sqf:54` - [_reporter,_player] call A3E_fnc_recordSighting;
- `Code/functions/SearchLeader/fn_ReportToHQ.sqf:63` - [_reporter,_player] call A3E_fnc_recordSighting;
- `Code/functions/SearchLeader/fn_ReportToHQ.sqf:71` - [_reporter,_player] call A3E_fnc_recordSighting;
- `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf:51` - [_reporter,_player] call A3E_fnc_recordSighting;
- `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf:55` - [_reporter,_player] call A3E_fnc_recordSighting;

### ReportToHQ  (`Code/functions/SearchLeader/fn_ReportToHQ.sqf`)
- `Code/functions/SearchLeader/fn_PlayerDetection.sqf:17` - _opforTrigger setTriggerStatements["this && A3E_var_PlayerCanBeDetected", format["[""%1""] spawn A3E_FNC_ReportToHQ;",str A3E_VAR_Side_Opfor], ""];
- `Code/functions/SearchLeader/fn_PlayerDetection.sqf:32` - _indepTrigger setTriggerStatements["this && A3E_var_PlayerCanBeDetected", format["[""%1""] spawn A3E_FNC_ReportToHQ;",str A3E_VAR_Side_Ind], ""];

### SearchLeader  (`Code/functions/SearchLeader/fn_SearchLeader.sqf`)
- `Code/functions/SearchLeader/fn_SearchLeaderInit.sqf:8` - _trigger setTriggerStatements["A3E_var_SearchLeaderTick", "[] spawn A3E_fnc_SearchLeader;A3E_var_SearchLeaderTick = false;", "A3E_var_SearchLeaderTick = true...

### SearchLeaderInit  (`Code/functions/SearchLeader/fn_SearchLeaderInit.sqf`)
- `Code/functions/Server/fn_initServer.sqf:237` - [] call A3E_fnc_SearchleaderInit;

### SearchLeaderRadio  (`Code/functions/SearchLeader/fn_SearchLeaderRadio.sqf`)
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:18` - ["No reports."] call A3E_fnc_SearchLeaderRadio;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:30` - ["Creating legacy searchzone."] call A3E_fnc_SearchLeaderRadio;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:49` - ["Sending squad " + str(_grp) +" to investigate report!"] call A3E_fnc_SearchLeaderRadio;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:79` - ["Trying to call artillery on "+ mapGridPosition _strikePos] call A3E_fnc_SearchLeaderRadio;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:100` - ["Lost contact with a group. Sending somebody to investigate to "+ mapGridPosition _pos] call A3E_fnc_SearchLeaderRadio;
- `Code/functions/SearchLeader/fn_SearchLeader.sqf:108` - ["Sending squad " + str(_send) +" to inve stigate missing squad!"] call A3E_fnc_SearchLeaderRadio;

## Server

### createAmmoDepots  (`Code/functions/Server/fn_createAmmoDepots.sqf`)
- `Code/functions/Server/fn_initServer.sqf:225` - [] call A3E_fnc_CreateAmmoDepots;

### createComCenters  (`Code/functions/Server/fn_createComCenters.sqf`)
- `Code/functions/Server/fn_initServer.sqf:219` - [] call A3E_fnc_CreateComCenters;

### CreateCrashSites  (`Code/functions/Server/fn_CreateCrashSites.sqf`)
- `Code/functions/Server/fn_initServer.sqf:231` - [] call A3E_fnc_createCrashSites;

### CreateExtractionPoint  (`Code/functions/Server/fn_CreateExtractionPoint.sqf`)
- `Code/functions/Server/fn_SelectExtractionZone.sqf:117` - [(_extraction select 0),(_extraction select 5)] call A3E_fnc_CreateExtractionPoint;

### createLocationMarker  (`Code/functions/Server/fn_createLocationMarker.sqf`)
- `Code/functions/Server/fn_createComCenters.sqf:49` - [format ["drn_CommunicationCenterMapMarker%1", _instanceNo], _pos, "o_hq"] call A3E_fnc_createLocationMarker;
- `Code/functions/Server/fn_RoadBlocks.sqf:48` - [format["A3E_Roadblock_%1",count(_roadBlocks)],_pos,"hd_warning","ColorRed",false,false] call a3e_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot.sqf:518` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_middlePos,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot2.sqf:520` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot3.sqf:445` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot4.sqf:442` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot5.sqf:526` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot_spe1.sqf:396` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot_spe2.sqf:379` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot_spe3.sqf:397` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf:408` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf:433` - ["drn_AmmoDepotMapMarker" + str _instanceNo,_center,"o_installation"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_BuildMotorPool.sqf:627` - ["A3E_MotorPoolMapMarker" + str _mNumber,_centerPos,"o_service"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_BuildMotorPool_SPE.sqf:205` - ["A3E_MotorPoolMapMarker" + str _mNumber,_center,"o_service"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_BuildMotorPool_VN.sqf:220` - ["A3E_MotorPoolMapMarker" + str _mNumber,_center,"o_service"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_CrashSite.sqf:34` - ["a3e_CrashSiteMarker" + str a3e_CrashSiteMarkerNo,_position,"hd_warning","ColorGreen",true] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_MortarSite.sqf:61` - ["A3E_MortarSiteMapMarker" + str _number,_position,"o_mortar"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_MortarSite2.sqf:61` - ["A3E_MortarSiteMapMarker" + str _number,_position,"o_mortar"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_MortarSite_spe1.sqf:119` - ["A3E_MortarSiteMapMarker" + str _number,_position,"o_mortar"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_MortarSite_vn_nva1.sqf:40` - ["A3E_MortarSiteMapMarker" + str _number,_position,"o_mortar"] call A3E_fnc_createLocationMarker;
- `Code/functions/Templates/fn_MortarSite_vn_us1.sqf:40` - ["A3E_MortarSiteMapMarker" + str _number,_position,"o_mortar"] call A3E_fnc_createLocationMarker;

### createMortarSites  (`Code/functions/Server/fn_createMortarSites.sqf`)
- `Code/functions/Server/fn_initServer.sqf:228` - [] call A3E_fnc_createMortarSites;

### createMotorPools  (`Code/functions/Server/fn_createMotorPools.sqf`)
- `Code/functions/Server/fn_initServer.sqf:222` - [] call A3E_fnc_CreateMotorPools;

### createStartpos  (`Code/functions/Server/fn_createStartpos.sqf`)
- `Code/functions/Server/fn_initServer.sqf:201` - private _backpack = [] call A3E_fnc_createStartpos;

### endMissionServer  (`Code/functions/Server/fn_endMissionServer.sqf`)
- `Code/functions/Server/fn_missionFlow.sqf:17` - _trigger setTriggerStatements["a3e_var_Escape_MissionComplete && !a3e_var_Escape_SearchLeader_civilianReporting && !a3e_var_Escape_AllPlayersDead", """end2""...
- `Code/functions/Server/fn_missionFlow.sqf:26` - _trigger setTriggerStatements["a3e_var_Escape_MissionComplete &&  (missionNamespace getvariable [""A3E_Warcrime_Score"",0])>1000 && !a3e_var_Escape_AllPlayer...
- `Code/functions/Server/fn_missionFlow.sqf:34` - _trigger setTriggerStatements["a3e_var_Escape_MissionFailed_LeftBehind && !a3e_var_Escape_AllPlayersDead", """end3"" call A3E_fnc_endMissionServer;", ""];
- `Code/functions/Server/fn_missionFlow.sqf:42` - _trigger setTriggerStatements["a3e_var_Escape_AllPlayersDead", """end1"" call A3E_fnc_endMissionServer;", ""];

### FindSpawnRoad  (`Code/functions/Server/fn_FindSpawnRoad.sqf`)
- `Code/Scripts/Escape/EscapeSurprises.sqf:129` - _spawnSegment = [] call A3E_fnc_FindSpawnRoad;
- `Code/Scripts/Escape/EscapeSurprises.sqf:331` - _spawnSegment = [] call A3E_fnc_FindSpawnRoad;
- `Code/Scripts/Escape/EscapeSurprises.sqf:348` - _spawnSegment = [] call A3E_fnc_FindSpawnRoad;

### firedNearExtraction  (`Code/functions/Server/fn_firedNearExtraction.sqf`)
- `Code/functions/Server/fn_CreateExtractionPoint.sqf:32` - private _code = compile format["[%1,""%2"",_this] call A3E_fnc_firedNearExtraction;",_markerNo,_extractionType];

### getRndEntryFromFaction  (`Code/functions/Server/fn_getRndEntryFromFaction.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### initPlayer  (`Code/functions/Server/fn_initPlayer.sqf`)
- `Code/description.ext:107` - class a3e_fnc_initPlayer { allowedTargets=2; jip=0; };
- `Code/functions/Common/fn_initLocalPlayer.sqf:11` - [player] remoteExec ["a3e_fnc_initPlayer", 2];
- `Code/Revive/functions/Revive/fn_OnRespawn.sqf:5` - [false] call ATR_fnc_InitPlayer;
- `Code/Revive/functions/Revive/fn_ReviveInit.sqf:25` - [true] spawn ATR_FNC_InitPlayer;

### initServer  (`Code/functions/Server/fn_initServer.sqf`)
- `Code/functions/Common/fn_bootstrapEscape.sqf:36` - [] spawn a3e_fnc_initServer;

### initTraps  (`Code/functions/Server/fn_initTraps.sqf`)
- `Code/functions/Server/fn_initServer.sqf:456` - call A3E_fnc_InitTraps;

### InitVillageMarkers  (`Code/functions/Server/fn_InitVillageMarkers.sqf`)
- `Code/functions/Server/fn_initServer.sqf:205` - [true] call A3E_fnc_InitVillageMarkers;

### loadFaction  (`Code/functions/Server/fn_loadFaction.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### missionFlow  (`Code/functions/Server/fn_missionFlow.sqf`)
- `Code/functions/Common/fn_bootstrapEscape.sqf:35` - [] spawn a3e_fnc_missionFlow;

### parameterInit  (`Code/functions/Server/fn_parameterInit.sqf`)
- `Code/functions/Server/fn_initServer.sqf:10` - call a3e_fnc_parameterInit;

### RoadBlocks  (`Code/functions/Server/fn_RoadBlocks.sqf`)
- `Code/functions/Server/fn_initServer.sqf:428` - [a3e_arr_Escape_InfantryTypes, a3e_arr_Escape_RoadBlock_MannedVehicleTypes, _fnc_OnSpawnInfantryGroup, _fnc_OnSpawnMannedVehicle, A3E_Debug] spawn A3E_fnc_Ro...
- `Code/functions/Server/fn_initServer.sqf:679` - ["A3E_FNC_RoadBlocks"] call A3E_FNC_Chronos_Register;

### RunExtraction  (`Code/functions/Server/fn_RunExtraction.sqf`)
- `Code/functions/Server/fn_firedNearExtraction.sqf:28` - [_markerNo] spawn A3E_fnc_RunExtraction;

### RunExtractionBoat  (`Code/functions/Server/fn_RunExtractionBoat.sqf`)
- `Code/functions/Server/fn_firedNearExtraction.sqf:20` - [_markerNo] spawn A3E_fnc_RunExtractionBoat;

### RunExtractionCar  (`Code/functions/Server/fn_RunExtractionCar.sqf`)
- `Code/functions/Server/fn_firedNearExtraction.sqf:24` - [_markerNo] spawn A3E_fnc_RunExtractionCar;

### RunExtractionHeli  (`Code/functions/Server/fn_RunExtractionHeli.sqf`)
- `Code/functions/Server/fn_firedNearExtraction.sqf:16` - [_markerNo] spawn A3E_fnc_RunExtractionHeli;

### SelectExtractionZone  (`Code/functions/Server/fn_SelectExtractionZone.sqf`)
- `Code/functions/Common/fn_hijack.sqf:56` - [getpos _generatorTrailer] remoteExec ["A3E_fnc_SelectExtractionZone",2];

### selectFaction  (`Code/functions/Server/fn_selectFaction.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### UpdateLocationMarker  (`Code/functions/Server/fn_UpdateLocationMarker.sqf`)
- `Code/functions/Intel/fn_RevealPOI.sqf:11` - _markerType = [_poi # 0] call A3E_fnc_updateLocationMarker;
- `Code/functions/Server/fn_createLocationMarker.sqf:24` - _activation = format["[%1,true] spawn A3E_fnc_UpdateLocationMarker;",str _marker];
- `Code/functions/Server/fn_createLocationMarker.sqf:36` - _activation = format["[%1,true] spawn A3E_fnc_UpdateLocationMarker;",str _marker];

### updateTraps  (`Code/functions/Server/fn_updateTraps.sqf`)
- `Code/functions/Server/fn_initTraps.sqf:3` - ["A3E_fnc_updateTraps","call",5,false] call A3E_fnc_Chronos_Register;

### watchKnownPosition  (`Code/functions/Server/fn_watchKnownPosition.sqf`)
- `Code/functions/SearchLeader/fn_createKnownPosition.sqf:17` - [_knownPosition] spawn A3E_fnc_watchKnownPosition;
- `Code/Scripts/Escape/SearchLeader.sqf:258` - [_knownPosition] spawn A3E_fnc_watchKnownPosition;

### weather  (`Code/functions/Server/fn_weather.sqf`)
- `Code/functions/Server/fn_initServer.sqf:102` - [] spawn A3E_fnc_weather;

## Spawning

### activatePatrolZone  (`Code/functions/Spawning/fn_activatePatrolZone.sqf`)
- `Code/functions/Spawning/fn_initPatrolZone.sqf:56` - private _activation = format["[%1] call A3E_FNC_activatePatrolZone;",_zoneIndex];

### AmbientPatrols  (`Code/functions/Spawning/fn_AmbientPatrols.sqf`)
- `Code/functions/Server/fn_initServer.sqf:680` - ["A3E_FNC_AmbientPatrols"] call A3E_FNC_Chronos_Register;

### CivilianCommuters  (`Code/functions/Spawning/fn_CivilianCommuters.sqf`)
- `Code/functions/Server/fn_initServer.sqf:682` - ["A3E_FNC_CivilianCommuters"] call A3E_FNC_Chronos_Register;

### deactivatePatrolZone  (`Code/functions/Spawning/fn_deactivatePatrolZone.sqf`)
- `Code/functions/Spawning/fn_initPatrolZone.sqf:57` - private _deactivation = format["[%1] call A3E_FNC_deactivatePatrolZone;",_zoneIndex];

### findSpawnPosBuilding  (`Code/functions/Spawning/fn_findSpawnPosBuilding.sqf`)
- `Code/functions/AI/fn_spawnGarisson.sqf:7` - _positions = [_building] call a3e_fnc_findSpawnPosBuilding;

### getDynamicSquadsize  (`Code/functions/Spawning/fn_getDynamicSquadsize.sqf`)
- `Code/functions/DRN/fn_AmbientInfantry.sqf:124` - _unitsInGroup = [] call a3e_fnc_getDynamicSquadSize;
- `Code/functions/DRN/fn_InitGuardedLocations.sqf:78` - _soldierCount = [] call a3e_fnc_getDynamicSquadSize;
- `Code/functions/Server/fn_initServer.sqf:466` - _guardCount = [-1,-1,3,8] call a3e_fnc_getDynamicSquadSize;
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:53` - private _unitCount = [] call a3e_fnc_getDynamicSquadSize;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:55` - _group = [_spawnpos,selectRandom [A3E_VAR_Side_Opfor,A3E_VAR_Side_Ind,A3E_VAR_Side_Ind,A3E_VAR_Side_Ind],[] call a3e_fnc_getDynamicSquadSize] call A3E_FNC_Sp...
- `Code/functions/Spawning/fn_populateLocationZone.sqf:51` - private _unitCount = [] call a3e_fnc_getDynamicSquadSize;
- `Code/functions/Spawning/fn_populateVillageZone.sqf:44` - private _unitCount = [] call a3e_fnc_getDynamicSquadSize;

### initPatrolZone  (`Code/functions/Spawning/fn_initPatrolZone.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### initVillages  (`Code/functions/Spawning/fn_initVillages.sqf`)
- `Code/functions/Server/fn_initServer.sqf:248` - [] spawn A3E_fnc_initVillages;

### MilitaryTraffic  (`Code/functions/Spawning/fn_MilitaryTraffic.sqf`)
- `Code/functions/Server/fn_initServer.sqf:399` - [A3E_VAR_Side_Opfor, [], _vehiclesCount/2, _enemySpawnDistance, _radius, _enemyMinSkill, _enemyMaxSkill, drn_fnc_Escape_TrafficSearch, A3E_Debug] spawn drn_f...
- `Code/functions/Server/fn_initServer.sqf:400` - [A3E_VAR_Side_Ind, [], _vehiclesCount/2, _enemySpawnDistance, _radius, _enemyMinSkill, _enemyMaxSkill, drn_fnc_Escape_TrafficSearch, A3E_Debug] spawn drn_fnc...
- `Code/functions/Server/fn_initServer.sqf:681` - ["A3E_FNC_MilitaryTraffic"] call A3E_FNC_Chronos_Register;

### onCivilianGroupSpawn  (`Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf`)
- `Code/functions/Spawning/fn_spawnCivilianStroller.sqf:22` - [_group] call A3E_fnc_onCivilianGroupSpawn;
- `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:28` - [_group] call A3E_fnc_onCivilianGroupSpawn;

### onCivilianSpawn  (`Code/functions/Spawning/fn_onCivilianSpawn.sqf`)
- `Code/functions/Spawning/fn_spawnCivilianStroller.sqf:19` - [_unit] call A3E_fnc_onCivilianSpawn;
- `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:30` - {[_x] call A3E_fnc_onCivilianSpawn;} foreach units _group;

### onEnemyGroupSpawn  (`Code/functions/Spawning/fn_onEnemyGroupSpawn.sqf`)
- `Code/functions/Server/fn_RoadBlocks.sqf:78` - [_group] call a3e_fnc_onEnemyGroupSpawn;
- `Code/functions/Server/fn_RoadBlocks.sqf:97` - [group _unit] call a3e_fnc_onEnemyGroupSpawn;
- `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf:31` - [_group] call A3E_fnc_onEnemyGroupSpawn;
- `Code/functions/Spawning/fn_spawnPatrol.sqf:21` - [_group] call A3E_fnc_onEnemyGroupSpawn;

### onEnemySoldierSpawn  (`Code/functions/Spawning/fn_onEnemySoldierSpawn.sqf`)
- `Code/functions/Server/fn_RoadBlocks.sqf:80` - [_x] call a3e_fnc_onEnemySoldierSpawn;
- `Code/functions/Server/fn_RoadBlocks.sqf:98` - [_unit] call a3e_fnc_onEnemySoldierSpawn;
- `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf:33` - {[_x] call A3E_fnc_onEnemySoldierSpawn;} foreach units _group;
- `Code/functions/Spawning/fn_spawnPatrol.sqf:26` - [_unit] call A3E_fnc_onEnemySoldierSpawn;
- `Code/functions/Spawning/fn_spawnPatrol.sqf:29` - [_unit] call A3E_fnc_onEnemySoldierSpawn;
- `Code/Scripts/Escape/Functions.sqf:2` - [_this] call A3E_fnc_onEnemySoldierSpawn;

### onVehicleSpawn  (`Code/functions/Spawning/fn_onVehicleSpawn.sqf`)
- `Code/functions/DRN/fn_MilitaryTraffic.sqf:327` - [_vehicle] call a3e_fnc_onVehicleSpawn;
- `Code/functions/DRN/fn_PopulateAquaticPatrol.sqf:30` - [_boat select 0] call a3e_fnc_onVehicleSpawn;
- `Code/functions/Server/fn_RoadBlocks.sqf:77` - [_vehicle] call a3e_fnc_onVehicleSpawn;
- `Code/functions/Server/fn_RoadBlocks.sqf:96` - [_static] call a3e_fnc_onVehicleSpawn;
- `Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf:23` - [_vehicle] call a3e_fnc_onVehicleSpawn;
- `Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf:26` - [_vehicle] call a3e_fnc_onVehicleSpawn;
- `Code/Scripts/Escape/CreateDropChopper.sqf:30` - [_chopper] call a3e_fnc_onVehicleSpawn;
- `Code/Scripts/Escape/CreateMotorizedSearchGroup.sqf:24` - [_vehicle] call a3e_fnc_onVehicleSpawn;
- `Code/Scripts/Escape/CreateReinforcementTruck.sqf:23` - [_vehicle] call a3e_fnc_onVehicleSpawn;
- `Code/Scripts/Escape/CreateSearchChopper.sqf:55` - [_chopper] call a3e_fnc_onVehicleSpawn;
- `Code/Scripts/Escape/EscapeSurprises.sqf:242` - [_chopper] call a3e_fnc_onVehicleSpawn;
- `Code/Scripts/Escape/Functions.sqf:403` - [_vehicle] call a3e_fnc_onVehicleSpawn;

### populateLocationZone  (`Code/functions/Spawning/fn_populateLocationZone.sqf`)
- `Code/functions/Zones/fn_initLocationZone.sqf:4` - private _index = [[_position,0,"ELLIPSE",[_size,_size]],"A3E_FNC_populateLocationZone",_type] call A3E_fnc_initZone;

### populateVillageZone  (`Code/functions/Spawning/fn_populateVillageZone.sqf`)
- `Code/functions/Spawning/fn_initVillages.sqf:3` - [_zone,"A3E_FNC_PopulateVillageZone","Village"] call A3E_fnc_initZone;

### spawnCivilianStroller  (`Code/functions/Spawning/fn_spawnCivilianStroller.sqf`)
- `Code/functions/Spawning/fn_populateVillageZone.sqf:62` - private _grp = [_pos,selectRandom[1,1,1,1,1,2]] call A3E_FNC_spawnCivilianStroller;

### SpawnCivilianVehicle  (`Code/functions/Spawning/fn_SpawnCivilianVehicle.sqf`)
- `Code/functions/Spawning/fn_CivilianCommuters.sqf:59` - private _group = [_spawnpos] call A3E_fnc_SpawnCivilianVehicle;

### SpawnMilitaryVehicle  (`Code/functions/Spawning/fn_SpawnMilitaryVehicle.sqf`)
- `Code/functions/Spawning/fn_MilitaryTraffic.sqf:56` - private _group = [_spawnpos,selectRandom [A3E_VAR_Side_Opfor,A3E_VAR_Side_Ind,A3E_VAR_Side_Ind,A3E_VAR_Side_Ind]] call A3E_fnc_SpawnMilitaryVehicle;

### spawnPatrol  (`Code/functions/Spawning/fn_spawnPatrol.sqf`)
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:54` - private _grp = [_pos,_side,_unitCount] call A3E_FNC_spawnPatrol;
- `Code/functions/Spawning/fn_activatePatrolZone.sqf:76` - private _grp = [_pos,_side,_count] call A3E_FNC_spawnPatrol;
- `Code/functions/Spawning/fn_AmbientPatrols.sqf:55` - _group = [_spawnpos,selectRandom [A3E_VAR_Side_Opfor,A3E_VAR_Side_Ind,A3E_VAR_Side_Ind,A3E_VAR_Side_Ind],[] call a3e_fnc_getDynamicSquadSize] call A3E_FNC_Sp...
- `Code/functions/Spawning/fn_populateLocationZone.sqf:52` - private _grp = [_pos,_side,_unitCount] call A3E_FNC_spawnPatrol;
- `Code/functions/Spawning/fn_populateVillageZone.sqf:45` - private _grp = [_pos,selectRandom _sides,_unitCount] call A3E_FNC_spawnPatrol;

## Statistics

### EndSession  (`Code/functions/Statistics/fn_EndSession.sqf`)
- `Code/functions/Server/fn_endMissionServer.sqf:2` - [_end] call A3E_fnc_EndSession;

### LoadStatistics  (`Code/functions/Statistics/fn_LoadStatistics.sqf`)
- `Code/functions/Server/fn_initServer.sqf:51` - [] spawn A3E_fnc_LoadStatistics;

### ParseStatistics  (`Code/functions/Statistics/fn_ParseStatistics.sqf`)
- `Code/functions/Statistics/fn_LoadStatistics.sqf:5` - private _statisticText = [_statistics] call A3E_fnc_parseStatistics;
- `Code/functions/Statistics/fn_SaveStatistics.sqf:19` - missionNamespace setvariable ["A3E_EndStatistics",[_statistics] call A3E_fnc_parseStatistics,true];

### PingStatistics  (`Code/functions/Statistics/fn_PingStatistics.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### SaveStatistics  (`Code/functions/Statistics/fn_SaveStatistics.sqf`)
- `Code/functions/Server/fn_endMissionServer.sqf:3` - [_end] call A3E_fnc_SaveStatistics;

### StartSession  (`Code/functions/Statistics/fn_StartSession.sqf`)
- `Code/functions/Statistics/fn_StartStatistics.sqf:1` - [] call A3E_fnc_StartSession;

### StartStatistics  (`Code/functions/Statistics/fn_StartStatistics.sqf`)
- `Code/functions/Server/fn_initServer.sqf:445` - [] call A3E_fnc_startStatistics;

### WriteStatisticsToBriefing  (`Code/functions/Statistics/fn_WriteStatisticsToBriefing.sqf`)
- `Code/functions/Statistics/fn_LoadStatistics.sqf:7` - _statisticText remoteExec ["A3E_fnc_WriteStatisticsToBriefing", 0, true];

## Templates

### AmmoDepot  (`Code/functions/Templates/fn_AmmoDepot.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:87` - private _AmmoDepotTemplates = missionnamespace getvariable ["A3E_AmmoDepotTemplates",["A3E_fnc_AmmoDepot","A3E_fnc_AmmoDepot2","A3E_fnc_AmmoDepot3","A3E_fnc_...
- `Mods/CSLA-US/UnitClasses.sqf:627` - "A3E_fnc_AmmoDepot"
- `Mods/Vanilla/UnitClasses.sqf:1139` - "A3E_fnc_AmmoDepot"

### AmmoDepot2  (`Code/functions/Templates/fn_AmmoDepot2.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:87` - private _AmmoDepotTemplates = missionnamespace getvariable ["A3E_AmmoDepotTemplates",["A3E_fnc_AmmoDepot","A3E_fnc_AmmoDepot2","A3E_fnc_AmmoDepot3","A3E_fnc_...
- `Mods/CSLA-US/UnitClasses.sqf:628` - ,"A3E_fnc_AmmoDepot2"
- `Mods/Vanilla/UnitClasses.sqf:1140` - ,"A3E_fnc_AmmoDepot2"

### AmmoDepot3  (`Code/functions/Templates/fn_AmmoDepot3.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:87` - private _AmmoDepotTemplates = missionnamespace getvariable ["A3E_AmmoDepotTemplates",["A3E_fnc_AmmoDepot","A3E_fnc_AmmoDepot2","A3E_fnc_AmmoDepot3","A3E_fnc_...
- `Mods/CSLA-US/UnitClasses.sqf:629` - ,"A3E_fnc_AmmoDepot3"
- `Mods/Vanilla/UnitClasses.sqf:1141` - ,"A3E_fnc_AmmoDepot3"

### AmmoDepot4  (`Code/functions/Templates/fn_AmmoDepot4.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:87` - private _AmmoDepotTemplates = missionnamespace getvariable ["A3E_AmmoDepotTemplates",["A3E_fnc_AmmoDepot","A3E_fnc_AmmoDepot2","A3E_fnc_AmmoDepot3","A3E_fnc_...
- `Mods/CSLA-US/UnitClasses.sqf:630` - ,"A3E_fnc_AmmoDepot4"
- `Mods/Vanilla/UnitClasses.sqf:1142` - ,"A3E_fnc_AmmoDepot4"

### AmmoDepot5  (`Code/functions/Templates/fn_AmmoDepot5.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:87` - private _AmmoDepotTemplates = missionnamespace getvariable ["A3E_AmmoDepotTemplates",["A3E_fnc_AmmoDepot","A3E_fnc_AmmoDepot2","A3E_fnc_AmmoDepot3","A3E_fnc_...
- `Mods/CSLA-US/UnitClasses.sqf:631` - ,"A3E_fnc_AmmoDepot5"
- `Mods/Vanilla/UnitClasses.sqf:1143` - ,"A3E_fnc_AmmoDepot5"

### AmmoDepot_spe1  (`Code/functions/Templates/fn_AmmoDepot_spe1.sqf`)
- `Mods/SPE GER vs US/UnitClasses.sqf:715` - "A3E_fnc_AmmoDepot_spe1"
- `Mods/SPE US vs GER/UnitClasses.sqf:606` - "A3E_fnc_AmmoDepot_spe1"

### AmmoDepot_spe2  (`Code/functions/Templates/fn_AmmoDepot_spe2.sqf`)
- `Mods/SPE GER vs US/UnitClasses.sqf:716` - ,"A3E_fnc_AmmoDepot_spe2"
- `Mods/SPE US vs GER/UnitClasses.sqf:607` - ,"A3E_fnc_AmmoDepot_spe2"

### AmmoDepot_spe3  (`Code/functions/Templates/fn_AmmoDepot_spe3.sqf`)
- `Mods/SPE GER vs US/UnitClasses.sqf:717` - ,"A3E_fnc_AmmoDepot_spe3"
- `Mods/SPE US vs GER/UnitClasses.sqf:608` - ,"A3E_fnc_AmmoDepot_spe3"

### AmmoDepot_VN_nva1  (`Code/functions/Templates/fn_AmmoDepot_VN_nva1.sqf`)
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:779` - "A3E_fnc_AmmoDepot_VN_nva1"

### AmmoDepot_VN_US1  (`Code/functions/Templates/fn_AmmoDepot_VN_US1.sqf`)
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:634` - "A3E_fnc_AmmoDepot_VN_US1"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:751` - "A3E_fnc_AmmoDepot_VN_US1"

### BuildComCenter  (`Code/functions/Templates/fn_BuildComCenter.sqf`)
- `Code/functions/Server/fn_createComCenters.sqf:45` - private _ComCenterTemplates = missionnamespace getvariable ["A3E_ComCenterTemplates",["a3e_fnc_BuildComCenter","a3e_fnc_BuildComCenter2","a3e_fnc_BuildComCen...
- `Mods/CSLA-US/UnitClasses.sqf:513` - "a3e_fnc_BuildComCenter"
- `Mods/Vanilla/UnitClasses.sqf:1021` - "a3e_fnc_BuildComCenter"

### BuildComCenter2  (`Code/functions/Templates/fn_BuildComCenter2.sqf`)
- `Code/functions/Server/fn_createComCenters.sqf:45` - private _ComCenterTemplates = missionnamespace getvariable ["A3E_ComCenterTemplates",["a3e_fnc_BuildComCenter","a3e_fnc_BuildComCenter2","a3e_fnc_BuildComCen...
- `Mods/CSLA-US/UnitClasses.sqf:514` - ,"a3e_fnc_BuildComCenter2"
- `Mods/Vanilla/UnitClasses.sqf:1022` - ,"a3e_fnc_BuildComCenter2"

### BuildComCenter3  (`Code/functions/Templates/fn_BuildComCenter3.sqf`)
- `Code/functions/Server/fn_createComCenters.sqf:45` - private _ComCenterTemplates = missionnamespace getvariable ["A3E_ComCenterTemplates",["a3e_fnc_BuildComCenter","a3e_fnc_BuildComCenter2","a3e_fnc_BuildComCen...
- `Mods/CSLA-US/UnitClasses.sqf:515` - ,"a3e_fnc_BuildComCenter3"
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:610` - "a3e_fnc_BuildComCenter3"
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:520` - "a3e_fnc_BuildComCenter3"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:569` - "a3e_fnc_BuildComCenter3"
- `Mods/Vanilla/UnitClasses.sqf:1023` - ,"a3e_fnc_BuildComCenter3"

### BuildComCenter4  (`Code/functions/Templates/fn_BuildComCenter4.sqf`)
- `Code/functions/Server/fn_createComCenters.sqf:45` - private _ComCenterTemplates = missionnamespace getvariable ["A3E_ComCenterTemplates",["a3e_fnc_BuildComCenter","a3e_fnc_BuildComCenter2","a3e_fnc_BuildComCen...
- `Mods/CSLA-US/UnitClasses.sqf:516` - ,"a3e_fnc_BuildComCenter4"
- `Mods/Vanilla/UnitClasses.sqf:1024` - ,"a3e_fnc_BuildComCenter4"

### BuildComCenter5  (`Code/functions/Templates/fn_BuildComCenter5.sqf`)
- `Code/functions/Server/fn_createComCenters.sqf:45` - private _ComCenterTemplates = missionnamespace getvariable ["A3E_ComCenterTemplates",["a3e_fnc_BuildComCenter","a3e_fnc_BuildComCenter2","a3e_fnc_BuildComCen...
- `Mods/CSLA-US/UnitClasses.sqf:517` - ,"a3e_fnc_BuildComCenter5"
- `Mods/Vanilla/UnitClasses.sqf:1025` - ,"a3e_fnc_BuildComCenter5"

### BuildComCenter_spe1  (`Code/functions/Templates/fn_BuildComCenter_spe1.sqf`)
- `Mods/SPE GER vs US/UnitClasses.sqf:589` - "a3e_fnc_BuildComCenter_spe1"
- `Mods/SPE US vs GER/UnitClasses.sqf:503` - "a3e_fnc_BuildComCenter_spe1"

### BuildComCenter_spe_ger1  (`Code/functions/Templates/fn_BuildComCenter_spe_ger1.sqf`)
- `Mods/SPE US vs GER/UnitClasses.sqf:504` - ,"a3e_fnc_BuildComCenter_spe_ger1"

### BuildComCenter_vn_nva1  (`Code/functions/Templates/fn_BuildComCenter_vn_nva1.sqf`)
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:611` - ,"a3e_fnc_BuildComCenter_VN_nva1"

### BuildComCenter_vn_nva2  (`Code/functions/Templates/fn_BuildComCenter_vn_nva2.sqf`)
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:612` - ,"a3e_fnc_BuildComCenter_VN_nva2"

### BuildComCenter_vn_us1  (`Code/functions/Templates/fn_BuildComCenter_vn_us1.sqf`)
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:521` - ,"a3e_fnc_BuildComCenter_VN_US1"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:570` - ,"a3e_fnc_BuildComCenter_VN_US1"

### BuildComCenter_vn_us2  (`Code/functions/Templates/fn_BuildComCenter_vn_us2.sqf`)
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:522` - ,"a3e_fnc_BuildComCenter_VN_US2"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:571` - ,"a3e_fnc_BuildComCenter_VN_US2"

### BuildMotorPool  (`Code/functions/Templates/fn_BuildMotorPool.sqf`)
- `Code/functions/Server/fn_createMotorPools.sqf:77` - private _MotorPoolTemplates = missionnamespace getvariable ["A3E_MotorPoolTemplates",["A3E_fnc_BuildMotorPool"]];
- `Mods/CSLA-US/UnitClasses.sqf:502` - "A3E_fnc_BuildMotorPool"
- `Mods/Vanilla/UnitClasses.sqf:1010` - "A3E_fnc_BuildMotorPool"

### BuildMotorPool_SPE  (`Code/functions/Templates/fn_BuildMotorPool_SPE.sqf`)
- `Mods/SPE GER vs US/UnitClasses.sqf:578` - "A3E_fnc_BuildMotorPool_SPE"
- `Mods/SPE US vs GER/UnitClasses.sqf:492` - "A3E_fnc_BuildMotorPool_SPE"

### BuildMotorPool_VN  (`Code/functions/Templates/fn_BuildMotorPool_VN.sqf`)
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:599` - "A3E_fnc_BuildMotorPool_VN"
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:509` - "A3E_fnc_BuildMotorPool_VN"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:558` - "A3E_fnc_BuildMotorPool_VN"

### BuildPrison  (`Code/functions/Templates/fn_BuildPrison.sqf`)
- `Code/functions/Server/fn_createStartpos.sqf:5` - private _template = (selectRandom (missionNamespace getVariable ["A3E_PrisonTemplates", ["a3e_fnc_BuildPrison", "a3e_fnc_BuildPrison1", "a3e_fnc_BuildPrison2...
- `Mods/SFP/UnitClasses.sqf:37` - "a3e_fnc_BuildPrison"
- `Mods/SFP d/UnitClasses.sqf:37` - "a3e_fnc_BuildPrison"
- `Mods/SFP w/UnitClasses.sqf:37` - "a3e_fnc_BuildPrison"
- `Mods/Vanilla/UnitClasses.sqf:33` - "a3e_fnc_BuildPrison"

### BuildPrison1  (`Code/functions/Templates/fn_BuildPrison1.sqf`)
- `Code/functions/Server/fn_createStartpos.sqf:5` - private _template = (selectRandom (missionNamespace getVariable ["A3E_PrisonTemplates", ["a3e_fnc_BuildPrison", "a3e_fnc_BuildPrison1", "a3e_fnc_BuildPrison2...
- `Mods/GM-BW/UnitClasses.sqf:37` - "a3e_fnc_BuildPrison1"
- `Mods/GM-BW w/UnitClasses.sqf:37` - "a3e_fnc_BuildPrison1"
- `Mods/GM-NVA/UnitClasses.sqf:37` - "a3e_fnc_BuildPrison1"
- `Mods/GM-NVA w/UnitClasses.sqf:37` - "a3e_fnc_BuildPrison1"
- `Mods/SFP/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison1"
- `Mods/SFP d/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison1"
- `Mods/SFP w/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison1"
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:33` - "a3e_fnc_BuildPrison1"
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:33` - "a3e_fnc_BuildPrison1"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:35` - "a3e_fnc_BuildPrison1"
- `Mods/SPE GER vs US/UnitClasses.sqf:38` - "a3e_fnc_BuildPrison1"
- `Mods/SPE US vs GER/UnitClasses.sqf:38` - "a3e_fnc_BuildPrison1"
- `Mods/Vanilla/UnitClasses.sqf:34` - ,"a3e_fnc_BuildPrison1"

### BuildPrison2  (`Code/functions/Templates/fn_BuildPrison2.sqf`)
- `Code/functions/Server/fn_createStartpos.sqf:5` - private _template = (selectRandom (missionNamespace getVariable ["A3E_PrisonTemplates", ["a3e_fnc_BuildPrison", "a3e_fnc_BuildPrison1", "a3e_fnc_BuildPrison2...
- `Mods/GM-BW/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison2"
- `Mods/GM-BW w/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison2"
- `Mods/GM-NVA/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison2"
- `Mods/GM-NVA w/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison2"
- `Mods/SFP/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison2"
- `Mods/SFP d/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison2"
- `Mods/SFP w/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison2"
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:34` - ,"a3e_fnc_BuildPrison2"
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:34` - ,"a3e_fnc_BuildPrison2"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:36` - ,"a3e_fnc_BuildPrison2"
- `Mods/SPE GER vs US/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison2"
- `Mods/SPE US vs GER/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison2"
- `Mods/Vanilla/UnitClasses.sqf:35` - ,"a3e_fnc_BuildPrison2"

### BuildPrison3  (`Code/functions/Templates/fn_BuildPrison3.sqf`)
- `Code/functions/Server/fn_createStartpos.sqf:5` - private _template = (selectRandom (missionNamespace getVariable ["A3E_PrisonTemplates", ["a3e_fnc_BuildPrison", "a3e_fnc_BuildPrison1", "a3e_fnc_BuildPrison2...
- `Mods/GM-BW/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison3"
- `Mods/GM-BW w/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison3"
- `Mods/GM-NVA/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison3"
- `Mods/GM-NVA w/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison3"
- `Mods/SFP/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison3"
- `Mods/SFP d/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison3"
- `Mods/SFP w/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison3"
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:35` - ,"a3e_fnc_BuildPrison3"
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:35` - ,"a3e_fnc_BuildPrison3"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:37` - ,"a3e_fnc_BuildPrison3"
- `Mods/SPE GER vs US/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison3"
- `Mods/SPE US vs GER/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison3"
- `Mods/Vanilla/UnitClasses.sqf:36` - ,"a3e_fnc_BuildPrison3"

### BuildPrison4  (`Code/functions/Templates/fn_BuildPrison4.sqf`)
- `Code/functions/Server/fn_createStartpos.sqf:5` - private _template = (selectRandom (missionNamespace getVariable ["A3E_PrisonTemplates", ["a3e_fnc_BuildPrison", "a3e_fnc_BuildPrison1", "a3e_fnc_BuildPrison2...
- `Mods/GM-BW/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison4"
- `Mods/GM-BW w/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison4"
- `Mods/GM-NVA/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison4"
- `Mods/GM-NVA w/UnitClasses.sqf:40` - ,"a3e_fnc_BuildPrison4"
- `Mods/SFP/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison4"
- `Mods/SFP d/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison4"
- `Mods/SFP w/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison4"
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:36` - ,"a3e_fnc_BuildPrison4"
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:36` - ,"a3e_fnc_BuildPrison4"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison4"
- `Mods/SPE GER vs US/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison4"
- `Mods/SPE US vs GER/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison4"
- `Mods/Vanilla/UnitClasses.sqf:37` - ,"a3e_fnc_BuildPrison4"

### BuildPrison5  (`Code/functions/Templates/fn_BuildPrison5.sqf`)
- `Code/functions/Server/fn_createStartpos.sqf:5` - private _template = (selectRandom (missionNamespace getVariable ["A3E_PrisonTemplates", ["a3e_fnc_BuildPrison", "a3e_fnc_BuildPrison1", "a3e_fnc_BuildPrison2...
- `Mods/GM-BW/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison5"
- `Mods/GM-BW w/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison5"
- `Mods/GM-NVA/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison5"
- `Mods/GM-NVA w/UnitClasses.sqf:41` - ,"a3e_fnc_BuildPrison5"
- `Mods/SFP/UnitClasses.sqf:42` - ,"a3e_fnc_BuildPrison5"
- `Mods/SFP d/UnitClasses.sqf:42` - ,"a3e_fnc_BuildPrison5"
- `Mods/SFP w/UnitClasses.sqf:42` - ,"a3e_fnc_BuildPrison5"
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:37` - ,"a3e_fnc_BuildPrison5"
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:37` - ,"a3e_fnc_BuildPrison5"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:39` - ,"a3e_fnc_BuildPrison5"
- `Mods/SPE GER vs US/UnitClasses.sqf:42` - ,"a3e_fnc_BuildPrison5"
- `Mods/SPE US vs GER/UnitClasses.sqf:42` - ,"a3e_fnc_BuildPrison5"
- `Mods/Vanilla/UnitClasses.sqf:38` - ,"a3e_fnc_BuildPrison5"

### CrashSite  (`Code/functions/Templates/fn_CrashSite.sqf`)
- `Code/functions/Server/fn_CreateCrashSites.sqf:4` - [_pos] spawn A3E_fnc_crashSite;
- `Code/functions/Server/fn_initServer.sqf:435` - [_pos] call A3E_fnc_crashSite;

### isoTemplateRestore  (`Code/functions/Templates/fn_isoTemplateRestore.sqf`)
- `Code/functions/Server/fn_RoadBlocks.sqf:46` - private _templatePositions = [_pos,_dir, selectRandom _templatesAvailable]  call a3e_fnc_IsoTemplateRestore;

### isoTemplateStore  (`Code/functions/Templates/fn_isoTemplateStore.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### LoadTemplates  (`Code/functions/Templates/fn_LoadTemplates.sqf`)
- `Code/functions/Server/fn_initServer.sqf:69` - [] call a3e_fnc_loadTemplates;

### MortarSite  (`Code/functions/Templates/fn_MortarSite.sqf`)
- `Code/functions/Server/fn_createMortarSites.sqf:93` - private _mortarSiteTemplates = missionnamespace getvariable ["A3E_MortarSiteTemplates",["A3E_fnc_MortarSite","A3E_fnc_MortarSite2"]];
- `Mods/CSLA-US/UnitClasses.sqf:1023` - "A3E_fnc_MortarSite"
- `Mods/Vanilla/UnitClasses.sqf:1505` - "A3E_fnc_MortarSite"

### MortarSite2  (`Code/functions/Templates/fn_MortarSite2.sqf`)
- `Code/functions/Server/fn_createMortarSites.sqf:93` - private _mortarSiteTemplates = missionnamespace getvariable ["A3E_MortarSiteTemplates",["A3E_fnc_MortarSite","A3E_fnc_MortarSite2"]];

### MortarSite_spe1  (`Code/functions/Templates/fn_MortarSite_spe1.sqf`)
- `Mods/SPE GER vs US/UnitClasses.sqf:1085` - "A3E_fnc_MortarSite_spe1"
- `Mods/SPE US vs GER/UnitClasses.sqf:975` - "A3E_fnc_MortarSite_spe1"

### MortarSite_vn_nva1  (`Code/functions/Templates/fn_MortarSite_vn_nva1.sqf`)
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:1259` - "A3E_fnc_MortarSite_vn_nva1"

### MortarSite_vn_us1  (`Code/functions/Templates/fn_MortarSite_vn_us1.sqf`)
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:1109` - "A3E_fnc_MortarSite_vn_us1"
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:1217` - "A3E_fnc_MortarSite_vn_us1"

### Roadblock  (`Code/functions/Templates/fn_Roadblock.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Roadblock2  (`Code/functions/Templates/fn_Roadblock2.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Roadblock3  (`Code/functions/Templates/fn_Roadblock3.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Roadblock4  (`Code/functions/Templates/fn_Roadblock4.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Roadblock_vn1  (`Code/functions/Templates/fn_Roadblock_vn1.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

### Roadblock_vn2  (`Code/functions/Templates/fn_Roadblock_vn2.sqf`)
- _no `fnc_` references found - entry point or dead code; verify._

## Zones

### activateZone  (`Code/functions/Zones/fn_activateZone.sqf`)
- `Code/functions/Zones/fn_initZone.sqf:56` - private _activation = format["[%1] call A3E_FNC_activateZone;",_zoneIndex];

### deactivateZone  (`Code/functions/Zones/fn_deactivateZone.sqf`)
- `Code/functions/Zones/fn_initZone.sqf:57` - private _deactivation = format["[%1] call A3E_FNC_deactivateZone;",_zoneIndex];

### DeserializeZoneGroups  (`Code/functions/Zones/fn_DeserializeZoneGroups.sqf`)
- `Code/functions/Zones/fn_activateZone.sqf:25` - [_zoneIndex] call A3E_fnc_DeserializeZoneGroups;

### initLocationZone  (`Code/functions/Zones/fn_initLocationZone.sqf`)
- `Code/functions/Server/fn_createAmmoDepots.sqf:94` - [_x,60,selectRandom[A3E_VAR_Side_Opfor],"AMMODEPOT"] call A3E_fnc_initLocationZone;
- `Code/functions/Server/fn_createComCenters.sqf:66` - [_x,80,selectRandom[A3E_VAR_Side_Opfor],"COMCENTER"] call A3E_fnc_initLocationZone;
- `Code/functions/Server/fn_createMortarSites.sqf:96` - [_x,40,selectRandom[A3E_VAR_Side_Opfor,A3E_VAR_Side_Ind],"MORTAR"] call A3E_fnc_initLocationZone;
- `Code/functions/Server/fn_createMotorPools.sqf:85` - [_x select 0,70,selectRandom[A3E_VAR_Side_Opfor,A3E_VAR_Side_Ind],"MOTORPOOL"] call A3E_fnc_initLocationZone;
- `Code/functions/Server/fn_RoadBlocks.sqf:51` - private _zoneIndex = [_pos,30,_side,"ROADBLOCK"] call A3E_fnc_initLocationZone;

### initZone  (`Code/functions/Zones/fn_initZone.sqf`)
- `Code/functions/Spawning/fn_initVillages.sqf:3` - [_zone,"A3E_FNC_PopulateVillageZone","Village"] call A3E_fnc_initZone;
- `Code/functions/Zones/fn_initLocationZone.sqf:4` - private _index = [[_position,0,"ELLIPSE",[_size,_size]],"A3E_FNC_populateLocationZone",_type] call A3E_fnc_initZone;

### SerializeZoneGroups  (`Code/functions/Zones/fn_SerializeZoneGroups.sqf`)
- `Code/functions/Zones/fn_deactivateZone.sqf:16` - [_zoneIndex] call A3E_fnc_SerializeZoneGroups;

## ace

### ATCam  (`Code/functions/ace/fn_ATCam.sqf`)
- `Code/functions/ace/fn_GroundHandler.sqf:14` - if(AT_Revive_Camera==1) then {[1] remoteExec ["ACE_fnc_ATCam",_unit];};
- `Code/functions/ace/fn_HandleUnconscious.sqf:16` - if(AT_Revive_Camera==1) then {[1] remoteExec ["ACE_fnc_ATCam",_unit];};
- `Code/functions/ace/fn_HandleUnconscious.sqf:22` - if((AT_Revive_Camera==1)&&(_unit getVariable "ACE_Revive_isUnconscious")) then {[2] remoteExec ["ACE_fnc_ATCam",_unit];};

### CaptiveHandle  (`Code/functions/ace/fn_CaptiveHandle.sqf`)
- `Code/functions/ace/fn_HandleUnconscious.sqf:8` - [_unit] remoteExec ["ACE_fnc_CaptiveHandle",_unit];//Loop because for whatever reason unit gets set out of captive mode here and there

### GroundHandler  (`Code/functions/ace/fn_GroundHandler.sqf`)
- `Code/functions/ace/fn_HandleUnconscious.sqf:9` - if !(_unit getVariable ["ACE_isUnconscious", false]) then {[_unit,1] remoteExec ["ACE_fnc_GroundHandler",_unit];};
- `Code/functions/ace/fn_HandleUnconscious.sqf:12` - [_unit,2] remoteExec ["ACE_fnc_GroundHandler",_unit];
- `Code/functions/ace/fn_HandleUnconscious.sqf:24` - [_unit,2] remoteExec ["ACE_fnc_GroundHandler",_unit];

### HandleUnconscious  (`Code/functions/ace/fn_HandleUnconscious.sqf`)
- `Code/functions/Server/fn_initServer.sqf:46` - ["ace_unconscious", {params["_unit", "_isDown"]; [_unit,_isDown] spawn ACE_fnc_HandleUnconscious;}] call CBA_fnc_addEventHandler;

---

# Indirect-invocation appendices

## Appendix - CfgFunctions auto-run (preInit/postInit = 1)

These functions run automatically at mission load - caller is the **engine/CBA**.

- `Code/include/functions.hpp:10` - postInit = 1; // 1 to call the function upon mission start, after objects are initialized. Passed arguments are ["postInit"]
- `Code/include/functions.hpp:34` - //	postInit = 1;
- `Code/include/functions.hpp:242` - postInit = 1;

## Appendix - Chronos registrations

Functions registered **by name string** for periodic execution - caller is the **Chronos scheduler**.

- `Code/functions/Server/fn_initServer.sqf:678` - //["A3E_FNC_AmbientAISpawn"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:679` - ["A3E_FNC_RoadBlocks"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:680` - ["A3E_FNC_AmbientPatrols"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:681` - ["A3E_FNC_MilitaryTraffic"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:682` - ["A3E_FNC_CivilianCommuters"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initServer.sqf:683` - ["A3E_FNC_TrackGroup_Update"] call A3E_FNC_Chronos_Register;
- `Code/functions/Server/fn_initTraps.sqf:3` - ["A3E_fnc_updateTraps","call",5,false] call A3E_fnc_Chronos_Register;
- `Code/include/functions.hpp:245` - class Chronos_Register {};

## Appendix - Trigger statements (setTriggerStatements)

Code run on trigger activation; function names appear as **strings** here.

- `Code/functions/Chronos/fn_Chronos_Init.sqf:24` - _trigger setTriggerStatements["A3E_CronTick", "A3E_CronTick = false; [] call a3e_fnc_chronos_run;", "A3E_CronTick = true;"];
- `Code/functions/Common/fn_briefing.sqf:9` - _trigger setTriggerStatements["A3E_SoundPrisonAlarm", "thisTrigger setposASL ((getposASL A3E_PrisonLoudspeakerObject) vectorAdd [0,0,4]);", ""];
- `Code/functions/Common/fn_briefing.sqf:20` - _trigger setTriggerStatements["!isDedicated && a3e_var_Escape_AllPlayersDead || a3e_var_Escape_MissionComplete", "[] spawn ATHSC_fnc_exit;", ""];
- `Code/functions/Common/fn_briefing.sqf:49` - _trigger setTriggerStatements["A3E_Task_Prison_Complete", "A3E_Task_Prison setTaskState ""Succeeded"";", ""];
- `Code/functions/Common/fn_briefing.sqf:56` - _trigger setTriggerStatements["A3E_Task_Prison_Failed", "A3E_Task_Prison setTaskState ""Failed"";", ""];
- `Code/functions/Common/fn_briefing.sqf:81` - _trigger setTriggerStatements["A3E_Task_Map_Complete", "A3E_Task_Map setTaskState ""Succeeded"";", ""];
- `Code/functions/Common/fn_briefing.sqf:88` - _trigger setTriggerStatements["A3E_Task_Map_Failed", "A3E_Task_Map setTaskState ""Failed"";", ""];
- `Code/functions/Common/fn_briefing.sqf:116` - _trigger setTriggerStatements["A3E_Task_LocateComcenter_Complete", "A3E_Task_LocateComcenter setTaskState ""Succeeded"";", ""];
- `Code/functions/Common/fn_briefing.sqf:123` - _trigger setTriggerStatements["A3E_Task_LocateComcenter_Failed", "A3E_Task_LocateComcenter setTaskState ""Failed"";", ""];
- `Code/functions/Common/fn_briefing.sqf:147` - _trigger setTriggerStatements["A3E_Task_ComCenter_Complete", "A3E_Task_ComCenter setTaskState ""Succeeded"";", ""];
- `Code/functions/Common/fn_briefing.sqf:154` - _trigger setTriggerStatements["A3E_Task_ComCenter_Failed", "A3E_Task_ComCenter setTaskState ""Failed"";", ""];
- `Code/functions/Common/fn_briefing.sqf:179` - _trigger setTriggerStatements["A3E_Task_Exfil_Complete", "A3E_Task_Exfil setTaskState ""Succeeded"";", ""];
- `Code/functions/Common/fn_briefing.sqf:186` - _trigger setTriggerStatements["A3E_Task_Exfil_Failed", "A3E_Task_Exfil setTaskState ""Failed"";", ""];
- `Code/functions/DRN/fn_InitAquaticPatrols.sqf:65` - _trigger setTriggerStatements["this", "_nil = [a3e_arr_aquaticPatrols_Markers select " + str _aquaticPatrolZoneNo + ", " + str _debug + "] spawn drn_fnc_PopulateAquaticPatrol;",...
- `Code/functions/DRN/fn_InitGuardedLocations.sqf:101` - _trigger setTriggerStatements["this", "_nil = [a3e_var_guardedLocations" + str _instanceNo + " select " + str _locationNo + ", " + str _side + ", " + str _maxGroupsCount + ", " ...
- `Code/functions/SearchLeader/fn_PlayerDetection.sqf:17` - _opforTrigger setTriggerStatements["this && A3E_var_PlayerCanBeDetected", format["[""%1""] spawn A3E_FNC_ReportToHQ;",str A3E_VAR_Side_Opfor], ""];
- `Code/functions/SearchLeader/fn_PlayerDetection.sqf:32` - _indepTrigger setTriggerStatements["this && A3E_var_PlayerCanBeDetected", format["[""%1""] spawn A3E_FNC_ReportToHQ;",str A3E_VAR_Side_Ind], ""];
- `Code/functions/SearchLeader/fn_SearchLeaderInit.sqf:8` - _trigger setTriggerStatements["A3E_var_SearchLeaderTick", "[] spawn A3E_fnc_SearchLeader;A3E_var_SearchLeaderTick = false;", "A3E_var_SearchLeaderTick = true;"];
- `Code/functions/Server/fn_createLocationMarker.sqf:25` - _trigger setTriggerStatements["this",_activation ,""];
- `Code/functions/Server/fn_createLocationMarker.sqf:37` - _trigger setTriggerStatements["this",_activation ,""];
- `Code/functions/Server/fn_missionFlow.sqf:17` - _trigger setTriggerStatements["a3e_var_Escape_MissionComplete && !a3e_var_Escape_SearchLeader_civilianReporting && !a3e_var_Escape_AllPlayersDead", """end2"" call A3E_fnc_endMis...
- `Code/functions/Server/fn_missionFlow.sqf:26` - _trigger setTriggerStatements["a3e_var_Escape_MissionComplete &&  (missionNamespace getvariable [""A3E_Warcrime_Score"",0])>1000 && !a3e_var_Escape_AllPlayersDead", """end4"" ca...
- `Code/functions/Server/fn_missionFlow.sqf:34` - _trigger setTriggerStatements["a3e_var_Escape_MissionFailed_LeftBehind && !a3e_var_Escape_AllPlayersDead", """end3"" call A3E_fnc_endMissionServer;", ""];
- `Code/functions/Server/fn_missionFlow.sqf:42` - _trigger setTriggerStatements["a3e_var_Escape_AllPlayersDead", """end1"" call A3E_fnc_endMissionServer;", ""];
- `Code/functions/Server/fn_missionFlow.sqf:57` - _trigger setTriggerStatements["A3E_EscapeHasStarted && ([] call A3E_fnc_InlineEverybodyUnconscious)", "missionNamespace setvariable [""a3e_var_Escape_AllPlayersDead"",true,true]...
- `Code/functions/Server/fn_missionFlow.sqf:64` - _trigger setTriggerStatements["A3E_EscapeHasStarted && ({(_x distance A3E_StartPos) > 50} count (call BIS_fnc_listPlayers))>0", "A3E_Task_Prison_Complete = true;publicVariable "...
- `Code/functions/Server/fn_missionFlow.sqf:71` - _trigger setTriggerStatements["A3E_EscapeHasStarted && ({""ItemMap"" in (assignedItems _x)} count playableunits)>0", "A3E_Task_Map_Complete = true; publicvariable ""A3E_Task_Map...
- `Code/functions/Spawning/fn_initPatrolZone.sqf:58` - _trigger setTriggerStatements["this",_activation,""];
- `Code/functions/Spawning/fn_initPatrolZone.sqf:73` - _deactivationTrigger setTriggerStatements["this","",_deactivation];
- `Code/functions/Zones/fn_initZone.sqf:58` - _trigger setTriggerStatements["this && time > 1",_activation,""];
- `Code/functions/Zones/fn_initZone.sqf:73` - _deactivationTrigger setTriggerStatements["this","",_deactivation];
- `Code/Scripts/Escape/Functions.sqf:489` - _trigger setTriggerStatements["this", "_nil = [" + str _index + "] spawn drn_fnc_Escape_AddRemoveComCenArmor;", "_nil = [" + str _index + "] spawn drn_fnc_Escape_AddRemoveComCen...
- `Code/Scripts/Escape/SearchLeader.sqf:55` - _trigger setTriggerStatements["this", "a3e_var_SearchLeader_Detected = true;", ""];
- `Code/Scripts/Escape/SearchLeader.sqf:61` - _trigger2 setTriggerStatements["this", "a3e_var_SearchLeader_Detected = true;", ""];
- `Code/Scripts/Escape/SearchLeader.sqf:179` - _trigger setTriggerStatements["this", "a3e_var_SearchLeader_Detected = true;", ""];
- `Code/Scripts/Escape/SearchLeader.sqf:185` - _trigger2 setTriggerStatements["this", "a3e_var_SearchLeader_Detected = true;", ""];

## Appendix - Template arrays (A3E_*Templates)

Functions selected at runtime from these arrays (via callRandomFunction / getVariable).

- `Code/functions/Server/fn_createAmmoDepots.sqf:87` - private _AmmoDepotTemplates = missionnamespace getvariable ["A3E_AmmoDepotTemplates",["A3E_fnc_AmmoDepot","A3E_fnc_AmmoDepot2","A3E_fnc_AmmoDepot3","A3E_fnc_AmmoDepot4","A3E_fnc...
- `Code/functions/Server/fn_createComCenters.sqf:45` - private _ComCenterTemplates = missionnamespace getvariable ["A3E_ComCenterTemplates",["a3e_fnc_BuildComCenter","a3e_fnc_BuildComCenter2","a3e_fnc_BuildComCenter3","a3e_fnc_Build...
- `Code/functions/Server/fn_createMortarSites.sqf:93` - private _mortarSiteTemplates = missionnamespace getvariable ["A3E_MortarSiteTemplates",["A3E_fnc_MortarSite","A3E_fnc_MortarSite2"]];
- `Code/functions/Server/fn_createMotorPools.sqf:77` - private _MotorPoolTemplates = missionnamespace getvariable ["A3E_MotorPoolTemplates",["A3E_fnc_BuildMotorPool"]];
- `Code/functions/Server/fn_createStartpos.sqf:5` - private _template = (selectRandom (missionNamespace getVariable ["A3E_PrisonTemplates", ["a3e_fnc_BuildPrison", "a3e_fnc_BuildPrison1", "a3e_fnc_BuildPrison2", "a3e_fnc_BuildPri...
- `Code/functions/Server/fn_initServer.sqf:69` - [] call a3e_fnc_loadTemplates;
- `Code/functions/Server/fn_RoadBlocks.sqf:40` - private _templatesAvailable = missionnamespace getvariable ["A3E_RoadblockTemplates",[]];
- `Code/functions/Templates/fn_isoTemplateRestore.sqf:2` - private _templateIndex = A3E_Templates findIf {([_x,"Name",""] call BIS_fnc_getFromPairs) == _templateName};
- `Code/functions/Templates/fn_isoTemplateRestore.sqf:7` - private _template = A3E_Templates select _templateIndex;
- `Code/functions/Templates/fn_isoTemplateStore.sqf:92` - missionnamespace setvariable ["A3E_Templates",[_result]];
- `Code/functions/Templates/fn_LoadTemplates.sqf:1` - private _roadblocks = missionNamespace getvariable ["A3E_RoadblockTemplates",["rb_bis_rb1","rb_bis_rb2","rb_bis_rb3"]];
- `Code/functions/Templates/fn_LoadTemplates.sqf:28` - missionNamespace setvariable ["A3E_RoadblockTemplates",_roadblocks];
- `Code/functions/Templates/fn_LoadTemplates.sqf:42` - missionNamespace setvariable ["A3E_Templates",_templates];
- `Mods/CSLA-US/UnitClasses.sqf:437` - A3E_RoadblockTemplates = [
- `Mods/CSLA-US/UnitClasses.sqf:501` - A3E_MotorPoolTemplates = [
- `Mods/CSLA-US/UnitClasses.sqf:512` - A3E_ComCenterTemplates = [
- `Mods/CSLA-US/UnitClasses.sqf:626` - A3E_AmmoDepotTemplates = [
- `Mods/CSLA-US/UnitClasses.sqf:1022` - A3E_MortarSiteTemplates = [
- `Mods/GM-BW/UnitClasses.sqf:36` - A3E_PrisonTemplates = [
- `Mods/GM-BW/UnitClasses.sqf:482` - A3E_RoadblockTemplates = [
- `Mods/GM-BW w/UnitClasses.sqf:36` - A3E_PrisonTemplates = [
- `Mods/GM-BW w/UnitClasses.sqf:476` - A3E_RoadblockTemplates = [
- `Mods/GM-NVA/UnitClasses.sqf:36` - A3E_PrisonTemplates = [
- `Mods/GM-NVA/UnitClasses.sqf:430` - A3E_RoadblockTemplates = [
- `Mods/GM-NVA w/UnitClasses.sqf:36` - A3E_PrisonTemplates = [
- `Mods/GM-NVA w/UnitClasses.sqf:430` - A3E_RoadblockTemplates = [
- `Mods/SFP/UnitClasses.sqf:36` - A3E_PrisonTemplates = [
- `Mods/SFP/UnitClasses.sqf:489` - A3E_RoadblockTemplates = [
- `Mods/SFP d/UnitClasses.sqf:36` - A3E_PrisonTemplates = [
- `Mods/SFP d/UnitClasses.sqf:489` - A3E_RoadblockTemplates = [
- `Mods/SFP w/UnitClasses.sqf:36` - A3E_PrisonTemplates = [
- `Mods/SFP w/UnitClasses.sqf:457` - A3E_RoadblockTemplates = [
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:32` - A3E_PrisonTemplates = [
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:535` - A3E_RoadblockTemplates = [
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:598` - A3E_MotorPoolTemplates = [
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:609` - A3E_ComCenterTemplates = [
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:778` - A3E_AmmoDepotTemplates = [
- `Mods/SOGPF MACV vs PAVN-VC/UnitClasses.sqf:1258` - A3E_MortarSiteTemplates = [
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:32` - A3E_PrisonTemplates = [
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:458` - A3E_RoadblockTemplates = [
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:508` - A3E_MotorPoolTemplates = [
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:519` - A3E_ComCenterTemplates = [
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:633` - A3E_AmmoDepotTemplates = [
- `Mods/SOGPF PAVN vs ANZAC-ROK/UnitClasses.sqf:1108` - A3E_MortarSiteTemplates = [
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:34` - A3E_PrisonTemplates = [
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:497` - A3E_RoadblockTemplates = [
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:557` - A3E_MotorPoolTemplates = [
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:568` - A3E_ComCenterTemplates = [
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:750` - A3E_AmmoDepotTemplates = [
- `Mods/SOGPF PAVN vs MACV-ARVN/UnitClasses.sqf:1216` - A3E_MortarSiteTemplates = [
- `Mods/SPE GER vs US/UnitClasses.sqf:37` - A3E_PrisonTemplates = [
- `Mods/SPE GER vs US/UnitClasses.sqf:512` - A3E_RoadblockTemplates = [
- `Mods/SPE GER vs US/UnitClasses.sqf:577` - A3E_MotorPoolTemplates = [
- `Mods/SPE GER vs US/UnitClasses.sqf:588` - A3E_ComCenterTemplates = [
- `Mods/SPE GER vs US/UnitClasses.sqf:714` - A3E_AmmoDepotTemplates = [
- `Mods/SPE GER vs US/UnitClasses.sqf:1084` - A3E_MortarSiteTemplates = [
- `Mods/SPE US vs GER/UnitClasses.sqf:37` - A3E_PrisonTemplates = [
- `Mods/SPE US vs GER/UnitClasses.sqf:443` - A3E_RoadblockTemplates = [
- `Mods/SPE US vs GER/UnitClasses.sqf:491` - A3E_MotorPoolTemplates = [
- `Mods/SPE US vs GER/UnitClasses.sqf:502` - A3E_ComCenterTemplates = [
- `Mods/SPE US vs GER/UnitClasses.sqf:605` - A3E_AmmoDepotTemplates = [
- `Mods/SPE US vs GER/UnitClasses.sqf:974` - A3E_MortarSiteTemplates = [
- `Mods/Vanilla/UnitClasses.sqf:32` - A3E_PrisonTemplates = [
- `Mods/Vanilla/UnitClasses.sqf:964` - A3E_RoadblockTemplates = [
- `Mods/Vanilla/UnitClasses.sqf:1009` - A3E_MotorPoolTemplates = [
- `Mods/Vanilla/UnitClasses.sqf:1020` - A3E_ComCenterTemplates = [
- `Mods/Vanilla/UnitClasses.sqf:1138` - A3E_AmmoDepotTemplates = [
- `Mods/Vanilla/UnitClasses.sqf:1504` - A3E_MortarSiteTemplates = [

## Appendix - Event handlers (addEventHandler / CBA)

Functions invoked from **event-handler code blocks**.

- `Code/functions/ace/fn_GroundHandler.sqf:5` - _eventID = _unit addEventHandler ["Dammaged", { //Create EventHandler incase player gets damaged on ground
- `Code/functions/Common/fn_initLocalPlayer.sqf:39` - player addeventhandler["HandleRating","_this call A3E_FNC_handleRating;"];
- `Code/functions/Common/fn_initLocalPlayer.sqf:41` - player addeventhandler["InventoryClosed","_this call A3E_FNC_collectIntel;"];
- `Code/functions/Common/fn_initLocalPlayer.sqf:56` - // (findDisplay 46) displayAddEventHandler ["KeyDown","_nil=[_this select 1] call drn_fnc_Escape_DisableLeaderSetWaypoints"];
- `Code/functions/Common/fn_initLocalPlayer.sqf:57` - (findDisplay 46) displayAddEventHandler ["MouseButtonDown","_nil=[_this select 1] call drn_fnc_Escape_DisableLeaderSetWaypoints"];
- `Code/functions/Common/fn_initLocalPlayer.sqf:83` - (findDisplay 46) displayAddEventHandler ["keyDown", "_this call a3e_fnc_KeyDown"];
- `Code/functions/Server/fn_CreateExtractionPoint.sqf:34` - _location3 addeventhandler["firedNear",_code];
- `Code/functions/Server/fn_initPlayer.sqf:14` - _player addeventhandler["HandleScore","_this call A3E_FNC_handleScore;"];
- `Code/functions/Server/fn_initServer.sqf:46` - ["ace_unconscious", {params["_unit", "_isDown"]; [_unit,_isDown] spawn ACE_fnc_HandleUnconscious;}] call CBA_fnc_addEventHandler;
- `Code/functions/Server/fn_initServer.sqf:560` - _unit addEventHandler ["Killed", {
- `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf:6` - _group addEventHandler ["EnemyDetected", {_this call A3E_fnc_onEnemyDetected;}];
- `Code/functions/Spawning/fn_onCivilianGroupSpawn.sqf:8` - _group addEventHandler ["KnowsAboutChanged", {
- `Code/functions/Spawning/fn_onCivilianSpawn.sqf:26` - _unit addEventHandler ["Killed", {
- `Code/functions/Spawning/fn_onCivilianSpawn.sqf:43` - _unit addEventHandler["FiredNear",{
- `Code/functions/Spawning/fn_onEnemyGroupSpawn.sqf:5` - _grp addEventHandler ["EnemyDetected", {_this call A3E_fnc_onEnemyDetected;}];
- `Code/functions/Spawning/fn_onEnemySoldierSpawn.sqf:136` - _unit addEventHandler ["Killed", {
- `Code/Revive/functions/HSC/fn_createCam.sqf:34` - ATHSC_KeyDownHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call ATHSC_FNC_keydown;"];
- `Code/Revive/functions/HSC/fn_createCam.sqf:38` - ATHSC_MouseHandler = (findDisplay 46) displayAddEventHandler ["MouseMoving", "_this call ATHSC_FNC_mouseMove;"];
- `Code/Revive/functions/HSC/fn_createCam.sqf:42` - ATHSC_MouseZHandler = (findDisplay 46) displayAddEventHandler ["MouseZChanged", "_this call ATHSC_FNC_mouseZMove;"];
- `Code/Revive/functions/HSC/fn_createCam.sqf:44` - //ATHSC_MouseKeyHandler = (findDisplay 46) displayAddEventHandler ["MouseButtonClick", "_this call ATHSC_FNC_mousekeyclick;"];
- `Code/Revive/functions/Revive/fn_AddVehicleWatchdog.sqf:4` - _EH = _vehicle addEventHandler ["GetOut", {_this spawn ATR_FNC_WatchVehicle;}];
- `Code/Revive/functions/Revive/fn_InitPlayer.sqf:10` - player addEventHandler ["HandleDamage", ATR_FNC_HandleDamage];
- `Code/Revive/functions/Revive/fn_ReviveInit.sqf:28` - player addEventHandler
- `Code/Revive/functions/Revive/fn_ReviveInit.sqf:43` - _x addEventHandler ["HandleDamage", ATR_FNC_HandleDamage];
- `Code/Scripts/AT/dronehack_init.sqf:10` - player addEventHandler
- `Code/Scripts/outlw_magRepack/MagRepack_init_sv.sqf:58` - (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call outlw_MR_keyDown;"];

