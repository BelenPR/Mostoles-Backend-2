/*Comprobar la existencia de las tablas t1 y t2, eliminandolas si existen*/
drop table if exists t1, t2;

create temporary table t1 (c1 int not null, c2 int not null, c3 int not null);
create temporary table t2 (c1 int not null, c2 int not null, c3 int not null);

insert into t1 values (1,2,3), (2,2,2), (3,3,3);
insert into t2 values (5,5,5), (2,2,2), (4,4,4), (3,3,3);

table t1;
table t2;

select c1, c2, c3 
from t1 
where row(c1,c2,c3) in (select c1, c2, c3 from t2);

/*Creación de tablas temporales a partir de tablas existentes.
 * 
 * Por ejemplo, de la base de datos world y de la tabla country crear una tabla temporal.
 * 
 * */
use world;

drop table if exists t3;

create temporary table t3 select Name, Continent, Region, SurfaceArea, IndepYear, Population from country;

table t3;

/*Ejercicio 1 Martes 24 de noviembre 2026
 * 
 * 1- Crear tabla temporal t4 con los campos Code, Name, Continent, Region, SurfaceArea, IndepYear, 
 *    Population. Hacer que el campo Code sea PK
 * 2- Crear una tabla temporal t5 a partir de la tabla countryLanguage
 * 3- Eliminar de la tabla t4 los paises que tengan menos de 4 lenguas oficiales
 * 
 * No olvidar hacer la operación de borrado en el marco de una transación
 * 
 * Nota: Previamente, crear una tabla temporal t6 con los paises que tengan menos de 4 lenguas oficiales
 * */

-- 1.
drop table if exists t4;

create temporary table t4 select Code, Name, Continent, Region, SurfaceArea, IndepYear, Population 
from country; 

alter table t4 add constraint pk_t4 primary key (Code); 

table t4;

describe t4;

-- 2.
drop table if exists t5;

create temporary table t5 select CountryCode, Language, IsOfficial from countrylanguage;

-- Previamente t6
drop table if exists t6;

create temporary table t6 select CountryCode, Language, IsOfficial 
from countrylanguage 
where CountryCode in 
(select CountryCode from 
(select CountryCode, COUNT(IsOfficial) `numOficiales` from countrylanguage where IsOfficial = 'T' group by CountryCode having `numOficiales` < 4) c1);

start transaction;

delete t4 from t4 join t6 on t4.Code = t6.CountryCode;

table t4;


-- rollback;

