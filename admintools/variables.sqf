// Do not modify this file unless you know what you are doing

AdminList = AdminList + SuperAdminList; // add SuperAdmin to Admin
AdminAndModList = AdminList + ModList; // Add all admin/mod into one list for easy call

tempList = []; // Initialize templist
helpQueue = []; // Initialize help queue

/*
	Determines default on or off for admin tools menu
	Set this to false if you want the menu to be off by default.
	F11 turns the tool off, F10 turns it on.
	Leave this as True for now, it is under construction.
*/
if (isNil "toolsAreActive") then {toolsAreActive = true;};


// load server public variables
if(isDedicated) then {
	"usageLogger" addPublicVariableEventHandler {
		"EATadminLogger" callExtension (_this select 1);
		diag_log format ["CHILD:667:%1", (_this select 1)];	//Epoch Linux Dedi - usageLogger integration (log2FILE+STDERR)
	};
	"useBroadcaster" addPublicVariableEventHandler {
		EAT_toClient = (_this select 1);
		{
		if ((getPlayerUID _x ) in AdminList) then {
			(owner _x) publicVariableClient "EAT_toClient";
			};		
		} forEach entities "CAManBase";
	};
	"EAT_baseExporter" addPublicVariableEventHandler {
		"EATbaseExporter" callExtension (_this select 1);
	};
	"EAT_teleportFixServer" addPublicVariableEventHandler{
		_array = (_this select 1);
		_addRemove = (_array select 0);

		if(_addRemove == "add") then {
			_array = _array - ["add"];
			tempList = tempList + _array;
		} else {
			_array = _array - ["remove"];
			tempList = tempList - _array;
		};
		EAT_teleportFixClient = tempList;
		{(owner _x) publicVariableClient "EAT_teleportFixClient";} forEach entities "CAManBase";
	};
	"EAT_SetDateServer" addPublicVariableEventHandler {
		EAT_setDateClient = (_this select 1);
		setDate EAT_setDateClient;
		{(owner _x) publicVariableClient "EAT_setDateClient";} forEach entities "CAManBase";
	};
	"EAT_SetOvercastServer" addPublicVariableEventHandler {
		EAT_setOvercastClient = (_this select 1);
		5 setOvercast EAT_setOvercastClient;
		{(owner _x) publicVariableClient "EAT_setOvercastClient";} forEach entities "CAManBase";
	};
	"EAT_SetFogServer" addPublicVariableEventHandler {
		EAT_setFogClient = (_this select 1);
		5 setFog EAT_setFogClient;
		{(owner _x) publicVariableClient "EAT_setFogClient";} forEach entities "CAManBase";
	};
	"EAT_contactAdminServer" addPublicVariableEventHandler {
		_array = (_this select 1);
		_addRemove = (_array select 0);

		if(_addRemove == "add") then {
			_array = _array - ["add"];
			helpQueue = helpQueue + _array;
			diag_log format ["CHILD:666:Player *%1* needs assistance on the server!", _array];  //Epoch Linux Dedi - Slack WebHook Push Notification
		} else {
			_array = _array - ["remove"];
			helpQueue = helpQueue - _array;
			diag_log format ["CHILD:666:Player *%1 no longer* needs assistance on the server!", _array];  //Epoch Linux Dedi - Slack WebHook Push Notification
		};
		EAT_contactAdminClient = helpQueue;
		{
			if ((getPlayerUID _x) in AdminAndModList) then {	//check if the clientID(uniqueID) is an admin|mod, if : then set contactAdminC... 
				(owner _x) publicVariableClient "EAT_contactAdminClient";
			};
		} forEach entities "CAManBase";
	};
};

// Client public variables
if ((getPlayerUID player) in SuperAdminList) then {
	"EAT_toClient" addPublicVariableEventHandler {
		systemChat (_this select 1);
	};
};

"EAT_teleportFixClient" addPublicVariableEventHandler {
	tempList = (_this select 1);
};

"EAT_SetDateClient" addPublicVariableEventHandler {
	setDate (_this select 1);
};
"EAT_setOvercastClient" addPublicVariableEventHandler {
	drn_fnc_DynamicWeather_SetWeatherLocal = {};
	5 setOvercast (_this select 1);
};
"EAT_setFogClient" addPublicVariableEventHandler {
	drn_fnc_DynamicWeather_SetWeatherLocal = {};
	5 setFog (_this select 1);
};

"EAT_contactAdminClient" addPublicVariableEventHandler {
	helpQueue = (_this select 1);
	if ((getPlayerUID player) in AdminAndModList) then {
		systemChat "****A player needs help****";
	};
};

// overwrite epoch public variables
"PVDZE_plr_SetDate" addPublicVariableEventHandler {};

// Show the admin list has loaded
adminListLoaded = true;
diag_log("Admin Tools: variables.sqf loaded");
