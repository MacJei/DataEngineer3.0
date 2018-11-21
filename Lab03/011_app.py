#!/api/flask/bin/python

#pip install flask
from flask import Flask
import pandas as pd
from sqlalchemy import create_engine

app = Flask(__name__)
engine = create_engine('postgresql://flaskdb@localhost:5432/flaskdb')
#engine = create_engine('postgresql://pythonspot@localhost:5432/testdb')

@app.route('/')
def index():
    return "It's API for checker"

#@app.route('/api/v1.0/products')
#def products():
#    df=pd.read_sql_query('select * from Products',con=engine)
#    return df.to_json(orient='records')

@app.route('/api/v1.0/users/')
def users1():
    df=pd.read_sql_query('select * from v_user_deeps',con=engine)
    #df=pd.read_sql_query('select * from v_store',con=engine)
    return df.to_json(orient='records')

@app.route('/api/v1.0/users/<ts>')
def users2(ts):
    df=pd.read_sql_query('select * from v_user_deeps',con=engine)
    #df=pd.read_sql_query('select * from v_store',con=engine)
    return df.to_json(orient='records')

@app.route('/api/v1.0/orders/')
def orders1():
    df=pd.read_sql_query('select * from v_user_orders',con=engine)
    #df=pd.read_sql_query('select * from v_store',con=engine)
    return df.to_json(orient='records')

@app.route('/api/v1.0/orders/<ts>')
def orders2(ts):
    df=pd.read_sql_query('select * from v_user_orders',con=engine)
    #df=pd.read_sql_query('select * from v_store',con=engine)
    return df.to_json(orient='records')

@app.route('/api/v1.0/test/')
def test():
    df=pd.read_sql_query('select * from v_store',con=engine)
    return df.to_json(orient='records')

@app.route('/api/v1.0/conversion_rate/')
def conversion_rate():
    df=pd.read_sql_query('select * from v_conversation',con=engine)
    return df.to_json(orient='records')

#Проверяем доступность:
#http://35.204.145.90:5001/
if __name__ == '__main__':
    app.run(debug=True,host = "0.0.0.0", port=5001)
