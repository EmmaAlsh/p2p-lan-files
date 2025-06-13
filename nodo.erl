-module(nodo).
-export([start/0, loop/3]).

% compilar haciendo: spawn(nodo, start, []).

% Inicia el nodo generando un ID único automáticamente teniendo en cuenta la hora exacta
start() ->

  {MegaSecs, Secs, _MicroSecs} = os:timestamp(),
  UniqueId = list_to_atom("nodo_" ++ integer_to_list(MegaSecs) ++ "_" ++ integer_to_list(Secs)),
  io:format("Mi ID generado es: ~p~n", [UniqueId]),
  
  case file:list_dir("compartida") of
    {ok, Files} ->
      io:format("Archivos compartidos: ~p~n", [Files]),
      loop(UniqueId, Files, []);
    {error, Reason} ->
      io:format("Error al leer carpeta compartida: ~p~n", [Reason]),
      loop(UniqueId, [], [])
  end.

loop(NodeId, Files, KnownNodes) ->
  receive
    {get_id, From} ->
      From ! {node_id, NodeId},
      loop(NodeId, Files, KnownNodes);

    {get_files, From} ->
      From ! {file_list, Files},
      loop(NodeId, Files, KnownNodes);

    {get_known_nodes, From} ->
      From ! {known_nodes, KnownNodes},
      loop(NodeId, Files, KnownNodes);

    {add_node, NodeInfo, From} ->
      NewKnownNodes = [NodeInfo | KnownNodes],
      From ! {ok, node_added},
      loop(NodeId, Files, NewKnownNodes);

    stop ->
      io:format("El nodo ~p se detuvo.~n", [NodeId]),
      ok;

    _ ->
      loop(NodeId, Files, KnownNodes)
  end.
