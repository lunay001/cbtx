%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Dec 2019 上午9:59
%%%-------------------------------------------------------------------
-module(sqerl_tests).
-author("lunay").

-include_lib("eunit/include/eunit.hrl").

-define(_safe_test(Expr),
	(fun(Expect, _) ->
		{Expect, ?_assertEqual(Expect, sqerl:sql(Expr, true))}
	 end)).

-define(_unsafe_test(Expr),
	(fun(Expect, _) ->
		{Expect, ?_assertEqual(Expect, sqerl:unsafe_sql(Expr, true))}
	 end)).

safe_test_() ->
	{foreachx,
		fun (_) -> ok end,
		[
			{<<"INSERT INTO t1(name, age, sex) VALUES ('aa', 10, 1)">>,
				?_safe_test({insert, t1, [{name, "aa"}, {age, 10}, {sex, 1}]})
			},
			{<<"INSERT INTO project(foo, baz) VALUES (5, 'bob')">>,
				?_safe_test({insert,project,[{foo,5},{baz,"bob"}]})
			},

			{<<"INSERT INTO project(foo, bar, baz) VALUES ('a', 'b', 'c'), ('d', 'e', 'f')">>,
				?_safe_test({insert,project,{[foo,bar,baz],[[a,b,c],[d,e,f]]}})
			},

			{<<"INSERT INTO project(foo, bar, baz) VALUES ('a', 'b', 'c'), ('d', 'e', 'f')">>,
				?_safe_test({insert,project,{[foo,bar,baz],[{a,b,c},{d,e,f}]}})
			},

			{<<"INSERT INTO Documents(projectid, documentpath) VALUES (42, '/') RETURNING documentid">>,
				?_safe_test({insert,'Documents',
					[{projectid,42},{documentpath,"/"}],
					{returning,documentid}})
			},

			{<<"UPDATE project SET foo = 5, bar = 6, baz = 'hello'">>,
				?_safe_test({update,project,[{foo,5},{bar,6},{baz,"hello"}]})
			},

			{<<"UPDATE project SET foo = 'quo\\'ted', baz = blub WHERE NOT (a = 5)">>,
				?_safe_test({update,project,
					[{foo,"quo'ted"},{baz,blub}],
					{where,{'not',{a,'=',5}}}})
			},

			{<<"UPDATE project JOIN client ON (project.client_id = client.id) SET foo = 5">>,
				?_safe_test({update,
					{project,join,client,{'project.client_id','=','client.id'}},[{foo,5}]})
			},

			{<<"UPDATE project INNER JOIN client ON (project.client_id = client.id) SET foo = 5">>,
				?_safe_test({update,
					{project,{inner,join},client,{'project.client_id','=','client.id'}},[{foo,5}]})
			},

			{<<"DELETE FROM project">>,
				?_safe_test({delete,project})
			},

			{<<"DELETE FROM project WHERE (a = 5)">>,
				?_safe_test({delete,project,{a,'=',5}})
			},

			{<<"DELETE FROM project JOIN client ON (project.client_id = client.id) WHERE (client.a = 8)">>,
				?_safe_test({delete,{project,join,client,
					{'project.client_id','=','client.id'}},{'client.a','=',8}})
			},

			{<<"DELETE FROM project WHERE (a = 5)">>,
				?_safe_test({delete,{from,project},{where,{a,'=',5}}})
			},

			{<<"DELETE FROM developer WHERE NOT ((name LIKE '%Paul%') OR (name LIKE '%Gerber%'))">>,
				?_safe_test({delete,developer,
					{'not',{{name,like,"%Paul%"},
						'or',
						{name,like,"%Gerber%"}}}})
			},

			{<<"SELECT 'foo'">>,
				?_safe_test({select,["foo"]})
			},

			{<<"SELECT 'foo', 'bar'">>,
				?_safe_test({select,["foo","bar"]})
			},

			{<<"SELECT (1 + 1)">>,
				?_safe_test({select,{1,'+',1}})
			},

			{<<"SELECT foo AS bar FROM baz AS blub">>,
				?_safe_test({select,{foo,as,bar},{from,{baz,as,blub}}})
			},

			{<<"SELECT name FROM developer WHERE (country = 'quoted \\' \\\" string')">>,
				?_safe_test({select,name,
					{from,developer},
					{where,{country,'=',"quoted ' \" string"}}})
			},

			{<<"SELECT p.name AS name, p.age AS age, project.* FROM person AS p, project">>,
				?_safe_test({select,[{{p,name},as,name},{{p,age},as,age},{project,'*'}],
					{from,[{person,as,p},project]}})
			},

			{<<"SELECT count(name) FROM developer">>,
				?_safe_test({select,{call,count,[name]},{from,developer}})
			},

			{<<"SELECT count(name) AS c FROM developer">>,
				?_safe_test({select,{{call,count,[name]},as,c},{from,developer}})
			},

			{<<"SELECT CONCAT('-- [', GROUP_CONCAT(comment.id), ']') AS comments FROM posts">>,
				?_safe_test({select,{{call,'CONCAT',["-- [",{call,'GROUP_CONCAT',['comment.id']},"]"]},as,comments},{from,posts}})
			},

			{<<"SELECT last_insert_id()">>,
				?_safe_test({select,{call,last_insert_id,[]}})
			},

			{<<"(SELECT name FROM person) UNION (SELECT name FROM project)">>,
				?_safe_test({{select,name,{from,person}},
					union,
					{select,name,{from,project}}})
			},

			{<<"SELECT DISTINCT name FROM person LIMIT 5">>,
				?_safe_test({select,distinct,name,{from,person},{limit,5}})
			},

			{<<"SELECT name, age FROM person ORDER BY name DESC, age">>,
				?_safe_test({select,[name,age],{from,person},{order_by,[{name,desc},age]}})
			},

			{<<"SELECT count(name), age FROM developer GROUP BY age">>,
				?_safe_test({select,[{call,count,[name]},age],
					{from,developer},
					{group_by,age}})
			},

			{<<"SELECT count(name), age, country FROM developer GROUP BY age, country HAVING (age > 20)">>,
				?_safe_test({select,[{call,count,[name]},age,country],
					{from,developer},
					{group_by,[age,country],having,{age,'>',20}}})
			},

			{<<"SELECT * FROM developer WHERE name IN ('Paul', 'Frank')">>,
				?_safe_test({select,'*',
					{from,developer},
					{where,{name,in,["Paul","Frank"]}}})
			},

			{<<"SELECT name FROM developer WHERE name IN (SELECT DISTINCT name FROM gymnast)">>,
				?_safe_test({select,name,
					{from,developer},
					{where,{name,in,
						{select,distinct,name,{from,gymnast}}}}})
			},

			{<<"SELECT name FROM developer WHERE name IN ((SELECT DISTINCT name FROM gymnast) "
			"UNION (SELECT name FROM dancer WHERE ((name LIKE 'Mikhail%') OR (country = 'Russia'))) "
			"WHERE (name LIKE 'M%') ORDER BY name DESC LIMIT 5, 10)">>,
				?_safe_test({select,name,
					{from,developer},
					{where,
						{name,in,
							{{select,distinct,name,{from,gymnast}},
								union,
								{select,name,
									{from,dancer},
									{where,
										{{name,like,"Mikhail%"},
											'or',
											{country,'=',"Russia"}}}},
								{where,{name,like,"M%"}},
								[{order_by,{name,desc}},{limit,5,10}]}}}})
			},

			{<<"SELECT * FROM developer WHERE (name = ?)">>,
				?_safe_test({select,'*',{from,developer},{where,{name,'=','?'}}})
			},

			{<<"SELECT * FROM foo WHERE (a = (1 + 2 + 3))">>,
				?_safe_test({select,'*',{from,foo},{where,{a,'=',{'+',[1,2,3]}}}})
			},

			{<<"SELECT * FROM foo WHERE ((a + b + c) = (d + e + f))">>,
				?_safe_test({select,'*',
					{from,foo},
					{where,{'=',[{'+',[a,b,c]},{'+',[d,e,f]}]}}})
			},

			{<<"SELECT * FROM foo WHERE ((a = b) AND (c = d) AND (e = f))">>,
				?_safe_test({select,'*',
					{from,foo},
					{where,{'and',[{a,'=',b},{c,'=',d},{e,'=',f}]}}})
			},

			{<<"SELECT (1 + 2 + 3 + 4)">>,
				?_safe_test({select,{'+',[1,2,3,4]}})
			},

			{<<"SELECT * FROM blah">>,
				?_safe_test({select,'*',{from,blah},undefined,undefined})
			},

			{<<"SELECT name FROM search_people(age := 18)">>,
				?_safe_test({select,name,{from,{call,search_people,[{age, 18}]}}})
			},
			{<<"SELECT * FROM foo JOIN bar ON (foo.bar_id = bar.id)">>,
				?_safe_test({select,'*',{from,{foo,join,bar,{'foo.bar_id','=','bar.id'}}}})
			},
			{<<"SELECT * FROM foo AS f JOIN bar AS b ON (f.bar_id = b.id)">>,
				?_safe_test({select,'*',{from,{{foo,as,f},join,{bar,as,b},{'f.bar_id','=','b.id'}}}})
			},
			{<<"SELECT * FROM foo JOIN bar ON ((foo.bar_id = bar.id) AND (foo.bar_type = bar.type))">>,
				?_safe_test({select,'*',{from,{foo,join,bar,[
					{'and', [
						{'foo.bar_id','=','bar.id'},
						{'foo.bar_type','=','bar.type'}
					]
					}]}}})
			},
			{<<"SELECT * FROM foo LEFT JOIN bar ON (foo.bar_id = bar.id)">>,
				?_safe_test({select,'*',{from,{foo,{left,join},bar,{'foo.bar_id','=','bar.id'}}}})
			},
			{<<"SELECT * FROM foo INNER JOIN bar ON (foo.bar_id = bar.id)">>,
				?_safe_test({select,'*',{from,{foo,{inner,join},bar,{'foo.bar_id','=','bar.id'}}}})
			},
			{<<"SELECT * FROM foo RIGHT JOIN bar ON (foo.bar_id = bar.id)">>,
				?_safe_test({select,'*',{from,{foo,{right,join},bar,{'foo.bar_id','=','bar.id'}}}})
			},
			{<<"SELECT * FROM foo LEFT OUTER JOIN bar ON (foo.bar_id = bar.id)">>,
				?_safe_test({select,'*',{from,{foo,{left,outer,join},bar,{'foo.bar_id','=','bar.id'}}}})
			},
			{<<"SELECT * FROM foo CROSS JOIN bar ON (foo.bar_id = bar.id)">>,
				?_safe_test({select,'*',{from,{foo,{cross,join},bar,{'foo.bar_id','=','bar.id'}}}})
			},
			{<<"SELECT * FROM foo JOIN bar ON (foo.bar_id = bar.id) JOIN baz ON (bar.baz_id = baz.id)">>,
				?_safe_test({select,'*',{from,{foo,[ {join,bar,{'foo.bar_id','=','bar.id'}},
					{join,baz,{'bar.baz_id','=','baz.id'}} ]}}})
			}
		]
	}.

