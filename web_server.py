#!/usr/bin/env python3
import json
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

#define la ruta base donde se encuentra este script para encontrar archivos locales
BASE_DIR = Path(__file__).resolve().parent

#aqui ponemos las funciones que utilizara el prolog

def prolog_atom(text: str) -> str:
    """Escapa caracteres especiales y envuelve el texto en comillas simples 
    para que Prolog lo entienda como un 'átomo'."""
    escaped = text.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def prolog_list(values):
    """Convierte una lista de Python en el formato de lista de Prolog [a, b, c]."""
    atoms = ",".join(prolog_atom(v) for v in values)
    return f"[{atoms}]"


def run_api(goal: str):
    """
    Ejecuta un comando en SWI-Prolog.
    Llama al archivo 'ApiWeb.pl' y ejecuta el objetivo (goal) pasado por parámetro.
    """
    cmd = [
        "swipl",
        "-q",        # Modo silencioso
        "-f", "none", # No cargar archivos de inicio personales
        "-s", str(BASE_DIR / "ApiWeb.pl"), # Carga el archivo de lógica en Prolog
        "-g", goal,   # El objetivo/consulta a ejecutar
        "-t", "halt", # Detenerse al terminar
    ]
    # Ejecuta el proceso en el sistema operativo y captura la salida
    result = subprocess.run(cmd, cwd=BASE_DIR, capture_output=True, text=True)
    
    if result.returncode != 0:
        return {"ok": False, "error": result.stderr.strip() or "Error ejecutando Prolog"}

    output = result.stdout.strip()
    if not output:
        return {"ok": False, "error": "Sin respuesta de Prolog"}

    # Se espera que Prolog devuelva una cadena en formato JSON
    try:
        return json.loads(output)
    except json.JSONDecodeError:
        return {"ok": False, "error": f"Respuesta no JSON: {output}"}


#este maneja el servidro http

class Handler(BaseHTTPRequestHandler):
    """Maneja las peticiones web (GET y POST) del servidor."""

    def _send_json(self, data, status=200):
        """Método auxiliar para enviar respuestas JSON al cliente."""
        payload = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _send_file(self, path: Path, content_type: str):
        """Sirve archivos estáticos (como el index.html)."""
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
        """Maneja peticiones de lectura de datos."""
        parsed = urlparse(self.path)

        # Ruta principal: sirve el archivo HTML
        if parsed.path == "/" or parsed.path == "/index.html":
            return self._send_file(BASE_DIR / "index.html", "text/html; charset=utf-8")

        # Endpoints de la API que consultan a Prolog
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

        self.send_error(404, "Not found")

    def do_POST(self):
        """Maneja peticiones que modifican datos (crear, añadir, eliminar)."""
        parsed = urlparse(self.path)
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length).decode("utf-8") if length else "{}"

        try:
            body = json.loads(raw)
        except json.JSONDecodeError:
            return self._send_json({"ok": False, "error": "JSON inválido"}, 400)

        # Acción: Crear una nueva lista en Prolog
        if parsed.path == "/api/create_list":
            nombre = str(body.get("lista", "")).strip()
            elementos = body.get("elementos", [])
            # Validación de datos
            if not nombre:
                return self._send_json({"ok": False, "error": "Falta nombre de lista"}, 400)
            
            # Convierte datos de Python a formato compatible con la consulta de Prolog
            goal = f"api(create_list({prolog_atom(nombre)}, {prolog_list(elementos)}))"
            return self._send_json(run_api(goal))

        # Acción: Buscar un elemento y opcionalmente agregarlo
        if parsed.path == "/api/search":
            nombre = str(body.get("lista", "")).strip()
            elemento = str(body.get("elemento", "")).strip()
            agregar = "si" if bool(body.get("agregarSiNoExiste", False)) else "no"
            goal = f"api(search({prolog_atom(nombre)}, {prolog_atom(elemento)}, {agregar}))"
            return self._send_json(run_api(goal))

        self.send_error(404, "Not found")

#aqui arrancamos el servidor

def main():
    host, port = "127.0.0.1", 8000
    server = HTTPServer((host, port), Handler)
    print(f"Servidor listo en http://{host}:{port}")
    server.serve_forever()

if __name__ == "__main__":
    main()