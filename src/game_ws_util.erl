-module(game_ws_util).
-export([
        ws_send/3
    ]).

ws_send(Cmd, WsPid, RecordData) ->
    [H1, H2|_] = integer_to_list(Cmd),
    ProtocolModule = list_to_atom("pt_"++[H1, H2]++"_pb"),
    Bin = ProtocolModule:encode_msg(RecordData),
    BinRecordData = <<Cmd:32/little, Bin/binary>>,
    %%记录日志
    game_debug:debug(info,"wwwwwww WsPid: ~p, protobuf send: ~p   wwwwwww ~n", [WsPid, RecordData]),
    WsPid ! {send_binary, BinRecordData},
    ok.