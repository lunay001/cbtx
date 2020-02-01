-module(game_role_sup).

-author("Lunay").

-behaviour(supervisor).

-define(SERVER, ?MODULE).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init(_Args) ->
    SupFlags = #{strategy => simple_one_for_one, intensity => 1, period => 5},
    ChildSpecs = [#{id => game_role,
                    start => {game_role, start_link, []},
                    restart => transient,
                    shutdown => 30000,
                    type => worker,
                    modules => [game_role]}],
    {ok, {SupFlags, ChildSpecs}}.