#!/usr/bin/env python3
import json
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

BASE_DIR = Path(__file__).resolve().parent


def prolog_atom(text: str) -> str:
    escaped = text.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def prolog_list(values):
    atoms = ",".join(prolog_atom(v) for v in values)
    return f"[{atoms}]"


def run_api(goal: str):
    cmd = [
        "swipl",
        "-q",
        "-f",
        "none",
        "-s",
        str(BASE_DIR / "ApiWeb.pl"),
        "-g",
        goal,
        "-t",
        "halt",
    ]
    result = subprocess.run(cmd, cwd=BASE_DIR, capture_output=True, text=True)
    if result.returncode != 0:
        return {"ok": False, "error": result.stderr.strip() or "Error ejecutando Prolog"}

    output = result.stdout.strip()
    if not output:
        return {"ok": False, "error": "Sin respuesta de Prolog"}

    try:
        return json.loads(output)
    except json.JSONDecodeError:
        return {"ok": False, "error": f"Respuesta no JSON: {output}"}


class Handler(BaseHTTPRequestHandler):
    def _send_json(self, data, status=200):
        payload = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _send_file(self, path: Path, content_type: str):
        if not path.exists():
            self.send_error(404, "Not found")
            return
        content = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == "/" or parsed.path == "/index.html":
            return self._send_file(BASE_DIR / "index.html", "text/html; charset=utf-8")

        if parsed.path == "/api/list_names":
            return self._send_json(run_api("api(list_names)"))

        if parsed.path == "/api/full_state":
            return self._send_json(run_api("api(full_state)"))

        if parsed.path == "/api/list":
            query = parse_qs(parsed.query)
            nombre = (query.get("nombre") or [""])[0].strip()
            if not nombre:
                return self._send_json({"ok": False, "error": "Falta parámetro nombre"}, 400)
            goal = f"api(list({prolog_atom(nombre)}))"
            return self._send_json(run_api(goal))

        if parsed.path == "/api/length":
            query = parse_qs(parsed.query)
            nombre = (query.get("nombre") or [""])[0].strip()
            if not nombre:
                return self._send_json({"ok": False, "error": "Falta parámetro nombre"}, 400)
            goal = f"api(length({prolog_atom(nombre)}))"
            return self._send_json(run_api(goal))

        if parsed.path == "/api/recipes_possible":
            return self._send_json(run_api("api(recipes_possible)"))

        self.send_error(404, "Not found")

    def do_POST(self):
        parsed = urlparse(self.path)
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length).decode("utf-8") if length else "{}"

        try:
            body = json.loads(raw)
        except json.JSONDecodeError:
            return self._send_json({"ok": False, "error": "JSON inválido"}, 400)

        if parsed.path == "/api/init":
            return self._send_json(run_api("api(init)"))

        if parsed.path == "/api/create_list":
            nombre = str(body.get("lista", "")).strip()
            elementos = body.get("elementos", [])
            if not nombre:
                return self._send_json({"ok": False, "error": "Falta nombre de lista"}, 400)
            if not isinstance(elementos, list):
                return self._send_json({"ok": False, "error": "Elementos debe ser arreglo"}, 400)
            elementos = [str(x).strip() for x in elementos if str(x).strip()]
            goal = f"api(create_list({prolog_atom(nombre)}, {prolog_list(elementos)}))"
            return self._send_json(run_api(goal))

        if parsed.path == "/api/search":
            nombre = str(body.get("lista", "")).strip()
            elemento = str(body.get("elemento", "")).strip()
            agregar = "si" if bool(body.get("agregarSiNoExiste", False)) else "no"
            if not nombre or not elemento:
                return self._send_json({"ok": False, "error": "Faltan datos"}, 400)
            goal = f"api(search({prolog_atom(nombre)}, {prolog_atom(elemento)}, {agregar}))"
            return self._send_json(run_api(goal))

        if parsed.path == "/api/add":
            nombre = str(body.get("lista", "")).strip()
            elemento = str(body.get("elemento", "")).strip()
            if not nombre or not elemento:
                return self._send_json({"ok": False, "error": "Faltan datos"}, 400)
            goal = f"api(add({prolog_atom(nombre)}, {prolog_atom(elemento)}))"
            return self._send_json(run_api(goal))

        if parsed.path == "/api/remove":
            nombre = str(body.get("lista", "")).strip()
            elemento = str(body.get("elemento", "")).strip()
            if not nombre or not elemento:
                return self._send_json({"ok": False, "error": "Faltan datos"}, 400)
            goal = f"api(remove({prolog_atom(nombre)}, {prolog_atom(elemento)}))"
            return self._send_json(run_api(goal))

        if parsed.path == "/api/sort":
            nombre = str(body.get("lista", "")).strip()
            if not nombre:
                return self._send_json({"ok": False, "error": "Falta lista"}, 400)
            goal = f"api(sort({prolog_atom(nombre)}))"
            return self._send_json(run_api(goal))

        if parsed.path == "/api/concat":
            l1 = str(body.get("lista1", "")).strip()
            l2 = str(body.get("lista2", "")).strip()
            if not l1 or not l2:
                return self._send_json({"ok": False, "error": "Faltan listas"}, 400)
            goal = f"api(concat({prolog_atom(l1)}, {prolog_atom(l2)}))"
            return self._send_json(run_api(goal))

        self.send_error(404, "Not found")


def main():
    host, port = "127.0.0.1", 8000
    server = HTTPServer((host, port), Handler)
    print(f"Servidor listo en http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
