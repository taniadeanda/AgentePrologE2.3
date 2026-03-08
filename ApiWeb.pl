%todo este archivo se dedica de mostrar la parte grafica de nuestro programa ordenandolo en diferentes apartados
:- use_module(library(http/json)).
:- consult('BaseConocimiento.pl').
:- consult('OperacionesListas.pl').

responder_ok(Datos) :-
    json_write_dict(current_output, _{ok:true, data:Datos}).

responder_error(Mensaje) :-
    json_write_dict(current_output, _{ok:false, error:Mensaje}).

api(init) :-
    reiniciar_estado_web,
    responder_ok(_{mensaje:"Estado reiniciado"}).

api(list_names) :-
    preparar_estado_web,
    nombres_listas(Nombres),
    responder_ok(_{listas:Nombres}).

api(full_state) :-
    preparar_estado_web,
    findall(_{nombre:Nombre, elementos:Lista}, lista(Nombre, Lista), Listas),
    responder_ok(_{estado:Listas}).

api(list(NombreLista)) :-
    preparar_estado_web,
    (   obtener_lista(NombreLista, Lista)
    ->  responder_ok(_{nombre:NombreLista, elementos:Lista})
    ;   responder_error("No existe esa lista")
    ).

api(create_list(NombreLista, Elementos)) :-
    preparar_estado_web,
    (   lista(NombreLista, _)
    ->  responder_error("La lista ya existe")
    ;   assertz(lista(NombreLista, Elementos)),
        guardar_estado_web,
        responder_ok(_{nombre:NombreLista, elementos:Elementos})
    ).

api(search(NombreLista, Elemento, AgregarSiNoExiste)) :-
    preparar_estado_web,
    (   obtener_lista(NombreLista, Lista)
    ->  (   buscar_elemento(Elemento, Lista)
        ->  responder_ok(_{encontrado:true, actualizado:false, elementos:Lista})
        ;   (   AgregarSiNoExiste == si
            ->  agregar_elemento(Elemento, Lista, NuevaLista),
                actualizar_lista(NombreLista, NuevaLista),
                guardar_estado_web,
                responder_ok(_{encontrado:false, actualizado:true, elementos:NuevaLista})
            ;   responder_ok(_{encontrado:false, actualizado:false, elementos:Lista})
            )
        )
    ;   responder_error("No existe esa lista")
    ).

api(add(NombreLista, Elemento)) :-
    preparar_estado_web,
    (   obtener_lista(NombreLista, Lista)
    ->  agregar_elemento(Elemento, Lista, NuevaLista),
        actualizar_lista(NombreLista, NuevaLista),
        guardar_estado_web,
        responder_ok(_{nombre:NombreLista, elementos:NuevaLista})
    ;   responder_error("No existe esa lista")
    ).

api(remove(NombreLista, Elemento)) :-
    preparar_estado_web,
    (   obtener_lista(NombreLista, Lista)
    ->  (   eliminar_elemento(Elemento, Lista, NuevaLista)
        ->  actualizar_lista(NombreLista, NuevaLista),
            guardar_estado_web,
            responder_ok(_{nombre:NombreLista, elementos:NuevaLista, eliminado:true})
        ;   responder_ok(_{nombre:NombreLista, elementos:Lista, eliminado:false})
        )
    ;   responder_error("No existe esa lista")
    ).

api(length(NombreLista)) :-
    preparar_estado_web,
    (   obtener_lista(NombreLista, Lista)
    ->  longitud_lista(Lista, N),
        responder_ok(_{nombre:NombreLista, longitud:N})
    ;   responder_error("No existe esa lista")
    ).

api(sort(NombreLista)) :-
    preparar_estado_web,
    (   obtener_lista(NombreLista, Lista)
    ->  ordenar_lista(Lista, Ordenada),
        actualizar_lista(NombreLista, Ordenada),
        guardar_estado_web,
        responder_ok(_{nombre:NombreLista, elementos:Ordenada})
    ;   responder_error("No existe esa lista")
    ).

api(concat(ListaA, ListaB)) :-
    preparar_estado_web,
    (   obtener_lista(ListaA, L1), obtener_lista(ListaB, L2)
    ->  concatenar_propia(L1, L2, R1),
        concatenar_append(L1, L2, R2),
        responder_ok(_{lista1:ListaA, lista2:ListaB, resultado_propia:R1, resultado_append:R2})
    ;   responder_error("Una o ambas listas no existen")
    ).

api(recipes_possible) :-
    preparar_estado_web,
    (   obtener_lista(disponibles, Disponibles)
    ->  recetas_posibles(Disponibles, Recetas),
        responder_ok(_{disponibles:Disponibles, recetas:Recetas})
    ;   responder_error("No existe la lista disponibles")
    ).
