use world;

/* Recuperar el pais y la poblacion del pais que tiene mas habitantes, consulta que 
ya habiamos implementado, pero de una forma nada eficiente utilizando order by y limit */
select Name `Pais`, Population `Población`
from country
where Population = (select max(Population) from country);

-- Ejercicio # 1 del Jueves 19 de Nov. Recuperar la ciudad que tiene mas habitantes 
-- y el pais donde se encuentra dicha ciudad, utilizando una subconsulta.
select ci.Name `Ciudad`, co.Name `Pais`, ci.Population
from city ci join country co on ci.CountryCode = co.Code
where ci.Population = (select max(Population) from city);

use tienda;

/* Tipos de Subconsultas:

1- Subconsultas de fila: Devuelven multiples columnas (campos) y una sola fila 
2- Subconsultas de tabla: Pueden devolver una o varias columnas y entre cero y 
   varias filas 
3- Subconsultas escalares: Devuelven una columna y una fila (una celda), es decir 
   un valor  */

/* Subconsultas en la clausula WHERE */

/*
   Por ejemplo: Suponga que queremos conocer el nombre del producto
   que tiene mayor precio.
   
   La solucion, una de las posibles, seria: Realizar una primera consulta, que es
   la subconsulta, para recuperar el precio maximo y, a continuacion, en la 
   consulta principal bucar el nombre del producto cuyo precio coincide con el 
   valor del precio maximo: 

*/ 
select nombre, precio
from producto
where precio = (select max(precio) from producto);

use tienda;

/* Subconsulta en la clausula HAVING 

   Recuperar un listado con todos los nombres de los fabricantes que tienen
   el mismo numero de productos que el fabricante Asus */
 
 select fabricante.nombre, count(*) `Total de Productos`
 from fabricante join producto on fabricante.id = producto.id_fabricante
 group by fabricante.nombre
 having `Total de Productos` = (
 
	select count(producto.id_fabricante) 
    from fabricante join producto on fabricante.id = producto.id_fabricante
    and fabricante.nombre = 'Asus'
 
 );
   
-- Ejercicio # 2 del Jueves 19 de Nov
-- Eliminar del listado anterior al fabricante Asus
select fabricante.nombre, count(*) `Total de Productos`
 from fabricante join producto on 
   fabricante.id = producto.id_fabricante and fabricante.nombre != 'Asus' 
 group by fabricante.nombre
 having `Total de Productos` = (
 
	select count(producto.id_fabricante) 
    from fabricante join producto on fabricante.id = producto.id_fabricante
    and fabricante.nombre = 'Asus'
 
 );

/* 
   Subconsulta en la Clausula FROM 
	
   Recuperar el listado de todos los productos que tienen un precio
   mayor o igual al precio promedio, o medio, de todos los productos 
   de su mismo fabricante
   
 */

select producto.*
from producto join (
	select id_fabricante, avg(precio) precioPromedio
    from producto
    group by id_fabricante) t on producto.id_fabricante = t.id_fabricante 
    and producto.precio >= precioPromedio
    order by precio desc;
    
/* Por sugerencia y cortesia de Elias, la consulta anterior es mejor implementarla utilizando NATURAL JOIN, en 
lugar de INNER JOIN, porque el NATURAL JOIN es perfecto cuando hay campos en las dos tablas que tiene el mismo 
nombre, y nos evita utilizar la clausula ON USING */

/* Uso de la clausula USING */

select producto.*
from producto join (
	select id_fabricante, avg(precio) precioPromedio
    from producto
    group by id_fabricante) t using(id_fabricante) 
    where producto.precio >= precioPromedio
    order by precio desc;
    
/* Uso de NATURAL JOIN */

select producto.*
from producto natural join (
	select id_fabricante, avg(precio) precioPromedio
    from producto
    group by id_fabricante) t 
    where producto.precio >= precioPromedio
    order by precio desc;
    
/* OPERADORES QUE PODEMOS UTILIZAR EN LAS SUBCONSULTAS 

 1. Operadores basicos de comparacion (>, >=, <, <=, !=, <>, =) 
 2. Predicados (Predicate (Condicion que se evalua) ANY (SOME) y ALL 
 3- Predicados IN y NOT IN 
 4- Predicado EXISTS y NOT EXISTS */
 
 /* Los Operadores basicos de comparacion se utilizan cuando queremos comparar una expresion
 con el valor que devuelve una subconsulta */

