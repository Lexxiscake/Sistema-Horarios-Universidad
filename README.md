<div align="center">

# 🎓 Sistema de Gestión de Horarios Universitarios

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/PyQt5-GUI-41CD52?style=for-the-badge&logo=qt&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQL_Server-Database-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white"/>
  <img src="https://img.shields.io/badge/Algorithm-Backtracking-6A0DAD?style=for-the-badge"/>
</p>

<p align="center">
  <img src="https://img.shields.io/github/last-commit/Lexxiscake/Sistema-Horarios-Universidad?style=flat-square&color=orange"/>
  <img src="https://img.shields.io/github/repo-size/Lexxiscake/Sistema-Horarios-Universidad?style=flat-square&color=blue"/>
  <img src="https://img.shields.io/badge/status-active-success?style=flat-square"/>
</p>

> Aplicación de escritorio para la **gestión de horarios universitarios** y **carga de materias**, con un motor de **carga inteligente** basado en el algoritmo de Backtracking que asigna maestros y horarios sin conflictos, respaldado por **SQL Server**.

</div>

---

## 📋 Descripción

El **Sistema de Gestión de Horarios Universitarios** es una aplicación de escritorio desarrollada en Python con interfaz gráfica en PyQt5. Permite administrar de forma centralizada la asignación de materias, maestros y horarios de una institución universitaria.

Su módulo estrella es la **carga inteligente de materias**, que mediante el algoritmo de **Backtracking** genera automáticamente un horario completo, válido y sin conflictos, consultando la disponibilidad de maestros y restricciones almacenadas en SQL Server.

---

## ✨ Características

| Módulo | Descripción |
|---|---|
| 📚 Gestión de materias | Alta, baja y modificación de materias del catálogo |
| 👨‍🏫 Gestión de maestros | Registro de docentes con disponibilidad por día y hora |
| 🗓️ Gestión de horarios | Creación y administración de horarios por carrera y semestre |
| 🤖 Carga inteligente | Asignación automática con Backtracking sin cruces de horario |
| 🗄️ SQL Server | Persistencia robusta con consultas optimizadas |
| 🖥️ Interfaz PyQt5 | GUI moderna e intuitiva para el administrador |

---

## 🛠️ Tecnologías

<p>
  <img src="https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/PyQt5-41CD52?style=flat-square&logo=qt&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQL_Server-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white"/>
  <img src="https://img.shields.io/badge/pyodbc-lightgrey?style=flat-square"/>
</p>

- **Python 3.9+** — Lenguaje principal
- **PyQt5** — Interfaz gráfica de escritorio
- **SQL Server** — Base de datos relacional
- **pyodbc** — Conexión Python ↔ SQL Server
- **Backtracking** — Algoritmo de carga inteligente de materias

---

## ✅ Requisitos

Antes de empezar, cada persona necesita tener instalado:

1. **Python 3.9 o superior**
   - Descarga: <https://www.python.org/downloads/>
   - En Windows, marca la casilla **“Add python.exe to PATH”** durante la instalación.

2. **SQL Server** (cualquiera de estas opciones):
   - SQL Server Express (gratis): <https://www.microsoft.com/sql-server/sql-server-downloads>
   - SQL Server Developer (gratis): misma página, opción *Developer*.
   - Una instancia de SQL Server que ya tengas instalada.

3. **Microsoft ODBC Driver 18 for SQL Server**
   - Descarga: <https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server>
   - Si no lo instalas, la aplicación intentará usar el driver antiguo **“SQL Server”** que Windows suele traer. Funciona, pero se recomienda el 18.

4. **(Opcional) SQL Server Management Studio (SSMS)** para revisar la base de datos:
   - Descarga: <https://aka.ms/ssmsfullsetup>

> 💡 No necesitas descargar ninguna base de datos: el proyecto incluye un script que crea las tablas y los datos de prueba automáticamente.

---

## 🚀 Instalación paso a paso (Windows)

### 1. Clonar el repositorio

```powershell
git clone https://github.com/Lexxiscake/Sistema-Horarios-Universidad.git
cd Sistema-Horarios-Universidad
```

Si no tienes Git, descarga el ZIP desde GitHub y descomprímelo.

### 2. Crear el entorno virtual

```powershell
python -m venv .venv
```

Actívalo:

```powershell
.\.venv\Scripts\Activate.ps1
```

> Si PowerShell muestra un error de *ExecutionPolicy*, ejecuta una vez:
> ```powershell
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
> ```
> y vuelve a activar el entorno. También puedes usar directamente
> `.\.venv\Scripts\python.exe` en lugar de `python`.

En **CMD** sería:

