%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.10.5

-ifndef(addressbook_pb).
-define(addressbook_pb, true).

-define(addressbook_pb_gpb_version, "4.10.5").

-ifndef('PERSON_PB_H').
-define('PERSON_PB_H', true).
-record(person,
        {name                   :: iodata(),        % = 1
         id                     :: integer(),       % = 2, 32 bits
         email                  :: iodata() | undefined % = 3
        }).
-endif.

-endif.
