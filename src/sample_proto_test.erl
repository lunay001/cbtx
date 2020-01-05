%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 1月 2020 2:53 下午
%%%-------------------------------------------------------------------
-module(sample_proto_test).
-author("lunay").

%% API
-export([
  create_empty_person/0,
  create_named_person/1]).

% This imports the record for you to use from the generated file
-include("addressbook_pb.hrl").


create_empty_person() ->
  #person{}.

create_named_person(Name) ->
  #person{name = Name}.