```cmd
.venv\Scripts\activate
```

### 3. Instalar las dependencias

```powershell
pip install -r requirements.txt
```

### 4. Configurar la conexión

Crea un archivo `.env` en la raíz del proyecto:

```powershell
notepad .env
```

Escribe como mínimo `DB_SERVER`, `DB_NAME` y `DB_TRUSTED_CONNECTION`. Por ejemplo:

```ini
# Instancia Express (lo más común)
DB_SERVER=localhost\SQLEXPRESS
DB_PORT=

# O instancia predeterminada
# DB_SERVER=localhost
# DB_PORT=1433

DB_NAME=PruebaDB
DB_TRUSTED_CONNECTION=yes
```

- `DB_TRUSTED_CONNECTION=yes` usa tu usuario de Windows (no necesitas contraseña).
- Si tu SQL Server usa usuario y contraseña, cambia a `no` y llena `DB_USER` y `DB_PASSWORD`.

### 5. Crear la base de datos y los datos de prueba

```powershell
python scripts/init_db.py
```

El script:
- crea la base `PruebaDB` si no existe,
- crea todas las tablas,
- carga alumnos, materias y kardex de prueba,
- genera los grupos y horarios del periodo activo,
- crea el trigger de inscripciones.

Es seguro ejecutarlo varias veces: no duplica los datos.

> Alternativa con SSMS: abre `BD/init_db.sql` y ejecútalo con **F5**.
> Asegúrate de tener permisos para crear bases de datos (o ejecuta SSMS como administrador).

### 6. Ejecutar la aplicación

```powershell
pythonw.exe Programa.py
```

- `pythonw.exe` (en lugar de `python`) abre la app **sin ventana negra de consola**.
- Si necesitas ver los errores completos, ejecuta `python Programa.py` en una terminal.
- `.env` **no se sube a git** (está en `.gitignore`); cada quien crea el suyo.

---

## 🔑 Usuarios de prueba

Estos usuarios se crean automáticamente con `init_db.py`:

| Número de control | Contraseña | Nombre | Semestre |
|---|---|---|---|
| `23212002` | `panfilo` | Urabe Mikoto | 2 |
| `23212005` | `kill` | Ryuko | 3 |
| `23212006` | `miku` | Miku | 2 |
| `23212007` | `doro123` | Doro | 3 |
| `23212008` | `dinero` | Ryou | 4 |
| `23212009` | `vampiro` | Anko | 5 |
| `23212010` | `miedo` | Kobeni | 6 |
| `23211907` | `galleta` | Samuel “Galleta” | 5 |

> ⚠️ Las contraseñas se guardan en texto plano porque es un proyecto académico de demostración. No uses contraseñas reales.

---

## ⚙️ Variables de `.env`

| Variable | Descripción | Ejemplo |
|---|---|---|
| `DB_SERVER` | Servidor o instancia de SQL Server | `localhost\SQLEXPRESS` |
| `DB_PORT` | Puerto TCP (vacío si usas instancia con nombre) | `1433` |
| `DB_NAME` | Nombre de la base de datos | `PruebaDB` |
| `DB_TRUSTED_CONNECTION` | `yes` = autenticación de Windows, `no` = usuario/clave | `yes` |
| `DB_USER` | Usuario de SQL Server (si aplica) | `sa` |
| `DB_PASSWORD` | Contraseña de SQL Server (si aplica) | `MiClave123` |
| `DB_DRIVER` | Driver ODBC; vacío = autodetectar | `ODBC Driver 18 for SQL Server` |
| `DB_ENCRYPT` | Cifrado de la conexión (drivers 17/18) | `yes` |
| `DB_TRUST_SERVER_CERTIFICATE` | Acepta certificados autofirmados locales | `yes` |

---

## 🧭 ¿Cómo sé el nombre de mi instancia de SQL Server?

Abre **SSMS** y mira el campo *Server name* de la ventana de conexión. Algunos ejemplos:

- `localhost` → instancia predeterminada.
- `localhost\SQLEXPRESS` → instancia Express.
- `DESKTOP-ABC\SQLEXPRESS` → instancia Express en otra PC.
- `localhost,1433` → servidor con puerto TCP explícito.

También puedes ejecutar en PowerShell:

```powershell
Get-Service MSSQL*
```

o dentro de SQL Server:

```sql
SELECT @@SERVERNAME;
```

Si usas una **instancia con nombre** (`localhost\SQLEXPRESS`), deja `DB_PORT` vacío. Si usas `localhost` o una IP, normalmente necesitas `DB_PORT=1433`.

---

## 🗄️ Base de datos

El script de instalación es **`BD/init_db.sql`**. Crea:

