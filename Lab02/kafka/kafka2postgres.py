#!/api/flask/bin/python
# -*- coding: utf-8 -*-

#pip install confluent_kafka
from confluent_kafka import Consumer, KafkaError
#pip install avro_python3
from avro.io import DatumReader, BinaryDecoder
import avro.schema
import io
#pip install psycopg2
#import psycopg2
import sys
#pip install pandas
import pandas as pd
#pip install sqlalchemy
from sqlalchemy import create_engine

schema = avro.schema.Parse(open("/home/kruchininilya77/divolte-collector-0.9.0/conf/MyEventRecord.avsc").read())
reader = DatumReader(schema)

def decode(msg_value):
    message_bytes = io.BytesIO(msg_value)
    decoder = BinaryDecoder(message_bytes)
    event_dict = reader.read(decoder)
    return event_dict

def get_dict (event):
    dict = {}
    for i in event.keys():
        dict [i] = [event[i]]
    return dict

c = Consumer({'bootstrap.servers': '35.233.44.60:6667', 'group.id': "my-group", 'auto.offset.reset': 'latest', "enable.auto.commit": True})
c.subscribe(['ilya.kruchinin']) #topic
engine = create_engine('postgresql://flaskuser@localhost:5432/flaskdb')
con = None
running = True
while running:
    msg = c.poll()
    if not msg.error():
        msg_value = msg.value()
        event_dict = decode(msg_value)
        print(event_dict)
    
        df = pd.DataFrame.from_dict(get_dict (event_dict))
        #df.to_csv(path_or_buf='/api2/test.csv', sep=';')
        df[['sessionId', 'timestamp', 'location', 'id_product', 'id_product', 'price_product', 'total_price_product']].to_sql('store', engine, if_exists='append')
        print ("commit complete")
    elif msg.error().code() != KafkaError._PARTITION_EOF:
        print(msg.error())
        running = False
