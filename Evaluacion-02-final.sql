USE sakila;

 #Ejercicios
 /*Base de Datos Sakila:
 Para este ejerccio utilizaremos la BBDD Sakila que hemos estado utilizando durante el repaso de SQL. Es 
una base de datos de ejemplo que simula una tienda de alquiler de películas. Contiene tablas como film 
(películas), actor (actores), customer (clientes), rental (alquileres), category (categorías), entre otras. 
Estas tablas contienen información sobre películas, actores, clientes, alquileres y más, y se utilizan para 
realizar consultas y análisis de datos en el contexto de una tienda de alquiler de películas.*/

 /* 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.*/
 # un modo de hacerlo:
 
 SELECT DISTINCT title
 FROM film;
 
 # otro modo sería:
SELECT title
FROM film
GROUP BY title;

 
 /*2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".*/

SELECT title, rating
FROM film
WHERE rating = 'PG-13';

 
/* 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en 
su descripción.*/
/* busco la palabra "amazing" en la descripción usando regex para buscar coincidencias de la palabra "amazing" en la descripción. [[:<:]] y [[:>:]] son anclas de límites de palabra en MySQL,
 lo que significa que la palabra "amazing" debe estar delimitada por los límites de la palabra.
 Esto evita que se hagan coincidencias parciales (por ejemplo, "amazingly").*/
 
SELECT title, description 
FROM film_text 
WHERE description REGEXP '\\bamazing\\b';



/* 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.*/

SELECT title, length
FROM film
WHERE length > 120;

 /* 5. Recupera los nombres de todos los actores.*/
 
 SELECT first_name
 FROM actor;
 
/* 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.*/

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Gibson%';

 /*7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.*/
 
 SELECT actor_id, CONCAT (first_name, ' ',last_name) AS nombre_apellido
 FROM actor
 WHERE actor_id BETWEEN 10 AND 20;
 
 
/* 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su 
clasificación.*/
# un modo
SELECT title, rating
FROM film
WHERE rating NOT LIKE '%R%' AND rating NOT LIKE '%pg-13%';

# otro modo
SELECT title, rating
FROM film
WHERE rating NOT IN ('R', 'PG-13');


 /*9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la 
clasificación junto con el recuento.*/

SELECT rating, COUNT(*) AS total_pelis_clasificacion
FROM film
GROUP BY rating;


 /*10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su 
nombre y apellido junto con la cantidad de películas alquiladas.*/

SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS cantidad_peliculas_alquiladas
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
GROUP BY c.customer_id, c.first_name, c.last_name;


 /*11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la 
categoría junto con el recuento de alquileres.*/

SELECT c.name AS category_name, COUNT(r.rental_id) AS recuento_alquileres
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name;




/* 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y 
muestra la clasificación junto con el promedio de duración.*/

SELECT rating, AVG(length) AS promedio_duracion
FROM film
GROUP BY rating;


 /*13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".*/
 
SELECT film.title, actor.first_name, actor.last_name
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
WHERE film.title = 'Indian Love';

 
 /*14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.
 
 Busco coincidencias de patrones que incluyan "dog" o (|: funciona como el operador or)"cat" en la descripción de la película.*/
 
SELECT title, description
FROM film_text
WHERE description REGEXP 'dog|cat';

  
/* 15. Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor.*/
/* en esta consulta selecciono el id, nombre y apellido del actor de su respectiva tabla y busco que no haya coincidencia (que no exista el id usando not in) en la tabla de film_actor*/

SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id NOT IN (SELECT actor_id 
					   FROM film_actor);
                       
/* otro modo de hacer esta consulta es:*/

SELECT actor.actor_id, actor.first_name, actor.last_name
FROM actor
LEFT JOIN film_actor ON actor.actor_id = film_actor.actor_id
WHERE film_actor.actor_id IS NULL;
/*utilizo actor_id para unir(left join) las filas donde no hay una coincidencia en la tabla film_actor, es decir, donde film_actor.actor_id es NULL(null significa que no hay una entrada que se corresponda en la tabla film_actor*/


/* 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.*/

SELECT title, release_year AS año_lanzamiento
FROM film
WHERE release_year BETWEEN '2005' AND '2010';

/*esta consulta me devuelve el título de todas las películas que fueron lanzadas entre los años 2005 y 2010*/


/* 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".*/

/*para conocer cuáles son los títulos de las películas que se corresponden con la categoría 'Family' he usado un 
inner join para unir film con film_category y otro inner join para unir film_category con category*/

SELECT title AS titulo, c.name AS categoria
FROM  film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON c.category_id = fc.category_id
WHERE c.name = 'Family';


/* 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.*/

/* hice una cuenta del número de películas en las que aparece cada actor  y filtré aquellos que tienen más
 de 10 participaciones.La sentencia HAVING funciona como un filtro de grupo, 
 lo que significa que tendré que usarla con un GROUP BY. 
 Esto me permite aplicar condiciones a grupos específicos en función de los resultados de las funciones agregadas como COUNT.*/

SELECT a.first_name, a.last_name, COUNT(a.actor_id) AS cantidad_pelis_actor
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
HAVING COUNT(*) > 10;


/* 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la 
tabla film.*/
/*selecciono todos los títulos de las películas de la tabla film y condiciono que la clasificación sea "R" y 
además duren las de 2 horas, para ello uso AND*/

