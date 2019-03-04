-module(voifinity_message_group_handler).
-export([init/2
	      ,handle_req/3
        ,json_creation/3
        ]).
init(Req0, State) ->
  InputMethod = maps:get(method,Req0),
  InputPath = maps:get(path_info,Req0),
  handle_req(InputMethod,InputPath,Req0),
  {ok, Req0, State}.
handle_req(<<"GET">>,[<<"message_log">>,GroupId], Req) ->
  case Data = mnesia:dirty_index_read(storemessage,GroupId,groupid) of
    [] ->
      cowboy_req:reply(404, Req);
    _ ->
      json_creation(Data,[],Req)
  end;
handle_req(<<"GET">>,[<<"group_details">>,GroupId], Req) ->
  case Data = mnesia:dirty_read(group,GroupId) of
    [] ->
      cowboy_req:reply(404, Req);
    _  ->
      GroupMembers = element(3,hd(Data)),
      GroupAdmins = element(4,hd(Data)),
      GroupName = element(7,hd(Data)),
      Out = [{<<"group_member">>,GroupMembers}
             ,{<<"group_admins">>,GroupAdmins}
             ,{<<"group_name">>,GroupName}
            ],
      Out1 = jsx:encode(Out),
      cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},Out1,Req)
  end.
json_creation([],Accumulator,Req) ->
  Out = jsx:encode(Accumulator),
  cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},Out,Req);
json_creation([H|T],Accumulator,Req) ->
  Message = jsx:decode(element(8,element(5,H))),
  json_creation(T,[Message|Accumulator],Req).