unsafe_test_() ->
	{foreachx,
		fun (_) -> ok end,
		[
			{<<"SELECT * FROM foo WHERE a = b">>,
				?_unsafe_test({select,'*',{from,foo},"WHERE a = b"})
			},

			{<<"SELECT * FROM foo WHERE a = 'foo'">>,
				?_unsafe_test({select,'*',{from,foo},"WHERE a = 'foo'"})
			},

			{<<"SELECT * FROM foo WHERE a = 'i'm an evil query'">>,
				?_unsafe_test({select,'*',{from,foo},<<"WHERE a = 'i'm an evil query'">>})
			},

			{<<"SELECT * FROM foo WHERE a = b">>,
				?_unsafe_test({select,'*',{from,foo},<<"WHERE a = b">>})
			},

			{<<"SELECT * FROM foo WHERE a = b">>,
				?_unsafe_test({select,'*',{from,foo},{where,"a = b"}})
			},

			{<<"SELECT * FROM foo WHERE a = b">>,
				?_unsafe_test({select,'*',{from,foo},{where,<<"a = b">>}})
			},

			{<<"SELECT * FROM foo WHERE a IN (SELECT * FROM bar WHERE a = b)">>,
				?_unsafe_test({select,'*',
					{from,foo},
					{where,{a,in,
						{select,'*',{from,bar},{where,"a = b"}}}}})
			},

			{<<"SELECT * FROM foo WHERE a IN (SELECT * FROM bar WHERE a = b)">>,
				?_unsafe_test({select,'*',
					{from,foo},
					{where,
						{a,in,{select,'*',{from,bar},{where,<<"a = b">>}}}}})
			},

			{<<"SELECT * FROM foo WHERE a IN (SELECT * FROM bar WHERE a = b)">>,
				?_unsafe_test({select,'*',
					{from,foo},
					{where,
						{a,in,{select,'*',{from,bar},<<"WHERE a = b">>}}}})
			},

			{<<"SELECT * FROM foo WHERE a = b LIMIT 5">>,
				?_unsafe_test({select,'*',{from,foo},{where,<<"a = b">>},<<"LIMIT 5">>})
			},

			{<<"(SELECT * FROM foo WHERE a = b) UNION (SELECT * FROM bar)">>,
				?_unsafe_test({{select,'*',{from,foo},{where,<<"a = b">>}},
					union,
					{select,'*',{from,bar}}})
			},

			{<<"(SELECT * FROM foo) UNION (SELECT * FROM bar WHERE a = b)">>,
				?_unsafe_test({{select,'*',{from,foo}},
					union,
					{select,'*',{from,bar},{where,<<"a = b">>}}})
			},

			{<<"(SELECT * FROM foo) UNION (SELECT * FROM bar) WHERE a = b">>,
				?_unsafe_test({{select,'*',{from,foo}},
					union,
					{select,'*',{from,bar}},
					{where,"a = b"}})
			},

			{<<"SELECT (a OR (foo))">>,
				?_unsafe_test({select,{a,'or',"foo"}})
			},

			{<<"SELECT ((bar) OR b)">>,
				?_unsafe_test({select,{"bar",'or',b}})
			},

			{<<"SELECT ((foo) AND (bar))">>,
				?_unsafe_test({select,{"foo",'and',<<"bar">>}})
			},

			{<<"SELECT NOT (foo = bar)">>,
				?_unsafe_test({select,{'not',"foo = bar"}})
			},

			{<<"SELECT NOT (foo = bar)">>,
				?_unsafe_test({select,{'!',"foo = bar"}})
			}
		]
	}.


