%% Feel free to use, reuse and abuse the code in this file.

%% @doc GET echo handler.
-module(echo_get2).
-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	#{n := N} = cowboy_req:match_qs([{n, [], undefined}], Req0),
	Req = echo(Method, N, Req0),
	{ok, Req, Opts}.

echo(<<"GET">>, undefined, Req) ->
	cowboy_req:reply(400, #{}, <<"Missing echo parameter.">>, Req);

echo(<<"GET">>, N, Req) ->
	io:format("n:>>> ~p~n", [N]),
	{ok, FieldList, UserList} = hope_sql:fetch_rows(N),

	io:format("UserList:>>> ~p~n", [UserList]),

	DataList = [lists:zip(FieldList, User) || User <- UserList],
	RespBody = jsx:encode([{<<"msg">>, <<"ok">>}, {<<"code">>, 200}, {<<"data">>, DataList}]),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RespBody, Req);

echo(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).