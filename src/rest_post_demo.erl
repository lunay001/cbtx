%%curl -v POST http://localhost:8888/rest/post/demo -i -H "Content-Type:application/json" -d '{ "title": "中国", "content": "The Content" }'
-module(rest_post_demo).
-export([init/2]).

-export([welcome/2, terminate/3, allowed_methods/2]).
-export([
	content_types_accepted/2,
	content_types_provided/2,
	hello_to_json/2
	]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"POST">>, <<"GET">>], Req, State}.

content_types_accepted(Req, State) ->
%%	接受给定的资源类新
%%	PUT，POST和PATCH方法 content_types_accepted
	{[{<<"application/json">>, welcome}], Req, State}.

content_types_provided(Req, State) ->
%%	送出给定的类型资源
%%	content_types_provided还返回它接受所有的内容类型回调的名称。
%% 当满足所有条件时，仅在“ GET和HEAD方法”图的末尾调用此回调。
	{[{<<"application/json">>, hello_to_json}], Req, State}.


terminate(_Reason, _Req, _State) ->
	ok.


hello_to_json(Req, State) ->
	Body = <<"{\"rest\": \"Hello World!\"}">>,
	{Body, Req, State}.

welcome(Req, State) ->
	io:format(">>>>>>>>>>>"),
	{ok, ReqBody, Req2} = cowboy_req:read_body(Req),
	Req_Body_decoded = jsx:decode(ReqBody),
	[{<<"title">>,Title},{<<"content">>,Content}] = Req_Body_decoded,
	Title1 = binary_to_list(Title),
	Content1 = binary_to_list(Content),
	lager:info("Title1 is ~p ~n ", [Title1]),
	lager:info("Content1 is ~p ~n", [Content1]),

	T1 = proplists:get_value(<<"title">>, Req_Body_decoded),
	C1 = proplists:get_value(<<"content">>, Req_Body_decoded),

	lager:info("T1 is ~p ~n ", [T1]),
	lager:info("C1 is ~p ~n", [C1]),

	Res1 = cowboy_req:set_resp_body(ReqBody, Req2),
	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
	Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
	{true, Res3, State}.