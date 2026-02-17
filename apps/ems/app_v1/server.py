import http.server
import ssl

server = http.server.HTTPServer(('0.0.0.0', 8181), http.server.SimpleHTTPRequestHandler)
server.socket = ssl.wrap_socket(server.socket, certfile='cert.pem', keyfile='key.pem', server_side=True)
print('Servindo em https://localhost:8181')
server.serve_forever()