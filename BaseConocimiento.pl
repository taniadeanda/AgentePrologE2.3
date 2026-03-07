:- dynamic lista/2.

% ===========================================
% CASO REAL: PLANIFICADOR SEMANAL DE COMIDAS
% ===========================================

% Hechos del dominio (recetas e ingredientes)
receta(avena_desayuno, [avena, leche, platano, miel]).
receta(ensalada_fresca, [lechuga, tomate, pepino, aceite_oliva]).
receta(tacos_pollo, [tortilla, pollo, cebolla, cilantro]).
receta(smoothie_fresa, [leche, fresa, platano, avena]).
receta(pasta_vegetal, [pasta, tomate, ajo, aceite_oliva]).

% Inicializa listas dinámicas del agente
inicializar_listas :-
	retractall(lista(_, _)),
	assertz(lista(disponibles, [avena, leche, platano, tomate, tortilla, pollo])),
	assertz(lista(compra_semana, [huevo, arroz, frijol, cebolla])),
	assertz(lista(recetas_favoritas, [avena_desayuno, tacos_pollo])).

% -----------------------------
% Operaciones funcionales listas
% -----------------------------

obtener_lista(NombreLista, Lista) :-
	lista(NombreLista, Lista).

actualizar_lista(NombreLista, NuevaLista) :-
	retractall(lista(NombreLista, _)),
	assertz(lista(NombreLista, NuevaLista)).

listar_elementos([]).
listar_elementos([H|T]) :-
	write('- '), write(H), nl,
	listar_elementos(T).

buscar_elemento(Elemento, Lista) :-
	member(Elemento, Lista).

concatenar_propia([], L, L).
concatenar_propia([H|T], L2, [H|R]) :-
	concatenar_propia(T, L2, R).

concatenar_append(L1, L2, R) :-
	append(L1, L2, R).

agregar_elemento(Elemento, Lista, NuevaLista) :-
	append(Lista, [Elemento], NuevaLista).

eliminar_elemento(Elemento, Lista, NuevaLista) :-
	select(Elemento, Lista, NuevaLista).

longitud_lista(Lista, N) :-
	length(Lista, N).

ordenar_lista(Lista, Ordenada) :-
	msort(Lista, Ordenada).

subset_lista([], _).
subset_lista([H|T], L) :-
	member(H, L),
	subset_lista(T, L).

receta_posible(Disponibles, NombreReceta) :-
	receta(NombreReceta, Ingredientes),
	subset_lista(Ingredientes, Disponibles).
