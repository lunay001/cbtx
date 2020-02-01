-module(game_ets).
-export([
    ets_start/0
]).

ets_start() ->
    lists:foreach(fun({EtsName, Options}) -> 
                    supervisor:start_child(game_ets_sup, [{EtsName, Options}]) 
                end, ets_data:get_init_ets_list()),
    game_debug:debug(error, "~n cache ets is starting succeed!!! ~n").