make_insert_sql_test_() ->
	?_assertEqual(<<"INSERT INTO t1(name, age, sex) VALUES ('bb', 1, 2)">>,
		db_sql:make_insert_sql(t1, [{name, "bb"}, {age, 1}, {sex, 2}])).

make_insert_sql2_test_() ->
	Fx = [foo,bar,baz],
	Vx = [[a,b,c],[d,e,f]],
	?_assertEqual(<<"INSERT INTO project(foo, bar, baz) VALUES ('a', 'b', 'c'), ('d', 'e', 'f')">>,
		db_sql:make_insert_sql(project, Fx, Vx)).

make_insert_sql3_test_() ->
	Fx = [foo,bar,baz],
	Vx = [{a,b,c},{d,e,f}],
	?_assertEqual(<<"INSERT INTO project(foo, bar, baz) VALUES ('a', 'b', 'c'), ('d', 'e', 'f')">>,
		db_sql:make_insert_sql(project, Fx, Vx)).

make_update_sql_test_()->
	Table_name = project,
	Props = [{foo, 5}, {bar, 6}, {baz, "hello"}],
	Where = {'and', [{'or', [{a,'=',5}, {b, '>', 6}]}, {'c', in, [1, 2]}]},
	?_assertEqual(<<"UPDATE project SET foo = 5, bar = 6, baz = 'hello' WHERE (((a = 5) OR (b > 6)) AND c IN (1, 2))">>,
		db_sql:make_update_sql(Table_name, Props, Where)).

make_delete_sql_test_()->
	Table = project,
	Where = {'and', [{'or', [{a, '=', 5}, {b, '=', 5}]}, {c, '=', 1}]},
	?_assertEqual(<<"DELETE FROM project WHERE (((a = 5) OR (b = 5)) AND (c = 1))">>,
		db_sql:make_delete_sql(Table, Where)).

make_replace_sql_test_()->
	Table = project,
	Field_Value_List = [{status, 0}, {online_flag,1}, {hp,50}, {mp,30}],
	?_assertEqual(<<"replace into `project` set `status`=0,`online_flag`=1,`hp`=50,`mp`=30">>,
		db_sql:make_replace_sql(Table, Field_Value_List)).

insert_test_() ->
	Table = t1,
	Field_Value_List = [{name, "Mingyue"}, {age, 30}, {sex, 1}],
	?_assertEqual(<<"replace into `t1` set `name`='Mingyue',`age`=30,`sex`=1">>,
		db_sql:make_replace_sql(Table, Field_Value_List)).

