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

%%开启网关服务
start_gateway()->
	{ok, Start} = application:get_env(gateway, start),
	io:format("Gatewany is :~p~n", [Start]),

	{ok, Gateway_Server_Port} = application:get_env(gateway, server_port),

	if
		Start =:= 1 ->
			Dispatch = cowboy_router:compile([
				{'_', [
					{"/", cowboy_static, {priv_file, cbtx, "index.html"}},
					{"/post", post_demo, []},
					{"/compress/res", compress_response, []},
					{"/hello/world", hello_world, []},
					{"/eventsource", eventsource_h, []},
					{"/static/[...]", cowboy_static, {priv_dir, cbtx, ""}},
					{"/rest/basic/auth", rest_basic_auth, []},
					{"/hello/to", hello_to, []},
					{"/assets/[...]", cowboy_static, {priv_dir, cbtx, "", [{mimetypes, cow_mimetypes, all}]}},

					{"/file/server/[...]", cowboy_static, {priv_dir, cbtx, "", [
						{mimetypes, cow_mimetypes, all}, {dir_handler, directory_h}]}},

					{"/file/upload", cowboy_static, {priv_file, cbtx, "upload.html"}},
					{"/do/upload", upload_h, []},
					{"/websocket", cowboy_static, {priv_file, cbtx, "ws.html"}},
					{"/ws", ws, []},
					{"/echo/get", echo_get, []},
					{"/echo/get2", echo_get2, []},
					{"/echo/post", echo_post, []},
					{"/rest/hello/world", rest_hello_world, []},
					{"/rest/pastebin/[:paste_id]", rest_pastebin, []},
					{"/rest/post/demo", rest_post_demo, []},
					{"/get/data/list", query_get, []},
					{"/get2/data/list", query_get2, []}
				]}
			]),
			{ok, _} = cowboy:start_clear(gateway_listener, [{port, Gateway_Server_Port}], #{
				env => #{dispatch => Dispatch},
				stream_handlers => [cowboy_compress_h, cowboy_stream_h],
				middlewares => [cowboy_router, cowboy_handler]
			});
		true ->
			ok
	end.


start_game_server()->
	%% TCP Websocket
	GameServerDispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, cbtx, "ws.html"}},
			{"/ws", game_ws_handler, []}
		]}
	]),

%%	提取websocket/server_port服务端口
	{ok, Websocket_Port} = application:get_env(game_server, websocket_port),
	{ok, Server_Port} = application:get_env(game_server, server_port),

	{ok, _} = cowboy:start_clear(game_server_listener, [{port, Websocket_Port}], #{
		env => #{dispatch => GameServerDispatch},
		stream_handlers => [cowboy_compress_h, cowboy_stream_h],
		middlewares => [cowboy_router, cowboy_handler]
	}),

	{ok, _} = ranch:start_listener(tcp_reverse,
		ranch_tcp, [{port, Server_Port}], reverse_protocol, []).

start(_StartType, _StartArgs) ->
	application:start(lager),
	application:start(eredis_pool),
	application:start(eredis_cluster),

%%	HTTP AND Websocket
%%	启动游戏服务
	start_game_server(),

%%  开启网关服务
	start_gateway(),
	ok = game_mnesia:mnesia_start(),
	Ret = cbtx_sup:start_link(),
	ok = game_ets:ets_start(),
	Ret.



prep_stop(State) ->
	ok = ranch:suspend_listener(my_listener),
	ok = ranch:wait_for_connections(my_listener, '==', 0),
	ok = ranch:stop_listener(my_listener),

	application:stop(lager),
	application:stop(eredis_pool),
	application:stop(eredis_cluster),
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
