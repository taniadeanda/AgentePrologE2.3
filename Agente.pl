%INTEGRANTES
%De Anda Lara Tania Citlaly <3
%Gómez Navarro Juan Fernando


%INSTRUCCIONES
%Debe poder consultar sobre un tema, puede ser de nuestra infografia: programacion funcional
%Crear un menu para usuario con opciones de buscar, listar, concatenar, agregar, eliminar, longitud y ordenamiento.
%Ejecutable en HTML o Java
%nombre de zip deandalarataniacitlaly_eq.zip.



%INICIO
limpiar :- write('\033[2J').


%CRUD
inicio :- 
    consult('BaseConocimiento.pl'),
    limpiar,
    write('Programacion Funcional').

%5 listas del tema
caracteristicas ([funciones_puras, inmutabilidad, funciones_de_orden_superior, declarativa, calculo_lambda, aplicacion_en_IA]). 
funcionales_puros ([Haskell, Elm, Idris]).
funcionales_altos ([Elixir, Erlang, F_Sharp]).
funcionales_medios ([Scala, Kotlin, Swift]).
funcionales_basicos ([Java, Python, C++, Javascript]).
%ventajas?desventajas?


%FUNCIONES

%buscar: si no esta debe preguntar al usuario si quiere agregarlo.

%comprobar/listar: mostrar de 1 en 1 los elementos de la listar

%Concatenar 2 listas: manera propia y extra con metodo append
concatenar_propia

concatenar_append(L1,L2) :- lista(L1,Lt1),
    lista(L2,Lt2), append(Lt1,Lt2,Lr),
    assert(concatenar_append(L1,L2,Lr)),
    write("Listas concatenadas "), 
    write(Lr).

%agregar
agregar(E,NL) :- lista(NL,Lt),
    append([E],Lt,Lr),
    retract(lista(NL,_)), %borra
    assert(append(NL, Lr)), %guarda
    write("Elemento agregado "), 
    write(Lr).

%Eliminar
eliminar(E,NL) :- lista(NL,Lt),
    delete(Lt,E,Lr),
    retract(lista(NL, _)),
    assert(lista(NL,Lr)),
    write("Elemento eliminado "), 
    write(Lr).

%Longitud
tamanio(NL) :- lista(NL,Lt),
    length(Lt,N),
    assert(tamanio(NL, N)), %guarda la lista ordenada
    write("Longitud guardada "), 
    write(N).

%Ordenamiento: predefinido sort o msort
ordenar(NL) :- 
    lista(NL,Lt),
    sort(Lt,Lr), %o msort
    retract(lista(NL,_)), %elimina la lista anterior
    assert(lista(NL, Lr)), %guarda la lista ordenada
    write("Lista actualizada "), 
    write(Lr).
