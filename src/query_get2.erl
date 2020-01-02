%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 11月 2019 8:14 下午
%%%-------------------------------------------------------------------
-module(query_get2).
-author("lunay").

%% API
-export([init/2]).

init(Req0, Opts) ->
  Method = cowboy_req:method(Req0),
  #{echo := Echo} = cowboy_req:match_qs([{echo, [], undefined}], Req0),
  Req = echo(Method, Echo, Req0),
  {ok, Req, Opts}.

echo(<<"GET">>, undefined, Req) ->
  cowboy_req:reply(400, #{}, <<"Missing echo parameter.">>, Req);

echo(<<"GET">>, Echo, Req) ->
  {ok, Data} = hope_sql:fetch_one2(Echo),
%%  io:format("~p~n", [Data]),
  RespBody = jsx:encode([{<<"status">>, <<"ok">>}, {<<"data">>, Data}]),
  io:format("~p~n", [RespBody]),
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"application/json; charset=utf-8">>
  }, RespBody, Req);

echo(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).
