import os
import json
import sys
import time
from flask import Flask, request, current_app

app = Flask(__name__)

@app.route('/testapp', methods=['GET'])
def get_rich_query():    
    return json.dumps({
        'status': 'success',
        'message': 'This port 80 is working fine.'
    })

@app.route('/groupings/', methods=['GET'])
def get_groupings():    
    parameters = request.args.to_dict()
    return json.dumps({
        'status': 'success this is version VERSION',
        'message': 'route groupings',
        'parameters': parameters
    })

@app.route('/search/', methods=['GET'])
def get_search():    
    parameters = request.args.to_dict()
    return json.dumps({
        'status': 'success this is version VERSION',
        'message': 'route search',
        'parameters': parameters
    })


@app.route('/', methods=['GET'])
def get_main_root():    
    return json.dumps({
        'status': 'success',
        'message': 'route updated'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
