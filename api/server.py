"""Учебный HTTP API CoinGuard. Запуск: python api/server.py."""
import argparse
import json
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if urlparse(self.path).path != '/subscriptions':
            self.respond(404, {'error': 'Not found'})
            return
        records = json.loads(Path(__file__).with_name('subscriptions.json').read_text(encoding='utf-8'))
        today = datetime.now().date()
        for record in records:
            record['nextBillingDate'] = (today + timedelta(days=record.pop('billingInDays'))).isoformat()
        self.respond(200, {'data': records})

    def do_OPTIONS(self):
        self.respond(204, None)

    def respond(self, status, data):
        body = b'' if data is None else json.dumps(data, ensure_ascii=False).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=8080)
    args = parser.parse_args()
    print(f'CoinGuard API: http://{args.host}:{args.port}/subscriptions', flush=True)
    ThreadingHTTPServer((args.host, args.port), Handler).serve_forever()
