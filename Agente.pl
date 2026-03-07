:- consult('BaseConocimiento.pl').
:- consult('OperacionesListas.pl').

limpiar :- write('\033[2J').

iniciar_agente :-
    inicializar_listas,
    limpiar,
    write('=== AGENTE: PLANIFICADOR SEMANAL DE COMIDAS ==='), nl,
    write('Enfoque: Programacion Funcional con Listas'), nl,
    menu.

menu :-
    nl,
    write('------------- MENU PRINCIPAL -------------'), nl,
    write('1) Ver nombres de listas'), nl,
    write('2) Listar elementos de una lista'), nl,
    write('3) Buscar elemento (si no existe, ofrece agregarlo)'), nl,
    write('4) Concatenar dos listas (propia y append)'), nl,
    write('5) Agregar elemento a lista'), nl,
    write('6) Eliminar elemento de lista'), nl,
    write('7) Longitud de una lista'), nl,
    write('8) Ordenar una lista'), nl,
    write('9) Ver recetas posibles con ingredientes disponibles'), nl,
    write('0) Salir'), nl,
    write('Selecciona opcion: '),
    read(Opcion),
    ejecutar_opcion(Opcion).

ejecutar_opcion(1) :-
    mostrar_listas,
    menu.
ejecutar_opcion(2) :-
    opcion_listar,
    menu.
ejecutar_opcion(3) :-
    opcion_buscar,
    menu.
ejecutar_opcion(4) :-
    opcion_concatenar,
    menu.
ejecutar_opcion(5) :-
    opcion_agregar,
    menu.
ejecutar_opcion(6) :-
    opcion_eliminar,
    menu.
ejecutar_opcion(7) :-
    opcion_longitud,
    menu.
ejecutar_opcion(8) :-
    opcion_ordenar,
    menu.
ejecutar_opcion(9) :-
    opcion_recetas_posibles,
    menu.
ejecutar_opcion(0) :-
    write('Hasta luego.').
ejecutar_opcion(_) :-
    write('Opcion no valida.'), nl,
    menu.

mostrar_listas :-
    nl,
    write('Listas disponibles:'), nl,
    forall(lista(Nombre, _), (write('- '), write(Nombre), nl)).

pedir_lista(NombreLista) :-
    write('Ingresa el nombre de la lista (ej. disponibles): '),
    read(NombreLista).

opcion_listar :-
    pedir_lista(NombreLista),
    (   obtener_lista(NombreLista, Lista)
    ->  write('Elementos de '), write(NombreLista), write(':'), nl,
        listar_elementos(Lista)
    ;   write('No existe esa lista.'), nl
    ).

opcion_buscar :-
    pedir_lista(NombreLista),
    (   obtener_lista(NombreLista, Lista)
    ->  write('Elemento a buscar: '),
        read(Elemento),
        (   buscar_elemento(Elemento, Lista)
        ->  write('Elemento encontrado en la lista.'), nl
        ;   write('No se encontro. ¿Deseas agregarlo? (si/no): '),
            read(Respuesta),
            manejar_agregado_condicional(Respuesta, Elemento, NombreLista, Lista)
        )
    ;   write('No existe esa lista.'), nl
    ).

manejar_agregado_condicional(si, Elemento, NombreLista, Lista) :-
    agregar_elemento(Elemento, Lista, NuevaLista),
    actualizar_lista(NombreLista, NuevaLista),
    write('Elemento agregado. Lista actualizada:'), nl,
    listar_elementos(NuevaLista).
manejar_agregado_condicional(no, _, _, _) :-
    write('No se realizaron cambios.'), nl.
manejar_agregado_condicional(_, _, _, _) :-
    write('Respuesta no valida. No se realizaron cambios.'), nl.

opcion_concatenar :-
    write('Primera lista: '),
    read(ListaA),
    write('Segunda lista: '),
    read(ListaB),
    (   obtener_lista(ListaA, L1), obtener_lista(ListaB, L2)
    ->  concatenar_propia(L1, L2, R1),
        concatenar_append(L1, L2, R2),
        write('Resultado (concatenar_propia): '), write(R1), nl,
        write('Resultado (concatenar_append): '), write(R2), nl
    ;   write('Una o ambas listas no existen.'), nl
    ).

opcion_agregar :-
    pedir_lista(NombreLista),
    (   obtener_lista(NombreLista, Lista)
    ->  write('Elemento a agregar: '),
        read(Elemento),
        agregar_elemento(Elemento, Lista, NuevaLista),
        actualizar_lista(NombreLista, NuevaLista),
        write('Lista actualizada:'), nl,
        listar_elementos(NuevaLista)
    ;   write('No existe esa lista.'), nl
    ).

opcion_eliminar :-
    pedir_lista(NombreLista),
    (   obtener_lista(NombreLista, Lista)
    ->  write('Elemento a eliminar: '),
        read(Elemento),
        (   eliminar_elemento(Elemento, Lista, NuevaLista)
        ->  actualizar_lista(NombreLista, NuevaLista),
            write('Elemento eliminado. Lista actualizada:'), nl,
            listar_elementos(NuevaLista)
        ;   write('El elemento no existe en la lista.'), nl
        )
    ;   write('No existe esa lista.'), nl
    ).

opcion_longitud :-
    pedir_lista(NombreLista),
    (   obtener_lista(NombreLista, Lista)
    ->  longitud_lista(Lista, N),
        write('Longitud de '), write(NombreLista), write(': '), write(N), nl
    ;   write('No existe esa lista.'), nl
    ).

opcion_ordenar :-
    pedir_lista(NombreLista),
    (   obtener_lista(NombreLista, Lista)
    ->  ordenar_lista(Lista, Ordenada),
        actualizar_lista(NombreLista, Ordenada),
        write('Lista ordenada y actualizada:'), nl,
        listar_elementos(Ordenada)
    ;   write('No existe esa lista.'), nl
    ).

opcion_recetas_posibles :-
    (   obtener_lista(disponibles, Disponibles)
    ->  write('Ingredientes disponibles actuales: '), write(Disponibles), nl,
        write('Recetas posibles hoy:'), nl,
        (   receta_posible(Disponibles, Receta),
            write('- '), write(Receta), nl,
            fail
        ;   true
        )
    ;   write('No existe la lista disponibles.'), nl
    ).