| Tabla | Descripción |
|---|---|
| `Alumnos` | Datos de los estudiantes y credenciales |
| `Materias` | Catálogo de materias por semestre |
| `Kardex` | Historial académico (aprobadas, reprobadas, cursando) |
| `Periodos` | Periodos escolares y cuál está activo |
| `Grupos` | Grupos A–D por materia, cupo y aula |
| `Horario_Grupo` | Días y horas de cada grupo |
| `Inscripciones` | Materias inscritas por el alumno |

Además crea el trigger `TR_Inscribir_Auto_Cursando`, que registra la materia como `CURSANDO` en el kardex al inscribirse.

> 📌 La única fuente de verdad para crear la base es **`BD/init_db.sql`**.

---

## 🤖 Carga inteligente con Backtracking

El módulo de carga inteligente utiliza el algoritmo de **Backtracking** para generar horarios completos y válidos de forma automática.

### ¿Cómo funciona?

```
Inicio → Tomar materia sin asignar
           └─ Buscar maestro disponible
                 ├─ ✅ Sin conflicto → Asignar y avanzar a la siguiente materia
                 └─ ❌ Conflicto    → Backtrack → Probar otra combinación
```

### Restricciones que evalúa

- ✔️ Disponibilidad del maestro por día y franja horaria
- ✔️ Materias ya asignadas al mismo grupo (sin cruces)
- ✔️ Capacidad y disponibilidad de aulas
- ✔️ Restricciones definidas en SQL Server

El resultado es un **horario completo, sin conflictos**, generado automáticamente con un solo clic.

---

## 🩺 Solución de problemas

| Error | Causa probable | Solución |
|---|---|---|
| `ModuleNotFoundError: No module named 'PyQt5'` | No se activó el entorno virtual o faltan dependencias | Activa `.venv` y ejecuta `pip install -r requirements.txt` |
| `No se encuentra el nombre del origen de datos y no se especificó ningún controlador predeterminado` | Falta el driver ODBC | Instala **ODBC Driver 18** o pon `DB_DRIVER=SQL Server` si tienes el driver antiguo |
| `Login failed for user 'sa'` | Autenticación SQL mal configurada | Usa `DB_TRUSTED_CONNECTION=yes` o revisa `DB_USER`/`DB_PASSWORD` |
| `No se puede abrir la base de datos "PruebaDB"` | La base no existe | Ejecuta `python scripts/init_db.py` |
| `Invalid object name 'Alumnos'` | La base existe pero está vacía | Ejecuta `python scripts/init_db.py` |
| `TCP Provider: No such host is known` o `could not open a connection` | Servidor o puerto incorrecto, o TCP/IP deshabilitado | Revisa `DB_SERVER` y `DB_PORT`; si usas una instancia con nombre, habilita **TCP/IP** en *SQL Server Configuration Manager* y reinicia el servicio |
| No conecta con una instancia con nombre | El servicio **SQL Server Browser** está detenido | Inícialo en `services.msc` (servicio `SQLBrowser`) o usa `localhost,1433` |
| `El usuario no tiene permiso para crear la base de datos` | Tu usuario no tiene rol `dbcreator` | Ejecuta SSMS como administrador o pide que te den permisos |
| `La arquitectura del DSN no coincide` | Python de 32 bits con driver de 64 bits | Instala Python de 64 bits |
| La ventana no abre o error de *platform plugin* | PyQt5 incompleto | Reinstala: `pip install --force-reinstall PyQt5` |

Si el error persiste, abre una terminal en la carpeta del proyecto y ejecuta:

```powershell
python -c "from db_config import get_settings, pick_driver, build_connection_string; print(get_settings()); print(pick_driver()); print(build_connection_string())"
```

Eso muestra exactamente qué servidor, base y driver está usando la aplicación.

---

## 🗂️ Estructura del proyecto

```
Sistema-Horarios-Universidad/
├── BD/
│   └── init_db.sql            # Script de instalación (usar este)
├── Diseño_Interfaces/         # Vistas y diseño de ventanas PyQt5
├── Logica_Interfaces/         # Controladores y lógica de negocio
├── img/                       # Fotos de los alumnos
├── scripts/
│   └── init_db.py             # Crea la base de datos automáticamente
├── db_config.py               # Lectura de .env y conexión a SQL Server
├── Programa.py                # Punto de entrada de la aplicación
├── requirements.txt           # Dependencias de Python
└── README.md
```

---

<div align="center">
  <img width="693" height="488" alt="Sistema de Horarios" src="https://github.com/user-attachments/assets/44063976-3c64-4565-8456-829f30ad747c" />
</div>
