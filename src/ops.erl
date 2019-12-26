%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Sep 2019 下午4:27
%%%-------------------------------------------------------------------
-module(ops).
-author("lunay").

%% API
-export([add/2, new_add/3]).

add(A,B) -> A + B.

new_add(A, B, C) -> A + B + C.

