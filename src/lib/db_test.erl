%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2020 上午10:19
%%%-------------------------------------------------------------------
-module(db_test).
-author("lunay").

%% API
-export([fetch_data/1, fetch_datas/1]).


fetch_data(Id)->
	Tables = 't1',
	Fields = '*',
	WhereExpr = {id, '=', Id},
	Extras = [{limit, 1}],
	S = {select, undefined, Fields, {from, Tables}, WhereExpr, Extras},
	db_mysql:fetch_row(S).

fetch_datas(Size) ->
	S = {select, undefined, '*', {from, 't1'}, undefined, [{limit, Size}]},
	db_mysql:fetch_rows(S).

