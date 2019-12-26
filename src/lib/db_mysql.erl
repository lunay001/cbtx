%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Dec 2019 下午5:11
%%%-------------------------------------------------------------------
-module(db_mysql).
-author("lunay").

%% API
-export([
	insert/2,
	insert/3,
	replace/2,
	update/3,
	delete/2,
	query/2
]).

%%sql语句执行
query(Sql, R)->
	if
		R =:= 1 ->
			Result = mysql_poolboy:transaction(pool, fun (Conn) ->
				ok = mysql:query(Conn, Sql),
				New_id = mysql:insert_id(Conn),
				New_id end);
		true ->
			Result = mysql_poolboy:transaction(pool, fun (Conn) ->
				ok = mysql:query(Conn, Sql),
				_Count = mysql:affected_rows(Conn),
				_Count end)
	end,
	case Result of
		{atomic, R_info} ->
			lager:info("~nSql Success: ~p~n", [R_info]);
		{_, Reason} ->
			lager:error(">>>>>>>>>>>>>>>>"),
			lager:error("Error Msg>>>>: ~p~n", [Reason]),
			lager:error("Sql>>>>: ~p~n", [Sql]),
			lager:error("<<<<<<<<<<<<<<<<"),
			R_info = -1
	end,
	R_info.


%% 插入数据表
insert(Table_name, FieldList, ValueList) ->
	Sql = db_sql:make_insert_sql(Table_name, FieldList, ValueList),
	query(Sql, 1).

insert(Table, Field_Value_List) ->
	Sql = db_sql:make_insert_sql(Table, Field_Value_List),
	query(Sql, 1).

%% 修改数据表(replace方式)
replace(Table, Field_Value_List) ->
	Sql = db_sql:make_replace_sql(Table, Field_Value_List),
	query(Sql, 2).

%% 修改数据表(update方式)
update(Table, Props, Where) ->
	Sql = db_sql:make_update_sql(Table, Props, Where),
	query(Sql, 2).


delete(Table, Where)->
	Sql = db_sql:make_delete_sql(Table, Where),
	query(Sql, 2).
