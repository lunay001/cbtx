%%%-------------------------------------------------------------------
%% @doc cbtx public API
%% @end
%%%-------------------------------------------------------------------
-module(cbtx_app).
-include("common.hrl").
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).
-export([prep_stop/1]).

%%====================================================================
%% API
%%====================================================================
start(_StartType, _StartArgs) ->
	application:start(lager),
	application:start(eredis_pool),
	application:start(eredis_cluster),
	application:start(mnesia),

%%	HTTP AND Websocket
%%	启动游戏服务
	server_box:start_game_server(),

%%  开启网关服务
	server_box:start_gateway(),

	ok = game_mnesia:mnesia_start(),
	Ret = cbtx_sup:start_link(),
	ok = game_ets:ets_start(),
	Ret.

prep_stop(State) ->
	ok = ranch:suspend_listener(game_server_listener),
	ok = ranch:wait_for_connections(game_server_listener, '==', 0),
	ok = ranch:stop_listener(game_server_listener),

	application:stop(lager),
	application:stop(eredis_pool),
	application:stop(eredis_cluster),
	application:stop(mnesia),

	State.

start()->
  io:format("~w~n", [good]),
	lager:info("start......................"),
  ok.


%%--------------------------------------------------------------------
stop(_State) ->
  ok.

%%====================================================================
%% Internal functions
%%====================================================================
