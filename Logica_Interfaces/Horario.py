from db_config import get_connection


def obtener_horario_alumno(num_control):
    """Devuelve (nombre_del_alumno, filas_del_horario_inscrito)."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(
            "SELECT Nombre FROM Alumnos WHERE Num_control = ?",
            (num_control,),
        )
        fila = cur.fetchone()
        nombre = fila[0] if fila else "Alumno"

        cur.execute(
            """
            SELECT h.Dia_semana,
                   h.Hora_inicio,
                   h.Hora_fin,
                   m.Nombre,
                   g.Grupo_letra,
                   g.Aula
            FROM Inscripciones i
            JOIN Grupos g       ON g.Id_grupo = i.Id_grupo
            JOIN Materias m     ON m.Serie = g.Serie_materia
            JOIN Horario_Grupo h ON h.Id_grupo = g.Id_grupo
            JOIN Periodos p     ON p.Id_periodo = g.Id_periodo
            WHERE i.Num_control = ?
              AND p.Activo = 1
            ORDER BY
                CASE h.Dia_semana
                    WHEN 'Lunes' THEN 1
                    WHEN 'Martes' THEN 2
                    WHEN 'Miércoles' THEN 3
                    WHEN 'Jueves' THEN 4
                    WHEN 'Viernes' THEN 5
                END,
                h.Hora_inicio
            """,
            (num_control,),
        )
        filas = cur.fetchall()
        return nombre, filas
    finally:
        cur.close()
        conn.close()
