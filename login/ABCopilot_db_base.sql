--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 16.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: privacy_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.privacy_type AS ENUM (
    'P',
    'T',
    'A'
);


ALTER TYPE public.privacy_type OWNER TO admin;

--
-- Name: actions_upsert(bigint, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.actions_upsert(IN p_id bigint, IN p_description character varying, IN p_statement character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "id" FROM "public"."actions" WHERE "id" = p_id)) THEN
	UPDATE "public"."actions" SET
		"description" = p_description,
		  "statement" = p_statement,
		"updated_at" = CURRENT_TIMESTAMP,
	    "sequence_id" = nextval('actions_sequence')
	WHERE
			"id" = p_id;
ELSE
	INSERT INTO "public"."actions" ("description", "statement", "created_at", "sequence_id")
	VALUES (p_description, p_statement, CURRENT_TIMESTAMP, nextval('actions_sequence') );
END IF;

END;
$$;


ALTER PROCEDURE public.actions_upsert(IN p_id bigint, IN p_description character varying, IN p_statement character varying) OWNER TO admin;

--
-- Name: categories_upsert(character varying, bigint, bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.categories_upsert(IN p_name character varying, IN p_action_id bigint, IN p_parent_id bigint, IN p_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "id" FROM "public"."categories" WHERE "id" = p_id)) THEN
	UPDATE "public"."categories" SET
			   "name" = p_name,
		  "action_id" = p_action_id,
		  "parent_id" = p_parent_id,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('categories_sequence')
	WHERE
			"id" = p_id;
ELSE
	INSERT INTO "public"."categories" ( "name", "action_id", "parent_id", "created_at", "sequence_id")
	VALUES ( p_name, p_action_id, p_parent_id, CURRENT_TIMESTAMP, nextval('categories_sequence') );
END IF;

END;
$$;


ALTER PROCEDURE public.categories_upsert(IN p_name character varying, IN p_action_id bigint, IN p_parent_id bigint, IN p_id bigint) OWNER TO admin;

