-- Tables
SELECT c.oid, c.relname
  FROM pg_catalog.pg_class c --Этот подзапрос возвращает --идентификатор таблицы... 
  LEFT JOIN pg_catalog.pg_namespace n
    ON n.oid = c.relnamespace 
 WHERE pg_catalog.pg_table_is_visible(c.oid)
   AND c.relname = 't_store_loader';

-- Tables structure:
SELECT a.attname,pg_catalog.format_type(a.atttypid, a.atttypmod), a.attnotnull, a.atthasdef, a.attnum 
  FROM pg_catalog.pg_attribute a 
 WHERE a.attrelid in (SELECT c.oid
                       FROM pg_catalog.pg_class c --Этот подзапрос возвращает --идентификатор таблицы... 
                  LEFT JOIN pg_catalog.pg_namespace n
                         ON n.oid = c.relnamespace 
                      WHERE pg_catalog.pg_table_is_visible(c.oid)
                         AND c.relname ~ 't_store_py')  -- Имя таблицы (~ is like)
   AND a.attnum > 0
   AND NOT a.attisdropped 
 ORDER BY a.attnum;

         attname         | format_type | attnotnull | atthasdef | attnum
-------------------------+-------------+------------+-----------+--------
 index                   | bigint      | f          | f         |      1
 sessionId               | text        | f          | f         |      2
 timestamp               | bigint      | f          | f         |      3
 referer                 | text        | f          | f         |      4
 remoteHost              | text        | f          | f         |      5
 eventType               | text        | f          | f         |      6
 location                | text        | f          | f         |      7
 localPath               | text        | f          | f         |      8
 userAgent               | text        | f          | f         |      9
 userAgentDeviceCategory | text        | f          | f         |     10
 userAgentOsFamily       | text        | f          | f         |     11
 userAgentOsVersion      | text        | f          | f         |     12
 basket_price            | text        | f          | f         |     13
 item_id                 | text        | f          | f         |     14
 item_price              | text        | f          | f         |     15
 item_url

-- Check constraints
               SELECT t.table_name
		    , t.constraint_type
		    , t.constraint_name
		    , array_to_string(array_agg(c.column_name::text),',') AS keys
		 FROM information_schema.TABLE_CONSTRAINTS t
		 JOIN information_schema.CONSTRAINT_COLUMN_USAGE c 
		   ON t.constraint_name = c.constraint_name
		WHERE constraint_type
		   IN ('UNIQUE', 'PRIMARY KEY')
		  AND t.table_schema = ?
		  AND t.table_name = ?
	     GROUP BY t.constraint_name
		    , t.table_name
		    , t.constraint_type
	     ORDER BY t.table_name
		    , t.constraint_type

         attname         | format_type | attnotnull | atthasdef | attnum
-------------------------+-------------+------------+-----------+--------
 index                   | bigint      | f          | f         |      1
 sessionId               | text        | f          | f         |      2
 timestamp               | bigint      | f          | f         |      3
 referer                 | text        | f          | f         |      4
 remoteHost              | text        | f          | f         |      5
 eventType               | text        | f          | f         |      6
 location                | text        | f          | f         |      7
 localPath               | text        | f          | f         |      8
 userAgent               | text        | f          | f         |      9
 userAgentDeviceCategory | text        | f          | f         |     10
 userAgentOsFamily       | text        | f          | f         |     11
 userAgentOsVersion      | text        | f          | f         |     12
 basket_price            | text        | f          | f         |     13
 item_id                 | text        | f          | f         |     14
 item_price              | text        | f          | f         |     15
 item_url

--------------------------------------- Create View:
-- v_store
create or replace view v_store as
select to_timestamp(timestamp / 1000) AT TIME ZONE 'UTC' as dt,
       timestamp as timestamp_int, "sessionId" as session_id,
       replace (location, 'https://b24-jlvsu4.bitrix24.', '') as curr_location,
       replace (referer, 'https://b24-jlvsu4.bitrix24.', '') as prev_location,
       "remoteHost" as remote_host, "eventType" as event_type,
       case
          when location similar to '%shop/katalog/item/%' = 't'
             then replace (replace (location, 'https://b24-jlvsu4.bitrix24.shop/katalog/item/', ''), '/', '')
          else null
       end as item_code,
       case
          when location similar to '%oformleniezakaza%' = 't'
             then 1
          else 0
       end as is_trade,
       nullif ("basket_price", '')::int as basket_price,
       nullif ("item_price", '')::int as item_price,
       "item_id" as item_id, "item_url" as item_url,
       'DIVOLTE' as source_code
  from t_store_py
 union all
