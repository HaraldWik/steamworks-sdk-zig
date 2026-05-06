const std = @import("std");

pub const ErrMsg = [1024]u8;

pub const ESteamAPIInitResult = enum(c_int) {
    pub const ok = 0;
    /// Some other failure
    pub const failed_generic = 1;
    /// We cannot connect to Steam, steam probably isn't running
    pub const no_steam_client = 2;
    /// Steam client appears to be out of date
    pub const version_mismatch = 3;
};

/// See "Initializing the Steamworks SDK" above for how to choose an init method.
/// On success k_ESteamAPIInitResult_OK is returned. Otherwise, returns a value that can be used
/// to create a localized error message for the user. If pOutErrMsg is non-NULL,
/// it will receive an example error message, in English, that explains the reason for the failure.
///
/// Example usage:
/// ```zig
/// var err_msg: ErrMsg = undefined;
///
/// ```
///   SteamErrMsg errMsg;
///   if ( SteamAPI_Init(&errMsg) != k_ESteamAPIInitResult_OK )
///       FatalError( "Failed to init Steam.  %s", errMsg );
///
extern fn SteamAPI_InitEx(out_err_msg: ?*ErrMsg) ESteamAPIInitResult;
pub const initEx = SteamAPI_InitEx;

/// See "Initializing the Steamworks SDK" above for how to choose an init method.
/// Returns true on success
/// See also:
/// * `initEx`
pub fn init() bool {
    return initEx(null) == .ok;
}

extern fn SteamAPI_Shutdown() void;
pub const shutdown = SteamAPI_Shutdown;

extern fn SteamAPI_RestartAppIfNecessary(unOwnAppID: u32) bool;
pub const restartAppIfNecessary = SteamAPI_RestartAppIfNecessary;

extern fn SteamAPI_ReleaseCurrentThreadMemory() void;
pub const releaseCurrentThreadMemory = SteamAPI_ReleaseCurrentThreadMemory;