SELECT title, rating, length AS duracion
FROM film
WHERE rating = 'R' AND length > 120;


/* 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 
minutos y muestra el nombre de la categoría junto con el promedio de duración.*/

/*selecciono el nombre de la categoria, averiguo el promedio de duracion de cada una de ellas, para
ello uno la tabla category con la de film_category para encontrar coincidencia en los id de category, luego uno la de film_category
con la de film de lo cual obtengo coincidencia en el id de los film, finalmente agrupo por categoria 
con la condición de que el promedio de duracion debe ser mayor a 120 min. */

SELECT c.name AS nombre_categoria, AVG(f.length) AS promedio_duracion
FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN film f ON fc.film_id = f.film_id
GROUP BY c.category_id
HAVING promedio_duracion > 120;

/* 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor 
junto con la cantidad de películas en las que han actuado.*/

/* He concatenado el nombre y apellido del actor para facilitar la lectura, luego cuento el número de filas agrupadas para cada actor
 de la tabla film_actor para saber en cuántas pel
 iculas aparece, luego le asigno un alias para mayor claridad en la comprensión de la lectura. 
 Uso inner join para buscar las coincidencias en los id de ambas tablas y poder obtener 
 aquellos actores que aparecen en 5 o más películas con la condición HAVING*/
 
SELECT CONCAT(a.first_name, ' ' ,a.last_name) AS nombre_actor, COUNT(fa.actor_id) AS cantidad_pelis_actor
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
HAVING COUNT(fa.actor_id) >= 5;


/* 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una 
subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona 
las películas correspondientes.*/
/*en este código no logré obtener información del cliente ya que no tengo alcance a los datos de la subconsulta
a la columna 'rental'*/
SELECT f.film_id, f.title, f.rental_duration AS alquiler_dias
FROM film f
WHERE film_id IN (
    SELECT i.film_id
    FROM inventory i
    JOIN rental r ON r.inventory_id = i.inventory_id
    WHERE DATEDIFF(return_date, rental_date) > 5);
    
    /*para incluir datos del cliente, el código debería ser así:*/
    SELECT 
    f.film_id, 
    f.title, 
    f.rental_duration AS alquiler_dias, 
    r.customer_id
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON r.inventory_id = i.inventory_id
WHERE 
    DATEDIFF(r.return_date, r.rental_date) > 5;

    
/* 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la 
categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en 
películas de la categoría "Horror" y luego exclúyelos de la lista de actores.*/

/*El razonamiento que he usado es primero identificar que debo usar not in, para excluir los actores que aparezcan en horror.
En la consulta principal busco los actores que no estén en la lista de actores que actúan en las pelis de horror,
para obtenerla defino la subconsulta para encontrar qué actores actuan en la categoría horror*/

SELECT 
    a.first_name AS nombre, 
    a.last_name AS apellido,
    GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS categorias
FROM 
    actor a
JOIN 
    film_actor fa ON a.actor_id = fa.actor_id
JOIN 
    film_category fc ON fa.film_id = fc.film_id
JOIN 
    category c ON fc.category_id = c.category_id
WHERE 
    a.actor_id NOT IN (
        SELECT DISTINCT fa.actor_id
        FROM film_actor fa
        JOIN film_category fc ON fa.film_id = fc.film_id
        JOIN category c ON fc.category_id = c.category_id
        WHERE c.name = 'Horror'
    )
GROUP BY 
    a.actor_id;
    
    
 # BONUS
 /* 24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 
minutos en la tabla film.*/
/*Selecciono (select) el título de la película (f.title), la duración de la película (f.length), y el nombre de la categoría (c.name).
el uso de los JOIN aseguran que cada película esté correctamente relacionada con su categoría.
Where filtra para incluir sólo las películas que pertenecen a la categoría "Comedy" y tienen una duración mayor a 180 minutos*/
		
SELECT 
    f.title AS titulo, 
    f.length AS duracion,
    c.name AS categoria
FROM 
    film f
INNER JOIN 
    film_category fc ON f.film_id = fc.film_id
INNER JOIN 
    category c ON fc.category_id = c.category_id
WHERE 
    c.name = 'Comedy' 
    AND f.length > 180;


/* 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. La 
consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que 
han actuado juntos.*/

/*he usado self join para "unir/combinar/relacionar" datos de una tabla consigo misma. 
La tabla film_actor se está uniendo consigo misma dos veces, una vez con el alias fa1 y otra vez con el alias fa2.
Esta parte de la consulta establece "fa1.film_id = fa2.film_id" asegura que obtenga combinaciones únicas de actores. 
La condición fa1.actor_id < fa2.actor_id evita duplicados al garantizar que cada par de actores se muestre
 solo una vez en la consulta resultante.*/


SELECT 
    CONCAT(a1.first_name, ' ', a1.last_name) AS actor1,
    CONCAT(a2.first_name, ' ', a2.last_name) AS actor2,
    COUNT(DISTINCT fa1.film_id) AS num_peliculas_actuadas_juntos
FROM 
    film_actor fa1
JOIN 
    film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
JOIN 
    actor a1 ON fa1.actor_id = a1.actor_id
JOIN 
    actor a2 ON fa2.actor_id = a2.actor_id
GROUP BY 
    fa1.actor_id, fa2.actor_id;


