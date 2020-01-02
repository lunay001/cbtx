%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Sep 2019 下午4:27
%%%-------------------------------------------------------------------
-module(ops_tests).
-author("lunay").

%% API
-include_lib("eunit/include/eunit.hrl").

%%add_test_() ->
%%    [
%%      test_them_types(),
%%      test_them_values(),
%%      ?_assertEqual(badarith, 1/0)].
%%
%%test_them_types() ->
%%  ?_assert(is_number(ops:add(1, 2))).
%%
%%test_them_values()->
%%  [?_assertEqual(4, ops:add(2, 2)),
%%    ?_assertEqual(3, ops:add(1,2)),
%%    ?_assertEqual(3, ops:add(1, 1))].
%%
%%
%%new_add_test_() ->
%%  [
%%    test_them_types(),
%%    ?_assertEqual(5, ops:new_add(1,3,1)),
%%    ?_assertEqual(badarith, 1/0)].

make_insert_sql_test_() ->
    ?_assertEqual(<<"INSERT INTO t1(name, age, sex) VALUES ('bb', 1, 2)">>,
        db_sql:make_insert_sql(t1, [{name, "bb"}, {age, 1}, {sex, 2}])).

make_insert_sql2_test_() ->
    Fx = [foo,bar,baz],
    Vx = [[a,b,c],[d,e,f]],
    ?_assertEqual(<<"">>, db_sql:make_insert_sql(project, Fx, Vx)).


%%UPDATE project SET foo = 5, bar = 6, baz = 'hello'
make_update_sql_test_()->
    Table_name = project,
    Props = [{foo, 5}, {bar, 6}, {baz, "hello"}],
    Where = {where,{a,'=',5}},
    ?_assertEqual(<<"UPDATE project SET foo = 5, bar = 6, baz = 'hello' WHERE (a = 5)">>,
        db_sql:make_update_sql(Table_name, Props, Where)).
