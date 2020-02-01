-module(game_util).

-export([
    unixtime/0
]).

unixtime() ->
    {GSec, Sec, _MiSec} = erlang:timestamp(), 
    round(GSec * math:pow(10,6) + Sec).