select to_timestamp(timestamp / 1000) AT TIME ZONE 'UTC' as dt,
       timestamp as timestamp_int, "session_id" as session_id,
       curr_location, prev_location,
       '35.204.145.90' as remote_host, "event_type" as event_type,
       case
          when curr_location similar to '%shop/katalog/item/%' = 't'
             then replace (replace (curr_location, 'shop/katalog/item/', ''), '/', '')
          else null
       end as item_code,
       case
          when curr_location similar to '%oformleniezakaza%' = 't'
             then 1
          else 0
       end as is_trade,
       "basket_price" as basket_price,
       "item_price" as item_price,
       null as item_id, null as item_url,
       'LOADER' as source_code
  from t_store_loader;

-- Глубина проссмотра
create or replace view v_user_deeps as
select z.curr_location, z.item_id, y.total, z.deep
  from (select x.curr_location, x.item_id, avg(x.deep) as deep
          from (select a.curr_location, a.item_id, a.session_Id, count(*) as deep
                  from (select vs.curr_location, vs.item_id, vs.session_id, min (vs.timestamp_int) as ts1
                          from v_store vs
                      group by vs.curr_location, vs.item_id, vs.session_id) a
             left join v_store b
                    on a.session_Id = b.session_Id
                 where timestamp_int >= 1541074972330
                   and b.timestamp_int <= a.ts1
              group by a.curr_location, a.item_id, a.session_Id) x
      group by x.curr_location, x.item_id) z
  left join (select curr_location, count(*) as total
               from v_store
              where timestamp_int >= 1541074972330
           group by curr_location) y
    on z.curr_location = y.curr_location
 order by z.curr_location;

-- Заказы пользователя
create or replace view v_user_orders as
select max(curr_location) as url, item_id, sum(basket_price) as price,
       count (*) as item_count
  from v_store
 where timestamp_int > 1541069788510
 group by item_id;

-- select max(location) as url, id_item, sum(total_price_product) as price, count (*) as item_count from store where num_timestamp > 1541069788510 group by id_item

-- Conversation
create or replace view v_conversation as
select timestamp_minute as timestamp, --count (*) as total_sessions, sum (is_trade) as total_trades,
       round (sum (is_trade) / count (*)::decimal, 2) as conversion_rate
  from (select timestamp_int / 1000 / 60 as timestamp_minute, session_id,
               max (is_trade) is_trade
          from v_store
      group by timestamp_int / 1000 / 60, session_id) t
 group by timestamp_minute;

create or replace view v_sessions_activity as
select timestamp_minute, cnt, to_timestamp(min_sec) AT TIME ZONE 'UTC' as dt
  from (select timestamp_int / 1000 / 60 as timestamp_minute,
               count (distinct session_id) cnt, min (timestamp_int) / 1000 as min_sec
          from v_store
      group by timestamp_int / 1000 / 60) t
 order by timestamp_minute desc;

create or replace view v_item_stat as
select to_timestamp(timestamp_minute * 60) AT TIME ZONE 'UTC' as dt, item_code, cnt
  from (select timestamp_int / 1000 / 60 as timestamp_minute, item_code, count (*) cnt
          from v_store
         where item_code is not null
      group by timestamp_int / 1000 / 60, item_code) t;

--------------------------------------- TESTs
select timestamp_int, curr_location, prev_location, event_type,
       sum (basket_price) as basket_price, sum (item_price) as item_price, session_id
       --, item_id, item_url
  from v_store
 where event_type in ('itemViewEvent', 'checkoutEvent')
 group by timestamp_int, curr_location, prev_location, event_type, session_id;

select event_type, session_id,
       sum (basket_price) as basket_price,
       sum (item_price) as item_price
       --, item_id, item_url
  from v_store
 where event_type in ('itemViewEvent', 'checkoutEvent')
 group by event_type, session_id;

select distinct prev_location, curr_location, event_type, item_code, item_price, basket_price
  from v_store;

 timestamp_int |               curr_location                |               prev_location                |  event_type   | basket_price | item_price
