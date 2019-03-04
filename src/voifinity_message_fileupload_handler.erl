-module(voifinity_message_fileupload_handler).
-export([init/2
	    ,handle_req/3
        ,file_saving/3
        ,stream_body/4
        ,file_saving_starting/4
        ]).
-define(videotypes,[<<"video/mp4">>
	               ,<<"video/x-msvideo">>
	               ,<<"video/x-flv">>
	               ,<<"video/x-matroska">>
	               ,<<"video/3gpp">>
	               ,<<"video/quicktime">>
	               ]).
-deine(imagetypes,[<<"image/jpeg">>
	              ,<<"image/png">>
	              ,<<"image/gif">>
	              ,<<"image/svg+xml">>
	              ]).
-define(audiotypes,[<<"audio/mpeg">>])
init(Req0, State) ->
  InputMethod = maps:get(method,Req0),
  InputPath = maps:get(path_info,Req0),
  handle_req(InputMethod,InputPath,Req0),
  {ok, Req0, State}.

handle_req(<<"PUT">>,[<<"media">>,Filename],Req) ->
  {ok, Headers, Req2} = cowboy_req:read_part(Req),
  io:format("~p\n",[maps:get( <<"content-type">>, Headers)]),
  Filetype = maps:get(<<"content-type">>,Headers),
  stream_body(Req2,[],Filetype,Filename);
file_saving(Filename,Filetype,Data) ->
  %Videotypes = [<<"video/mp4">>,<<"video/x-msvideo">>,<<"video/x-flv">>,<<"video/x-matroska">>,<<"video/3gpp">>,<<"video/quicktime">>],
  %Imagetypes = [<<"image/jpeg">>,<<"image/png">>,<<"image/gif">>,<<"image/svg+xml">>],
  %Audiotypes = [<<"audio/mpeg">>],
  Isvideo = lists:member(Filetype,?videotypes),
  Isimage = lists:member(Filetype,?imagetypes),
  Isaudio = lists:member(Filetype,?audiotypes),
  case {Is_image,Is_audio,Is_video} of
    {true,false,false}  ->
      file_saving_starting("image",Filename,Data,Req);
    {false,true,false}  ->
      file_saving_starting("audio",Filename,Data,Req);
    {false,false,true}  ->
      file_saving_starting("video",Filename,Data,Req);
    {false,false,false} ->
      file_saving_starting("store",Filename,Data,Req)
   end.
stream_body(Req0,Acc,Filetype,Filename) ->
  case cowboy_req:read_part_body(Req0) of
    {more, Data, Req} ->
       stream_body(Req,[Data|Acc],Filetype,Filename);
    {ok, Data, Req} ->
      FinalData = lists:reverse([Data|Acc]),
      file_saving(Filename,Filetype,FinalData)
      %file_storage(Path,Filetype,FinalData,Req)
  end.
file_saving_starting(Filetype,Filename,Data,Req) ->
  FilenameStr = erlang:binary_to_list(Filename),
  UniqueId    = uuid:uuid_to_string(uuid:get_v4()),
  Fileurl    = "http://157.230.12.112/" ++ Filetype ++ "/" ++ UniqueId ++ FilenameStr,
  Fileurlfinal= list_to_binary(Fileurl),
  case file:write_file("/usr/share/nginx/html/" ++ Filetype
  	                    ++ "/" ++ UniqueId ++ FilenameStr,Data) of
    ok ->
       Out={[{<<"url">>,Fileurlfinal},{<<"original_name">>,Filename}]},
       jsx:encode(element(1,Out));
    _  ->
      ok
  end.