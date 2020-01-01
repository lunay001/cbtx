%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Dec 2019 下午4:37
%%%-------------------------------------------------------------------
-module(hope_sql).
-author("lunay").
-include("common.hrl").

%% API
-export([fetch_row/1, fetch_rows/0, fetch_one2/1, query/1]).

query(Sql) ->
	mysql_poolboy:query(pool, Sql).

%% API
fetch_row(Id) ->
	{ok, FieldList, DataList} = mysql_poolboy:query(?DB_MYSQL_POOL, "SELECT * FROM foo where id = ? LIMIT 1", [Id]),
	if
		length(DataList) > 0 ->
			[H|_] = DataList,
			Data = lists:zip(FieldList, H);
		true ->
			Data = #{}
	end,
	{ok,  Data}.

fetch_rows() ->
	{ok, FieldList, UserList} = mysql_poolboy:query(?DB_MYSQL_POOL, "SELECT * FROM foo where 1 LIMIT 100", []),
	DataList = [lists:zip(FieldList, User) || User <- UserList],
	{ok,  DataList}.

fetch_one2(Id) ->
	{ok, FieldList, DataList} = mysql_poolboy:query(?DB_MYSQL_POOL, "SELECT * FROM foo where id = ? LIMIT 1", [Id]),
	case length(DataList) > 0 of
		true ->
			[H|_] = DataList,
			Data = lists:zip(FieldList, H);
		false ->
			Data = #{}
	end,
	{ok, Data}.

