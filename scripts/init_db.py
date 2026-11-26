"""
Crea la base de datos, las tablas y los datos de prueba del sistema.

Uso:
    python scripts/init_db.py

Lee la configuración desde el archivo .env de la raíz del proyecto (o desde
las variables de entorno). Es seguro ejecutarlo varias veces.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from db_config import get_connection, get_settings  # noqa: E402

SQL_FILE = PROJECT_ROOT / "BD" / "init_db.sql"
DEFAULT_DB_NAME = "PruebaDB"


def split_batches(sql: str):
    """Separa un script de SQL Server en lotes usando las líneas GO."""
    batch: list[str] = []
    for line in sql.splitlines():
        if line.strip().upper() == "GO":
            text = "\n".join(batch).strip()
            if text:
                yield text
            batch = []
        else:
            batch.append(line)

    text = "\n".join(batch).strip()
    if text:
        yield text


def main() -> int:
    settings = get_settings()
    db_name = settings["database"]

    if not re.fullmatch(r"[A-Za-z0-9_]+", db_name):
        print(f"ERROR: el nombre de base de datos no es válido: {db_name!r}")
        return 1

    if not SQL_FILE.is_file():
        print(f"ERROR: no se encontró el script {SQL_FILE}")
        return 1

    print("=" * 70)
    print("Instalación de la base de datos")
    print("=" * 70)
    print(f"Servidor:        {settings['server']}")
    if settings["port"]:
        print(f"Puerto:          {settings['port']}")
    print(f"Base de datos:   {db_name}")
    print(f"Autenticación:   {'Windows' if settings['trusted'] == 'yes' else 'SQL Server'}")
    print(f"Script:          {SQL_FILE}")
    print()

    sql = SQL_FILE.read_text(encoding="utf-8-sig")
    if db_name != DEFAULT_DB_NAME:
        # Permite usar otro nombre de base de datos sin editar el .sql
        sql = sql.replace(DEFAULT_DB_NAME, db_name)

    try:
        # Nos conectamos a master para poder crear la base de datos.
        connection = get_connection(database="master", autocommit=True, timeout=15)
    except Exception as exc:
        print("ERROR: no se pudo conectar a SQL Server.")
        print(exc)
        return 1

    batches = list(split_batches(sql))
    print(f"Ejecutando {len(batches)} lotes...")

    try:
        cursor = connection.cursor()
        for index, batch in enumerate(batches, start=1):
            try:
                cursor.execute(batch)
                # Consumir resultados pendientes (si el lote devuelve filas).
                while cursor.nextset():
                    pass
            except Exception as exc:
                print(f"\nERROR en el lote {index}:")
                print("-" * 70)
                print("\n".join(batch.splitlines()[:12]))
                print("-" * 70)
                print(exc)
                return 1
        cursor.close()
    finally:
        connection.close()

    # Verificación final
    try:
        connection = get_connection(database=db_name, timeout=15)
        cursor = connection.cursor()
        cursor.execute(
            """
            SELECT
                (SELECT COUNT(*) FROM dbo.Alumnos)       AS alumnos,
                (SELECT COUNT(*) FROM dbo.Materias)      AS materias,
                (SELECT COUNT(*) FROM dbo.Kardex)        AS kardex,
                (SELECT COUNT(*) FROM dbo.Grupos)        AS grupos,
                (SELECT COUNT(*) FROM dbo.Horario_Grupo) AS horarios
            """
        )
        alumnos, materias, kardex, grupos, horarios = cursor.fetchone()
        cursor.close()
        connection.close()
    except Exception as exc:
        print("\nLa base se creó, pero no se pudo verificar.")
        print(exc)
        return 1

    print()
    print("¡Listo! Base de datos instalada correctamente.")
    print(f"  Alumnos:   {alumnos}")
    print(f"  Materias:  {materias}")
    print(f"  Kardex:    {kardex}")
    print(f"  Grupos:    {grupos}")
    print(f"  Horarios:  {horarios}")
    print()
    print("Ya puedes ejecutar la aplicación con:  python Programa.py")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
