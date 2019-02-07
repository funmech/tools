from os import getenv

from flask import Flask, request
import requests


app = Flask(__name__)

@app.route('/')
def main():
    return 'Flask Dockerized'

@app.route('/lookup')
def lookup():
    timeout = 3
    try:
        ns = request.args.get('ns')
        return requests.get(ns, timeout=timeout, verify=False).text
    except requests.exceptions.ConnectTimeout:
        return F"Connectting from url {ns} timed out after {timeout} seconds"
    except requests.exceptions.ReadTimeout:
        return F"Reading from url {ns} timed out after {timeout} seconds"
    except Exception as err:
        return str(err)


if __name__ == '__main__':
    if getenv('Docker', False):
        app.run(debug=True, host='0.0.0.0')
    else:
        # this is for local
        app.run(debug=True)