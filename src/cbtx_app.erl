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

%%	HTTP AND Websocket
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

  	{ok, _} = cowboy:start_clear(http, [{port, ?SERVER_PORT}], #{
		env => #{dispatch => Dispatch},
		stream_handlers => [cowboy_compress_h, cowboy_stream_h],
		middlewares => [cowboy_router, cowboy_handler]
  	}),

	lager:info("Larger is start ......"),

	%% TCP
	{ok, _} = ranch:start_listener(my_listener,
		ranch_tcp, [{port, 5555}, {max_connections, 100}],
		echo_protocol, []
	),

	{ok, _} = ranch:start_listener(tcp_reverse,
		ranch_tcp, [{port, 6666}], reverse_protocol, []),

    cbtx_sup:start_link().


prep_stop(State) ->
	ok = ranch:suspend_listener(my_listener),
	ok = ranch:wait_for_connections(my_listener, '==', 0),
	ok = ranch:stop_listener(my_listener),
	State.

start()->
  io:format("~w~n", [good]),
  ok.



%%--------------------------------------------------------------------
stop(_State) ->
  ok.

%%====================================================================
%% Internal functions
%%====================================================================
