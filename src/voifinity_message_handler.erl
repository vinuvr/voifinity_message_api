-module(voifinity_message_handler).
-export([init/2
	,handle_req/3
        ]).
init(Req0, State) ->
  InputMethod = maps:get(method,Req0),
  InputPath    = maps:get(path_info,Req0),
  handle_req(InputMethod,InputPath,Req0),
  {ok, Req0, State}.
handle_req(<<"DELETE">>,[<<"delete">>,MessageId],Req) ->
  mnesia:dirty_delete(storemessage,MessageId),
  mnesia:dirty_delete(undeliveredmsg,MessageId),
  Out = {[{<<"message_id">>,MessageId}
        ,{<<"status">>,<<"deleted successfully">>}
      ]},
  Out1 = jsx:encode(element(1,Out)),
  cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},Out1,Req).