---------------+--------------------------------------------+--------------------------------------------+---------------+--------------+------------
 1542147318708 | shop/personalnyyrazdel/korzina/            | shop/                                      | pageView      |              |
 1542147332063 | shop/                                      | shop/personalnyyrazdel/korzina/            | pageView      |              |
 1542147390284 | shop/                                      | shop/personalnyyrazdel/korzina/            | itemViewEvent |              | 980
 1542147391491 | shop/katalog/item/t-shirt-men-s-fire/      | shop/                                      | pageView      |              |
 1542147397126 | shop/katalog/item/t-shirt-men-s-fire/      | shop/                                      | itemBuyEvent  |              | 980
 1542147398456 | shop/personalnyyrazdel/korzina/            | shop/katalog/item/t-shirt-men-s-fire/      | pageView      |              |
 1542147425371 | shop/personalnyyrazdel/korzina/            | shop/katalog/item/t-shirt-men-s-fire/      | checkoutEvent | 980          |
 1542147426729 | shop/personalnyyrazdel/oformleniezakaza/   | shop/personalnyyrazdel/korzina/            | pageView      |              |
 1542147480709 | shop/                                      | shop/personalnyyrazdel/oformleniezakaza/   | pageView      |              |
 1542147609342 | shop/personalnyyrazdel/korzina/            | shop/                                      | pageView      |              |
 1542147614969 | shop/personalnyyrazdel/korzina/            | shop/                                      | checkoutEvent | 980          |
 1542147616003 | shop/personalnyyrazdel/oformleniezakaza/   | shop/personalnyyrazdel/korzina/            | pageView      |              |
 1542147622387 | shop/                                      | shop/personalnyyrazdel/oformleniezakaza/   | pageView      |              |
 1542147625864 | shop/                                      | shop/personalnyyrazdel/oformleniezakaza/   | itemViewEvent |              | 470
 1542147626765 | shop/katalog/item/slippers-favorite-sport/ | shop/                                      | pageView      |              |
 1542147636490 | shop/katalog/item/slippers-favorite-sport/ | shop/                                      | itemBuyEvent  |              | 470
 1542147637789 | shop/personalnyyrazdel/korzina/            | shop/katalog/item/slippers-favorite-sport/ | pageView      |              |
 1542147643976 | shop/personalnyyrazdel/korzina/            | shop/katalog/item/slippers-favorite-sport/ | checkoutEvent | 1450         |
 1542147645010 | shop/personalnyyrazdel/oformleniezakaza/   | shop/personalnyyrazdel/korzina/            | pageView      |              |


                  prev_location                  |                  curr_location                  |  event_type   |          item_code           | item_price | basket_price