/*Subconsulta para el uso de los operadores básicos de comparación*/
/*Recuperar todos los productos que tienen un precio mayor o igual al producto más caro del 
fabricante 'Asus'*/
select * 
from producto
where precio >= 
(select max(p.precio)
from producto p join fabricante f on p.id_fabricante = f.id and f.nombre = 'Asus');

/*¿Se puede reescribir la consulta anterior utilizando USING? La respuesta es no, ya que 
las tablas unidas por el join deben compartir el mismo nombre de columna 
en el campo que las une, y sin embargo, en este caso, en la tabla producto se llama 'id_fabricante
mientras que en fabricante la columna se llama 'id'*/


/*Uso de los operadores ANY y ALL en subconsultas*/
/*Estos operadores se utilizan conjuntamente con los operadores básicos relacionales y 
el operador ANY es equivalente al operdor SOME, se pueden usar de igual manera*/
/*Ejemplo: vamos a reescribir la consulta anterior que recupera todos los productos que tienen un 
precio >= que todos los prodcutos del fabricante 'Asus'*/
select * 
from producto
where precio >= 
ALL (select p.precio
from producto p join fabricante f on p.id_fabricante = f.id and f.nombre = 'Asus');

/*Recuperar el nombre de los fabricantes que tienen productos asociados */
select nombre from fabricante where id = ANY (select id_fabricante from producto);

/*Recuperar los nombres de los fabricantes que no tienen productos asociados*/
select nombre
from fabricante 
where id != ALL(select id_fabricante from producto);

/*Uso de los operadores IN y NOT IN. Hay que tener en cuenta que 
IN es equivalente a  '=ANY', pero NOT IN no es equivalente a '!= ANY'
pero sí a '!= ALL'*/
use jardineria;
/*Recuperar un listado de todos los clientes que no han realizado ningún pedido
utilizando los operadores IN y NOT IN*/
select nombre_cliente
from cliente
where codigo_cliente not IN (select codigo_cliente from pedido);

/*Recuperar los clientes con sus pedidos y el nombre de representante de */
/*select cli.nombre_cliente, ped. codigo_pedido, emp.nombre `Representante de Ventas`
from cliente cli natural join  !!MIRAR GRABACIÓN PARA COMPLETAR*/

/*USO DE LOS OPERADORES EXITS Y NOT EXISTS*/ 
/*Este tipo de operadores se emplean con subconsultas correlacionales, es decir,
subconsultas que hacen referencia a una o varias de las consultas que la contienen o cualquier
consulta más externa*/
/*A modo de ejemplo, devolver un listado de los clientes que no han realizado ningún pedido*/
SELECT 
    *
FROM
    cliente
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            pedido
        WHERE
            cliente.codigo_cliente = pedido.codigo_cliente);
/*En la consulta anterior, concretamente en la subconsulta, inicialmente en la select
especificamos el campo codigo_cliente, pero finalmente lo cambiamos por * y el resultado
obtenido es exactamente el mismo*/

/*Mas informacion respecto a las subconsultas CORRELACIONALES*/
/*A modo de ejemplo: Recuperar un listado de todos los productos que tienen 
un precio mayor o igual a la media de todos los productos de su mismo fabricante
Para la solución poner en uso la base de datos tienda*/
use tienda;

-- Forma 1:
select *
from producto p1
where precio >= (SELECT AVG(p2.precio)
    FROM producto p2
    WHERE p2.id_fabricante = p1.id_fabricante);
    
    
-- Forma 2:
SELECT *
FROM producto p
WHERE
    EXISTS( SELECT *
        FROM producto
        WHERE p.precio >= 
			(SELECT AVG(precio)
                FROM producto pro
                WHERE pro.id_fabricante = p.id_fabricante));


/*Otro ejemplo de uso del operador EXISTS en las subconsultas, utilizando la base de datos
ejemplo_exists.*/
/*Que tipo de tienda está presente en una o más ciudades*/
use ejemplo_exists;
TABLE cities;
TABLE stores;
TABLE cities_stores;

SELECT store_type 
from stores WHERE EXISTS 
	(select * FROM cities_stores 
	WHERE cities_stores.store_type  = stores.store_type);




-- Consultas auxiliares
table fabricante;
table producto;





