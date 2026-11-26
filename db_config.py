"""
Configuración central de la conexión a SQL Server.

Los valores se leen del archivo `.env` (en la raíz del proyecto) o de las
variables de entorno del sistema. Así cada persona puede usar su propia
instancia de SQL Server sin tocar el código.

Variables disponibles (crear `.env` en la raíz del proyecto; ver README):

    DB_SERVER                    Servidor o instancia, ej. localhost\\SQLEXPRESS
    DB_PORT                      Puerto TCP (opcional)
    DB_NAME                      Nombre de la base de datos (PruebaDB)
    DB_TRUSTED_CONNECTION        yes = autenticación de Windows, no = usuario/clave
    DB_USER / DB_PASSWORD        Credenciales cuando DB_TRUSTED_CONNECTION=no
    DB_DRIVER                    Driver ODBC (vacío = autodetectar)
    DB_ENCRYPT                   yes/no (solo ODBC Driver 17/18)
    DB_TRUST_SERVER_CERTIFICATE  yes/no (solo ODBC Driver 17/18)
"""

from __future__ import annotations

import os
import re
from datetime import datetime, time
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
ENV_FILE = BASE_DIR / ".env"

DEFAULT_DATABASE = "PruebaDB"
DEFAULT_SERVER = r"localhost\SQLEXPRESS"

# Orden de preferencia de drivers ODBC.
_PREFERRED_DRIVERS = (
    "ODBC Driver 18 for SQL Server",
    "ODBC Driver 17 for SQL Server",
    "ODBC Driver 13 for SQL Server",
    "SQL Server Native Client 11.0",
    "SQL Server",
)


def _load_env_file(path: Path) -> None:
    """Carga un archivo .env sencillo sin dependencias externas.

    Las variables que ya existen en el sistema tienen prioridad.
    """
    if not path.is_file():
        return

    for raw_line in path.read_text(encoding="utf-8-sig").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[len("export "):].strip()
        if "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()

        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]

        if key:
            os.environ.setdefault(key, value)


_load_env_file(ENV_FILE)


def _env_bool(name: str, default: bool = False) -> bool:
    value = os.getenv(name)
    if value is None or value.strip() == "":
        return default
    return value.strip().lower() in {"1", "yes", "y", "true", "si", "sí"}


def _clean(value: str | None, default: str = "") -> str:
    value = (value or "").strip()
    return value if value else default


def get_settings() -> dict[str, str]:
    """Devuelve la configuración efectiva (útil para scripts y mensajes)."""
    return {
        "server": _clean(os.getenv("DB_SERVER"), DEFAULT_SERVER),
        "port": _clean(os.getenv("DB_PORT")),
        "database": _clean(os.getenv("DB_NAME"), DEFAULT_DATABASE),
        "driver": _clean(os.getenv("DB_DRIVER")),
        "trusted": "yes" if _env_bool("DB_TRUSTED_CONNECTION", True) else "no",
        "user": _clean(os.getenv("DB_USER")),
        "password": os.getenv("DB_PASSWORD", ""),
    }


def available_drivers() -> list[str]:
    try:
        import pyodbc
    except ImportError:
        return []
    return list(pyodbc.drivers())


def pick_driver() -> str:
    """Elige el driver ODBC configurado o el mejor disponible."""
    configured = _clean(os.getenv("DB_DRIVER"))
    if configured:
        return configured

    installed = available_drivers()
    for candidate in _PREFERRED_DRIVERS:
        if candidate in installed:
            return candidate

    # Último recurso: si no hay ninguno instalado, devolvemos el recomendado
    # para que el mensaje de error sea claro.
    return _PREFERRED_DRIVERS[0]


def _server_with_port(server: str, port: str) -> str:
    if not port or "," in server:
        return server
    return f"{server},{port}"


def build_connection_string(database: str | None = None) -> str:
    settings = get_settings()
    driver = pick_driver()
    database = database or settings["database"]

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={_server_with_port(settings['server'], settings['port'])}",
        f"DATABASE={{{database}}}",
    ]

    if settings["trusted"] == "yes":
        parts.append("Trusted_Connection=yes")
    else:
        parts.append(f"UID={{{settings['user']}}}")
        parts.append(f"PWD={{{settings['password']}}}")

    # Los drivers modernos (17/18) permiten configurar el cifrado. El driver
    # antiguo "SQL Server" no entiende estas opciones.
    if driver.startswith("ODBC Driver"):
        default_encrypt = "yes" if "18" in driver else "no"
        encrypt = _clean(os.getenv("DB_ENCRYPT"), default_encrypt)
        trust_cert = _clean(os.getenv("DB_TRUST_SERVER_CERTIFICATE"), "yes")
        parts.append(f"Encrypt={encrypt}")
        parts.append(f"TrustServerCertificate={trust_cert}")

    return ";".join(parts) + ";"


def _friendly_error(exc: Exception, database: str) -> str:
    settings = get_settings()
    installed = available_drivers()
    drivers_txt = ", ".join(installed) if installed else "ninguno detectado"

    hints = [
        "No se pudo conectar a SQL Server.",
        f"Servidor: {settings['server']}"
        + (f", puerto {settings['port']}" if settings['port'] else ""),
        f"Base de datos: {database}",
        f"Driver usado: {pick_driver()}",
        f"Drivers ODBC instalados: {drivers_txt}",
        "",
        "Revisa:",
        "  1. Que SQL Server esté iniciado (servicios MSSQL*).",
        "  2. Que el nombre de la instancia en .env sea correcto.",
        "  3. Que exista el driver ODBC 18 (o 17) para SQL Server.",
        "  4. Si usas autenticación de Windows, DB_TRUSTED_CONNECTION=yes.",
        "",
        f"Detalle original: {exc}",
    ]
    return "\n".join(hints)


def get_connection(
    database: str | None = None,
    *,
    autocommit: bool = False,
    timeout: int = 10,
):
    """Crea y devuelve una conexión pyodbc usando la configuración actual."""
    import pyodbc

    target_db = database or get_settings()["database"]
    connection_string = build_connection_string(target_db)

    try:
        return pyodbc.connect(
            connection_string,
            autocommit=autocommit,
            timeout=timeout,
        )
    except pyodbc.Error as exc:
        raise ConnectionError(_friendly_error(exc, target_db)) from exc


def parse_time(value) -> time:
    """Convierte un valor de hora de SQL Server a datetime.time.

    Algunos drivers ODBC devuelven las columnas TIME como texto
    ('07:00:00.0000000') y otros como datetime.time. La aplicación debe
    funcionar con ambos.
    """
    if isinstance(value, time):
        return value
    if isinstance(value, datetime):
        return value.time()
    if isinstance(value, str):
        match = re.match(r"^\s*(\d{1,2}):(\d{2})(?::(\d{2}))?", value)
        if match:
            hour = int(match.group(1))
            minute = int(match.group(2))
            second = int(match.group(3) or 0)
            return time(hour, minute, second)
    raise ValueError(f"No se pudo interpretar la hora: {value!r}")


def resolve_project_path(relative_path: str) -> Path:
    """Convierte una ruta guardada en la BD (ej. img/miku.jpg) en ruta absoluta."""
    path = Path(relative_path)
    if path.is_absolute():
        return path
    return (BASE_DIR / path).resolve()
