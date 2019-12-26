%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Dec 2019 下午1:35
%%%-------------------------------------------------------------------
-module(db_sql).
-author("lunay").

%% API
-export([
	make_insert_sql/2,
	make_insert_sql/3,
	make_update_sql/3,
	make_update_sql/2,
	make_delete_sql/2,
	make_delete_sql/1,
	make_select_sql/1,
	make_replace_sql/2
	]).

%% 插入数据表
make_insert_sql(Table, Field_Value_List) ->
%%  db_sql:make_insert_sql(player,
%%                         [{status, 0}, {online_flag,1}, {hp,50}, {mp,30}]).
	sqerl:sql({insert, Table, Field_Value_List}, true).

%%{insert,project,{[foo,bar,baz],[[a,b,c],[d,e,f]]}}
make_insert_sql(Table, FieldList, ValueList) ->
	sqerl:sql({insert, Table, {FieldList, ValueList}}, true).

%% UPDATE project SET foo = 'quo\\'ted', baz = blub WHERE NOT (a = 5)
make_update_sql(Table, Props, Where) ->
	sqerl:sql({update, Table, Props, Where}, true).

make_update_sql(Table, Props) ->
	make_update_sql(Table, Props, undefined).

make_delete_sql(Table, Where) ->
	sqerl:sql({delete, Table, Where}, true).

make_delete_sql(Table) ->
	make_delete_sql(Table, undefined).

make_select_sql(Sql)->
	sqerl:sql(Sql, true).

make_replace_sql(Table_name, Field_Value_List) ->
%%  db_sql:make_replace_sql(player,
%%                         [{status, 0}, {online_flag,1}, {hp,50}, {mp,30}]).
	{Vsql, _Count1} =
		lists:mapfoldl(
			fun(Field_value, Sum) ->
				Expr = case Field_value of
						   {Field, Val} ->
							   case is_binary(Val) orelse is_list(Val) of
								   true -> io_lib:format("`~s`='~s'",[Field, re:replace(Val,"'","''",[global,{return,binary}])]);
								   _-> io_lib:format("`~s`=~p",[Field, Val])
							   end
					   end,
				S1 = if Sum == length(Field_Value_List) -> io_lib:format("~s",[Expr]);
						 true -> io_lib:format("~s,",[Expr])
					 end,
				{S1, Sum+1}
			end,
			1, Field_Value_List),
	iolist_to_binary(lists:concat(["replace into `", Table_name, "` set ",
		lists:flatten(Vsql)
	])).


