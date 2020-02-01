-module(game_debug).
-export([
        debug/2, debug/3
    ]).

debug(info, String) ->
    game_log:info(String);
debug(warning, String) ->
    game_log:warning(String);
debug(error, String) ->
    game_log:error(String);
debug(info_error, String) ->
    debug(info, String),
    debug(error, String).


debug(info, FormatStr, ArgsList) ->
    game_log:info(FormatStr, ArgsList);
debug(warning, FormatStr, ArgsList) ->
    game_log:warning(FormatStr, ArgsList);
debug(error, FormatStr, ArgsList) ->
    game_log:error(FormatStr, ArgsList);
debug(info_error,FormatStr, ArgsList) ->
    debug(info, FormatStr, ArgsList),
    debug(error, FormatStr, ArgsList).