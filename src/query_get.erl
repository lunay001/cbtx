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
  #{size := Size} = cowboy_req:match_qs([{size, [], undefined}], Req0),
  S = case Size =:= undefined of
        true ->
          100;
        false ->
          try binary_to_integer(Size) of
            R -> R
          catch
            Class:Reason:Stacktrace ->
              lager:error(
                "~nStacktrace:~s",
                [lager:pr_stacktrace(Stacktrace, {Class, Reason})]),
                10
          end
      end,

  Req = echo(Method, S, Req0),
  {ok, Req, Opts}.

echo(<<"GET">>, Size, Req) ->
  io:format("Size: >>  ~p~n", [Size]),
  {ok, DataList} = db_test:fetch_datas(Size),
  io:format("~p~n", [DataList]),
  RespBody = jsx:encode([{<<"msg">>, <<"ok">>}, {<<"data">>, DataList}]),
  io:format("~p~n", [RespBody]),
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"application/json; charset=utf-8">>
  }, RespBody, Req);


echo(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).


