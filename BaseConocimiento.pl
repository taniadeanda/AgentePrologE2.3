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
