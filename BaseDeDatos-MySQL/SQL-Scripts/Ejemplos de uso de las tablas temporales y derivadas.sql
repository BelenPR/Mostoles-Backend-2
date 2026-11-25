/*Primero utilizaremos la base de datos empresa.
 * 
 * Vamos a eliminar los telefonos correspondientes a un empleado concreto.
 * 
 * No siempre la base de datos es propiedad nuestra y podemos, por ejemplo, configurar
 * las relaciones para que las actualizaciones y el borrado se propague en cascada a los
 * hijos, porque no somos DBA(Data Base Administrator) y no tenemos los privilegios para hacerlo.
 * Además, los DBA acostumbran a exigir el uno dela primary key en operaciones de borrado y 
 * actualización.
 * 
 * Es decir, que vamos a ver como se procede cuando no es posible que cuando se elimine 
 * o actualice un empleado los cambios se propaguen a telefonos y correos.
 * 
 * NOTA IMPORTANTE!!!! Hasta el momento, las consultas no las hemos realizado en el marco de una 
 * transacción, pero el resto de las consultas se sugiere hacerlas en el marco de una transacción, 
 * como el borrado y las actualizaciones, pero las sentencias de inser into no.
 * 
 * Una transacción es un conjunto de operaciones, un conjunto de sentencias SQL en este caso, que 
 * el sistema ve como si fuera una sola operación. Es una apuesta de todo o nada, es decir, si 
 * falla alguna operación hay que deshacer todas las demás (rollback) y si todas las operaciones 
 * han tenido éxito se confirman entonces (commit).
 * 
 * Es una muy buena práctica de programación tener las sentencias de rollback y commit entre 
 * comentarios y poderlas ejecutar sin descomentarlas. 
 */

use empresa;

-- Una transacción se inicia con la siguiente sentencia:
start transaction;

/*Cuando se está en una transacción, las tablas de la base de datos no se modifican hasta que se 
 * ejecute un commit explicitamente
 */

/*Comprobar si es posible eliminar los telefonos correspondientes a un empleados sin especificar
 * la primary key de la tabla teléfonos*/
table telefonos;

delete from telefonos where empleado_id = 7;

/*En el caso de que no haya sido posible ejecutar la sentencia anterior porque la seguridad está 
 * bien configurada por los DBA, se procederá de la siguiente forma:
 */

-- VARIANTE 1#: creando una tabla temporal con todos los Id de la tabla teléfono:
create temporary table ids select id from telefonos;
table ids;
-- Para eliminar los telefonos del empleado cuyo id es 7, es decir, los registros donde el campo empleado_id = 7
delete from telefonos where id = any (table ids) and empleado_id = 7;
/*Recordar que = any es lo mismo que in pero != any no es lo mismo que not in*/

-- ¿Por qué hemos utilizado una tabla temporal en lugar de una subconsulta?
delete from telefonos where id = any (select id from telefonos) and empleado_id = 7;

-- VARIANTE 2: utilizando una derived table
delete telefonos 
from telefonos join 
	(select id from telefonos) dt on telefonos.id = dt.id 
	where telefonos.empleado_id = 7;

/*Si utilizamos el mysql workbench, la consulta anterior no da ninguna advertencia por no utilizar 
 * la clausula where y utilizar el operador AND en su lugar*/
-- rollback;
-- commit;