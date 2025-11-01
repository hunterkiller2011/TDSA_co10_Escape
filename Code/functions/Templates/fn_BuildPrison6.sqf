// Object composition created and exported with Map Builder
// See www.map-builder.info - Map Builder by NeoArmageddon
// Call this script by [Position,Rotation] execVM "filename.sqf"
//Slum house small 2 doors and window, flag, speakers, burning barrels x 2 and sandbags


private["_obj","_pos"];
params ["_center","_rotation","_backpack"];

//Stuff that needs to be global
if(isserver) then {
	[_center,25] call a3e_fnc_cleanupTerrain;
	
	_pos = [_center,_center vectorAdd [4.2,2.2,0],_rotation] call A3E_fnc_rotatePosition;
	_obj = "Land_Barracks_05_F" createVehicle _pos;
	_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
	_obj setdir ((getdir _obj) + _rotation);
	_obj setPosATL _pos;
	_obj allowDamage false;
	_bpos = _pos;
	_height = getTerrainHeightASL (getPosATL _obj);
	_height = getposASL _obj;
	
	_pos = [_center,_center vectorAdd [9.8,2.3,0],_rotation] call A3E_fnc_rotatePosition;
	_obj = "Land_Wall_Gate_Village" createVehicle _pos;
	_obj setVectorDirAndUp [[-1,1.19249e-08,0],[0,0,1]];
	_obj setdir ((getdir _obj) + _rotation);
	_obj setPosATL _pos;
	_obj allowDamage false;
	_npos = getPos _obj;
	_num = _height select 2;
	_nnum = _num + 0.18;
	_npos set [2, _nnum];
	_obj setPosASL _npos;

	A3E_PrisonGateObject = _obj;
	
	_pos = [_center,_center vectorAdd [0.4,6.4,0],_rotation] call A3E_fnc_rotatePosition;
	_obj = "Land_Loudspeakers_F" createVehicle _pos;
	_obj setVectorDirAndUp [[-0.689121,0.724646,0],[0,0,1]];
	_obj setdir ((getdir _obj) + _rotation);
	_obj setPosATL _pos;

	A3E_PrisonLoudspeakerObject = _obj;
	publicvariable "A3E_PrisonLoudspeakerObject";

	_pos = [_center,_center vectorAdd [random 2.0 - 1, random 2.0 -1,0],_rotation] call A3E_fnc_rotatePosition;
	_backpack setdir ((getdir _backpack) + _rotation);
	_backpack setPosATL _pos;
	
};

//Stuff that can be local and is created duplicated on each client. This reduces network traffic at start.
_pos = [_center,_center vectorAdd [4.6,-2.2,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Wall_bis_HBarrier5_01" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-1.2,-2.2,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Wall_bis_HBarrier5_01" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-7.0,-2.2,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Wall_bis_HBarrier5_01" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [4.6,6.7,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Wall_bis_HBarrier5_01" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-1.3,6.7,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Wall_bis_HBarrier5_01" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-7.1,6.7,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Wall_bis_HBarrier5_01" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-6.5,5.2,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Wall_bis_HBarrier5_01" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [10.4,6.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "FlagPole_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [10.4,4.6,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_SandbagBarricade_01_F" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [10.4,0,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_SandbagBarricade_01_F" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [8.1,-1.5,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [4.8,-1.5,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[-8.74228e-08,-1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [1.2,-1.5,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-3.4,-1.5,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[-8.74228e-08,-1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [7.6,6.0,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [4.0,6.0,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[-8.74228e-08,-1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-.6,6.0,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-3.8,6.0,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Long_F" createVehicle _pos;
_obj setVectorDirAndUp [[-8.74228e-08,-1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-5.9,4.6,1.35931],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_BagFence_Short_F" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-7.1,-.3,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Fire_barrel" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-6.2,-.3,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_PortableLight_single_F" createVehicle _pos;
_obj setVectorDirAndUp [[0.866025,0.5,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [10.4,-1.8,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_PortableLight_single_F" createVehicle _pos;
_obj setVectorDirAndUp [[-0.5,0.866025,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [10.4,6.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_PortableLight_double_F" createVehicle _pos;
_obj setVectorDirAndUp [[-0.766045,-0.642788,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [10.4,7.3,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Portable_generator_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-10.7,6.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_FenceD_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-10.8,-1.6,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-6.8,-5.6,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [1.2,-5.6,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [-6.8,10.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[-8.74228e-08,-1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [1.2,10.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[-8.74228e-08,-1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [9.2,10.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[-8.74228e-08,-1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [9.2,-5.6,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_8m_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [13.2,3.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_Gate_F" createVehicle _pos;
_obj setVectorDirAndUp [[-1,1.19249e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [13.2,8.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_4m_F" createVehicle _pos;
_obj setVectorDirAndUp [[-1,1.19249e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [13.2,-1.5,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_4m_F" createVehicle _pos;
_obj setVectorDirAndUp [[-1,1.19249e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [13.2,-3.6,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Net_Fence_4m_F" createVehicle _pos;
_obj setVectorDirAndUp [[1,-4.37114e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [15.6,6.8,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_CampingChair_V2_F" createVehicle _pos;
_obj setVectorDirAndUp [[-1,1.19249e-08,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [15.9,9.2,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_CampingChair_V2_white_F" createVehicle _pos;
_obj setVectorDirAndUp [[-0.642788,0.766044,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [18.7,9.3,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_ChairPlastic_F" createVehicle _pos;
_obj setVectorDirAndUp [[0.939693,-0.34202,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [17.6,6.9,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Campfire_burning" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [17.6,7.0,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Garbage_square5_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;

_pos = [_center,_center vectorAdd [20.1,6.4,0],_rotation] call A3E_fnc_rotatePosition;
_obj = "Land_Tyre_F" createVehicle _pos;
_obj setVectorDirAndUp [[0,1,0],[0,0,1]];
_obj setdir ((getdir _obj) + _rotation);
_obj setPosATL _pos;
