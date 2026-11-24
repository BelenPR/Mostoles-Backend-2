/*
 * Una tabla derivada (derived table) es una expresión de tabla (combinación 
 * de operadores y operandos, que hay que evaluarpara obtener un resultado, 
 * en este caso una expresión de tabla, se evalua y da como resultado un 
 * conjunto (ResultSet) de filas y columnas) y se utiliza en la clausula FROM 
 * de la consulta principal, entre parentesis.
 * 
 * Las tablas derivadas se utilizan como alternativa a las tablas temporales 
 * y existen consultas que no se pueden implementar si no se utiliza una tabla
 *  temporal o mejor una tabla derivada.
 * 
 * Una tabla temporal, como la que vamos a crear a continuación, sólo existirá
 * durante la sesión, es decir, durante la conexión que hemos establecido con
 * el motor de base de datos, pero una vez hemos cerrado la sesión la tabla
 * temporal se elimina de forma automática.
 */
 
 create database test;
 use test;
 
 /*Creación de la tabla temporal t1*/
 create temporary table t1 (s1 int not null, s2 char(5) not null, s3 float not null);
 table t1;
 
 insert into t1 values (1, '2', 3.0), (2, '3', 4.0);
 
 /*Creación de la tabla derivada a parti de la tabla temporal t1, en todos los casos
  * 
  * VARIANTE 1#
  * 
  * Sin definir alias para los campos de la expresión de la tabla que aparece en la clausula FROM 
  * entre paréntesis*/
 
 select s1, s2, s3 from (select s1, s2, s3 from t1) dt;
 
 /*VARIANTE 2#
  * 
  * Definiendo alias para los campos de la expresión de tabla
  * */
select sb1, sb2, sb3 from (select s1 sb1, s2 sb2, s3 sb3 from t1) dt where sb1 > 1; 

/*VARIANTE 3#
 * 
 * Agregando una lista entre paréntesis, con los nombres que le vamos a asignar a 
 * los campos de la expresión de tabla, es decir, a la tabla derivada
 * */
select sb1, sb2, sb3 from (select * from t1) dt(sb1, sb2, sb3);

/*Preparando las condiciones para utilizar una tabla derivada en un tipo de consulta que 
 * no se puede efectuar sin la tabla derivada o una tabla temporal*/
/*Creamos una tabla temporal con registros repetidos*/
create temporary table t2 (columna1 int not null);

insert into t2 values (2), (2), (2), (4), (4), (5), (5), (5);
table t2;

/*Queremos obtener el promedio de la suma de los valores que son iguales en la tabla t2*/
-- En principio, la solución sería la siguiente:
select avg(sum(columna1)) from t2 group by columna1;
/*Sin embargo, al ejecutar la sentencia anterior nos sale un error 'uso invalido de la clausula group by'
 * por lo que uno puede pensar que la solución es quitar el group by, lo que también nos daría error.
 * 
 * En este caso la solución adecuada sería utilizar una tabla derivada
 */
select AVG(dt.sumatoria_por_columna1) `Promedio de las sumas parciales` 
from (select sum(columna1) sumatoria_por_columna1 from t2 group by columna1) dt;





