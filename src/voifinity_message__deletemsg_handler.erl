-module(voifinity_message_deletemsg_handler).
-export([init/2
	    ,handle_req/3
        ]).
init(Req0, State) ->
  InputMethod = maps:get(method,Req0),
  InputPath    = maps:get(path_info,Req0),
  handle_req(InputMethod,InputPath,Req0),
  {ok, Req0, State}.
handle_req(<<"DELETE">>,[<<"user">>,<<"delete_message">>,MessageId],Req) ->
  mnesia:dirty_delete(storemessage,Message_id),
  mnesia:dirty_delete(undeliveredmsg,Message_id),
  Out={[{<<"message_id">>,MessageId},{<<"status">>,<<"deleted successfully">>}]},
  jsx:encode(element(1,Out)),
  cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},Out,Req).