-------------------------------------------------+-------------------------------------------------+---------------+------------------------------+------------+--------------
 shop/katalog/item/t-shirt-female-temptation/    | shop/katalog/clothes/t-shirts/                  | itemViewEvent |                              |       1010 |
 shop/katalog/item/slippers-pink-paradise/       | shop/katalog/clothes/t-shirts/                  | pageView      |                              |            |
 shop/katalog/item/women-s-t-shirt-purity/       | shop/katalog/clothes/t-shirts/                  | itemViewEvent |                              |        750 |
 shop/personalnyyrazdel/korzina/                 | shop/                                           | itemViewEvent |                              |        980 |
 shop/katalog/item/t-shirt-men-s-fire/           | shop/personalnyyrazdel/korzina/                 | pageView      |                              |            |
 shop/katalog/item/slippers-pink-paradise/       | shop/katalog/clothes/t-shirts/                  | itemViewEvent |                              |       1550 |
 shop/personalnyyrazdel/korzina/                 | shop/                                           | itemViewEvent |                              |       2999 |
 shop/katalog/item/dress-red-fairy/              | shop/                                           | itemViewEvent |                              |       4500 |
 shop/katalog/item/t-shirt-mens-purity/          | shop/katalog/clothes/t-shirts/                  | itemViewEvent |                              |       3230 |
 shop/                                           | shop/katalog/item/slippers-favorite-sport/      | pageView      | slippers-favorite-sport      |            |
 shop/                                           | shop/katalog/item/dress-red-fairy/              | pageView      | dress-red-fairy              |            |
 shop/                                           | shop/katalog/item/sports-suit-breath-sports/    | pageView      | sports-suit-breath-sports    |            |
 shop/katalog/clothes/dresses/                   | shop/katalog/clothes/shoes/                     | itemViewEvent |                              |        899 |
 shop/katalog/item/slippers-favorite-sport/      | shop/personalnyyrazdel/korzina/                 | pageView      |                              |            |
 shop/                                           | shop/katalog/item/t-shirt-men-s-fire/           | pageView      | t-shirt-men-s-fire           |            |
 shop/katalog/clothes/dresses/                   | shop/katalog/clothes/shoes/                     | pageView      |                              |            |
 shop/katalog/item/slippers-favorite-sport/      | shop/personalnyyrazdel/korzina/                 | checkoutEvent |                              |            |        1450
 shop/                                           | shop/personalnyyrazdel/korzina/                 | pageView      |                              |            |
 shop/katalog/clothes/t-shirts/                  | shop/katalog/item/women-s-t-shirt-purity/       | pageView      | women-s-t-shirt-purity       |            |
 shop/katalog/item/dress-red-fairy/              | shop/                                           | itemViewEvent |                              |       3920 |        
 shop/katalog/clothes/shoes/                     | shop/katalog/item/pantolety-bones-on-the-beach/ | pageView      | pantolety-bones-on-the-beach |            |        
 shop/katalog/clothes/dresses/                   | shop/katalog/item/dress-red-fairy/              | pageView      | dress-red-fairy              |            |        
 shop/katalog/item/t-shirt-female-temptation/    | shop/katalog/clothes/t-shirts/                  | pageView      |                              |            |        
 shop/katalog/item/t-shirt-men-s-fire/           | shop/katalog/clothes/t-shirts/                  | pageView      |                              |            |        
 shop/katalog/clothes/t-shirts/                  | shop/katalog/item/t-shirt-men-s-fire/           | pageView      | t-shirt-men-s-fire           |            |        
 shop/katalog/item/dress-red-fairy/              | shop/                                           | itemViewEvent |                              |        470 |        
 shop/                                           | shop/katalog/item/sports-suit-pink-vortex/      | pageView      | sports-suit-pink-vortex      |            |        
 shop/personalnyyrazdel/oformleniezakaza/        | shop/                                           | pageView      |                              |            |        
 shop/personalnyyrazdel/korzina/                 | shop/                                           | pageView      |                              |            |        
 shop/katalog/clothes/t-shirts/                  | shop/katalog/item/women-s-t-shirt-night/        | pageView      | women-s-t-shirt-night        |            |        
 shop/katalog/clothes/t-shirts/                  | shop/katalog/item/t-shirt-mens-purity/          | pageView      | t-shirt-mens-purity          |            |        
 shop/personalnyyrazdel/korzina/                 | shop/personalnyyrazdel/oformleniezakaza/        | pageView      |                              |            |        
 shop/katalog/item/dress-red-fairy/              | shop/                                           | itemViewEvent |                              |       4499 |        
 shop/katalog/item/pantolety-bones-on-the-beach/ | shop/katalog/clothes/shoes/                     | pageView      |                              |            |        
 shop/katalog/item/dress-spring-ease/            | shop/katalog/clothes/dresses/                   | pageView      |                              |            |        
 shop/katalog/item/t-shirt-men-s-fire/           | shop/personalnyyrazdel/korzina/                 | checkoutEvent |                              |            |          980
 shop/                                           | shop/katalog/item/dress-nightlife/              | pageView      | dress-nightlife              |            |        
 shop/                                           | shop/katalog/item/t-shirt-men-s-fire/           | itemBuyEvent  | t-shirt-men-s-fire           |        980 |        
 shop/personalnyyrazdel/oformleniezakaza/        | shop/                                           | itemViewEvent |                              |        470 |        
 shop/katalog/item/pantolety-bones-on-the-beach/ | shop/katalog/clothes/shoes/                     | itemViewEvent |                              |        355 |        
 shop/katalog/item/t-shirt-mens-purity/          | shop/katalog/clothes/t-shirts/                  | pageView      |                              |            |        
 shop/                                           | shop/personalnyyrazdel/korzina/                 | checkoutEvent |                              |            |          980
 shop/katalog/clothes/shoes/                     | shop/katalog/item/slippers-pink-paradise/       | pageView      | slippers-pink-paradise       |            |        
 shop/kakkupit/                                  | shop/katalog/clothes/dresses/                   | itemViewEvent |                              |       3999 |        
 shop/kakkupit/                                  | shop/katalog/clothes/dresses/                   | pageView      |                              |            |        
 shop/katalog/item/dress-red-fairy/              | shop/                                           | pageView      |                              |            |        
 shop/katalog/item/women-s-t-shirt-night/        | shop/katalog/clothes/t-shirts/                  | itemViewEvent |                              |        980 |        
 shop/                                           | shop/katalog/item/slippers-favorite-sport/      | itemBuyEvent  | slippers-favorite-sport      |        470 |        
 shop/katalog/item/women-s-t-shirt-purity/       | shop/katalog/clothes/t-shirts/                  | pageView      |                              |            |        
 shop/katalog/item/women-s-t-shirt-night/        | shop/katalog/clothes/t-shirts/                  | pageView      |                              |            |        
 shop/                                           | shop/katalog/item/dress-spring-ease/            | pageView      | dress-spring-ease            |            |        
 shop/katalog/clothes/t-shirts/                  | shop/katalog/item/t-shirt-female-temptation/    | pageView      | t-shirt-female-temptation    |            |        
 shop/katalog/clothes/t-shirts/                  | shop/kakkupit/                                  | pageView      |                              |            |        

