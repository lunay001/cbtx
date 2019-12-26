%%%-------------------------------------------------------------------
%% @doc cbtx public API
%% @end
%%%-------------------------------------------------------------------
-module(cbtx_app).
-include("common.hrl").
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
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
		{"/rest/pastebin", rest_pastebin, []},
		{"/rest/post/demo", rest_post_demo, []}
		]}
  ]),
  {ok, _} = cowboy:start_clear(http, [{port, ?SERVER_PORT}], #{
	  env => #{dispatch => Dispatch},
	  stream_handlers => [cowboy_compress_h, cowboy_stream_h],
	  middlewares => [cowboy_router, cowboy_handler]
  }),

    lager:start(),
%%  redis连接池服务
	eredis_pool:start(),
	lager:info("Larger is start ......"),
    cbtx_sup:start_link().


start()->
  io:format("~w~n", [good]),
  ok.



%%--------------------------------------------------------------------
stop(_State) ->
  ok.

%%====================================================================
%% Internal functions
%%====================================================================