--
-- Name: count_all_batteries_status(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_batteries_status() RETURNS TABLE(status_battery character varying, quantity bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT combined.health_status_final, CAST(SUM(combined.quantity) AS bigint) AS quantity
from (
select CAST(sb.health_status_final AS varchar(191)), CAST(count (sb.health_status_final) AS bigint) as quantity
  from services_battery_complete sb
-- where sb.status_battery in ('Buen estado', 'Nueva', 'Requiere Carga', 'Dañada','Reemplazar')
 group by sb.health_status_final
union all 
SELECT CAST(status_battery_temp AS varchar(191)), CAST(cantidad_temp AS bigint) AS cantidad_temp
    FROM (
        VALUES ('Buen estado', 0),
               ('Recargar', 0),
               ('Dañada', 0),
               ('Reemplazar', 0)
    ) AS t(status_battery_temp, cantidad_temp)
) combined
GROUP BY combined.health_status_final;
END;
$$;


ALTER FUNCTION public.count_all_batteries_status() OWNER TO admin;

--
-- Name: count_all_users_activity_status(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_activity_status() RETURNS TABLE(months character varying, registered_users integer, users_using_app integer)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
            SELECT
                CAST(CASE subquery.month
                    WHEN 1 THEN 'Enero'
                    WHEN 2 THEN 'Febrero'
                    WHEN 3 THEN 'Marzo'
                    WHEN 4 THEN 'Abril'
                    WHEN 5 THEN 'Mayo'
                    WHEN 6 THEN 'Junio'
                    WHEN 7 THEN 'Julio'
                    WHEN 8 THEN 'Agosto'
                    WHEN 9 THEN 'Septiembre'
                    WHEN 10 THEN 'Octubre'
                    WHEN 11 THEN 'Noviembre'
                    WHEN 12 THEN 'Diciembre' END AS varchar(10)) AS months_output,
                CAST(COUNT(CASE WHEN page = 'R' THEN 1 END) AS integer) AS registered_users_output,
                CAST(COUNT(CASE WHEN page = 'U' THEN 1 END) AS integer) AS users_using_app_output
            FROM (
                SELECT
                    DISTINCT
                    user_id,
                    date_part('month', event_date) AS month,
                    CASE
                        WHEN page = 'webview' THEN 'R'
                        ELSE 'U'
                    END AS page,
                    object
                FROM public.heat_maps
                WHERE date_part('year', event_date) = date_part('year', current_date)
            ) subquery
            GROUP BY month
            ORDER BY month;
    END;
$$;


ALTER FUNCTION public.count_all_users_activity_status() OWNER TO admin;

--
-- Name: count_all_users_batteries_physical_state(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_batteries_physical_state() RETURNS TABLE(users bigint, status character varying)
    LANGUAGE plpgsql
    AS $$ 
BEGIN 
	RETURN QUERY
        select 	CAST(subquery.quantity AS bigint ) AS users_output,
        CAST(subquery.status AS varchar(50)) AS status_output
  from (        
	select 	'Buen estado' status, sum (services_battery_complete.count_buen_estado) as quantity
	  from services_battery_complete
	union all
	select 	'Fuga de líquido' status, sum (services_battery_complete.count_fuga_de_liquido) as quantity
	  from services_battery_complete
	union all
	select 	'Bornes sulfatados y/o dañados' status, sum (services_battery_complete.count_bornes_sulfatados) as quantity
	  from services_battery_complete
	union all
	select 	'Cables partidos y/o sulfatados' status, sum (services_battery_complete.count_cables_partidos) as quantity
	  from services_battery_complete
	union all
	select 	'Carcasa partida o impactada' status, sum (services_battery_complete.count_carcasa_partida) as quantity
	  from services_battery_complete
	union all
	select 	'Batería Inflada' status, sum (services_battery_complete.count_bateria_inflada) as quantity
	  from services_battery_complete  
	) subquery;  
    END;
$$;


ALTER FUNCTION public.count_all_users_batteries_physical_state() OWNER TO admin;

--
-- Name: count_all_users_batteries_summary_status(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_batteries_summary_status() RETURNS TABLE(users bigint, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY

        select cast (count (*) as bigint) users_output, CAST('Usuarios con baterías registradas' AS varchar(50)) status_output
  from public.services_battery_complete
union all
select cast (count (*) as bigint) users_output, CAST('Usuarios sin baterías registradas' AS varchar(50)) status_output
  from vehicle_without_services_battery
union all
select cast (sum (count_recarga_bateria) as bigint) users_output, CAST('Usuarios con recargas' AS varchar(50)) status_output
  from public.services_battery_complete ;
    END;
$$;


ALTER FUNCTION public.count_all_users_batteries_summary_status() OWNER TO admin;

--
-- Name: count_all_users_service_balancing_status(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_service_balancing_status() RETURNS TABLE(users bigint, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT CAST(SUM(combined.users) AS bigint), CAST(combined.status AS VARCHAR(191))
          FROM (
			select count(*) users, 'Requieren Servicio' status
  			  from services_balancing_complete sbc 
             where kms_recorridos >= 5000 or elapsed_days >= 180
			 union all 
			select count(*) users, 'No Requieren Servicio' status
			  from services_balancing_complete sbc 
			 where kms_recorridos < 5000 and elapsed_days < 180
			 union all 
			select count(*) users, 'Sin Servicios Registrados' status
			  from vehicle_without_services_balancing
			UNION ALL
			SELECT CAST(users_temp AS bigint) AS users_temp, CAST(status_temp AS varchar(191))
                FROM (
                    VALUES 
                        (0, 'No Requieren Servicio'),
                        (0, 'Requieren Servicio'),
                        (0, 'Sin Servicios Registrados') 
                ) AS t(users_temp, status_temp)
	  	) AS combined
		GROUP BY combined.status;
    END;
$$;


ALTER FUNCTION public.count_all_users_service_balancing_status() OWNER TO admin;

--
-- Name: count_all_users_service_oil_change_status(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_service_oil_change_status() RETURNS TABLE(users bigint, status character varying)
    LANGUAGE plpgsql
    AS $$ BEGIN 
	RETURN QUERY
        SELECT CAST(SUM(combined.users) AS bigint), CAST(combined.status AS VARCHAR(191))
          FROM (
			select count(*) users, 'Requiere Cambio de Aceite' status
  			  from services_oil_complete sbc 
             where kms_recorridos >= life_span or elapsed_days >= 90
			 union all 
			select count(*) users, 'Aceite Saludable' status
			  from services_oil_complete sbc 
			 where kms_recorridos < life_span and elapsed_days < 90
			 union all 
			select count(*) users, 'Sin Cambios Registrados' status
			  from vehicle_without_services_oil
			UNION ALL
			SELECT CAST(users_temp AS bigint) AS users_temp, CAST(status_temp AS varchar(191))
                FROM (
                    VALUES 
                        (0, 'Aceite Saludable'),
                        (0, 'Requiere Cambio de Aceite'),
                        (0, 'Sin Cambios Registrados') 
                ) AS t(users_temp, status_temp)
	  	) AS combined
		GROUP BY combined.status;
    END;
$$;


ALTER FUNCTION public.count_all_users_service_oil_change_status() OWNER TO admin;

--
-- Name: count_all_users_tires_lifespand_consumed_status(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_tires_lifespand_consumed_status() RETURNS TABLE(status character varying, cantidad bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT combined.status AS status, CAST(SUM(combined.cantidad) AS bigint) AS cantidad

        FROM
        (
            
			select subquery.status, sum (subquery.cantidad) cantidad
			  from (
			  	select CAST('0%-25%' AS varchar(10)) status, count_25 cantidad from services_tires_complete where count_25 > 0 
			  	union all 
			  	select CAST('26%-50%' AS varchar(10)) status, count_50 cantidad  from services_tires_complete where count_50 > 0 
			  	union all 
			  	select CAST('51%-75%' AS varchar(10)) status, count_75 cantidad  from services_tires_complete where count_75 > 0 
			  	union all 
			  	select CAST('76%-100%' AS varchar(10)) status, count_100 cantidad  from services_tires_complete where count_100 > 0 
			  ) subquery
			group by subquery.status

        UNION ALL 

        SELECT CAST(status_temp AS varchar(10)) AS status_tmp, CAST(cantidad_temp AS bigint) AS cantidad_temp
            FROM (
                VALUES 
                	('0%-25%', 0),
                    ('26%-50%', 0),
                    ('51%-75%', 0),
                    ('76%-100%', 0)
            ) AS t(status_temp, cantidad_temp)

        ) AS combined
        GROUP BY combined.status;
END;
$$;


ALTER FUNCTION public.count_all_users_tires_lifespand_consumed_status() OWNER TO admin;

--
-- Name: count_all_users_tires_require_change(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_tires_require_change() RETURNS TABLE(status character varying, cantidad bigint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
    RETURN QUERY
        SELECT combined.status AS status, CAST(SUM(combined.cantidad) AS bigint) AS cantidad

        FROM
        (
            
			select subquery.status, sum (subquery.cantidad) cantidad
			  from (
			  	select CAST('Requieren Cambio' AS varchar(50)) status, 1 cantidad 
			  	  from services_tires_complete where count_100 > 0 or count_75 > 0 
			  	union all 
			  	select CAST('No Requieren Cambio' AS varchar(50)) status, 1 cantidad  
			  	  from services_tires_complete where count_25 > 0 or count_50 > 0 
			  ) subquery
			group by subquery.status

        UNION ALL 

        SELECT CAST(status_temp AS varchar(50)) AS status_tmp, CAST(cantidad_temp AS bigint) AS cantidad_temp
            FROM (
                VALUES 
                	('Requieren Cambio', 0),
                    ('No Requieren Cambio', 0)
            ) AS t(status_temp, cantidad_temp)

        ) AS combined
        GROUP BY combined.status;
END;
$$;


ALTER FUNCTION public.count_all_users_tires_require_change() OWNER TO admin;

--
-- Name: count_all_users_tires_summary_physical_state(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.count_all_users_tires_summary_physical_state() RETURNS TABLE(users bigint, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        
        select 	CAST(subquery.quantity AS bigint ) AS users_output,
        CAST(subquery.status AS varchar(50)) AS status_output
  from (        
	select 	'Buen estado' status, sum (services_tires_complete.count_not_apply) as quantity
	  from services_tires_complete
	union all
	select 	'Abultamiento' status, sum (services_tires_complete.count_bulge) as quantity
	  from services_tires_complete
	union all
	select 	'Perforaciones' status, sum (services_tires_complete.count_perforations) as quantity
	  from services_tires_complete
	union all
	select 	'Vulcanizado' status, sum (services_tires_complete.count_vulcanized) as quantity
	  from services_tires_complete
	union all
	select 	'Envejecimiento' status, sum (services_tires_complete.count_aging) as quantity
	  from services_tires_complete
	union all
	select 	'Grietas' status, sum (services_tires_complete.count_cracked) as quantity
	  from services_tires_complete
	union all
	select 	'Deformaciones' status, sum (services_tires_complete.count_deformations) as quantity
	  from services_tires_complete  
	union all
	select 	'Separaciones' status, sum (services_tires_complete.count_separations) as quantity
	  from services_tires_complete  
	) subquery;  
    END;
$$;


ALTER FUNCTION public.count_all_users_tires_summary_physical_state() OWNER TO admin;

--
-- Name: get_all_detail_services_by_user(bigint, character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_services_by_user(p_user_id bigint, p_service_id character varying) RETURNS TABLE(service_id bigint, vehicle_id bigint, marca character varying, modelo character varying, placa character varying, dueno character varying, conductor character varying, fecha date, estado character varying, tienda character varying, odometro double precision)
    LANGUAGE plpgsql
    AS $$ BEGIN 
	RETURN QUERY
SELECT services.odoo_id as service_id, 
			   services.vehicle_id, 	
			   services.vehicle_brand_name, 
			   services.vehicle_model_name,
			   services.plate,
			   services.owner_name,
			   services.driver_name,
			   services.service_date,
			   services.status,
			   services.store_name,
			   services.odometer 
		  from services_by_user_complete services
		 where (services.owner_id = p_user_id or driver_id = p_user_id) 
		   and CAST(services.service_id AS varchar) like CONCAT (p_service_id, '%') 
		 order by services.plate, services.service_date;
    END;
$$;


ALTER FUNCTION public.get_all_detail_services_by_user(p_user_id bigint, p_service_id character varying) OWNER TO admin;

--
-- Name: get_all_detail_services_status(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_services_status(p_user character varying, p_vehicle character varying, p_store character varying) RETURNS TABLE(service_id bigint, marca character varying, modelo character varying, placa character varying, dueno character varying, conductor character varying, fecha timestamp without time zone, estado character varying, tienda character varying)
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN QUERY
SELECT subquery.service_id_output,
    subquery.marca_output,
    subquery.modelo_output,
    subquery.placa_output,
    subquery.dueno_output,
    subquery.conductor_output,
    subquery.fecha_output,
    subquery.estado_output,
    subquery.tienda_output
FROM (
        SELECT CAST(service_id_ AS bigint) AS service_id_output,
            CAST(marca_ AS varchar(191)) AS marca_output,
            CAST(modelo_ AS varchar(191)) AS modelo_output,
            CAST(placa_ AS varchar(191)) AS placa_output,
            CAST(dueno_ AS varchar(191)) AS dueno_output,
            CAST(conductor_ AS varchar(191)) AS conductor_output,
            CAST(fecha_ AS timestamp) AS fecha_output,
            CAST(estado_ AS varchar(50)) AS estado_output,
            CAST(tienda_ AS varchar(50)) AS tienda_output
        FROM (
                VALUES (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    ),
                    (
                        123,
                        'Chevrolet',
                        'Aveo',
                        'ABC123',
                        'Jesus Salas',
                        'Jesus Salas',
                        '2024-01-01',
                        'Hecho',
                        'inv.facol'
                    )
            ) AS t(
                service_id_,
                marca_,
                modelo_,
                placa_,
                dueno_,
                conductor_,
                fecha_,
                estado_,
                tienda_
            )
    ) AS subquery;
END;
$$;


ALTER FUNCTION public.get_all_detail_services_status(p_user character varying, p_vehicle character varying, p_store character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_batteries_physical_state(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_batteries_physical_state(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, battery_brand_name character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        
		select 
				CAST(subquery.full_name AS varchar(191)) as full_name, 
				CAST(subquery.email AS varchar(191)) AS email, 
				CAST(subquery.phone AS varchar(50)) AS phone, 
				CAST(subquery.ubicacion AS varchar(50)) AS ubicacion,
				CAST(subquery.plate AS varchar(191)) AS plate, 
				CAST(subquery.battery_brand_name AS varchar(191)) AS battery_brand_name,
				CAST(subquery.status_temp AS varchar(191)) AS status
  from (
	select 'Buen estado' status_temp, services_battery_complete.*
	  from services_battery_complete
	 where services_battery_complete.count_buen_estado = 1  
	union all
	select 	'Fuga de líquido' status_temp, services_battery_complete.*
	  from services_battery_complete
	 where services_battery_complete.count_fuga_de_liquido = 1
	union all
	select 	'Bornes sulfatados y/o dañados' status, services_battery_complete.*
	  from services_battery_complete
	 where services_battery_complete.count_bornes_sulfatados = 1
	union all
	select 	'Cables partidos y/o sulfatados' status_temp, services_battery_complete.*
	  from services_battery_complete
	 where services_battery_complete.count_cables_partidos = 1
	union all
	select 	'Carcasa partida o impactada' status_temp, services_battery_complete.*
	  from services_battery_complete
	 where services_battery_complete.count_carcasa_partida = 1
	union all
	select 	'Batería Inflada' status_temp, services_battery_complete.*
	  from services_battery_complete
	 where services_battery_complete.count_bateria_inflada = 1
 ) subquery
 where status_temp = p_status;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_batteries_physical_state(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_batteries_status(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_batteries_status(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, battery_brand_name character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY

		select
			CAST(services_battery_complete.full_name AS varchar(191)) as full_name,
			CAST(services_battery_complete.email AS varchar(191)) AS email,
			CAST(services_battery_complete.phone AS varchar(50)) AS phone,
			CAST(services_battery_complete.ubicacion AS varchar(50)) AS ubicacion,
			CAST(services_battery_complete.plate AS varchar(191)) AS plate,
			CAST(services_battery_complete.battery_brand_name AS varchar(191)) AS battery_brand_name,
			CAST(services_battery_complete.health_status_final AS varchar(191)) AS status
		  from	services_battery_complete
 		 where health_status_final = p_status;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_batteries_status(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_batteries_summary_status(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_batteries_summary_status(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, battery_brand_name character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
		select 	details.full_name, 
				details.email, 
				details.phone, 
				details.ubicacion, 
				details.plate, 
				details.battery_brand_name,
				details.status
from 
(
select 	CAST(services_battery_complete.full_name AS varchar(191)) as full_name, 
		CAST(services_battery_complete.email AS varchar(191)) AS email, 
		CAST(services_battery_complete.phone AS varchar(50)) AS phone, 
		CAST(services_battery_complete.ubicacion AS varchar(50)) AS ubicacion,
		CAST(services_battery_complete.plate AS varchar(191)) AS plate, 
		CAST(services_battery_complete.battery_brand_name AS varchar(191)) AS battery_brand_name,
		CAST('Usuarios con baterías registradas'AS varchar(191)) AS status
  from public.services_battery_complete 
union all
select CAST(vehicle_without_services_battery.full_name AS varchar(191)) as full_name, 
		CAST(vehicle_without_services_battery.email AS varchar(191)) AS email, 
		CAST(vehicle_without_services_battery.phone AS varchar(50)) AS phone, 
		CAST(vehicle_without_services_battery.ubicacion AS varchar(50)) AS ubicacion,
		CAST(vehicle_without_services_battery.plate AS varchar(191)) AS plate, 
		CAST('N/D' AS varchar(191)) AS battery_brand_name,
		CAST('Usuarios sin baterías registradas' AS varchar(191)) AS status
  from vehicle_without_services_battery
union all
select CAST(services_battery_complete.full_name AS varchar(191)) as full_name, 
		CAST(services_battery_complete.email AS varchar(191)) AS email, 
		CAST(services_battery_complete.phone AS varchar(50)) AS phone, 
		CAST(services_battery_complete.ubicacion AS varchar(50)) AS ubicacion,
		CAST(services_battery_complete.plate AS varchar(191)) AS plate, 
		CAST(services_battery_complete.battery_brand_name AS varchar(191)) AS battery_brand_name,
		CAST('Usuarios con recargas' AS varchar(191)) AS status
  from public.services_battery_complete
  where services_battery_complete.battery_charged = true	) details
where details.status = p_status ;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_batteries_summary_status(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_service_balancing_status(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_service_balancing_status(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, vehicle_brand_name character varying, vehicle_model_name character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
			SELECT 
				CAST(subquery.full_name AS varchar(191)) as full_name, 
				CAST(subquery.email AS varchar(191)) AS email, 
				CAST(subquery.phone AS varchar(50)) AS phone, 
				CAST(subquery.ubicacion AS varchar(50)) AS ubicacion,
				CAST(subquery.plate AS varchar(191)) AS plate, 
				CAST(subquery.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
				CAST(subquery.vehicle_model_name AS varchar(191)) AS vehicle_model_name
			FROM(
				select 	CAST(subquery_1.full_name AS varchar(191)) as full_name, 
						CAST(subquery_1.email AS varchar(191)) AS email, 
						CAST(subquery_1.phone AS varchar(50)) AS phone, 
						CAST(subquery_1.ubicacion AS varchar(50)) AS ubicacion,
						CAST(subquery_1.plate AS varchar(191)) AS plate, 
						CAST(subquery_1.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
						CAST(subquery_1.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
						'Requieren Servicio' status
	  			  from services_balancing_complete subquery_1
	             where kms_recorridos >= 5000 or elapsed_days >= 180
				 union all 
				select 	CAST(subquery_2.full_name AS varchar(191)) as full_name, 
						CAST(subquery_2.email AS varchar(191)) AS email, 
						CAST(subquery_2.phone AS varchar(50)) AS phone, 
						CAST(subquery_2.ubicacion AS varchar(50)) AS ubicacion,
						CAST(subquery_2.plate AS varchar(191)) AS plate, 
						CAST(subquery_2.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
						CAST(subquery_2.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
					   'No Requieren Servicio' status
				  from services_balancing_complete  subquery_2
				 where kms_recorridos < 5000 and elapsed_days < 180
				 union all 
				select 	CAST(subquery_3.full_name AS varchar(191)) as full_name, 
						CAST(subquery_3.email AS varchar(191)) AS email, 
						CAST(subquery_3.phone AS varchar(50)) AS phone, 
						CAST(subquery_3.ubicacion AS varchar(50)) AS ubicacion,
						CAST(subquery_3.plate AS varchar(191)) AS plate, 
						CAST(subquery_3.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
						CAST(subquery_3.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
					   'Sin Servicios Registrados' status
				  from vehicle_without_services_balancing subquery_3
			) subquery		
			WHERE subquery.status = p_status;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_service_balancing_status(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_service_oil_change_status(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_service_oil_change_status(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, vehicle_brand_name character varying, vehicle_model_name character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
			SELECT 
				CAST(subquery.full_name AS varchar(191)) as full_name, 
				CAST(subquery.email AS varchar(191)) AS email, 
				CAST(subquery.phone AS varchar(50)) AS phone, 
				CAST(subquery.ubicacion AS varchar(50)) AS ubicacion,
				CAST(subquery.plate AS varchar(191)) AS plate, 
				CAST(subquery.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
				CAST(subquery.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
				CAST(subquery.status_temp AS varchar(191)) AS status
			FROM(
				select 	CAST(subquery_1.full_name AS varchar(191)) as full_name, 
						CAST(subquery_1.email AS varchar(191)) AS email, 
						CAST(subquery_1.phone AS varchar(50)) AS phone, 
						CAST(subquery_1.ubicacion AS varchar(50)) AS ubicacion,
						CAST(subquery_1.plate AS varchar(191)) AS plate, 
						CAST(subquery_1.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
						CAST(subquery_1.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
						CAST('Requiere Cambio de Aceite' AS varchar(191)) as status_temp
	  			  from services_oil_complete subquery_1
	             where kms_recorridos >= life_span or elapsed_days >= 90
				 union all 
				select 	CAST(subquery_2.full_name AS varchar(191)) as full_name, 
						CAST(subquery_2.email AS varchar(191)) AS email, 
						CAST(subquery_2.phone AS varchar(50)) AS phone, 
						CAST(subquery_2.ubicacion AS varchar(50)) AS ubicacion,
						CAST(subquery_2.plate AS varchar(191)) AS plate, 
						CAST(subquery_2.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
						CAST(subquery_2.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
					   CAST('Aceite Saludable' AS varchar(191)) as status_temp
				  from services_oil_complete  subquery_2
				 where kms_recorridos < life_span and elapsed_days < 90
				 union all 
				select 	CAST(subquery_3.full_name AS varchar(191)) as full_name, 
						CAST(subquery_3.email AS varchar(191)) AS email, 
						CAST(subquery_3.phone AS varchar(50)) AS phone, 
						CAST(subquery_3.ubicacion AS varchar(50)) AS ubicacion,
						CAST(subquery_3.plate AS varchar(191)) AS plate, 
						CAST(subquery_3.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
						CAST(subquery_3.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
					   CAST('Sin Cambios Registrados' AS varchar(191))  as status_temp
				  from vehicle_without_services_oil subquery_3
			) subquery		
			WHERE subquery.status_temp = p_status;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_service_oil_change_status(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_tires_lifespand_consumed_status(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_tires_lifespand_consumed_status(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, vehicle_brand_name character varying, vehicle_model_name character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        
		select 
				CAST(subquery.full_name AS varchar(191)) as full_name, 
				CAST(subquery.email AS varchar(191)) AS email, 
				CAST(subquery.phone AS varchar(50)) AS phone, 
				CAST(subquery.ubicacion AS varchar(50)) AS ubicacion,
				CAST(subquery.plate AS varchar(191)) AS plate, 
				CAST(subquery.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
				CAST(subquery.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
				CAST(subquery.status_temp AS varchar(191)) AS status
  from (
	select CAST('0%-25%' AS varchar(191)) AS status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_25 > 0   
	union all
	select 	CAST('26%-50%' AS varchar(191)) AS status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_50 > 0
	union all
	select 	CAST('51%-75%' AS varchar(191)) AS status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_75 > 0 
	union all
	select 	CAST('76%-100%' AS varchar(191)) AS status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_100 > 0
 ) subquery
 where status_temp = p_status;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_tires_lifespand_consumed_status(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_tires_require_change(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_tires_require_change(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, vehicle_brand_name character varying, vehicle_model_name character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        
		select 
				CAST(subquery.full_name AS varchar(191)) as full_name, 
				CAST(subquery.email AS varchar(191)) AS email, 
				CAST(subquery.phone AS varchar(50)) AS phone, 
				CAST(subquery.ubicacion AS varchar(50)) AS ubicacion,
				CAST(subquery.plate AS varchar(191)) AS plate, 
				CAST(subquery.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
				CAST(subquery.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
				CAST(subquery.status_temp AS varchar(191)) AS status
  from (
	select CAST('Requieren Cambio' AS varchar(191)) status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_100 > 0 or services_tires_complete.count_75 > 0
	union all
	select 	CAST('No Requieren Cambio' AS varchar(191)) status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_50 > 0 or services_tires_complete.count_25 > 0
 ) subquery
 where status_temp = p_status;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_tires_require_change(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_users_by_tires_summary_physical_state(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_users_by_tires_summary_physical_state(p_status character varying) RETURNS TABLE(full_name character varying, email character varying, phone character varying, ubicacion character varying, plate character varying, vehicle_brand_name character varying, vehicle_model_name character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        
		select 
				CAST(subquery.full_name AS varchar(191)) as full_name, 
				CAST(subquery.email AS varchar(191)) AS email, 
				CAST(subquery.phone AS varchar(50)) AS phone, 
				CAST(subquery.ubicacion AS varchar(50)) AS ubicacion,
				CAST(subquery.plate AS varchar(191)) AS plate, 
				CAST(subquery.vehicle_brand_name AS varchar(191)) AS vehicle_brand_name,
				CAST(subquery.vehicle_model_name AS varchar(191)) AS vehicle_model_name,
				CAST(subquery.status_temp AS varchar(191)) AS status
  from (
	select 'Buen estado' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_not_apply = 1  
	union all
	select 	'Abultamiento' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_bulge = 1
	union all
	select 	'Perforaciones' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_perforations = 1
	union all
	select 	'Vulcanizado' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_vulcanized = 1
	union all
	select 	'Envejecimiento' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_aging = 1
	union all
	select 	'Grietas' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_cracked = 1
	union all
	select 	'Deformaciones' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_deformations = 1
	union all
	select 	'Separaciones' status_temp, services_tires_complete.*
	  from services_tires_complete
	 where services_tires_complete.count_separations = 1
 ) subquery
 where status_temp = p_status;
    END;
$$;


ALTER FUNCTION public.get_all_detail_users_by_tires_summary_physical_state(p_status character varying) OWNER TO admin;

--
-- Name: get_all_detail_vehicles_by_user(integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_all_detail_vehicles_by_user(p_user_id integer) RETURNS TABLE(vehicle_id bigint, placa character varying, marca character varying, modelo character varying, color character varying, anio integer, transmision character varying, combustible character varying, odometro double precision)
    LANGUAGE plpgsql
    AS $$
	begin
		        RETURN QUERY

		select distinct v.odoo_id vehicle_id,
			v.plate,
	        CASE
	            WHEN vb.name IS NULL THEN 'N/D'::character varying
	            ELSE vb.name
	        END AS vehicle_brand_name,
	        CASE
	            WHEN vm.name IS NULL THEN 'N/D'::character varying
	            ELSE vm.name
	        END AS vehicle_model_name,
	        v.color, 
	        v.year,
	        CASE
	            WHEN v.transmission = 'manual' THEN 'Sincrónico'::character varying
	            WHEN v.transmission = 'automatic' THEN 'Automático'::character varying
	            WHEN v.transmission = 'dual' THEN 'Dual'::character varying
	            ELSE 'N/D'::character varying
	        END AS transmission,
	        CASE
	            WHEN v.fuel = 'glp' THEN 'GLP'::character varying
	            WHEN v.fuel = 'gasolin' THEN 'Gasolina'::character varying
	            WHEN v.fuel = 'diesel' THEN 'Diesel'::character varying
	            WHEN v.fuel = 'electric' THEN 'Eléctrico'::character varying
	            ELSE 'N/D'::character varying
	        END AS fuel, 
	        v.odometer
		    from services services 
			JOIN vehicles v ON services.vehicle_id = v.odoo_id
			JOIN vehicle_brands vb ON v.vehicle_brand_id = vb.odoo_id
			JOIN vehicle_models vm ON v.vehicle_model_id = vm.odoo_id
           where services.owner_id = p_user_id or services.driver_id = p_user_id;			
	END;
$$;


ALTER FUNCTION public.get_all_detail_vehicles_by_user(p_user_id integer) OWNER TO admin;

--
-- Name: get_app_warnings_resume(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_app_warnings_resume() RETURNS TABLE(id integer, warning_name character varying, quantity bigint, threshold bigint, result_color character varying)
    LANGUAGE plpgsql
    AS $$
	BEGIN 
	RETURN QUERY

		select 1 as id, cast('Neumático Autoregenerado' as varchar(50)) warning_name, 
				(select count(*) from  warning_autohealing_tires) as quantity, cast(500 as bigint) threshold, cast('#CA0000' as varchar(20)) result_color
		union all
		select 2 as id, cast('Warning Desconocido' as varchar(50)) warning_name, 
				(select count(*) from  services_oil_complete soc) as quantity, cast(300 as bigint) threshold, cast('' as varchar(20)) result_color;
			
	END;
$$;


ALTER FUNCTION public.get_app_warnings_resume() OWNER TO admin;

--
-- Name: get_service_inspections(bigint, bigint); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_service_inspections(p_user_id bigint, p_service_id bigint) RETURNS TABLE(flag_service_tires boolean, flag_service_oil boolean, flag_service_battery boolean, flag_service_balancing boolean, flag_service_rotation boolean, flag_service_alignment boolean)
    LANGUAGE plpgsql
    AS $$ BEGIN 
	RETURN QUERY
select 
	case when
		summarize.count_service_tires > 0 then true else false
	end flag_service_tires,
	case when
       summarize.count_service_oil > 0 then true else false
	end flag_service_oil,
	case when
       summarize.count_service_battery > 0 then true else false
	end flag_service_battery,
	case when
       summarize.count_service_balancing > 0 then true else false
	end flag_service_balancing,
	case when
       summarize.count_service_rotation > 0 then true else false
	end flag_service_rotation,
	case when
       summarize.count_service_alignment > 0 then true else false
	end flag_service_alignment
  from (
select sum (details.count_service_tires) count_service_tires, 
       sum (details.count_service_oil) count_service_oil, 
       sum (details.count_service_battery) count_service_battery, 
       sum (details.count_service_balancing) count_service_balancing, 
       sum (details.count_service_rotation) count_service_rotation,
       sum (details.count_service_alignment) count_service_alignment
       from (
			select count(*) count_service_tires, 
			       0 count_service_oil, 
			       0 count_service_battery, 
			       0 count_service_balancing, 
			       0 count_service_rotation,
			       0 count_service_alignment
			  from services_tires_histories_complete 
			 where res_partner_id = p_user_id
			   and service_id = p_service_id
			 union all 
			select 0 count_service_tires, 
			       count(*) count_service_oil, 
			       0 count_service_battery, 
			       0 count_service_balancing, 
			       0 count_service_rotation,
			       0 count_service_service_alignment
			  from services_oil_histories_complete 
			 where res_partner_id = p_user_id
			   and service_id = p_service_id
			 union all 
			select 0 count_service_tires, 
			       0 count_service_oil, 
			        count(*)  count_service_battery, 
			       0 count_service_balancing, 
			       0 count_service_rotation,
			       0 count_service_service_alignment
			  from services_battery_histories_complete 
			 where res_partner_id = p_user_id
			   and service_id = p_service_id
			  union all 
			select 0 count_service_tires, 
			       0 count_service_oil, 
			       0 count_service_battery, 
			       count(*) count_service_balancing, 
			       0 count_service_rotation,
			       0 count_service_service_alignment
			  from services_balancing_histories_complete
			 where res_partner_id = p_user_id
			   and service_id = p_service_id
			union all 
			select 0 count_service_tires, 
			       0 count_service_oil, 
			       0 count_service_battery, 
			       0 count_service_balancing, 
			       count(*) count_service_rotation,
			       0 count_service_service_alignment
			  from services_tires_histories_complete 
			 where (rotation_x or rotation_lineal)
			   and res_partner_id = p_user_id
			   and service_id = p_service_id
	) details   
) summarize
;
    END;
$$;


ALTER FUNCTION public.get_service_inspections(p_user_id bigint, p_service_id bigint) OWNER TO admin;

--
-- Name: log_message(character varying); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.log_message(IN p_message character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    project VARCHAR(50) := 'iron-staging-db';
BEGIN
    RAISE LOG '% - % - %', project, p_message, current_timestamp;
END;
$$;


ALTER PROCEDURE public.log_message(IN p_message character varying) OWNER TO admin;

--
-- Name: odometers_upsert(bigint, bigint, character varying, double precision, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.odometers_upsert(IN p_vehicle_id bigint, IN p_driver_id bigint, IN p_date character varying, IN p_value double precision, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."odometers" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."odometers" SET
		 "vehicle_id" = p_vehicle_id,
		  "driver_id" = p_driver_id,
			   "date" = p_date,
			  "value" = p_value,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('odometers_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."odometers" ( "vehicle_id", "driver_id", "date", "value", "created_at", "sequence_id", "odoo_id")
	VALUES ( p_vehicle_id, p_driver_id, p_date, p_value, CURRENT_TIMESTAMP, nextval('odometers_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.odometers_upsert(IN p_vehicle_id bigint, IN p_driver_id bigint, IN p_date character varying, IN p_value double precision, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: oil_change_histories_addnewservice(bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.oil_change_histories_addnewservice(IN p_service_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_sequence_id bigint;
BEGIN
    p_sequence_id = NEXTVAL('oil_change_histories_sequence');
    INSERT INTO public.oil_change_histories (vehicle_id, service_id, change_date, change_km, change_next_km, change_next_date, life_span, life_span_standar, service_state, created_at, sequence_id)
    SELECT
        src.vehicle_id,
        src.service_id,
        src.change_date,
        src.change_km,
		src.change_next_km,
		src.change_next_date,
		src.life_span,
		src.life_span_standar,
	    src.service_state,
        CURRENT_TIMESTAMP AS created_at,
        p_sequence_id
    FROM
        public.datato_oil_change_histories AS src
    WHERE
        src.service_id = p_service_id
    ON CONFLICT (vehicle_id, service_id)
    /* or you may use [DO NOTHING;] */
        DO UPDATE SET
          change_date = EXCLUDED.change_date,
            change_km = EXCLUDED.change_km,
       change_next_km = EXCLUDED.change_next_km,
     change_next_date = EXCLUDED.change_next_date,
            life_span = EXCLUDED.life_span,
    life_span_standar = EXCLUDED.life_span_standar,
	    service_state = EXCLUDED.service_state,
           updated_at = CURRENT_TIMESTAMP,
          sequence_id = p_sequence_id;
END
$$;


ALTER PROCEDURE public.oil_change_histories_addnewservice(IN p_service_id bigint) OWNER TO admin;

--
-- Name: oil_change_histories_addnewvisits(bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.oil_change_histories_addnewvisits(IN p_vehicle_id bigint, IN p_service_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_rowcount int4;
    FC date;
    F2 date;
    F3 date;
    F1 date;
    O2 int4;
    O1 int4;
    lsp int4;
    FP date;
    p_change_next_days int4;
    last_service_id bigint;
BEGIN
    SELECT
        COUNT(*)
    FROM
        public.datato_oil_change_histories INTO p_rowcount
    WHERE
        vehicle_id = p_vehicle_id
        AND NOT service_state = 'cancelled';
    IF (p_rowcount >= 1) THEN
        WITH dataVeh AS (
            SELECT
              --FIRST_VALUE(change_date) OVER (PARTITION BY vehicle_id) AS FF1,
              --FIRST_VALUE(change_km) OVER (PARTITION BY vehicle_id) AS FO1,
                life_span,
                LAST_VALUE(service_id) OVER (PARTITION BY vehicle_id) AS service_id,
                LAST_VALUE(change_date) OVER (PARTITION BY vehicle_id) AS change_date,
                vehicle_id
            FROM
                public.datato_oil_change_histories
            WHERE
                vehicle_id = p_vehicle_id
            LIMIT 1
)
    SELECT
        life_span,
        service_id,
        change_date
    FROM
        dataVeh INTO lsp,
        last_service_id,
        FC
    WHERE
        vehicle_id = p_vehicle_id;
        SELECT
            "date",
            odometer
        FROM
            services s INTO F1,
            O1
        WHERE
            s.vehicle_id = p_vehicle_id
        ORDER BY
            s.vehicle_id,
            s.odoo_id
        LIMIT 1;
        SELECT
            "date",
            odometer
        FROM
            services s INTO F3,
            O2
        WHERE
            s.vehicle_id = p_vehicle_id
            AND s.odoo_id = p_service_id;
        p_change_next_days = lsp / ((O2 - O1) / ((F3 - F1) + 1));
        FP = FC + p_change_next_days;
        RAISE NOTICE 'Cantidad %, FP %, days %, data: F2: % | O2: % | F1: % | O1: % | LSP: % | LAST_OIL_CHANGE % | O2-O1: % | F2-F1: %  | KMXDIA: % ', p_rowcount, FP, p_change_next_days, F3, O2, F1, O1, lsp, last_service_id, O2 - O1, (F3 - F1)+1, ((O2 - O1) / ((F3 - F1) + 1)) ;
        UPDATE
            public.oil_change_histories
        SET
            change_next_date = FP,
            change_next_days = p_change_next_days,
            updated_at = CURRENT_TIMESTAMP
        WHERE
            vehicle_id = p_vehicle_id
            AND service_id = last_service_id;
    END IF;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'División por cero';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error %', sqlstate;
END
$$;


ALTER PROCEDURE public.oil_change_histories_addnewvisits(IN p_vehicle_id bigint, IN p_service_id bigint) OWNER TO admin;

--
-- Name: oil_change_histories_change_next_date(bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.oil_change_histories_change_next_date(IN p_vehicle_id bigint, IN p_service_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_rowcount int4;
    F2 date;
    F1 date;
    O2 int4;
    O1 int4;
    lsp int4;
    FP date;
    p_change_next_days int4;
BEGIN
    SELECT
        COUNT(*)
    FROM
        public.datato_oil_change_histories INTO p_rowcount
    WHERE
        vehicle_id = p_vehicle_id
        AND NOT service_state = 'cancelled';
    IF (p_rowcount >= 2) THEN
        WITH dataVeh AS (
            SELECT
                vehicle_id,
                service_id,
                change_date,
                change_km,
                FIRST_VALUE(change_date) OVER (PARTITION BY vehicle_id) AS FF1,
                FIRST_VALUE(change_km) OVER (PARTITION BY vehicle_id) AS FO1,
                life_span
            FROM
                public.datato_oil_change_histories
            WHERE
                vehicle_id = p_vehicle_id
)
        SELECT
            change_date,
            change_km,
            FF1,
            FO1,
            life_span
        FROM
            dataVeh INTO F2,
            O2,
            F1,
            O1,
            lsp
        WHERE
            vehicle_id = p_vehicle_id
            AND service_id = p_service_id;
        --RAISE NOTICE 'Cantidad %, data: % % % % %', p_rowcount, F2, O2, F1, O1, lsp;
        -- FP = F2 + (lsp / ((O2 - o1) / (F2 - F1 + 1)));
        --RAISE NOTICE ' DATA % % %', lsp, (O2 - O1), (F2 - F1 + 1);
        p_change_next_days = lsp / ((O2 - O1) / (F2 - F1 + 1));
        FP = F2 + p_change_next_days;
        --RAISE NOTICE 'Cantidad %, FP %, days %, data: % % % % %', p_rowcount, FP, p_change_next_days, F2, O2, F1, O1, lsp;
        UPDATE
            public.oil_change_histories
        SET
            change_next_date = FP,
            change_next_days = p_change_next_days,
            updated_at = CURRENT_TIMESTAMP
        WHERE
            vehicle_id = p_vehicle_id
            AND service_id = p_service_id;
    END IF;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'División por cero';
END
$$;


ALTER PROCEDURE public.oil_change_histories_change_next_date(IN p_vehicle_id bigint, IN p_service_id bigint) OWNER TO admin;

--
-- Name: oil_change_histories_upsert(bigint, bigint, date, double precision, double precision, date, integer, integer, character varying); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.oil_change_histories_upsert(IN p_vehicle_id bigint, IN p_service_id bigint, IN p_change_date date, IN p_change_km double precision, IN p_change_next_km double precision, IN p_change_next_date date, IN p_life_span integer, IN p_life_span_standar integer, IN p_service_state character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (EXISTS (
        SELECT
            vehicle_id
        FROM
            public.oil_change_histories
        WHERE
            vehicle_id = p_vehicle_id AND service_id = p_service_id)) THEN
        UPDATE
            public.oil_change_histories
        SET
            change_date = p_change_date,
            change_km = p_change_km,
            change_next_km = p_change_next_km,
            change_next_date = p_change_next_date,
            life_span = p_life_span,
            life_span_standar = p_life_span_standar,
            service_state = p_service_state,
            updated_at = CURRENT_TIMESTAMP,
            sequence_id = NEXTVAL('oil_change_histories_sequence')
        WHERE
            vehicle_id = p_vehicle_id
            AND service_id = p_service_id;
    ELSE
        INSERT INTO public.oil_change_histories (vehicle_id, service_id, change_date, change_km, change_next_km, change_next_date, life_span, life_span_standar, service_state, created_at, sequence_id)
            VALUES (p_vehicle_id, p_service_id, p_change_date, p_change_km, p_change_next_km, p_change_next_date, p_life_span, p_life_span_standar, p_service_state, CURRENT_TIMESTAMP, NEXTVAL('oil_change_histories_sequence'));
    END IF;
END;
$$;


ALTER PROCEDURE public.oil_change_histories_upsert(IN p_vehicle_id bigint, IN p_service_id bigint, IN p_change_date date, IN p_change_km double precision, IN p_change_next_km double precision, IN p_change_next_date date, IN p_life_span integer, IN p_life_span_standar integer, IN p_service_state character varying) OWNER TO admin;

--
-- Name: product_categories_upsert(character varying, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.product_categories_upsert(IN p_name character varying, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."product_categories" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."product_categories" SET
			   "name" = p_name,
		 "updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('product_categories_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."product_categories" ("name", "created_at", "sequence_id", "odoo_id")
	VALUES (p_name, CURRENT_TIMESTAMP, nextval('product_categories_sequence'), p_odoo_id );


END IF;

END;
$$;


ALTER PROCEDURE public.product_categories_upsert(IN p_name character varying, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: products_upsert(character varying, double precision, integer, character varying, bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.products_upsert(IN p_name character varying, IN p_otd double precision, IN p_life_span integer, IN p_life_span_unit character varying, IN p_product_category_id bigint, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."products" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."products" SET
			   "name" = p_name,
				"otd" = p_otd,
		  "life_span" = p_life_span,
	 "life_span_unit" = p_life_span_unit,
"product_category_id" = p_product_category_id,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('products_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."products" ("name", "otd", "life_span", "life_span_unit", "product_category_id", "created_at", "sequence_id", "odoo_id")
	VALUES (p_name, p_otd, p_life_span, p_life_span_unit, p_product_category_id, CURRENT_TIMESTAMP, nextval('products_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.products_upsert(IN p_name character varying, IN p_otd double precision, IN p_life_span integer, IN p_life_span_unit character varying, IN p_product_category_id bigint, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: service_alignment_upsert(bigint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_alignment_upsert(IN p_service_id bigint, IN p_eje character varying, IN p_valor character varying, IN p_full_convergence_d character varying, IN p_semiconvergence_izq_d character varying, IN p_semiconvergence_der_d character varying, IN p_camber_izq_d character varying, IN p_camber_der_d character varying, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."service_alignment" WHERE "odoo_id" = p_odoo_id)) THEN
		UPDATE "public"."service_alignment" SET
		"service_id" = p_service_id,
		"eje" = p_eje,
		"valor" = p_valor,
		"full_convergence_d" = p_full_convergence_d,
		"semiconvergence_izq_d" = p_semiconvergence_izq_d,
		"semiconvergence_der_d" = p_semiconvergence_der_d,
		"camber_izq_d" = p_camber_izq_d,
		"camber_der_d" = p_camber_der_d,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('service_alignment_sequence')
	  WHERE "odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."service_alignment" ("service_id", "eje", "valor", "full_convergence_d", "semiconvergence_izq_d", "semiconvergence_der_d", "camber_izq_d", "camber_der_d", "created_at", "sequence_id", "odoo_id")
	VALUES(p_service_id, p_eje, p_valor, p_full_convergence_d, p_semiconvergence_izq_d, p_semiconvergence_der_d, p_camber_izq_d, p_camber_der_d, CURRENT_TIMESTAMP, nextval('service_alignment_sequence'), p_odoo_id);


END IF;

END;
$$;


ALTER PROCEDURE public.service_alignment_upsert(IN p_service_id bigint, IN p_eje character varying, IN p_valor character varying, IN p_full_convergence_d character varying, IN p_semiconvergence_izq_d character varying, IN p_semiconvergence_der_d character varying, IN p_camber_izq_d character varying, IN p_camber_der_d character varying, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: service_balancing_upsert(bigint, bigint, character varying, double precision, character varying, boolean, boolean, boolean, boolean, boolean); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_balancing_upsert(IN p_odoo_id bigint, IN p_service_id bigint, IN p_location character varying, IN p_lead_used double precision, IN p_type_lead character varying, IN p_balanced boolean, IN p_wheel_good_state boolean, IN p_wheel_scratched boolean, IN p_wheel_cracked boolean, IN p_wheel_bent boolean)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."service_balancing" WHERE "odoo_id" = p_odoo_id)) THEN
    UPDATE "public"."service_balancing" SET
           "service_id" = p_service_id,
          "location" = p_location,
           "lead_used" = p_lead_used,
          "type_lead" = p_type_lead,
          "balanced" = p_balanced,
          "wheel_good_state" = p_wheel_good_state,
          "wheel_scratched" = p_wheel_scratched,
          "wheel_cracked" = p_wheel_cracked,
          "wheel_bent" = p_wheel_bent,
          "updated_at" = CURRENT_TIMESTAMP,
          "sequence_id" = nextval('service_balancing_sequence')
      WHERE "odoo_id" = p_odoo_id;
ELSE
    INSERT INTO "public"."service_balancing" ("sequence_id","odoo_id","service_id", "location", "lead_used", "type_lead", "balanced", "wheel_good_state", "wheel_scratched", "wheel_cracked", "wheel_bent", "created_at")
    VALUES(nextval('service_balancing_sequence'), p_odoo_id, p_service_id, p_location, p_lead_used, p_type_lead, p_balanced, p_wheel_good_state, p_wheel_scratched, p_wheel_cracked, p_wheel_bent, CURRENT_TIMESTAMP);

END IF;

END;
$$;


ALTER PROCEDURE public.service_balancing_upsert(IN p_odoo_id bigint, IN p_service_id bigint, IN p_location character varying, IN p_lead_used double precision, IN p_type_lead character varying, IN p_balanced boolean, IN p_wheel_good_state boolean, IN p_wheel_scratched boolean, IN p_wheel_cracked boolean, IN p_wheel_bent boolean) OWNER TO admin;

--
-- Name: service_battery_upsert(bigint, bigint, bigint, timestamp without time zone, timestamp without time zone, bigint, character varying, double precision, double precision, character varying, character varying, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, character varying, double precision, double precision, character varying, double precision, boolean); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_battery_upsert(IN p_odoo_id bigint, IN p_battery_brand_id bigint, IN p_battery_model_id bigint, IN p_date_of_purchase timestamp without time zone, IN p_warranty_date timestamp without time zone, IN p_service_id bigint, IN p_amperage character varying, IN p_alternator_voltage double precision, IN p_battery_voltage double precision, IN p_status_battery character varying, IN p_status_alternator character varying, IN p_good_condition boolean, IN p_liquid_leakage boolean, IN p_corroded_terminals boolean, IN p_frayed_cables boolean, IN p_inflated boolean, IN p_cracked_case boolean, IN p_new_battery boolean, IN p_replaced_battery boolean, IN p_serial_product character varying, IN p_starting_current double precision, IN p_accumulated_load_capacity double precision, IN p_health_status character varying, IN p_health_percentage double precision, IN p_battery_charged boolean)
    LANGUAGE plpgsql
    AS $$

DECLARE
  p_health_status_final character varying(50); -- Declaración de la variable p_health_status_final

BEGIN

--SI DETECTA UN CAMBIO DE BATERIA BORRA TODOS LOS REGISTROS service_battery PARA ESE VEHICULO
IF (p_replaced_battery) THEN

    WITH s1 AS (
      SELECT vehicle_id
      FROM services
      WHERE odoo_id = p_service_id
    )

    DELETE FROM service_battery
    WHERE service_id IN (
      SELECT odoo_id
      FROM services
      JOIN s1 ON services.vehicle_id = s1.vehicle_id
    );

END IF;

IF (p_health_percentage >= 75) THEN

    IF(p_battery_voltage >  12.4) THEN
      p_health_status_final := 'Buen estado';

    ELSIF(p_battery_voltage >= 12 AND p_battery_voltage <= 12.4) THEN
      p_health_status_final := 'Requiere carga';

    ELSIF(p_battery_voltage >= 10.5 AND p_battery_voltage <= 12) THEN
      p_health_status_final := 'Requiere carga';

    ELSIF(p_battery_voltage < 10.5) THEN
      p_health_status_final := 'Dañada';

    ELSE
      p_health_status_final := 'Dañada';

    END IF;

ELSIF (p_health_percentage <= 74) THEN

    IF(p_battery_voltage >  12.4) THEN
      p_health_status_final := 'Deficiente';

    ELSIF(p_battery_voltage >= 12 AND p_battery_voltage <= 12.4) THEN
      p_health_status_final := 'Deficiente';

    ELSIF(p_battery_voltage >= 10.5 AND p_battery_voltage < 12) THEN
      p_health_status_final := 'Deficiente';

    ELSIF(p_battery_voltage < 10.5) THEN
      p_health_status_final := 'Dañada';

    ELSE
      p_health_status_final := 'Dañada';

    END IF;
ELSE
    p_health_status_final := 'Dañada';

END IF;

-- SI EXISTE EL ID EN ODOO SE ACTUALIZA
IF (EXISTS (SELECT "odoo_id" FROM "public"."service_battery" WHERE "odoo_id" = p_odoo_id)) THEN
    UPDATE "public"."service_battery" SET
          "battery_brand_id" = p_battery_brand_id,
          "battery_model_id" = p_battery_model_id,
          "date_of_purchase" = p_date_of_purchase,
          "warranty_date" = p_warranty_date,
          "service_id" = p_service_id,
          "amperage" = p_amperage,
          "alternator_voltage" = p_alternator_voltage,
          "battery_voltage" = p_battery_voltage,
          "status_battery" = p_status_battery,
          "status_alternator" = p_status_alternator,
          "good_condition" = p_good_condition,
          "liquid_leakage" = p_liquid_leakage,
          "corroded_terminals" = p_corroded_terminals,
          "frayed_cables" = p_frayed_cables,
          "inflated" = p_inflated,
          "cracked_case" = p_cracked_case,
          "new_battery" = p_new_battery,
          "replaced_battery" = p_replaced_battery,
          "updated_at" = CURRENT_TIMESTAMP,
          "sequence_id" = nextval('service_battery_sequence'),
          "serial_product" = p_serial_product,
          "starting_current" = p_starting_current,
          "accumulated_load_capacity" = p_accumulated_load_capacity,
          "health_status" = p_health_status,
          "health_percentage" = p_health_percentage,
          "health_status_final" = p_health_status_final,
          "battery_charged" = p_battery_charged

      WHERE "odoo_id" = p_odoo_id;

-- SI NO EXISTE SE INSERTA
ELSE
  INSERT INTO "public"."service_battery"  (
        "sequence_id",
        "odoo_id",
        "battery_brand_id",
        "battery_model_id",
        "date_of_purchase",
        "warranty_date",
        "service_id",
        "amperage",
        "alternator_voltage",
        "battery_voltage",
        "status_battery",
        "status_alternator",
        "good_condition",
        "liquid_leakage",
        "corroded_terminals",
        "frayed_cables",
        "inflated",
        "cracked_case",
        "new_battery",
        "replaced_battery",
        "created_at",
        "serial_product",
        "starting_current",
        "accumulated_load_capacity",
        "health_status",
        "health_percentage",
        "health_status_final",
        "battery_charged")

      VALUES(
        nextval('service_battery_sequence'),
        p_odoo_id,
        p_battery_brand_id,
        p_battery_model_id,
        p_date_of_purchase,
        p_warranty_date,
        p_service_id,
        p_amperage,
        p_alternator_voltage,
        p_battery_voltage,
        p_status_battery,
        p_status_alternator,
        p_good_condition,
        p_liquid_leakage,
        p_corroded_terminals,
        p_frayed_cables,
        p_inflated,
        p_cracked_case,
        p_new_battery,
        p_replaced_battery,
        CURRENT_TIMESTAMP,
        p_serial_product,
        p_starting_current,
        p_accumulated_load_capacity,
        p_health_status,
        p_health_percentage,
        p_health_status_final,
        p_battery_charged);

END IF;

END;
$$;


ALTER PROCEDURE public.service_battery_upsert(IN p_odoo_id bigint, IN p_battery_brand_id bigint, IN p_battery_model_id bigint, IN p_date_of_purchase timestamp without time zone, IN p_warranty_date timestamp without time zone, IN p_service_id bigint, IN p_amperage character varying, IN p_alternator_voltage double precision, IN p_battery_voltage double precision, IN p_status_battery character varying, IN p_status_alternator character varying, IN p_good_condition boolean, IN p_liquid_leakage boolean, IN p_corroded_terminals boolean, IN p_frayed_cables boolean, IN p_inflated boolean, IN p_cracked_case boolean, IN p_new_battery boolean, IN p_replaced_battery boolean, IN p_serial_product character varying, IN p_starting_current double precision, IN p_accumulated_load_capacity double precision, IN p_health_status character varying, IN p_health_percentage double precision, IN p_battery_charged boolean) OWNER TO admin;

--
-- Name: service_items_actions_upsert(bigint, integer); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_items_actions_upsert(IN p_product_id bigint, IN p_code integer)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "code" FROM "public"."service_items_actions" WHERE "code" = p_code)) THEN
	UPDATE "public"."service_items_actions" SET
		 "product_id" = p_product_id,
		  "code" = p_code,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('service_items_actions_sequence')
	WHERE
			"product_id" = p_product_id AND "code" = p_code;
ELSE
	INSERT INTO "public"."service_items_actions" ( "product_id", "code", "created_at", "sequence_id")
	VALUES ( p_product_id, p_code, CURRENT_TIMESTAMP, nextval('service_items_actions_sequence') );
END IF;

END;
$$;


ALTER PROCEDURE public.service_items_actions_upsert(IN p_product_id bigint, IN p_code integer) OWNER TO admin;

--
-- Name: service_items_upsert(bigint, character, bigint, character varying, integer, bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_items_upsert(IN p_service_id bigint, IN p_type character, IN p_product_id bigint, IN p_display_name character varying, IN p_qty integer, IN p_operator_id bigint, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."service_items" WHERE "odoo_id" = p_odoo_id AND "service_id" = p_service_id)) THEN
	UPDATE "public"."service_items" SET
				"type" = p_type,
		  "product_id" = p_product_id,
		"display_name" = p_display_name,
				 "qty" = p_qty,
		 "operator_id" = p_operator_id,
		 "updated_at" = CURRENT_TIMESTAMP,
	     "sequence_id" = nextval('service_items_sequence')
	WHERE
			"odoo_id" = p_odoo_id AND "service_id" = p_service_id;
ELSE
	INSERT INTO "public"."service_items" ("service_id", "type", "product_id", "display_name", "qty", "operator_id", "created_at", "sequence_id", "odoo_id")
	VALUES (p_service_id, p_type, p_product_id, p_display_name, p_qty, p_operator_id , CURRENT_TIMESTAMP, nextval('service_items_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.service_items_upsert(IN p_service_id bigint, IN p_type character, IN p_product_id bigint, IN p_display_name character varying, IN p_qty integer, IN p_operator_id bigint, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: service_oil_upsert(bigint, bigint, bigint, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_oil_upsert(IN p_odoo_id bigint, IN p_service_id bigint, IN p_tire_brand_id bigint, IN p_oil_viscosity character varying, IN p_type_oil character varying, IN p_life_span integer)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."service_oil" WHERE "odoo_id" = p_odoo_id)) THEN
    UPDATE "public"."service_oil" SET
           "service_id" = p_service_id,
          "tire_brand_id" = p_tire_brand_id,
           "oil_viscosity" = p_oil_viscosity,
         "type_oil" = p_type_oil,
               "life_span" = p_life_span,
        "updated_at" = CURRENT_TIMESTAMP,
        "sequence_id" = nextval('service_oil_sequence')
      WHERE "odoo_id" = p_odoo_id;
ELSE
    INSERT INTO "public"."service_oil" ("odoo_id", "service_id", "tire_brand_id", "oil_viscosity", "type_oil", "life_span", "created_at", "sequence_id")
    VALUES(p_odoo_id, p_service_id, p_tire_brand_id, p_oil_viscosity, p_type_oil, p_life_span,  CURRENT_TIMESTAMP, nextval('service_oil_sequence'));

END IF;

END;
$$;


ALTER PROCEDURE public.service_oil_upsert(IN p_odoo_id bigint, IN p_service_id bigint, IN p_tire_brand_id bigint, IN p_oil_viscosity character varying, IN p_type_oil character varying, IN p_life_span integer) OWNER TO admin;

--
-- Name: service_operators_upsert(character, character, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_operators_upsert(IN p_vat character, IN p_name character, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."service_operators" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."service_operators" SET
				 "vat" = p_vat,
				"name" = p_name,
		 "updated_at" = CURRENT_TIMESTAMP,
	     "sequence_id" = nextval('service_operators_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."service_operators" ("vat", "name", "created_at", "sequence_id", "odoo_id")
	VALUES (p_vat, p_name, CURRENT_TIMESTAMP, nextval('service_operators_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.service_operators_upsert(IN p_vat character, IN p_name character, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: service_tires_upsert(integer, character varying, double precision, double precision, double precision, character varying, integer, integer, integer, integer, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, double precision); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.service_tires_upsert(IN p_service_id integer, IN p_location character varying, IN p_depth double precision, IN p_starting_pressure double precision, IN p_finishing_pressure double precision, IN p_dot character varying, IN p_tire_brand_id integer, IN p_tire_model_id integer, IN p_tire_size_id integer, IN p_odoo_id integer, IN p_regular boolean, IN p_staggered boolean, IN p_central boolean, IN p_right_shoulder boolean, IN p_left_shoulder boolean, IN p_not_apply boolean, IN p_bulge boolean, IN p_perforations boolean, IN p_vulcanized boolean, IN p_aging boolean, IN p_cracked boolean, IN p_deformations boolean, IN p_separations boolean, IN p_tire_change boolean, IN p_depth_original double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (EXISTS (
        SELECT
            "odoo_id"
        FROM
            "public"."service_tires"
        WHERE
            "odoo_id" = p_odoo_id)) THEN
        UPDATE
            "public"."service_tires"
        SET
            "service_id" = p_service_id,
            "location" = p_location,
            "depth" = p_depth,
            "starting_pressure" = p_starting_pressure,
            "finishing_pressure" = p_finishing_pressure,
            "dot" = p_dot,
            "tire_brand_id" = p_tire_brand_id,
            "tire_model_id" = p_tire_model_id,
            "tire_size_id" = p_tire_size_id,
            "regular" = p_regular,
            "staggered" = p_staggered,
            "central" = p_central,
            "right_shoulder" = p_right_shoulder,
            "left_shoulder" = p_left_shoulder,
            "not_apply" = p_not_apply,
            "bulge" = p_bulge,
            "perforations" = p_perforations,
            "vulcanized" = p_vulcanized,
            "aging" = p_aging,
            "cracked" = p_cracked,
            "deformations" = p_deformations,
            "separations" = p_separations,
            "updated_at" = CURRENT_TIMESTAMP,
            "sequence_id" = NEXTVAL('service_tires_sequence'),
			"tire_change" = p_tire_change,
            "depth_original" = p_depth_original
        WHERE
            "odoo_id" = p_odoo_id;
    ELSE
        INSERT INTO "public"."service_tires" ("service_id", "location", "depth", "starting_pressure", "finishing_pressure", "dot", "tire_brand_id", "tire_model_id", "tire_size_id", "created_at", "sequence_id", "odoo_id", "regular", "staggered", "central", "right_shoulder", "left_shoulder", "not_apply", "bulge", "perforations", "vulcanized", "aging", "cracked", "deformations", "separations", "tire_change", "depth_original")
            VALUES (p_service_id, p_location, p_depth, p_starting_pressure, p_finishing_pressure, p_dot, p_tire_brand_id, p_tire_model_id, p_tire_size_id, CURRENT_TIMESTAMP, NEXTVAL('service_tires_sequence'), p_odoo_id, p_regular, p_staggered, p_central, p_right_shoulder, p_left_shoulder, p_not_apply, p_bulge, p_perforations, p_vulcanized, p_aging, p_cracked, p_deformations, p_separations, p_tire_change, p_depth_original);
    END IF;
END;
$$;


ALTER PROCEDURE public.service_tires_upsert(IN p_service_id integer, IN p_location character varying, IN p_depth double precision, IN p_starting_pressure double precision, IN p_finishing_pressure double precision, IN p_dot character varying, IN p_tire_brand_id integer, IN p_tire_model_id integer, IN p_tire_size_id integer, IN p_odoo_id integer, IN p_regular boolean, IN p_staggered boolean, IN p_central boolean, IN p_right_shoulder boolean, IN p_left_shoulder boolean, IN p_not_apply boolean, IN p_bulge boolean, IN p_perforations boolean, IN p_vulcanized boolean, IN p_aging boolean, IN p_cracked boolean, IN p_deformations boolean, IN p_separations boolean, IN p_tire_change boolean, IN p_depth_original double precision) OWNER TO admin;

--
-- Name: services_upsert(bigint, bigint, bigint, bigint, date, double precision, bigint, character varying, bigint, character varying, character varying, boolean, boolean); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.services_upsert(IN p_store_id bigint, IN p_driver_id bigint, IN p_owner_id bigint, IN p_vehicle_id bigint, IN p_date date, IN p_odometer double precision, IN p_odometer_id bigint, IN p_state character varying, IN p_odoo_id bigint, IN p_driver_name character varying, IN p_owner_name character varying, IN p_rotation_x boolean, IN p_rotation_lineal boolean)
    LANGUAGE plpgsql
    AS $$

BEGIN
IF (EXISTS (SELECT "odoo_id" FROM "public"."services" WHERE "odoo_id" = p_odoo_id)) THEN
    UPDATE "public"."services" SET
           "store_id" = p_store_id,
          "driver_id" = p_driver_id,
           "owner_id" = p_owner_id,
         "vehicle_id" = p_vehicle_id,
               "date" = p_date,
           "odometer" = p_odometer,
        "odometer_id" = p_odometer_id,
              "state" = p_state,
        "driver_name" = p_driver_name,
         "owner_name" = p_owner_name,
         "rotation_x" = p_rotation_x,
         "rotation_lineal" = p_rotation_lineal,
        "updated_at" = CURRENT_TIMESTAMP,
        "sequence_id" = nextval('services_sequence')
      WHERE "odoo_id" = p_odoo_id;
ELSE
    INSERT INTO "public"."services" ("store_id", "driver_id", "owner_id", "vehicle_id", "date", "odometer", "odometer_id", "state", "created_at", "sequence_id", "odoo_id", "driver_name", "owner_name", "rotation_x", "rotation_lineal")
    VALUES(p_store_id, p_driver_id, p_owner_id, p_vehicle_id, p_date, p_odometer, p_odometer_id, p_state, CURRENT_TIMESTAMP, nextval('services_sequence'), p_odoo_id, p_driver_name, p_owner_name, p_rotation_x, p_rotation_lineal);

END IF;

END;
$$;


ALTER PROCEDURE public.services_upsert(IN p_store_id bigint, IN p_driver_id bigint, IN p_owner_id bigint, IN p_vehicle_id bigint, IN p_date date, IN p_odometer double precision, IN p_odometer_id bigint, IN p_state character varying, IN p_odoo_id bigint, IN p_driver_name character varying, IN p_owner_name character varying, IN p_rotation_x boolean, IN p_rotation_lineal boolean) OWNER TO admin;

--
-- Name: stores_upsert(character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.stores_upsert(IN p_name character varying, IN p_street character varying, IN p_street2 character varying, IN p_city character varying, IN p_state character varying, IN p_country character varying, IN p_phone character varying, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."stores" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."stores" SET
			   "name" = p_name,
			 "street" = p_street,
			"street2" = p_street2,
			   "city" = p_city,
			  "state" = p_state,
			"country" = p_country,
			  "phone" = p_phone,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('stores_sequence')
	  WHERE "odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."stores" ("name", "street", "street2", "city", "state", "country", "phone", "created_at", "sequence_id", "odoo_id")
	VALUES ( p_name, p_street, p_street2, p_city, p_state, p_country, p_phone, CURRENT_TIMESTAMP, nextval('stores_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.stores_upsert(IN p_name character varying, IN p_street character varying, IN p_street2 character varying, IN p_city character varying, IN p_state character varying, IN p_country character varying, IN p_phone character varying, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: tire_brands_upsert(character varying, character varying, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.tire_brands_upsert(IN p_name character varying, IN p_url_image character varying, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."tire_brands" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."tire_brands" SET
			   "name" = p_name,
		  "url_image" = p_url_image,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('tire_brands_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."tire_brands" ("name", "url_image", "created_at", "sequence_id", "odoo_id")
	VALUES (p_name, p_url_image, CURRENT_TIMESTAMP, nextval('tire_brands_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.tire_brands_upsert(IN p_name character varying, IN p_url_image character varying, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: tire_models_upsert(character varying, bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.tire_models_upsert(IN p_name character varying, IN p_tire_brand_id bigint, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."tire_models" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."tire_models" SET
			   "name" = p_name,
      "tire_brand_id" = p_tire_brand_id,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('tire_models_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."tire_models" ("name", "tire_brand_id", "created_at", "sequence_id", "odoo_id")
	VALUES (p_name, p_tire_brand_id, CURRENT_TIMESTAMP, nextval('tire_models_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.tire_models_upsert(IN p_name character varying, IN p_tire_brand_id bigint, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: tire_oem_depths_upsert(bigint, bigint, bigint, bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.tire_oem_depths_upsert(IN p_tire_brand_id bigint, IN p_tire_model_id bigint, IN p_tire_size_id bigint, IN p_otd bigint, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."tire_oem_depths" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."tire_oem_depths" SET
		"tire_brand_id" = p_tire_brand_id,
		"tire_model_id" = p_tire_model_id,
		 "tire_size_id" = p_tire_size_id,
				  "otd" = p_otd,
		  "updated_at" = CURRENT_TIMESTAMP,
		  "sequence_id" = nextval('tire_oem_depths_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."tire_oem_depths" ("tire_brand_id", "tire_model_id", "tire_size_id", "otd", "created_at", "sequence_id", "odoo_id")
	VALUES (p_tire_brand_id, p_tire_model_id, p_tire_size_id, p_otd, CURRENT_TIMESTAMP, nextval('tire_oem_depths_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.tire_oem_depths_upsert(IN p_tire_brand_id bigint, IN p_tire_model_id bigint, IN p_tire_size_id bigint, IN p_otd bigint, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: tire_sizes_upsert(character varying, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.tire_sizes_upsert(IN p_name character varying, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."tire_sizes" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."tire_sizes" SET
			   "name" = p_name,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('tire_sizes_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."tire_sizes" ("name", "created_at", "sequence_id", "odoo_id")
	VALUES (p_name, CURRENT_TIMESTAMP, nextval('tire_sizes_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.tire_sizes_upsert(IN p_name character varying, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: vehicle_brands_upsert(character varying, character varying, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicle_brands_upsert(IN p_name character varying, IN p_url_image character varying, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."vehicle_brands" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."vehicle_brands" SET
			   "name" = p_name,
		  "url_image" = p_url_image,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('vehicle_brands_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."vehicle_brands" ("name", "url_image", "created_at", "sequence_id", "odoo_id")
	VALUES (p_name, p_url_image, CURRENT_TIMESTAMP, nextval('vehicle_brands_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.vehicle_brands_upsert(IN p_name character varying, IN p_url_image character varying, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: vehicle_models_upsert(character varying, bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicle_models_upsert(IN p_name character varying, IN p_vehicle_brand_id bigint, IN p_odoo_id bigint)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."vehicle_models" WHERE "odoo_id" = p_odoo_id)) THEN
	UPDATE "public"."vehicle_models" SET
			   "name" = p_name,
   "vehicle_brand_id" = p_vehicle_brand_id,
		"updated_at" = CURRENT_TIMESTAMP,
		"sequence_id" = nextval('vehicle_models_sequence')
	WHERE
			"odoo_id" = p_odoo_id;
ELSE
	INSERT INTO "public"."vehicle_models" ("name", "vehicle_brand_id", "created_at", "sequence_id", "odoo_id")
	VALUES (p_name, p_vehicle_brand_id, CURRENT_TIMESTAMP, nextval('vehicle_models_sequence'), p_odoo_id );
END IF;

END;
$$;


ALTER PROCEDURE public.vehicle_models_upsert(IN p_name character varying, IN p_vehicle_brand_id bigint, IN p_odoo_id bigint) OWNER TO admin;

--
-- Name: vehicle_summaries_update_vehicle(bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicle_summaries_update_vehicle(IN p_vehicle_id bigint, IN p_service_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_sequence_id bigint;
BEGIN
    p_sequence_id = NEXTVAL('vehicle_summaries_sequence');
    WITH dataVeh AS (
        SELECT
            vehicle_id,
            service_id,
            visits_number,
            accum_oil_changes,
            last_visit,
            odometer,
            accum_km_traveled,
            accum_days_total,
            fuente
        FROM
            public.datato_vehicle_summaries
        WHERE
            vehicle_id = p_vehicle_id)
    INSERT INTO public.vehicle_summaries (vehicle_id, initial_date, initial_km, visits_number, last_visit, accum_days_total, accum_km_traveled, created_at, sequence_id)
    SELECT
        src.vehicle_id,
        src.last_visit AS initial_date,
        src.odometer AS initial_km,
        src.visits_number,
        src.last_visit,
        src.accum_days_total,
        src.accum_km_traveled,
        CURRENT_TIMESTAMP AS created_at,
        p_sequence_id
    FROM
        dataVeh AS src
    WHERE
        src.service_id = p_service_id
        AND src.fuente = 'Otros'
    LIMIT 1
ON CONFLICT (vehicle_id)
/* or you may use [DO NOTHING;] */
    DO UPDATE SET
        visits_number = EXCLUDED.visits_number,
        last_visit = EXCLUDED.last_visit,
        accum_days_total = EXCLUDED.accum_days_total,
        accum_km_traveled = EXCLUDED.accum_km_traveled,
        updated_at = CURRENT_TIMESTAMP,
        sequence_id = p_sequence_id;
    WITH dataVeh AS (
        SELECT
            vehicle_id,
            service_id,
            visits_number,
            accum_oil_changes,
            last_visit,
            odometer,
            accum_km_traveled,
            accum_days_total,
            fuente
        FROM
            public.datato_vehicle_summaries
        WHERE
            vehicle_id = p_vehicle_id)
    INSERT INTO public.vehicle_summaries (vehicle_id, accum_oil_changes, last_oil_change_date, last_oil_change_km, created_at, sequence_id)
    SELECT
        src.vehicle_id,
        src.accum_oil_changes,
        src.last_visit,
        src.odometer,
        CURRENT_TIMESTAMP AS created_at,
        p_sequence_id
    FROM
        dataVeh AS src
    WHERE
        src.service_id = p_service_id
        AND src.fuente = 'Aceite'
    LIMIT 1
ON CONFLICT (vehicle_id)
/* or you may use [DO NOTHING;] */
    DO UPDATE SET
        accum_oil_changes = EXCLUDED.accum_oil_changes,
        last_oil_change_date = EXCLUDED.last_oil_change_date,
        last_oil_change_km = EXCLUDED.last_oil_change_km,
        updated_at = CURRENT_TIMESTAMP,
        sequence_id = p_sequence_id;
END
$$;


ALTER PROCEDURE public.vehicle_summaries_update_vehicle(IN p_vehicle_id bigint, IN p_service_id bigint) OWNER TO admin;

--
-- Name: vehicle_summaries_upsert(bigint, date, integer, integer, integer, integer, integer, date, integer); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicle_summaries_upsert(IN p_vehicle_id bigint, IN p_initial_date date, IN p_initial_km integer, IN p_visits_number integer, IN p_accum_km_traveled integer, IN p_accum_days_total integer, IN p_accum_oil_changes integer, IN p_last_oil_change_date date, IN p_last_oil_change_km integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (EXISTS (
        SELECT
            vehicle_id
        FROM
            public.vehicle_summaries
        WHERE
            vehicle_id = p_vehicle_id)) THEN
        UPDATE
            public.vehicle_summaries
        SET
            initial_date = p_initial_date,
            initial_km = p_initial_km,
            visits_number = p_visits_number,
            accum_km_traveled = p_odometer,
            accum_days_total = p_accum_days_total,
            accum_oil_changes = p_accum_oil_changes,
            last_oil_change_date = p_last_visit,
            last_oil_change_km = p_odometer,
            updated_at = CURRENT_TIMESTAMP,
            sequence_id = NEXTVAL('vehicle_summaries_sequence')
        WHERE
            vehicle_id = p_vehicle_id;
    ELSE
        INSERT INTO public.vehicle_summaries (vehicle_id, initial_date, initial_km, visits_number, accum_km_traveled, accum_days_total, accum_oil_changes, last_oil_change_date, last_oil_change_km, created_at, sequence_id)
            VALUES (p_vehicle_id, p_initial_date, p_initial_km, p_visits_number, p_accum_km_traveled, p_accum_days_total, p_accum_oil_changes, p_last_oil_change_date, p_last_oil_change_km, CURRENT_TIMESTAMP, NEXTVAL('vehicle_summaries_sequence'));
    END IF;
END;
$$;


ALTER PROCEDURE public.vehicle_summaries_upsert(IN p_vehicle_id bigint, IN p_initial_date date, IN p_initial_km integer, IN p_visits_number integer, IN p_accum_km_traveled integer, IN p_accum_days_total integer, IN p_accum_oil_changes integer, IN p_last_oil_change_date date, IN p_last_oil_change_km integer) OWNER TO admin;

--
-- Name: vehicle_tire_histories_addnewservice(bigint, bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicle_tire_histories_addnewservice(IN p_vehicle_id bigint, IN p_service_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    last_service_id bigint;
    item RECORD;
    item2 RECORD;
    Perf RECORD;
    p_otd float8;
    safe_depth float8;
    lifespan_consumed float8;
    km_traveled int4;
    mm_consumed float8;
    months_between_visits float8;
    vperformance_index int4;
	prom_performance_index float8;
    km_proyected int4;
    odometer_estimated int4;
    p_message VARCHAR(512);
    p_current_sp VARCHAR(512);


begin
	--Comments:
    ----20-03-2024: Se modifica la formula para los kilometros proyectados segun tarjeta AC-451
	
    -- Borrar si existe en vehicle_tire_histories el Id de servicio definido por p_service_id
    p_current_sp := 'SP: vehicle_tire_histories_addnewservice: ';
    DELETE FROM vehicle_tire_histories vth
    WHERE vth.service_id = p_service_id AND vth.service_id = (SELECT MAX(service_id) FROM vehicle_tire_histories);
    -- Obtener el último servicio registrado
    SELECT
        coalesce(max(vth.service_id),0)
    FROM
        vehicle_tire_histories vth INTO last_service_id
    WHERE
        vth.vehicle_id = p_vehicle_id;
    -- validar que el id de servicio a procesar sea mayor al ultimo id de servicio procesado. esto para garantizar que el historial no se se altere por el reprocesamiento
    IF p_service_id > last_service_id THEN
        -- Obtener valor otd_standar

        -- Data actual en services -> service_tires
        FOR item IN (
            SELECT
                s.vehicle_id,
                s.odoo_id AS service_id,
                s."date" AS service_date,
                s.odometer,
                st."location" AS tire_location,
                st."depth" AS tread_depth,
                st."depth" - 1.6 AS safe_depth,
                ts."name",
                CASE
                    WHEN st.depth_original > 0 THEN st.depth_original
                    WHEN st.depth_original <= 0 THEN
                        CASE
                            WHEN tos.otd > 0 THEN tos.otd
                            WHEN tos.otd <= 0 THEN 0
                        END
                    ELSE 0
                END AS  otd,
                st.tire_change

            FROM
                public.services s
                INNER JOIN public.service_tires st ON s.odoo_id = st.service_id
                INNER JOIN public.tire_sizes ts ON st.tire_size_id = ts.odoo_id
                /* si no existe una profundidad standart para la medida no se debe registrar nada en el historico */
                left outer JOIN public.tire_otd_standars tos ON trim(ts."name") = trim(tos.tire_size)
            WHERE
                s.vehicle_id = p_vehicle_id
                AND s.odoo_id = p_service_id
            ORDER BY
                s.vehicle_id,
                st."location",
                s.odoo_id)
                LOOP
                    -- se debe validar que si el valor de tread_depth que se esta recibiendo en el servicio es mayor que el otd standart para esa medida no se llene el historial ya que esta condicion causa negativos que inhabilitan la proyecciones.

                    IF item.otd > 0 THEN

                        IF item.otd >= item.tread_depth  THEN

                            IF item.tire_change = TRUE THEN
								RAISE NOTICE 'Cambio de caucho ln 81';

                                DELETE FROM vehicle_tire_histories vehicle_th
                                    WHERE
                                    vehicle_th.vehicle_id = item.vehicle_id AND
                                    vehicle_th.tire_location = item.tire_location;

                                DELETE FROM vehicle_tire_summaries vehicle_ts
                                    WHERE
                                    vehicle_ts.vehicle_id = item.vehicle_id AND
                                    vehicle_ts.tire_location = item.tire_location;

                            ELSE
                                -- NO HUBO CAMBIO DE CAUCHO
                            END IF;

                            RAISE NOTICE 'item1 : last_service_id=% vehicle_id=% service_id=% tire_location=% tread_depth=% safe_depth=%', last_service_id, item.vehicle_id, item.service_id, item.tire_location, item.tread_depth, item.safe_depth;
                            -- Init variables
                            safe_depth = item.safe_depth;
                            lifespan_consumed = 1 - (item.tread_depth / item.otd);
                            RAISE NOTICE 'lifespan_consumed (%) = 1 - (item.tread_depth (%) / item.otd (%));', lifespan_consumed, item.tread_depth, item.otd;

                            -- lifespan_consumed = item.lifespan_consumed; SE CALCULA LIFE SPAND DESDE EL LOOP

                            -- lifespan_consumed = 1 - ( item.tread_depth / item.otd);

                            km_traveled = 0;
                            mm_consumed = 0;
                            months_between_visits = 0;
                            vperformance_index = 0;
                            prom_performance_index = 0;
                            km_proyected = 0;
                            odometer_estimated = 0;
                            -- Data en vehicle_tire_histories
                            FOR item2 IN (
                                SELECT
                                    vth.id,
                                    vth.vehicle_id,
                                    vth.service_id,
                                    vth.tire_location,
                                    vth.odometer,
                                    vth.tread_depth,
                                    vth.service_date
                                FROM
                                    vehicle_tire_histories vth
                                WHERE
                                    vth.vehicle_id = item.vehicle_id
                                    AND vth.tire_location = item.tire_location
                                    AND vth.service_id = last_service_id -- Id de servicio anterior
                                ORDER BY
                                    vth.vehicle_id,
                                    vth.tire_location,
                                    vth.service_id)
                                    LOOP

                                        RAISE NOTICE 'item2 : tire_location=% odometer=% tread_depth=% service_date=%', item2.tire_location, item2.odometer, item2.tread_depth, item2.service_date;
                                        -- Formulas
										RAISE NOTICE 'Formulas';
										
                                        km_traveled = item.odometer - item2.odometer;
										RAISE NOTICE 'km_traveled (%) = item.odometer (%) - item2.odometer (%)', km_traveled, item.odometer, item2.odometer;
										
                                        mm_consumed = item2.tread_depth - item.tread_depth;
										RAISE NOTICE 'mm_consumed (%) = item2.tread_depth (%) - item.tread_depth (%)', mm_consumed, item2.tread_depth, item.tread_depth;
										
                                        --fecha2 2023-01-05, fecha 1 2023-01-20, restado 15
                                        --RAISE NOTICE 'fecha2 %, fecha 1 %, restado %, resultado %', item2.service_date, item.service_date, item.service_date - item2.service_date, (item.service_date - item2.service_date) / 30::float8;
										
										IF mm_consumed > 0 THEN
											vperformance_index = km_traveled / mm_consumed;
										ELSE
											vperformance_index = 0;
										END IF;
										RAISE NOTICE 'vperformance_index (%) = km_traveled (%) / mm_consumed (%)', vperformance_index, km_traveled, mm_consumed;

									    -- AC-555
										FOR Perf IN (
											SELECT
												sum(vth.performance_index) AS Suma,
												count(*) AS Cantidad
											FROM
												public.vehicle_tire_histories vth
											WHERE
												vth.vehicle_id = item.vehicle_id
												AND vth.tire_location = item.tire_location
												AND vth.performance_index > 0)
											loop
												RAISE NOTICE 'Suma %, Cantidad %', Perf.Suma, Perf.Cantidad;
											    prom_performance_index = (coalesce(Perf.Suma, 0) + vperformance_index) / (Perf.Cantidad + 1);
											    RAISE NOTICE 'prom_performance_index = %', prom_performance_index;
											END LOOP;
									
                                        -- km_proyected = floor(vperformance_index * item.otd)::integer;
                                        km_proyected = floor(prom_performance_index * item.otd)::integer;
                                       
										RAISE NOTICE 'km_proyected (%) = floor(vperformance_index (%) * item.otd (%))::integer;', km_proyected, vperformance_index, item.otd;
										
                                        odometer_estimated = km_proyected + item.odometer;
										RAISE NOTICE 'odometer_estimated (%) = km_proyected (%) + item.odometer (%)', odometer_estimated, km_proyected, item.odometer;
										
                                        --lifespan_consumed = 1 - (item.tread_depth / item.otd);
										--RAISE NOTICE 'lifespan_consumed (%) = 1 - (item.tread_depth (%) / item.otd (%));', lifespan_consumed, item.tread_depth, item.otd;
										
                                        --RAISE NOTICE 'mm_consumed % % %', item2.tread_depth, item.tread_depth, mm_consumed;
                                        months_between_visits = (item.service_date::date - item2.service_date::date) / 30::float8;
										RAISE NOTICE 'months_between_visits (%) = (item.service_date::date (%) - item2.service_date::date (%)) / 30::float8 (%)', months_between_visits, item.service_date::date, item2.service_date::date, (item.service_date::date - item2.service_date::date) / 30::float8;

                                    END LOOP;
                            RAISE NOTICE 'Data ; % % % % % % % %', safe_depth, lifespan_consumed, km_traveled, mm_consumed, months_between_visits, vperformance_index, km_proyected, odometer_estimated;
                            -- Insert Data
                            INSERT INTO public.vehicle_tire_histories (id, vehicle_id, service_id, service_date, odometer, tire_location, otd, tread_depth, mm_consumed, performance_index, prom_performance_index, km_traveled, km_proyected, odometer_estimated, safe_depth, lifespan_consumed, months_between_visits, created_at, sequence_id)
                                VALUES (nextval('vehicle_tire_histories_id_seq'::regclass), item.vehicle_id, item.service_id, item.service_date, item.odometer, item.tire_location, item.otd, item.tread_depth, mm_consumed, vperformance_index, prom_performance_index, km_traveled, km_proyected, odometer_estimated, safe_depth, lifespan_consumed, months_between_visits, CURRENT_TIMESTAMP, nextval('vehicle_tire_histories_sequence'))
                            ON CONFLICT (vehicle_id, service_id, tire_location)
                            /* or you may use [DO NOTHING;] */
                                DO UPDATE SET
                                    service_date = EXCLUDED.service_date, odometer = EXCLUDED.odometer, otd = EXCLUDED.otd, tread_depth = EXCLUDED.tread_depth, mm_consumed = EXCLUDED.mm_consumed, performance_index = EXCLUDED.performance_index, prom_performance_index = EXCLUDED.prom_performance_index, km_traveled = EXCLUDED.km_traveled, km_proyected = EXCLUDED.km_proyected, odometer_estimated = EXCLUDED.odometer_estimated, safe_depth = EXCLUDED.safe_depth, lifespan_consumed = EXCLUDED.lifespan_consumed, months_between_visits = EXCLUDED.months_between_visits, sequence_id = nextval('vehicle_tire_histories_sequence'), updated_at = CURRENT_TIMESTAMP;
							RAISE NOTICE 'Debe haber insertado o modificado';
							RAISE NOTICE '';
                        ELSE
							RAISE NOTICE 'ERROR item.otd no es mayor o igual que item.tread_depth, ln 79';
                            p_message := p_current_sp || 'Tread_depth = ' || item.tread_depth || ' es mayor que el otd standart = ' || item.otd || ', p_service_id = ' || p_service_id;
                            CALL log_message(p_message);

                        END IF;

                    ELSE

                    -- NO PUEDO REALIZAR REGISTROS CON OTD 0
						RAISE NOTICE 'ERROR item.otd no es mayor que 0, ln 77';

                        p_message:=  p_current_sp || 'No puedo realizar registros con OTD 0, p_service_id = ' || p_service_id;
                        CALL log_message(p_message);

                    END IF;
                END LOOP;
    ELSE


        p_message:=  p_current_sp || 'p_service_id > last_service_id, p_service_id = ' || p_service_id;
        CALL log_message(p_message);

    END IF;
EXCEPTION
    WHEN division_by_zero THEN

        p_message:=  p_current_sp || 'Division por Cero, p_service_id = ' || p_service_id;
        CALL log_message(p_message);

        /*
        RAISE NOTICE 'División por cero';
        */
END;
$$;


ALTER PROCEDURE public.vehicle_tire_histories_addnewservice(IN p_vehicle_id bigint, IN p_service_id bigint) OWNER TO admin;

--
-- Name: vehicle_tire_summaries_addnewservice(bigint); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicle_tire_summaries_addnewservice(IN p_vehicle_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    item RECORD;
    accum_km_traveled float8;
    accum_days_total float8;
    prom_tire_km_month float8;
    prom_tire_mm_x_visit float8;
    months_to_tire_unsafe float8;
    projected_tire_visits float8;
    estimated_months_tire_visits float8;
    life_span_consumed float8;
BEGIN
    FOR item IN ( SELECT DISTINCT
            vehicle_id,
            tire_location,
            FIRST_VALUE(odometer) OVER (PARTITION BY vehicle_id, tire_location ORDER BY vehicle_id, tire_location, service_id) AS odometer1,
            LAST_VALUE(odometer) OVER (PARTITION BY vehicle_id, tire_location ORDER BY vehicle_id, tire_location) AS odometer2,
            FIRST_VALUE(service_date) OVER (PARTITION BY vehicle_id, tire_location ORDER BY vehicle_id, tire_location, service_id) AS service_date1,
            LAST_VALUE(service_date) OVER (PARTITION BY vehicle_id, tire_location ORDER BY vehicle_id, tire_location) AS service_date2,
            FIRST_VALUE(tread_depth) OVER (PARTITION BY vehicle_id, tire_location ORDER BY vehicle_id, tire_location, service_id) AS tread_depth1,
            LAST_VALUE(tread_depth) OVER (PARTITION BY vehicle_id, tire_location ORDER BY vehicle_id, tire_location) AS tread_depth2,
            LAST_VALUE(lifespan_consumed) OVER (PARTITION BY vehicle_id, tire_location ORDER BY vehicle_id, tire_location) AS life_span_consumed,
            COUNT(*) OVER (PARTITION BY vehicle_id, tire_location)::integer AS NumVisits,
          --SUM(months_between_visits) OVER (PARTITION BY vehicle_id, tire_location) AS months_between_visits,
            AVG(months_between_visits) OVER (PARTITION BY vehicle_id, tire_location) AS months_between_visits
        FROM
            public.vehicle_tire_histories
        WHERE
            vehicle_id = p_vehicle_id)
        LOOP
            accum_km_traveled = item.odometer2 - item.odometer1;
            accum_days_total = item.service_date2 - item.service_date1;
           	--validate if accum_days_total is bigger than 0 to avoid division by zero in calculations
           	if accum_days_total > 0 then
            	prom_tire_km_month = accum_km_traveled / (accum_days_total / 30);
	            prom_tire_mm_x_visit = (item.tread_depth1 - item.tread_depth2) / (accum_days_total / 30);
	            if prom_tire_mm_x_visit > 0 then
					months_to_tire_unsafe =  item.tread_depth2 / prom_tire_mm_x_visit;
				else
					months_to_tire_unsafe = 0;
				end if;
           	else
	           	prom_tire_km_month = 0;
	           	prom_tire_mm_x_visit = 0;
	           	months_to_tire_unsafe = 0;
           	end if;
			projected_tire_visits = 12 - item.NumVisits;
          --estimated_months_tire_visits = (months_to_tire_unsafe - item.months_between_visits) / projected_tire_visits;
            estimated_months_tire_visits = item.months_between_visits;
            life_span_consumed = item.life_span_consumed;
            RAISE NOTICE 'data : % % % % % % % % %', item.vehicle_id, item.tire_location, accum_km_traveled, accum_days_total, prom_tire_km_month, prom_tire_mm_x_visit, months_to_tire_unsafe, projected_tire_visits, estimated_months_tire_visits;
            CALL public.vehicle_tire_summaries_upsert (item.vehicle_id, item.tire_location, prom_tire_km_month, prom_tire_mm_x_visit, months_to_tire_unsafe, projected_tire_visits, estimated_months_tire_visits, accum_km_traveled, accum_days_total, life_span_consumed);
        END LOOP;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'División por cero';
END;
$$;


ALTER PROCEDURE public.vehicle_tire_summaries_addnewservice(IN p_vehicle_id bigint) OWNER TO admin;

--
-- Name: vehicle_tire_summaries_upsert(bigint, character varying, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicle_tire_summaries_upsert(IN p_vehicle_id bigint, IN p_tire_location character varying, IN p_prom_tire_km_month double precision, IN p_prom_tire_mm_x_visit double precision, IN p_months_to_tire_unsafe double precision, IN p_projected_tire_visits double precision, IN p_estimated_months_tire_visits double precision, IN p_accum_km_traveled double precision, IN p_accum_days_total double precision, IN p_life_span_consumed double precision)
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_sequence_id int4;
BEGIN
    p_sequence_id = NEXTVAL('vehicle_tire_summaries_sequence');
    INSERT INTO public.vehicle_tire_summaries (vehicle_id, tire_location, prom_tire_km_month, prom_tire_mm_x_visit, months_to_tire_unsafe, projected_tire_visits, estimated_months_tire_visits, accum_km_traveled, accum_days_total, life_span_consumed, sequence_id, created_at)
        VALUES (p_vehicle_id, p_tire_location, p_prom_tire_km_month, p_prom_tire_mm_x_visit, p_months_to_tire_unsafe, p_projected_tire_visits, p_estimated_months_tire_visits, p_accum_km_traveled, p_accum_days_total, p_life_span_consumed, p_sequence_id, CURRENT_TIMESTAMP)
    ON CONFLICT (vehicle_id, tire_location)
    /* or you may use [DO NOTHING;] */
        DO UPDATE SET
            vehicle_id = EXCLUDED.vehicle_id, tire_location = EXCLUDED.tire_location, prom_tire_km_month = EXCLUDED.prom_tire_km_month, prom_tire_mm_x_visit = EXCLUDED.prom_tire_mm_x_visit, months_to_tire_unsafe = EXCLUDED.months_to_tire_unsafe, projected_tire_visits = EXCLUDED.projected_tire_visits, estimated_months_tire_visits = EXCLUDED.estimated_months_tire_visits, accum_km_traveled = EXCLUDED.accum_km_traveled, accum_days_total = EXCLUDED.accum_days_total, life_span_consumed = EXCLUDED.life_span_consumed, sequence_id = p_sequence_id, updated_at = CURRENT_TIMESTAMP;
END;
$$;


ALTER PROCEDURE public.vehicle_tire_summaries_upsert(IN p_vehicle_id bigint, IN p_tire_location character varying, IN p_prom_tire_km_month double precision, IN p_prom_tire_mm_x_visit double precision, IN p_months_to_tire_unsafe double precision, IN p_projected_tire_visits double precision, IN p_estimated_months_tire_visits double precision, IN p_accum_km_traveled double precision, IN p_accum_days_total double precision, IN p_life_span_consumed double precision) OWNER TO admin;

--
-- Name: vehicles_upsert(character varying, bigint, bigint, date, character varying, integer, character varying, character varying, double precision, bigint, character varying, character varying, smallint, character varying); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.vehicles_upsert(IN p_plate character varying, IN p_vehicle_brand_id bigint, IN p_vehicle_model_id bigint, IN p_register_date date, IN p_color character varying, IN p_year integer, IN p_transmission character varying, IN p_fuel character varying, IN p_odometer double precision, IN p_odoo_id bigint, IN p_nickname character varying, IN p_color_hex character varying, IN p_icon smallint, IN p_type_vehicle character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN

IF (EXISTS (SELECT "odoo_id" FROM "public"."vehicles" WHERE "odoo_id" = p_odoo_id)) THEN
    UPDATE "public"."vehicles" SET
                   "plate" = p_plate,
        "vehicle_model_id" = p_vehicle_model_id,
           "register_date" = p_register_date,
                    "year" = p_year,
                   "color" = p_color,
            "transmission" = p_transmission,
                    "fuel" = p_fuel,
                "odometer" = p_odometer,
             "updated_at" = CURRENT_TIMESTAMP,
        "vehicle_brand_id" = p_vehicle_brand_id,
                "nickname" = p_nickname,
               "color_hex" = p_color_hex,
                    "icon" = p_icon,
            "type_vehicle" = p_type_vehicle,
             "sequence_id" = nextval('vehicles_sequence')
                 WHERE "odoo_id" = p_odoo_id;
ELSE
    INSERT INTO "public"."vehicles" ("plate", "vehicle_model_id", "register_date", "year", "color", "transmission", "fuel", "odometer", "created_at", "vehicle_brand_id", "sequence_id", "odoo_id","color_hex", "nickname", "icon", "type_vehicle")
    VALUES (p_plate, p_vehicle_model_id, p_register_date, p_year, p_color, p_transmission, p_fuel, p_odometer, CURRENT_TIMESTAMP, p_vehicle_brand_id, nextval('vehicles_sequence'), p_odoo_id, p_color_hex, p_nickname, p_icon, p_type_vehicle);
END IF;

END;
$$;


ALTER PROCEDURE public.vehicles_upsert(IN p_plate character varying, IN p_vehicle_brand_id bigint, IN p_vehicle_model_id bigint, IN p_register_date date, IN p_color character varying, IN p_year integer, IN p_transmission character varying, IN p_fuel character varying, IN p_odometer double precision, IN p_odoo_id bigint, IN p_nickname character varying, IN p_color_hex character varying, IN p_icon smallint, IN p_type_vehicle character varying) OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.actions (
    id bigint NOT NULL,
    description character varying(150) NOT NULL,
    statement character varying(500) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.actions OWNER TO admin;

--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.actions_id_seq OWNER TO admin;

--
-- Name: actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.actions_id_seq OWNED BY public.actions.id;


--
-- Name: actions_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.actions_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.actions_sequence OWNER TO admin;

--
-- Name: app_parameters; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.app_parameters (
    id bigint NOT NULL,
    key character varying(191) NOT NULL,
    value character varying(191) NOT NULL,
    type character varying(191) NOT NULL,
    description character varying(191) NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.app_parameters OWNER TO admin;

--
-- Name: app_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.app_parameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_parameters_id_seq OWNER TO admin;

--
-- Name: app_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.app_parameters_id_seq OWNED BY public.app_parameters.id;


--
-- Name: app_warnings; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.app_warnings (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(200) NOT NULL,
    threshold integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.app_warnings OWNER TO admin;

--
-- Name: app_warnings_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.app_warnings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_warnings_id_seq OWNER TO admin;

--
-- Name: app_warnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.app_warnings_id_seq OWNED BY public.app_warnings.id;


--
-- Name: application_user; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.application_user (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    application_id bigint NOT NULL,
    platform_version character varying(191) NOT NULL,
    last_session timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.application_user OWNER TO admin;

--
-- Name: application_user_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.application_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.application_user_id_seq OWNER TO admin;

--
-- Name: application_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.application_user_id_seq OWNED BY public.application_user.id;


--
-- Name: applications; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.applications (
    id bigint NOT NULL,
    version character varying(50) NOT NULL,
    platform character varying(15) NOT NULL,
    enable boolean DEFAULT false NOT NULL,
    note character varying(191) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.applications OWNER TO admin;

--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.applications_id_seq OWNER TO admin;

--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying(150) NOT NULL,
    action_id bigint,
    parent_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    code character varying(10)
);


ALTER TABLE public.categories OWNER TO admin;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO admin;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: categories_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.categories_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_sequence OWNER TO admin;

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    odoo_id bigint,
    vat character varying(25),
    name character varying(200),
    email character varying(100),
    country_code character varying(5),
    phone character varying(50),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.contacts OWNER TO admin;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO admin;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    otd double precision NOT NULL,
    life_span integer,
    life_span_unit character varying(15),
    product_category_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.products OWNER TO admin;

--
-- Name: service_items; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_items (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    service_id bigint,
    type character varying(191) NOT NULL,
    product_id bigint,
    display_name character varying(191) NOT NULL,
    qty numeric(8,2) NOT NULL,
    operator_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.service_items OWNER TO admin;

--
-- Name: service_items_actions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_items_actions (
    id bigint NOT NULL,
    code integer NOT NULL,
    product_id integer NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.service_items_actions OWNER TO admin;

--
-- Name: service_oil; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_oil (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    service_id bigint NOT NULL,
    tire_brand_id bigint,
    oil_viscosity character varying(191),
    type_oil character varying(191),
    life_span integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL,
    oil_quantity integer,
    filter_brand_id bigint
);


ALTER TABLE public.service_oil OWNER TO admin;

--
-- Name: services; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.services (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    store_id bigint NOT NULL,
    driver_id bigint NOT NULL,
    owner_id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    date date NOT NULL,
    odometer double precision NOT NULL,
    odometer_id bigint NOT NULL,
    state character varying(15) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL,
    owner_name character varying(191) NOT NULL,
    driver_name character varying(191) NOT NULL,
    rotation_x boolean DEFAULT false NOT NULL,
    rotation_lineal boolean DEFAULT false NOT NULL
);


ALTER TABLE public.services OWNER TO admin;

--
-- Name: datato_oil_change_histories; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW public.datato_oil_change_histories AS
 WITH life_span AS (
         SELECT so.service_id,
                CASE
                    WHEN (so.life_span > 0) THEN so.life_span
                    WHEN (so.life_span = 0) THEN 5000
                    ELSE NULL::integer
                END AS life_span,
            5000 AS life_span_standar
           FROM public.service_oil so
        UNION
         SELECT si_1.service_id,
                CASE
                    WHEN (p.life_span > 0) THEN p.life_span
                    WHEN (p.life_span = 0) THEN 5000
                    ELSE NULL::integer
                END AS life_span,
            5000 AS life_span_standar
           FROM (((public.service_items si_1
             JOIN public.services s_1 ON ((si_1.service_id = s_1.odoo_id)))
             JOIN public.products p ON ((si_1.product_id = p.odoo_id)))
             JOIN public.service_items_actions sia_1 ON ((si_1.product_id = sia_1.product_id)))
          WHERE ((sia_1.code = 2) AND (NOT (si_1.service_id IN ( SELECT service_oil.service_id
                   FROM public.service_oil))))
        )
 SELECT DISTINCT s.vehicle_id,
    si.service_id,
    s.date AS change_date,
    s.date AS change_next_date,
    (s.odometer)::integer AS change_km,
    ((s.odometer)::integer + ls.life_span) AS change_next_km,
    s.state AS service_state,
    ls.life_span,
    ls.life_span_standar
   FROM (((public.service_items si
     JOIN public.services s ON ((si.service_id = s.odoo_id)))
     JOIN public.service_items_actions sia ON ((si.product_id = sia.product_id)))
     JOIN life_span ls ON ((si.service_id = ls.service_id)))
  WHERE (sia.code = 1);


ALTER VIEW public.datato_oil_change_histories OWNER TO admin;

--
-- Name: oil_change_histories; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.oil_change_histories (
    id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    service_id bigint NOT NULL,
    service_state character varying(15),
    change_date date,
    change_km integer,
    change_next_km integer,
    change_next_date date,
    life_span integer,
    life_span_standar integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sequence_id bigint,
    change_next_days integer
);


ALTER TABLE public.oil_change_histories OWNER TO admin;

--
-- Name: datato_vehicle_oil_chart; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW public.datato_vehicle_oil_chart AS
 SELECT oil_change_histories.vehicle_id,
    oil_change_histories.service_id,
    oil_change_histories.change_km,
    oil_change_histories.change_date,
    oil_change_histories.life_span,
    oil_change_histories.change_next_days,
    COALESCE((oil_change_histories.change_km - lag(oil_change_histories.change_km, 1) OVER (PARTITION BY oil_change_histories.vehicle_id ORDER BY oil_change_histories.service_id)), 0) AS km_traveled,
    COALESCE((oil_change_histories.change_date - lag(oil_change_histories.change_date, 1) OVER (PARTITION BY oil_change_histories.vehicle_id ORDER BY oil_change_histories.service_id)), 0) AS days_passed,
    row_number() OVER (PARTITION BY oil_change_histories.vehicle_id ORDER BY oil_change_histories.service_id) AS rownumber
   FROM public.oil_change_histories
  WHERE ((oil_change_histories.service_state)::text = 'done'::text)
  ORDER BY oil_change_histories.vehicle_id, oil_change_histories.service_id;


ALTER VIEW public.datato_vehicle_oil_chart OWNER TO admin;

--
-- Name: vehicle_summaries; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.vehicle_summaries (
    id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    prom_km_month integer,
    visits_number integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL,
    last_oil_change_date date,
    last_oil_change_km integer,
    accum_km_traveled integer,
    accum_days_total integer,
    accum_oil_changes integer,
    initial_date date,
    initial_km integer,
    last_visit date
);


ALTER TABLE public.vehicle_summaries OWNER TO admin;

--
-- Name: datato_vehicle_summaries; Type: VIEW; Schema: public; Owner: admin
--

CREATE VIEW public.datato_vehicle_summaries AS
 SELECT DISTINCT s.vehicle_id,
    s.odoo_id AS service_id,
    0 AS visits_number,
    (row_number() OVER (PARTITION BY s.vehicle_id ORDER BY s.vehicle_id, s.odoo_id))::integer AS accum_oil_changes,
    s.date AS last_visit,
    (s.odometer)::integer AS odometer,
    0 AS accum_km_traveled,
    0 AS accum_days_total,
    'Aceite'::character varying(10) AS fuente
   FROM ((public.service_items si
     JOIN public.services s ON ((si.service_id = s.odoo_id)))
     JOIN public.service_items_actions sia ON ((si.product_id = sia.product_id)))
  WHERE ((sia.code = 1) AND (NOT ((s.state)::text = 'canceled'::text)))
UNION
 SELECT DISTINCT s.vehicle_id,
    s.odoo_id AS service_id,
    (row_number() OVER (PARTITION BY s.vehicle_id ORDER BY s.vehicle_id, s.odoo_id))::integer AS visits_number,
    0 AS accum_oil_changes,
    s.date AS last_visit,
    (s.odometer)::integer AS odometer,
    (COALESCE((s.odometer - (vs.initial_km)::double precision), (0)::double precision))::integer AS accum_km_traveled,
    COALESCE((s.date - vs.initial_date), 0) AS accum_days_total,
    'Otros'::character varying(10) AS fuente
   FROM (public.services s
     LEFT JOIN public.vehicle_summaries vs ON ((s.vehicle_id = vs.vehicle_id)))
  WHERE (NOT ((s.state)::text = 'canceled'::text));


ALTER VIEW public.datato_vehicle_summaries OWNER TO admin;

--
-- Name: error_logs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.error_logs (
    id bigint NOT NULL,
    sequence_id integer NOT NULL,
    user_id bigint NOT NULL,
    date timestamp(0) without time zone NOT NULL,
    screen character varying(200),
    action character varying(200),
    api character varying(200) NOT NULL,
    error_message character varying(1024) NOT NULL
);


ALTER TABLE public.error_logs OWNER TO admin;

--
-- Name: error_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.error_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.error_logs_id_seq OWNER TO admin;

--
-- Name: error_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.error_logs_id_seq OWNED BY public.error_logs.id;


--
-- Name: error_logs_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.error_logs_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.error_logs_sequence OWNER TO admin;

--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(191) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO admin;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO admin;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: heat_maps; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.heat_maps (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    event_date timestamp(0) without time zone NOT NULL,
    page character varying(50) NOT NULL,
    object character varying(50),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.heat_maps OWNER TO admin;

--
-- Name: heat_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.heat_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.heat_maps_id_seq OWNER TO admin;

--
-- Name: heat_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.heat_maps_id_seq OWNED BY public.heat_maps.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.job_batches (
    id character varying(191) NOT NULL,
    name character varying(191) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO admin;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(191) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO admin;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO admin;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(191) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO admin;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO admin;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: model_has_permissions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.model_has_permissions (
    permission_id bigint NOT NULL,
    model_type character varying(191) NOT NULL,
    model_id bigint NOT NULL
);


ALTER TABLE public.model_has_permissions OWNER TO admin;

--
-- Name: model_has_roles; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.model_has_roles (
    role_id bigint NOT NULL,
    model_type character varying(191) NOT NULL,
    model_id bigint NOT NULL
);


ALTER TABLE public.model_has_roles OWNER TO admin;

--
-- Name: odometers; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.odometers (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    driver_id bigint,
    date character varying(191) NOT NULL,
    value double precision NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.odometers OWNER TO admin;

--
-- Name: odometers_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.odometers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.odometers_id_seq OWNER TO admin;

--
-- Name: odometers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.odometers_id_seq OWNED BY public.odometers.id;


--
-- Name: odometers_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.odometers_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.odometers_sequence OWNER TO admin;

--
-- Name: oil_change_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.oil_change_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.oil_change_histories_id_seq OWNER TO admin;

--
-- Name: oil_change_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.oil_change_histories_id_seq OWNED BY public.oil_change_histories.id;


--
-- Name: oil_change_histories_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.oil_change_histories_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.oil_change_histories_sequence OWNER TO admin;

--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.password_reset_tokens (
    user_id bigint NOT NULL,
    email character varying(191),
    phone character varying(191),
    code integer NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO admin;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    name character varying(191) NOT NULL,
    guard_name character varying(191) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.permissions OWNER TO admin;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permissions_id_seq OWNER TO admin;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(191) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO admin;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO admin;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: privacy_terms_conditions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.privacy_terms_conditions (
    id bigint NOT NULL,
    type public.privacy_type NOT NULL,
    content text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.privacy_terms_conditions OWNER TO admin;

--
-- Name: privacy_terms_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.privacy_terms_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.privacy_terms_conditions_id_seq OWNER TO admin;

--
-- Name: privacy_terms_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.privacy_terms_conditions_id_seq OWNED BY public.privacy_terms_conditions.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.product_categories (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    category_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.product_categories OWNER TO admin;

--
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.product_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_categories_id_seq OWNER TO admin;

--
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.product_categories_id_seq OWNED BY public.product_categories.id;


--
-- Name: product_categories_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.product_categories_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_categories_sequence OWNER TO admin;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO admin;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: products_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.products_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_sequence OWNER TO admin;

--
-- Name: role_has_permissions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.role_has_permissions (
    permission_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.role_has_permissions OWNER TO admin;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(191) NOT NULL,
    guard_name character varying(191) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.roles OWNER TO admin;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO admin;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: service_alignment; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_alignment (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    service_id bigint NOT NULL,
    eje character varying(10) NOT NULL,
    valor character varying(15) NOT NULL,
    full_convergence_d character varying(10) NOT NULL,
    semiconvergence_izq_d character varying(10) NOT NULL,
    semiconvergence_der_d character varying(10) NOT NULL,
    camber_izq_d character varying(10) NOT NULL,
    camber_der_d character varying(10) NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.service_alignment OWNER TO admin;

--
-- Name: service_alignment_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_alignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_alignment_id_seq OWNER TO admin;

--
-- Name: service_alignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_alignment_id_seq OWNED BY public.service_alignment.id;


--
-- Name: service_alignment_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_alignment_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_alignment_sequence OWNER TO admin;

--
-- Name: service_balancing; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_balancing (
    id bigint NOT NULL,
    sequence_id integer NOT NULL,
    service_id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    location character varying(191) NOT NULL,
    lead_used double precision,
    type_lead character varying(191),
    balanced boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    wheel_good_state boolean DEFAULT false NOT NULL,
    wheel_scratched boolean DEFAULT false NOT NULL,
    wheel_cracked boolean DEFAULT false NOT NULL,
    wheel_bent boolean DEFAULT false NOT NULL
);


ALTER TABLE public.service_balancing OWNER TO admin;

--
-- Name: service_balancing_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_balancing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_balancing_id_seq OWNER TO admin;

--
-- Name: service_balancing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_balancing_id_seq OWNED BY public.service_balancing.id;


--
-- Name: service_balancing_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_balancing_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_balancing_sequence OWNER TO admin;

--
-- Name: service_battery; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_battery (
    id bigint NOT NULL,
    sequence_id integer NOT NULL,
    service_id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    battery_brand_id bigint,
    battery_model_id bigint,
    date_of_purchase timestamp(0) without time zone,
    serial_product character varying(191),
    warranty_date timestamp(0) without time zone,
    amperage character varying(191),
    alternator_voltage double precision NOT NULL,
    battery_voltage double precision NOT NULL,
    status_battery character varying(191) NOT NULL,
    status_alternator character varying(191) NOT NULL,
    good_condition boolean DEFAULT false NOT NULL,
    liquid_leakage boolean DEFAULT false NOT NULL,
    corroded_terminals boolean DEFAULT false NOT NULL,
    frayed_cables boolean DEFAULT false NOT NULL,
    inflated boolean DEFAULT false NOT NULL,
    cracked_case boolean DEFAULT false NOT NULL,
    new_battery boolean DEFAULT false NOT NULL,
    replaced_battery boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    starting_current double precision,
    accumulated_load_capacity double precision,
    health_status character varying(100),
    health_percentage double precision,
    health_status_final character varying(50),
    battery_charged boolean DEFAULT false NOT NULL
);


ALTER TABLE public.service_battery OWNER TO admin;

--
-- Name: service_battery_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_battery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_battery_id_seq OWNER TO admin;

--
-- Name: service_battery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_battery_id_seq OWNED BY public.service_battery.id;


--
-- Name: service_battery_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_battery_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_battery_sequence OWNER TO admin;

--
-- Name: service_configs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_configs (
    id bigint NOT NULL,
    code character varying(25) NOT NULL,
    url_base character varying(150) NOT NULL,
    app_code character varying(25) NOT NULL,
    app_secret character varying(150) NOT NULL,
    app_token character varying(150) NOT NULL,
    app_json_config character varying(1000) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.service_configs OWNER TO admin;

--
-- Name: service_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_configs_id_seq OWNER TO admin;

--
-- Name: service_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_configs_id_seq OWNED BY public.service_configs.id;


--
-- Name: service_items_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_items_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_items_actions_id_seq OWNER TO admin;

--
-- Name: service_items_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_items_actions_id_seq OWNED BY public.service_items_actions.id;


--
-- Name: service_items_actions_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_items_actions_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_items_actions_sequence OWNER TO admin;

--
-- Name: service_items_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_items_id_seq OWNER TO admin;

--
-- Name: service_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_items_id_seq OWNED BY public.service_items.id;


--
-- Name: service_items_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_items_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_items_sequence OWNER TO admin;

--
-- Name: service_oil_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_oil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_oil_id_seq OWNER TO admin;

--
-- Name: service_oil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_oil_id_seq OWNED BY public.service_oil.id;


--
-- Name: service_oil_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_oil_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_oil_sequence OWNER TO admin;

--
-- Name: service_operators; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_operators (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    vat character varying(25) NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.service_operators OWNER TO admin;

--
-- Name: service_operators_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_operators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_operators_id_seq OWNER TO admin;

--
-- Name: service_operators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_operators_id_seq OWNED BY public.service_operators.id;


--
-- Name: service_operators_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_operators_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_operators_sequence OWNER TO admin;

--
-- Name: service_synceds; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_synceds (
    id bigint NOT NULL,
    service_id bigint NOT NULL,
    procesado_iron boolean DEFAULT true NOT NULL,
    vehicle_id bigint NOT NULL,
    state character varying(191) NOT NULL,
    not_processed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.service_synceds OWNER TO admin;

--
-- Name: service_synceds_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_synceds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_synceds_id_seq OWNER TO admin;

--
-- Name: service_synceds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_synceds_id_seq OWNED BY public.service_synceds.id;


--
-- Name: service_tires; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.service_tires (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    service_id bigint NOT NULL,
    location character varying(50) NOT NULL,
    depth double precision NOT NULL,
    starting_pressure integer NOT NULL,
    finishing_pressure integer NOT NULL,
    dot character varying(191) NOT NULL,
    tire_brand_id bigint NOT NULL,
    tire_model_id bigint NOT NULL,
    tire_size_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL,
    regular boolean DEFAULT false NOT NULL,
    staggered boolean DEFAULT false NOT NULL,
    central boolean DEFAULT false NOT NULL,
    right_shoulder boolean DEFAULT false NOT NULL,
    left_shoulder boolean DEFAULT false NOT NULL,
    not_apply boolean DEFAULT true NOT NULL,
    bulge boolean DEFAULT false NOT NULL,
    perforations boolean DEFAULT false NOT NULL,
    vulcanized boolean DEFAULT false NOT NULL,
    aging boolean DEFAULT false NOT NULL,
    cracked boolean DEFAULT false NOT NULL,
    deformations boolean DEFAULT false NOT NULL,
    separations boolean DEFAULT false NOT NULL,
    tire_change boolean DEFAULT false NOT NULL,
    depth_original double precision
);


ALTER TABLE public.service_tires OWNER TO admin;

--
-- Name: service_tires_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_tires_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_tires_id_seq OWNER TO admin;

--
-- Name: service_tires_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.service_tires_id_seq OWNED BY public.service_tires.id;


--
-- Name: service_tires_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.service_tires_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.service_tires_sequence OWNER TO admin;

--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.services_id_seq OWNER TO admin;

--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: services_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.services_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.services_sequence OWNER TO admin;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    twi double precision DEFAULT '1.6'::double precision NOT NULL,
    otd_standar double precision DEFAULT '9'::double precision NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    warning_threshold double precision DEFAULT '75'::double precision NOT NULL,
    warning_color character varying(191) DEFAULT '#CA0000'::character varying NOT NULL,
    danger_threshold double precision DEFAULT '85'::double precision NOT NULL
);


ALTER TABLE public.settings OWNER TO admin;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.settings_id_seq OWNER TO admin;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: stores; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.stores (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    name character varying(250) NOT NULL,
    street character varying(150) NOT NULL,
    street2 character varying(250),
    city character varying(100) NOT NULL,
    state character varying(100) NOT NULL,
    country character varying(100) NOT NULL,
    phone character varying(100) NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.stores OWNER TO admin;

--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stores_id_seq OWNER TO admin;

--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.stores_id_seq OWNED BY public.stores.id;


--
-- Name: stores_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.stores_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stores_sequence OWNER TO admin;

--
-- Name: tire_brands; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tire_brands (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    url_image character varying(500),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.tire_brands OWNER TO admin;

--
-- Name: tire_brands_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_brands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_brands_id_seq OWNER TO admin;

--
-- Name: tire_brands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.tire_brands_id_seq OWNED BY public.tire_brands.id;


--
-- Name: tire_brands_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_brands_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_brands_sequence OWNER TO admin;

--
-- Name: tire_models; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tire_models (
    id bigint NOT NULL,
    tire_brand_id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.tire_models OWNER TO admin;

--
-- Name: tire_models_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_models_id_seq OWNER TO admin;

--
-- Name: tire_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.tire_models_id_seq OWNED BY public.tire_models.id;


--
-- Name: tire_models_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_models_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_models_sequence OWNER TO admin;

--
-- Name: tire_oem_depths; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tire_oem_depths (
    id bigint NOT NULL,
    tire_brand_id bigint,
    tire_model_id bigint,
    tire_size_id bigint,
    otd integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.tire_oem_depths OWNER TO admin;

--
-- Name: tire_oem_depths_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_oem_depths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_oem_depths_id_seq OWNER TO admin;

--
-- Name: tire_oem_depths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.tire_oem_depths_id_seq OWNED BY public.tire_oem_depths.id;


--
-- Name: tire_oem_depths_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_oem_depths_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_oem_depths_sequence OWNER TO admin;

--
-- Name: tire_otd_standars; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tire_otd_standars (
    id bigint NOT NULL,
    tire_size character varying(50) NOT NULL,
    otd double precision NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.tire_otd_standars OWNER TO admin;

--
-- Name: tire_otd_standars_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_otd_standars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_otd_standars_id_seq OWNER TO admin;

--
-- Name: tire_otd_standars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.tire_otd_standars_id_seq OWNED BY public.tire_otd_standars.id;


--
-- Name: tire_otd_standars_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_otd_standars_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_otd_standars_sequence OWNER TO admin;

--
-- Name: tire_sizes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tire_sizes (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.tire_sizes OWNER TO admin;

--
-- Name: tire_sizes_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_sizes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_sizes_id_seq OWNER TO admin;

--
-- Name: tire_sizes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.tire_sizes_id_seq OWNED BY public.tire_sizes.id;


--
-- Name: tire_sizes_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tire_sizes_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tire_sizes_sequence OWNER TO admin;

--
-- Name: tui_oem_depths; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.tui_oem_depths (
    id bigint NOT NULL,
    tui_brand character varying(100) NOT NULL,
    tui_model character varying(100) NOT NULL,
    tui_size character varying(100) NOT NULL,
    otd double precision NOT NULL,
    sequence_id bigint NOT NULL
);


ALTER TABLE public.tui_oem_depths OWNER TO admin;

--
-- Name: tui_oem_depths_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.tui_oem_depths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tui_oem_depths_id_seq OWNER TO admin;

--
-- Name: tui_oem_depths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.tui_oem_depths_id_seq OWNED BY public.tui_oem_depths.id;


--
-- Name: user_access_tokens; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.user_access_tokens (
    user_id bigint NOT NULL,
    type character varying(191) NOT NULL,
    email character varying(191),
    phone character varying(191),
    code integer NOT NULL,
    created_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.user_access_tokens OWNER TO admin;

--
-- Name: users; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    full_name character varying(50) NOT NULL,
    email character varying(50),
    password character varying(191) NOT NULL,
    res_partner_id bigint,
    country_code character varying(191) NOT NULL,
    phone character varying(191) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    avatar_url character varying(191),
    avatar_path character varying(191),
    language character varying(191) DEFAULT 'ES'::character varying NOT NULL,
    email_verified boolean DEFAULT false NOT NULL,
    phone_verified boolean DEFAULT false NOT NULL,
    legals_accepted boolean DEFAULT false NOT NULL,
    terms_and_conditions_id bigint,
    legal_disclaimer_id bigint,
    privacy_policy_id bigint
);


ALTER TABLE public.users OWNER TO admin;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO admin;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vehicle_brands; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.vehicle_brands (
    id bigint NOT NULL,
    odoo_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    url_image character varying(500),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.vehicle_brands OWNER TO admin;

--
-- Name: vehicle_brands_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_brands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_brands_id_seq OWNER TO admin;

--
-- Name: vehicle_brands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.vehicle_brands_id_seq OWNED BY public.vehicle_brands.id;


--
-- Name: vehicle_brands_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_brands_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_brands_sequence OWNER TO admin;

--
-- Name: vehicle_models; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.vehicle_models (
    id bigint NOT NULL,
    vehicle_brand_id bigint NOT NULL,
    name character varying(191) NOT NULL,
    odoo_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL
);


ALTER TABLE public.vehicle_models OWNER TO admin;

--
-- Name: vehicle_models_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_models_id_seq OWNER TO admin;

--
-- Name: vehicle_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.vehicle_models_id_seq OWNED BY public.vehicle_models.id;


--
-- Name: vehicle_models_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_models_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_models_sequence OWNER TO admin;

--
-- Name: vehicle_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_summaries_id_seq OWNER TO admin;

--
-- Name: vehicle_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.vehicle_summaries_id_seq OWNED BY public.vehicle_summaries.id;


--
-- Name: vehicle_summaries_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_summaries_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_summaries_sequence OWNER TO admin;

--
-- Name: vehicle_tire_histories; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.vehicle_tire_histories (
    id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    service_id bigint NOT NULL,
    service_date date NOT NULL,
    odometer double precision NOT NULL,
    tire_location character varying(50) NOT NULL,
    otd double precision NOT NULL,
    tread_depth double precision NOT NULL,
    mm_consumed double precision,
    performance_index integer,
    km_traveled integer,
    km_proyected integer,
    odometer_estimated integer,
    safe_depth double precision,
    lifespan_consumed double precision,
    months_between_visits double precision,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer,
    prom_performance_index double precision
);


ALTER TABLE public.vehicle_tire_histories OWNER TO admin;

--
-- Name: vehicle_tire_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_tire_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_tire_histories_id_seq OWNER TO admin;

--
-- Name: vehicle_tire_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.vehicle_tire_histories_id_seq OWNED BY public.vehicle_tire_histories.id;


--
-- Name: vehicle_tire_histories_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_tire_histories_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_tire_histories_sequence OWNER TO admin;

--
-- Name: vehicle_tire_summaries; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.vehicle_tire_summaries (
    id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    tire_location character varying(50) NOT NULL,
    prom_tire_km_month double precision,
    prom_tire_mm_x_visit double precision,
    months_to_tire_unsafe double precision,
    projected_tire_visits double precision,
    estimated_months_tire_visits double precision,
    accum_km_traveled double precision,
    accum_days_total double precision,
    life_span_consumed double precision,
    sequence_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.vehicle_tire_summaries OWNER TO admin;

--
-- Name: vehicle_tire_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_tire_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_tire_summaries_id_seq OWNER TO admin;

--
-- Name: vehicle_tire_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.vehicle_tire_summaries_id_seq OWNED BY public.vehicle_tire_summaries.id;


--
-- Name: vehicle_tire_summaries_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicle_tire_summaries_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_tire_summaries_sequence OWNER TO admin;

--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.vehicles (
    id bigint NOT NULL,
    odoo_id bigint,
    plate character varying(191) NOT NULL,
    vehicle_brand_id bigint,
    vehicle_model_id bigint,
    register_date timestamp(0) without time zone,
    color character varying(191),
    year integer,
    transmission character varying(191),
    fuel character varying(191),
    odometer double precision,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    sequence_id integer NOT NULL,
    nickname character varying(191) NOT NULL,
    color_hex character varying(191),
    icon character varying(191) DEFAULT '1'::character varying NOT NULL,
    type_vehicle character varying(50),
    odometer_unit character varying(30),
    brand_name character varying(191),
    model_name character varying(191),
    user_id bigint
);


ALTER TABLE public.vehicles OWNER TO admin;

--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicles_id_seq OWNER TO admin;

--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: vehicles_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.vehicles_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicles_sequence OWNER TO admin;

--
-- Name: actions id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.actions ALTER COLUMN id SET DEFAULT nextval('public.actions_id_seq'::regclass);


--
-- Name: app_parameters id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_parameters ALTER COLUMN id SET DEFAULT nextval('public.app_parameters_id_seq'::regclass);


--
-- Name: app_warnings id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_warnings ALTER COLUMN id SET DEFAULT nextval('public.app_warnings_id_seq'::regclass);


--
-- Name: application_user id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.application_user ALTER COLUMN id SET DEFAULT nextval('public.application_user_id_seq'::regclass);


--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: error_logs id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.error_logs ALTER COLUMN id SET DEFAULT nextval('public.error_logs_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: heat_maps id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.heat_maps ALTER COLUMN id SET DEFAULT nextval('public.heat_maps_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: odometers id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.odometers ALTER COLUMN id SET DEFAULT nextval('public.odometers_id_seq'::regclass);


--
-- Name: oil_change_histories id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.oil_change_histories ALTER COLUMN id SET DEFAULT nextval('public.oil_change_histories_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: privacy_terms_conditions id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.privacy_terms_conditions ALTER COLUMN id SET DEFAULT nextval('public.privacy_terms_conditions_id_seq'::regclass);


--
-- Name: product_categories id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.product_categories ALTER COLUMN id SET DEFAULT nextval('public.product_categories_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: service_alignment id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_alignment ALTER COLUMN id SET DEFAULT nextval('public.service_alignment_id_seq'::regclass);


--
-- Name: service_balancing id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_balancing ALTER COLUMN id SET DEFAULT nextval('public.service_balancing_id_seq'::regclass);


--
-- Name: service_battery id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_battery ALTER COLUMN id SET DEFAULT nextval('public.service_battery_id_seq'::regclass);


--
-- Name: service_configs id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_configs ALTER COLUMN id SET DEFAULT nextval('public.service_configs_id_seq'::regclass);


--
-- Name: service_items id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_items ALTER COLUMN id SET DEFAULT nextval('public.service_items_id_seq'::regclass);


--
-- Name: service_items_actions id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_items_actions ALTER COLUMN id SET DEFAULT nextval('public.service_items_actions_id_seq'::regclass);


--
-- Name: service_oil id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_oil ALTER COLUMN id SET DEFAULT nextval('public.service_oil_id_seq'::regclass);


--
-- Name: service_operators id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_operators ALTER COLUMN id SET DEFAULT nextval('public.service_operators_id_seq'::regclass);


--
-- Name: service_synceds id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_synceds ALTER COLUMN id SET DEFAULT nextval('public.service_synceds_id_seq'::regclass);


--
-- Name: service_tires id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_tires ALTER COLUMN id SET DEFAULT nextval('public.service_tires_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: stores id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);


--
-- Name: tire_brands id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_brands ALTER COLUMN id SET DEFAULT nextval('public.tire_brands_id_seq'::regclass);


--
-- Name: tire_models id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_models ALTER COLUMN id SET DEFAULT nextval('public.tire_models_id_seq'::regclass);


--
-- Name: tire_oem_depths id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_oem_depths ALTER COLUMN id SET DEFAULT nextval('public.tire_oem_depths_id_seq'::regclass);


--
-- Name: tire_otd_standars id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_otd_standars ALTER COLUMN id SET DEFAULT nextval('public.tire_otd_standars_id_seq'::regclass);


--
-- Name: tire_sizes id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_sizes ALTER COLUMN id SET DEFAULT nextval('public.tire_sizes_id_seq'::regclass);


--
-- Name: tui_oem_depths id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tui_oem_depths ALTER COLUMN id SET DEFAULT nextval('public.tui_oem_depths_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vehicle_brands id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_brands ALTER COLUMN id SET DEFAULT nextval('public.vehicle_brands_id_seq'::regclass);


--
-- Name: vehicle_models id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_models ALTER COLUMN id SET DEFAULT nextval('public.vehicle_models_id_seq'::regclass);


--
-- Name: vehicle_summaries id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_summaries ALTER COLUMN id SET DEFAULT nextval('public.vehicle_summaries_id_seq'::regclass);


--
-- Name: vehicle_tire_histories id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_tire_histories ALTER COLUMN id SET DEFAULT nextval('public.vehicle_tire_histories_id_seq'::regclass);


--
-- Name: vehicle_tire_summaries id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_tire_summaries ALTER COLUMN id SET DEFAULT nextval('public.vehicle_tire_summaries_id_seq'::regclass);


--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: app_parameters app_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_parameters
    ADD CONSTRAINT app_parameters_pkey PRIMARY KEY (id);


--
-- Name: app_warnings app_warnings_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_warnings
    ADD CONSTRAINT app_warnings_pkey PRIMARY KEY (id);


--
-- Name: application_user application_user_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.application_user
    ADD CONSTRAINT application_user_pkey PRIMARY KEY (id);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: error_logs error_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.error_logs
    ADD CONSTRAINT error_logs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: heat_maps heat_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.heat_maps
    ADD CONSTRAINT heat_maps_pkey PRIMARY KEY (id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: model_has_permissions model_has_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_has_permissions
    ADD CONSTRAINT model_has_permissions_pkey PRIMARY KEY (permission_id, model_id, model_type);


--
-- Name: model_has_roles model_has_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_has_roles
    ADD CONSTRAINT model_has_roles_pkey PRIMARY KEY (role_id, model_id, model_type);


--
-- Name: odometers odometers_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.odometers
    ADD CONSTRAINT odometers_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: odometers odometers_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.odometers
    ADD CONSTRAINT odometers_pkey PRIMARY KEY (id);


--
-- Name: oil_change_histories oil_change_histories_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.oil_change_histories
    ADD CONSTRAINT oil_change_histories_pk PRIMARY KEY (vehicle_id, service_id);


--
-- Name: permissions permissions_name_guard_name_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_name_guard_name_unique UNIQUE (name, guard_name);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: privacy_terms_conditions privacy_terms_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.privacy_terms_conditions
    ADD CONSTRAINT privacy_terms_conditions_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: products products_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: role_has_permissions role_has_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.role_has_permissions
    ADD CONSTRAINT role_has_permissions_pkey PRIMARY KEY (permission_id, role_id);


--
-- Name: roles roles_name_guard_name_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_guard_name_unique UNIQUE (name, guard_name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: service_alignment service_alignment_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_alignment
    ADD CONSTRAINT service_alignment_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: service_alignment service_alignment_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_alignment
    ADD CONSTRAINT service_alignment_pkey PRIMARY KEY (id);


--
-- Name: service_balancing service_balancing_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_balancing
    ADD CONSTRAINT service_balancing_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: service_balancing service_balancing_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_balancing
    ADD CONSTRAINT service_balancing_pkey PRIMARY KEY (id);


--
-- Name: service_battery service_battery_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_battery
    ADD CONSTRAINT service_battery_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: service_battery service_battery_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_battery
    ADD CONSTRAINT service_battery_pkey PRIMARY KEY (id);


--
-- Name: service_configs service_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_configs
    ADD CONSTRAINT service_configs_pkey PRIMARY KEY (id);


--
-- Name: service_items_actions service_items_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_items_actions
    ADD CONSTRAINT service_items_actions_pkey PRIMARY KEY (id);


--
-- Name: service_items service_items_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_items
    ADD CONSTRAINT service_items_pkey PRIMARY KEY (id);


--
-- Name: service_oil service_oil_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_oil
    ADD CONSTRAINT service_oil_pkey PRIMARY KEY (id);


--
-- Name: service_operators service_operators_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_operators
    ADD CONSTRAINT service_operators_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: service_operators service_operators_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_operators
    ADD CONSTRAINT service_operators_pkey PRIMARY KEY (id);


--
-- Name: service_synceds service_synceds_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_synceds
    ADD CONSTRAINT service_synceds_pkey PRIMARY KEY (id);


--
-- Name: service_synceds service_synceds_service_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_synceds
    ADD CONSTRAINT service_synceds_service_id_unique UNIQUE (service_id);


--
-- Name: service_tires service_tires_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_tires
    ADD CONSTRAINT service_tires_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: service_tires service_tires_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_tires
    ADD CONSTRAINT service_tires_pkey PRIMARY KEY (id);


--
-- Name: services services_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: stores stores_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: tire_brands tire_brands_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_brands
    ADD CONSTRAINT tire_brands_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: tire_brands tire_brands_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_brands
    ADD CONSTRAINT tire_brands_pkey PRIMARY KEY (id);


--
-- Name: tire_models tire_models_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_models
    ADD CONSTRAINT tire_models_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: tire_models tire_models_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_models
    ADD CONSTRAINT tire_models_pkey PRIMARY KEY (id);


--
-- Name: tire_oem_depths tire_oem_depths_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_oem_depths
    ADD CONSTRAINT tire_oem_depths_pkey PRIMARY KEY (id);


--
-- Name: tire_otd_standars tire_otd_standars_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_otd_standars
    ADD CONSTRAINT tire_otd_standars_pkey PRIMARY KEY (id);


--
-- Name: tire_sizes tire_sizes_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_sizes
    ADD CONSTRAINT tire_sizes_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: tire_sizes tire_sizes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_sizes
    ADD CONSTRAINT tire_sizes_pkey PRIMARY KEY (id);


--
-- Name: tui_oem_depths tui_oem_depths_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tui_oem_depths
    ADD CONSTRAINT tui_oem_depths_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_phone_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_unique UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_res_partner_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_res_partner_id_unique UNIQUE (res_partner_id);


--
-- Name: vehicle_brands vehicle_brands_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_brands
    ADD CONSTRAINT vehicle_brands_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: vehicle_brands vehicle_brands_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_brands
    ADD CONSTRAINT vehicle_brands_pkey PRIMARY KEY (id);


--
-- Name: vehicle_models vehicle_models_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_models
    ADD CONSTRAINT vehicle_models_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: vehicle_models vehicle_models_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_models
    ADD CONSTRAINT vehicle_models_pkey PRIMARY KEY (id);


--
-- Name: vehicle_summaries vehicle_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_summaries
    ADD CONSTRAINT vehicle_summaries_pkey PRIMARY KEY (id);


--
-- Name: vehicle_summaries vehicle_summaries_vehicle_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_summaries
    ADD CONSTRAINT vehicle_summaries_vehicle_id_unique UNIQUE (vehicle_id);


--
-- Name: vehicle_tire_histories vehicle_tire_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_tire_histories
    ADD CONSTRAINT vehicle_tire_histories_pkey PRIMARY KEY (id);


--
-- Name: vehicle_tire_histories vehicle_tire_histories_un; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_tire_histories
    ADD CONSTRAINT vehicle_tire_histories_un UNIQUE (vehicle_id, service_id, tire_location);


--
-- Name: vehicle_tire_summaries vehicle_tire_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_tire_summaries
    ADD CONSTRAINT vehicle_tire_summaries_pkey PRIMARY KEY (id);


--
-- Name: vehicle_tire_summaries vehicle_tire_summaries_un; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_tire_summaries
    ADD CONSTRAINT vehicle_tire_summaries_un UNIQUE (vehicle_id, tire_location);


--
-- Name: vehicles vehicles_odoo_id_unique; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_odoo_id_unique UNIQUE (odoo_id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: model_has_permissions_model_id_model_type_index; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX model_has_permissions_model_id_model_type_index ON public.model_has_permissions USING btree (model_id, model_type);


--
-- Name: model_has_roles_model_id_model_type_index; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX model_has_roles_model_id_model_type_index ON public.model_has_roles USING btree (model_id, model_type);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: application_user application_user_application_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.application_user
    ADD CONSTRAINT application_user_application_id_foreign FOREIGN KEY (application_id) REFERENCES public.applications(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_user application_user_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.application_user
    ADD CONSTRAINT application_user_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: categories categories_action_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_action_id_foreign FOREIGN KEY (action_id) REFERENCES public.actions(id);


--
-- Name: categories categories_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.categories(id);


--
-- Name: error_logs error_logs_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.error_logs
    ADD CONSTRAINT error_logs_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- Name: model_has_permissions model_has_permissions_permission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_has_permissions
    ADD CONSTRAINT model_has_permissions_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: model_has_roles model_has_roles_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.model_has_roles
    ADD CONSTRAINT model_has_roles_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: products products_product_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_product_category_id_foreign FOREIGN KEY (product_category_id) REFERENCES public.product_categories(odoo_id);


--
-- Name: role_has_permissions role_has_permissions_permission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.role_has_permissions
    ADD CONSTRAINT role_has_permissions_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_has_permissions role_has_permissions_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.role_has_permissions
    ADD CONSTRAINT role_has_permissions_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: service_items service_items_service_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_items
    ADD CONSTRAINT service_items_service_id_foreign FOREIGN KEY (service_id) REFERENCES public.services(odoo_id);


--
-- Name: service_tires service_tires_service_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_tires
    ADD CONSTRAINT service_tires_service_id_foreign FOREIGN KEY (service_id) REFERENCES public.services(odoo_id);


--
-- Name: service_tires service_tires_tire_brand_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_tires
    ADD CONSTRAINT service_tires_tire_brand_id_foreign FOREIGN KEY (tire_brand_id) REFERENCES public.tire_brands(odoo_id);


--
-- Name: service_tires service_tires_tire_model_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.service_tires
    ADD CONSTRAINT service_tires_tire_model_id_foreign FOREIGN KEY (tire_model_id) REFERENCES public.tire_models(odoo_id);


--
-- Name: services services_odometer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_odometer_id_foreign FOREIGN KEY (odometer_id) REFERENCES public.odometers(odoo_id);


--
-- Name: services services_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.stores(odoo_id);


--
-- Name: services services_vehicle_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_vehicle_id_foreign FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(odoo_id);


--
-- Name: tire_models tire_models_tire_brand_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_models
    ADD CONSTRAINT tire_models_tire_brand_id_foreign FOREIGN KEY (tire_brand_id) REFERENCES public.tire_brands(odoo_id);


--
-- Name: tire_oem_depths tire_oem_depths_tire_brand_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_oem_depths
    ADD CONSTRAINT tire_oem_depths_tire_brand_id_foreign FOREIGN KEY (tire_brand_id) REFERENCES public.tire_brands(odoo_id);


--
-- Name: tire_oem_depths tire_oem_depths_tire_model_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_oem_depths
    ADD CONSTRAINT tire_oem_depths_tire_model_id_foreign FOREIGN KEY (tire_model_id) REFERENCES public.tire_brands(odoo_id);


--
-- Name: tire_oem_depths tire_oem_depths_tire_size_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.tire_oem_depths
    ADD CONSTRAINT tire_oem_depths_tire_size_id_foreign FOREIGN KEY (tire_size_id) REFERENCES public.tire_brands(odoo_id);


--
-- Name: users users_legal_disclaimer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_legal_disclaimer_id_foreign FOREIGN KEY (legal_disclaimer_id) REFERENCES public.privacy_terms_conditions(id) ON DELETE SET NULL;


--
-- Name: users users_privacy_policy_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_privacy_policy_id_foreign FOREIGN KEY (privacy_policy_id) REFERENCES public.privacy_terms_conditions(id) ON DELETE SET NULL;


--
-- Name: users users_terms_and_conditions_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_terms_and_conditions_id_foreign FOREIGN KEY (terms_and_conditions_id) REFERENCES public.privacy_terms_conditions(id) ON DELETE SET NULL;


--
-- Name: vehicle_models vehicle_models_vehicle_brand_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_models
    ADD CONSTRAINT vehicle_models_vehicle_brand_id_foreign FOREIGN KEY (vehicle_brand_id) REFERENCES public.vehicle_brands(odoo_id);


--
-- Name: vehicle_tire_summaries vehicle_tire_summaries_vehicle_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicle_tire_summaries
    ADD CONSTRAINT vehicle_tire_summaries_vehicle_id_foreign FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(odoo_id);


--
-- Name: vehicles vehicles_vehicle_brand_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_vehicle_brand_id_foreign FOREIGN KEY (vehicle_brand_id) REFERENCES public.vehicle_brands(odoo_id);


--
-- Name: vehicles vehicles_vehicle_model_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_vehicle_model_id_foreign FOREIGN KEY (vehicle_model_id) REFERENCES public.vehicle_models(odoo_id);


--
-- PostgreSQL database dump complete
--

