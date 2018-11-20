import datetime as dt, time
from datetime import datetime, timezone, timedelta
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
import psycopg2

engine = create_engine('postgresql://flaskdb@localhost:5432/flaskdb')
delay = 60000

l =\
[{'prev_location': 'shop/katalog/item/t-shirt-female-temptation/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 1010, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/slippers-pink-paradise/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'pageView', 'item_code': '', 'item_price': 1010, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/women-s-t-shirt-purity/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 750, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/t-shirt-men-s-fire/', 'curr_location': 'shop/personalnyyrazdel/korzina/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/slippers-pink-paradise/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 1550, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/dress-red-fairy/', 'curr_location': 'shop/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 4500, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/t-shirt-mens-purity/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 3230, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/dresses/', 'curr_location': 'shop/katalog/clothes/shoes/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 899, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/slippers-favorite-sport/', 'curr_location': 'shop/personalnyyrazdel/korzina/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/dresses/', 'curr_location': 'shop/katalog/clothes/shoes/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/slippers-favorite-sport/', 'curr_location': 'shop/personalnyyrazdel/korzina/', 'event_type': 'checkoutEvent', 'item_code': '', 'item_price': 0, 'basket_price': 1450},
 {'prev_location': 'shop/katalog/clothes/t-shirts/', 'curr_location': 'shop/katalog/item/women-s-t-shirt-purity/', 'event_type': 'pageView', 'item_code': 'women-s-t-shirt-purity', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/dress-red-fairy/', 'curr_location': 'shop/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 3920, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/shoes/', 'curr_location': 'shop/katalog/item/pantolety-bones-on-the-beach/', 'event_type': 'pageView', 'item_code': 'pantolety-bones-on-the-beach', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/dresses/', 'curr_location': 'shop/katalog/item/dress-red-fairy/', 'event_type': 'pageView', 'item_code': 'dress-red-fairy', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/t-shirt-female-temptation/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/t-shirt-men-s-fire/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/t-shirts/', 'curr_location': 'shop/katalog/item/t-shirt-men-s-fire/', 'event_type': 'pageView', 'item_code': 't-shirt-men-s-fire', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/dress-red-fairy/', 'curr_location': 'shop/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 470, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/women-s-t-shirt-purity/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/women-s-t-shirt-night/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/t-shirts/', 'curr_location': 'shop/katalog/item/women-s-t-shirt-night/', 'event_type': 'pageView', 'item_code': 'women-s-t-shirt-night', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/t-shirts/', 'curr_location': 'shop/katalog/item/t-shirt-mens-purity/', 'event_type': 'pageView', 'item_code': 't-shirt-mens-purity', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/dress-red-fairy/', 'curr_location': 'shop/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 4499, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/pantolety-bones-on-the-beach/', 'curr_location': 'shop/katalog/clothes/shoes/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/dress-spring-ease/', 'curr_location': 'shop/katalog/clothes/dresses/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/t-shirt-men-s-fire/', 'curr_location': 'shop/personalnyyrazdel/korzina/', 'event_type': 'checkoutEvent', 'item_code': '', 'item_price': 0, 'basket_price': 980},
 {'prev_location': 'shop/katalog/item/pantolety-bones-on-the-beach/', 'curr_location': 'shop/katalog/clothes/shoes/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 355, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/t-shirt-mens-purity/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/shoes/', 'curr_location': 'shop/katalog/item/slippers-pink-paradise/', 'event_type': 'pageView', 'item_code': 'slippers-pink-paradise', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/t-shirts/', 'curr_location': 'shop/katalog/item/t-shirt-female-temptation/', 'event_type': 'pageView', 'item_code': 't-shirt-female-temptation', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/clothes/t-shirts/', 'curr_location': 'shop/kakkupit/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/dress-red-fairy/', 'curr_location': 'shop/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/katalog/item/women-s-t-shirt-night/', 'curr_location': 'shop/katalog/clothes/t-shirts/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 980, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/slippers-favorite-sport/', 'event_type': 'pageView', 'item_code': 'slippers-favorite-sport', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/dress-red-fairy/', 'event_type': 'pageView', 'item_code': 'dress-red-fairy', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/sports-suit-breath-sports/', 'event_type': 'pageView', 'item_code': 'sports-suit-breath-sports', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/t-shirt-men-s-fire/', 'event_type': 'pageView', 'item_code': 't-shirt-men-s-fire', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/personalnyyrazdel/korzina/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/sports-suit-pink-vortex/', 'event_type': 'pageView', 'item_code': 'sports-suit-pink-vortex', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/dress-nightlife/', 'event_type': 'pageView', 'item_code': 'dress-nightlife', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/t-shirt-men-s-fire/', 'event_type': 'itemBuyEvent', 'item_code': 't-shirt-men-s-fire', 'item_price': 980, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/personalnyyrazdel/korzina/', 'event_type': 'checkoutEvent', 'item_code': '', 'item_price': 0, 'basket_price': 980},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/slippers-favorite-sport/', 'event_type': 'itemBuyEvent', 'item_code': 'slippers-favorite-sport', 'item_price': 470, 'basket_price': 0},
 {'prev_location': 'shop/', 'curr_location': 'shop/katalog/item/dress-spring-ease/', 'event_type': 'pageView', 'item_code': 'dress-spring-ease', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/kakkupit/', 'curr_location': 'shop/katalog/clothes/dresses/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 3999, 'basket_price': 0},
 {'prev_location': 'shop/kakkupit/', 'curr_location': 'shop/katalog/clothes/dresses/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/personalnyyrazdel/korzina/', 'curr_location': 'shop/personalnyyrazdel/oformleniezakaza/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/personalnyyrazdel/korzina/', 'curr_location': 'shop/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 980, 'basket_price': 0},
 {'prev_location': 'shop/personalnyyrazdel/korzina/', 'curr_location': 'shop/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 2999, 'basket_price': 0},
 {'prev_location': 'shop/personalnyyrazdel/korzina/', 'curr_location': 'shop/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0},
 {'prev_location': 'shop/personalnyyrazdel/oformleniezakaza/', 'curr_location': 'shop/', 'event_type': 'itemViewEvent', 'item_code': '', 'item_price': 470, 'basket_price': 0},
 {'prev_location': 'shop/personalnyyrazdel/oformleniezakaza/', 'curr_location': 'shop/', 'event_type': 'pageView', 'item_code': '', 'item_price': 0, 'basket_price': 0}
]

def get_dict (event):
    dict = {}
    print ('prepare record:')
    print (event)
    for i in event.keys():
        dict [i] = [event[i]]
    return dict

def get_ts():
    now = datetime.now(timezone.utc)
    epoch = datetime(1970, 1, 1, tzinfo=timezone.utc) # use POSIX epoch
    posix_timestamp_micros = (now - epoch) // timedelta(microseconds=1)
    posix_timestamp_millis = posix_timestamp_micros // 1000 # or `/ 1e3` for float
    return posix_timestamp_millis

start_ts = get_ts ()
curr_ts = start_ts
while curr_ts < start_ts + delay:
    data_set = np.random.randint (53)
    d = l[data_set]
    session_id = 'session_' + str (np.random.randint (100))
    d['session_id'] = session_id
    curr_ts = get_ts()
    d['timestamp'] = curr_ts
    if np.random.randint (2) == 1:
        df = pd.DataFrame.from_dict(get_dict (d))
        df.to_sql('t_store_loader', engine, if_exists='append')
        print ("1 row processed")
        time.sleep(1)