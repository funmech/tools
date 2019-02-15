from os import getenv

from flask import Flask, request
import requests


app = Flask(__name__)
TIMEOUT = 3

@app.route('/')
def main():
    return 'Flask Dockerized'

@app.route('/lookup')
def lookup():
    try:
        ns = request.args.get('ns')
        return requests.get(ns, timeout=TIMEOUT, verify=False).text
    except requests.exceptions.ConnectTimeout:
        return F"Connectting from url {ns} timed out after {TIMEOUT} seconds"
    except requests.exceptions.ReadTimeout:
        return F"Reading from url {ns} timed out after {TIMEOUT} seconds"
    except Exception as err:
        return str(err)


@app.route('/checkport')
def tcpCheck():
    ip = request.args.get('ip')
    port = int(request.args.get('port'))
    import socket
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(TIMEOUT)
    try:
        s.connect((ip, port))
        s.shutdown(socket.SHUT_RDWR)
        return F"{ip}:{port} is open"
    except:
        return F"{ip}:{port} is closed/not accessible"
    finally:
        s.close()


if __name__ == '__main__':
    if getenv('Docker', False):
        app.run(debug=True, host='0.0.0.0')
    else:
        # this is for local
        app.run(debug=True)