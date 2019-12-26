%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Sep 2019 上午11:36
%%%-------------------------------------------------------------------
-module(hello_world).
-author("lunay").

%% API
-export([init/2]).

init(Req0, Opts) ->
	Req = cowboy_req:stream_reply(200, Req0),
	cowboy_req:stream_body("Hello\r\n", nofin, Req),
	timer:sleep(1000),
	cowboy_req:stream_body("World\r\n", nofin, Req),
	timer:sleep(1000),
	cowboy_req:stream_body("Chunked!\r\n", fin, Req),
	{ok, Req, Opts}.
