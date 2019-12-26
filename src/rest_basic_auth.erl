%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Sep 2019 下午5:28
%%%-------------------------------------------------------------------
-module(rest_basic_auth).
-author("lunay").

%% API
-export([init/2]).
-export([content_types_provided/2]).
-export([is_authorized/2]).
-export([to_text/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

is_authorized(Req, State) ->
	case cowboy_req:parse_header(<<"authorization">>, Req) of
		{basic, User = <<"Alladin">>, <<"open sesame">>} ->
			{true, Req, User};
		_ ->
			{{false, <<"Basic realm=\"cowboy\"">>}, Req, State}
	end.

content_types_provided(Req, State) ->
	{[
		{<<"text/plain">>, to_text}
	], Req, State}.

to_text(Req, User) ->
	{<< "Hello, ", User/binary, "!\n" >>, Req, User}.

