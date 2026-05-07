const std = @import("std");
const builtin = @import("builtin");

pub const Id = u64;
pub const AppId = u32;

pub const ApiCall = c_ulonglong;
pub const AccountID = c_uint;
pub const PartyBeaconID = c_ulonglong;
pub const HAuthTicket = c_uint;

pub const PFNPreMinidumpCallback = ?*const fn (?*anyopaque) callconv(.c) void;

pub const Pipe = c_int;

pub const ErrMsg = [1024]u8;

pub const FriendsGroupID = c_short;

pub const HServerListRequest = ?*anyopaque;
pub const HServerQuery = c_int;

pub const UGCHandle = c_ulonglong;
pub const PublishedFileUpdateHandle = c_ulonglong;
pub const PublishedFileId = c_ulonglong;
pub const UGCFileWriteStreamHandle = c_ulonglong;

pub const Leaderboard = c_ulonglong;
pub const LeaderboardEntries = c_ulonglong;

pub const SNetSocket = c_uint;
pub const SNetListenSocket = c_uint;

pub const ScreenshotHandle = c_uint;
pub const HTTPRequestHandle = c_uint;
pub const HTTPCookieContainerHandle = c_uint;

pub const InputHandle = c_ulonglong;
pub const InputActionSetHandle = c_ulonglong;
pub const InputDigitalActionHandle = c_ulonglong;
pub const InputAnalogActionHandle = c_ulonglong;

// pub const InputActionEventCallbackPointer = ?*const fn (*InputActionEvent) callconv(.c) void;

pub const ControllerHandle = c_ulonglong;
pub const ControllerActionSetHandle = c_ulonglong;
pub const ControllerDigitalActionHandle = c_ulonglong;
pub const ControllerAnalogActionHandle = c_ulonglong;

pub const UGCQueryHandle = c_ulonglong;
pub const UGCUpdateHandle = c_ulonglong;

pub const HHTMLBrowser = c_uint;

pub const ItemInstanceID = c_ulonglong;
pub const ItemDef = c_int;
pub const InventoryResult = c_int;
pub const InventoryUpdateHandle = c_ulonglong;

pub const TimelineEventHandle = c_ulonglong;

pub const RemotePlaySessionID = c_uint;
pub const RemotePlayCursorID = c_uint;

// pub const NetConnectionStatusChanged = ?*const fn (*NetConnectionStatusChangedCallback) callconv(.c) void;

// pub const NetAuthenticationStatusChanged = ?*const fn (*NetAuthenticationStatus) callconv(.c) void;

// pub const RelayNetworkStatusChanged = ?*const fn (*RelayNetworkStatus) callconv(.c) void;

pub const NetworkingMessagesSessionRequest = ?*const fn (*NetworkingMessagesSessionRequest) callconv(.c) void;

pub const NetworkingMessagesSessionFailed = ?*const fn (*NetworkingMessagesSessionFailed) callconv(.c) void;

pub const NetworkingFakeIPResult = ?*const fn (*NetworkingFakeIPResult) callconv(.c) void;

pub const NetConnection = c_uint;
pub const ListenSocket = c_uint;
pub const NetPollGroup = c_uint;

pub const NetworkingErrMsg = [1024]u8;

pub const NetworkingPOPID = c_uint;
pub const NetworkingMicroseconds = c_longlong;

pub const NetworkPingLocation = extern struct {
    data: [512]u8,
};

pub const NetworkingIdentity = extern struct {
    e_type: c_int,
    data: union {
        m_steamID: Id,
        m_ip: [16]u8,
    },
};

pub const NetworkingIPAddr = extern struct {
    data: [16]u8,
};

pub const RelayNetworkStatusChanged = extern struct {
    data: [256]u8,
};

pub const NetConnectionStatusChanged = extern struct {
    data: [256]u8,
};

pub const NetAuthenticationStatusChanged = extern struct {
    data: [256]u8,
};

pub const NetworkingSocketsDebugOutput = extern struct {
    data: [256]u8,
};

pub const NetworkingMessage = extern struct {
    data: [128]u8,
};

pub const NetworkingConnectionSignaling = extern struct {
    data: [256]u8,
};

pub const NetworkingSignalingRecvContext = extern struct {
    data: [256]u8,
};

pub const DatagramGameCoordinatorServerLogin = extern struct {
    data: [128]u8,
};

pub const DatagramHostedAddress = extern struct {
    data: [64]u8,
};

