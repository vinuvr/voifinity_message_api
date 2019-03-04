-module(voifinity_message_group_details_handler).
-export([init/2
	     ,handle_req/3
        ]).
init(Req0, State) ->
  Input_Method = maps:get(method,Req0),
  Input_Path    = maps:get(path_info,Req0),
  handle_req(Input_Method,Input_Path,Req0),
  {ok, Req0, State}.
handle_req(<<"GET">>,[<<"group_details">>, GroupId], Req) ->
  case Data = mnesia:dirty_read(group,GroupId) of
    [] ->
      Out= [{<<"status">>,<<"no exists">>}],
      jsx:encode(Out)
      cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>},Out,Req);
    _  ->
      GroupMembers = element(3,hd(Data)),
      GroupAdmins  = element(4,hd(Data)),
      GroupName    = element(7,hd(Data)),
      Out=[{<<"group_member">>,GroupMembers},{<<"group_admins">>,GroupAdmins},{<<"group_name">>,GroupName}],
      jsx:encode(Out),
      cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},Out,Req)
  end.
