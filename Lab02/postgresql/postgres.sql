sudo -u postgres psql

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

-- Глубина проссмотра
create or replace view v_user_deeps as
select z.location, z.id_item, y.total, z.deep
  from (select x.location, x.id_item, avg(x.deep) as deep
          from (select a.location, a.id_item, a.sessionId, count(*) as deep
                  from (select location, id_item, sessionId, min(num_timestamp) as ts1
                          from store
                      group by location, id_item, sessionId) a
             left join store b
                    on a.sessionId = b.sessionId
                 where num_timestamp >= 1541074972330
                   and b.num_timestamp <= a.ts1
              group by a.location, a.id_item, a.sessionId) x
      group by x.location, x.id_item) z
  left join (select location, count(*) as total
               from store
              where num_timestamp >= 1541074972330
           group by location) y
    on z.location = y.location
 order by z.location;

ERROR:  cannot cast type timestamp with time zone to integer
LINE 10:                  where cast (timestamp as int) >= 1541074972...
                                ^


-- Заказы пользователя
create or replace view v_user_orders as
select max(location) as url, id_item, sum(total_price_product) as price,
       count (*) as item_count
  from store
 where num_timestamp > 1541069788510
 group by id_item;

 -- select max(location) as url, id_item, sum(total_price_product) as price, count (*) as item_count from store where num_timestamp > 1541069788510 group by id_item