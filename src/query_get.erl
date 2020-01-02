%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 11月 2019 8:14 下午
%%%-------------------------------------------------------------------
-module(query_get).
-author("lunay").

%% API
-export([init/2]).

init(Req0, Opts) ->
  Method = cowboy_req:method(Req0),
  Req = echo(Method, undefined, Req0),
  {ok, Req, Opts}.

echo(<<"GET">>, _, Req) ->
  {ok, DataList} = hope_sql:fetch_rows(),
  io:format("~p~n", [DataList]),
  RespBody = jsx:encode([{<<"msg">>, <<"ok">>}, {<<"data">>, DataList}]),
  io:format("~p~n", [RespBody]),
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"application/json; charset=utf-8">>
  }, RespBody, Req);

echo(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).