pub const DatagramRelayAuthTicket = extern struct {
    data: [128]u8,
};

pub const NetConnectionInfo = extern struct {
    data: [256]u8,
};

pub const P2PSessionState = extern struct {
    data: [64]u8,
};

pub const RTime32 = u32;
pub const DepotId = u32;

pub const ParamStringArray = extern struct {
    data: [256]u8,
};

pub const UGCDetails = extern struct {
    data: [512]u8,
};

pub const LeaderboardEntry = extern struct {
    data: [128]u8,
};

pub const MatchMakingKeyValuePair = extern struct {
    data: [128]u8,
};

pub const FriendGameInfo = extern struct {
    data: [64]u8,
};

pub const Inventory = extern struct {
    data: [256]u8,
};

pub const Screenshots = extern struct {
    data: [128]u8,
};

pub const gameserveritem = extern struct {
    data: [512]u8,
};

pub const PartyBeaconLocation = extern struct {
    data: [128]u8,
};

pub const RelayNetworkStatus = extern struct {
    data: [512]u8,
};

pub const IPAddress = extern struct {
    data: [16]u8,
};

pub const NetAuthenticationStatus = extern struct {
    data: [256]u8,
};

pub const NetConnectionRealTimeStatus = extern struct {
    data: [256]u8,
};

pub const InputMotionData = extern struct {
    data: [64]u8,
};

pub const NetConnectionRealTimeLaneStatus = extern struct {
    data: [256]u8,
};

pub const RemotePlayInput = extern struct {
    data: [128]u8,
};

pub const ItemDetails = extern struct {
    data: [256]u8,
};

pub const ScePadTriggerEffectParam = extern struct {
    data: [64]u8,
};

pub const InputAnalogActionData = extern struct {
    x: f32,
    y: f32,
    active: bool,
};

pub const InputDigitalActionData = extern struct {
    active: bool,
    state: bool,
};

pub const InputActionEvent = extern struct {
    data: [64]u8,
};

pub const InputActionEventCallbackPointer = ?*const fn (*InputActionEvent) callconv(.c) void;

pub const APIWarningMessageHook = ?*const fn (c_int, [*:0]const u8) callconv(.c) void;

pub const Input = u64;

pub const CGameID = u64;
// pub const NetworkingSocketsDebugOutput = ?*const fn (NetworkingSocketsDebugOutputType, [*:0]const u8) callconv(.c) void;

pub const HTMLKeyModifiers = packed struct(u8) {
    shift: bool = false,
    ctrl: bool = false,
    alt: bool = false,
    meta: bool = false,

    pub const none: HTMLKeyModifiers = .{};
};

pub const HTMLMouseButton = enum(u8) {
    left = 0,
    middle = 1,
    right = 2,

    // optional extended buttons
    back = 3,
    forward = 4,
};

pub const InitResult = enum(c_int) {
    ok = 0,
    /// Some other failure
    failed_generic = 1,
    /// We cannot connect to Steam, steam probably isn't running
    no_steam_client = 2,
    /// Steam client appears to be out of date
    version_mismatch = 3,

    pub const Error = error{
        FailedGeneric,
        NoSteamClient,
        VersionMismatch,
    };
};

extern fn SteamAPI_InitFlat(out_err_msg: ?*ErrMsg) InitResult;

/// See also:
/// * `shutdown`
pub fn init() InitResult.Error!void {
    const result = switch (builtin.mode) {
        .Debug, .ReleaseSafe => result: {
            var err_msg: ErrMsg = undefined;
            const result = SteamAPI_InitFlat(&err_msg);
            if (result != .ok) std.log.err("{s}", .{err_msg});
            break :result result;
        },
        else => SteamAPI_InitFlat(null),
    };
    return switch (result) {
        .ok => {},
        .failed_generic => error.FailedGeneric,
        .no_steam_client => error.NoSteamClient,
        .version_mismatch => error.VersionMismatch,
    };
}

extern fn SteamAPI_Shutdown() void;
pub const shutdown = SteamAPI_Shutdown;

extern fn SteamAPI_RestartAppIfNecessary(unOwnAppID: u32) bool;
pub const restartAppIfNecessary = SteamAPI_RestartAppIfNecessary;

extern fn SteamAPI_ReleaseCurrentThreadMemory() void;
pub const releaseCurrentThreadMemory = SteamAPI_ReleaseCurrentThreadMemory;
