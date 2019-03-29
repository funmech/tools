"""
A simple Flask application to quickly test a jwt access token

pip install PyJWT
"""

import os

from flask import Flask, request

from cryptography.x509 import load_pem_x509_certificate
from cryptography.hazmat.backends import default_backend
import jwt

app = Flask(__name__)


def read_pem(path):
    with open(path) as pem:
        certificate = load_pem_x509_certificate(pem.read().encode('utf-8'), default_backend())
    return certificate

def verify_token(token, issuer_cert):
    print(token)

    audience = 'localserver8080'
    cert = read_pem(issuer_cert)
    claims = jwt.decode(token, cert.public_key(),
                        audience=audience,
                        issuer=os.getenv('issuer', ''),
                        algorithms='RS256')
    scopes = None
    if claims.get("scope"):
        scopes = claims["scope"].split()
    print('Authenticated %s with scope = %s' % (claims['sub'], scopes))

def authenticate_credentials(headers):
    # As a consumer of an Access Token
    print(headers)
    token = headers['Authorization'].split()[-1]
    verify_token(token, 'example.pem')


@app.route('/')
def main():
    # print(request.headers)
    # authenticate_credentials(request.headers)
    # if using implicit flow, access_token is in Uri Fragment which server
    # cannot read, so manually change it to query argument
    verify_token(request.args['access_token'])
    return 'request.headers'


if __name__ == '__main__':
    app.run(debug=True, port='8000')