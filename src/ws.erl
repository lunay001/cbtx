-module(ws).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).

init(Req, Opts) ->
	{cowboy_websocket, Req, Opts}.

websocket_init(State) ->
	erlang:start_timer(1000, self(), <<"Hello!">>),
	Pid = self(),
	lager:info("My Pid is ~p xxxxx", [Pid]),

	{reply, {text, << "##########################">>}, State, hibernate}.
%%	{ok, State}.

websocket_handle({text, Msg}, State) ->
	if
		Msg =:= <<"close">> ->
			self() ! {close, ""};
		true ->
			ok
	end,
	{reply, {text, << "That's what she said! ", Msg/binary >>}, State, hibernate};

websocket_handle(_Data, State) ->
	{ok, State, hibernate}.

websocket_info({timeout, _Ref, Msg}, State) ->
	erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, State, hibernate};

websocket_info({close, _}, State) ->
	self() ! {text, <<"Ready to logout">>},
	{reply, {close, <<"some-reason">>}, State}.

terminate(_Reason, _Req, State)->
	Pid = self(),
	self() ! {text, <<"Ready to logout">>},
	lager:info("pid: ~p is logout", [Pid]),
	lager:info("My Pid is ~p logout", [Pid]),
	{ok, State, hibernate}.