%% Feel free to use, reuse and abuse the code in this file.

%% @doc GET echo handler.
-module(echo_get).
-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	#{id := Id} = cowboy_req:match_qs([{id, [], undefined}], Req0),
	Req = echo(Method, Id, Req0),
	{ok, Req, Opts}.

echo(<<"GET">>, undefined, Req) ->
	cowboy_req:reply(400, #{}, <<"Missing echo parameter.">>, Req);

echo(<<"GET">>, Id, Req) ->
	io:format("id:~p~n", [Id]),
	{ok, FieldList, UserList} = hope_sql:fetch_row(Id),

	case length(UserList) > 0 of
		true ->
			[H|_] = UserList,
			DataList = lists:zip(FieldList, H);
		false ->
			DataList = #{}
	end,

	RespBody = jsx:encode([{<<"msg">>, <<"ok">>}, {<<"code">>, 200}, {<<"data">>, DataList}]),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json; charset=utf-8">>
	}, RespBody, Req);

echo(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).