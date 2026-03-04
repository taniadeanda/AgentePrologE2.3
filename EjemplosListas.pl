%BORRAR cuando se termine 

%predicado([])

%simples
mamiferos([vaca, leon, perro, gato, tigre)].
estaciones([primavera, verano)].

%listas de listas
mamiferos {
  [leon,tigre, gato, perro],
  [vaca,caballo,jirafa],
  [oso,mapache],
}

%listas y elementos
vegetales([[tomates, jitomates], papa, [col,lechuga]]).

%relacion conjuntos
tio(donald,[hugo,paco,luis]).
tio(sam,[usa]).

%Operaciones
lista([CMYK,[cyan,magenta,amarillo,negro]]).
lista(mamiferos,[vaca,leon,perro,gato,tigre]).

%Operaciones
%Buscar
comprobar([]). %quesealista, que tenga cola vacia
comprobar([]).
comprobar([H|T]) :-
  write('- '), write(H), nl, %si se invierte esta con la de abajo se imprime la lista al reves
  comprobar(T).

%buscar:member
buscar(E,[H|_]) :- E==H. %Elemento a buscar y la lista O
buscar(E,[E|_]) :-!.
buscar(E,[_|T]) :- buscar(E|T).

busqueda(E,NL) :- lista(NL, Lt),
  buscar(E,Lt).
buscar(E,[E|_]).
buscar(E,[_|T]) :- buscar(E|T).

%longitud : lenght
tamanio(NL) :- lista(NL,Lt),
  length(Lt,N)
  write(N).

%concatenar : append %que necesito? 2 listas
concat(L1,L2) :- lista(L1,Lt1),
  lista(L2,Lt2), append(Lt1,Lt2,Lr),
  write(Lr).
 
%agregar :append
agregar(E,NL) :- lista(NL,Lt),
  append([E],Lt,Lr),
  write(Lr).

%eliminar : delete
agregar(E,NL) :- lista(NL,Lt),
  delete(Lt,E,Lr),
  write(Lr).

%ordenar : sort elimina los repetidos, msort mantiene los repetidos, 
ordenar(NL) :- lista(NL,Lt),
  sort(Lt,Lr). %o msort
  write(Lr).







%-----PROLOG-------
%mostrar lista
mamferos(x)

%headandtailcabezaycola
mamiferos([H|T]).

%solocabeza
mamiferos([H|_]).
mamiferos([_|T]).

%recursiva
mamiferos([_|[H|T]]).
muestrasoloperro
mamiferos([_|[_|[H|_]]]).
listing(mamiferos).

%Muestra las listas de listas
mamiferos(C,H,O).

%Muestra lo que esta dentro de
tio(donald,X)
tio(sam,X)

%funcionparaverificar si es lita
is_list([hugo,paco,luis]).

%ver cual es mas optimo
time(comprobar([vaca,leon,perro,fato,tigre])).
time(is_list([vaca,leon,perro,gato,tigre])).

%devuelve todas las veces que haya ese elemento con true
member(gato,[vaca,leon,perro,gato,tigre]).

%busca un elemento en una lista
busqueda(leon,mamiferos).

tamanio(mamiferos).

concat(cmyk,mamiferos).

agregar(oso,mamiferos).

borrar(oso,mamiferos).

ordenar(mamifero).