-- Create tables:
--Перед публикацией творений неплохо было бы почитать документацию про системные
--таблицы pg_catalog и про наличествующие стандартные функции или, хотя бы, подсмотреть,
--как это делает psql, благо тот предоставляет эту возможность.
------------------------------------------ Create schema objects -----------------------------------------
/*
CREATE TABLE store (
   store_id            serial PRIMARY KEY,
   sessionId           varchar (128),
   num_timestamp       numeric,
   location            varchar (128),
   id_item             varchar (128),
   id_product          varchar (128),
   price_product       numeric,
   total_price_product numeric
   --item_count          UInt16
);
*/

CREATE TABLE t_store_py (
   sessionId           varchar (128),
   timestamp           numeric,
   referer             varchar2 (256),
   location            varchar (128),
   id_item             varchar (128),
   id_product          varchar (128),
   price_product       numeric,
   total_price_product numeric
);

-- SYS_CONTEXT:
-- http://www.sql.ru/forum/803336/row-number-a-lya-oracle?mid=9725723#9725723
-- http://www.sql.ru/forum/579561/global-session-variables

SET SESSION 'usrvar.name'='Вася';
SELECT current_setting('usrvar.name');

--Решаю... Конечно custom_variable_classes = 'usrvar' в postgresql.conf прописано.... 

--String to Integer:
SELECT NULLIF(your_value, '')::int;

-- Case example:
select timestamp_int, curr_location,
       case
          when curr_location similar to 'shop/katalog/item/%' = 't'
             then replace (replace (curr_location, 'shop/katalog/item/', ''), '/', '')
          else null
       end as item_code
  from v_store;

-- Convert timestamp to date
select to_date (to_char (1542147614969, 'dd.mm.rrrr'), 'dd.mm.rrrr');
select to_timestamp(TRUNC(CAST(1542147614969 AS bigint)));
SELECT to_timestamp(1542147614) AT TIME ZONE 'UTC'; -- it's good
SELECT timestamp '1970-01-01 00:00:00' + interval '1542147614 second';

l =\
[{"item_code": 'slippers-favorite-sport', "item_price": 470},
 {"item_code": 'slippers-pink-paradise', "item_price":355},
 {"item_code": 'pantolety-bones-on-the-beach', "item_price": 890},
 {"item_code": 'dress-spring-ease', "item_price": 2999},
 {"item_code": 'dress-red-fairy', "item_price": 3999},
 {"item_code": 'dress-nightlife', "item_price": 4499},
 {"item_code": 'sports-suit-breath-sports', "item_price": 4500},
 {"item_code": 'sports-suit-gentle-warmth', "item_price": 4100},
 {"item_code": 'sports-suit-pink-vortex', "item_price": 3920},
 {"item_code": 'women-s-t-shirt-night', "item_price": 750},
 {"item_code": 'women-s-t-shirt-purity', "item_price": 3230},
 {"item_code": 't-shirt-female-temptation', "item_price": 1550},
 {"item_code": 't-shirt-mens-purity', "item_price": 1010},
 {"item_code": 't-shirt-men-s-fire', "item_price": 980}
]

--------------------------------------- Errors
'Error!' ModuleNotFoundError: No module named 'gdbm'
select * from store;
'Error!' bash: syntax error near unexpected token 'from'
https://askubuntu.com/questions/372926/bash-syntax-error-near-unexpected-token
