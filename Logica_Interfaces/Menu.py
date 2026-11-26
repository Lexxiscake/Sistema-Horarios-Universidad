from PyQt5.QtWidgets import QLabel
from PyQt5.QtGui import QPixmap
from PyQt5.QtCore import Qt

from db_config import get_connection, resolve_project_path
from Diseño_Interfaces.Menu import Menu
from Diseño_Interfaces import navegacion


class MenuLogic(Menu):
    def __init__(self, num_control):
        super().__init__()
        self.num_control = num_control
        self.semestre_alumn = None  

        # Cargar datos del alumno 
        self.cargar_datos_alumno()

        self.btn_inicio.clicked.connect(self.recargar_menu)
        self.btn_kardex.clicked.connect(self.abrir_kardex)
        self.btn_materias.clicked.connect(self.abrir_carga_materias)
        self.btn_horario.clicked.connect(self.abrir_horario)

    # Navegación 
    def recargar_menu(self):
        navegacion.ir_inicio(self, self.num_control)

    def abrir_kardex(self):
        navegacion.ir_kardex(self, self.num_control)

    def abrir_carga_materias(self):
        navegacion.ir_carga(self, self.num_control)

    def abrir_horario(self):
        navegacion.ir_horario(self, self.num_control)

    # Conexión SQL
    def conectar_sql(self):
        return get_connection()

    def cargar_datos_alumno(self):
        try:
            conn = self.conectar_sql()
            cursor = conn.cursor()
            query = "SELECT Nombre, Semestre, Carrera, Foto FROM Alumnos WHERE Num_control = ?"
            cursor.execute(query, (self.num_control,))
            resultado = cursor.fetchone()

            if resultado:
                nombre, semestre, carrera, foto = resultado
                self.semestre_alumn = semestre

                # Etiquetas
                self.label_linea1.setText(f"<b>Nombre:</b> {nombre}")
                self.label_linea2.setText(f"<b>Número de Control:</b> {self.num_control}")
                self.label_linea3.setText(
                    f"<b>Carrera:</b> {carrera} &nbsp;&nbsp; "
                    f"<b>Semestre:</b> {semestre} &nbsp;&nbsp; "
                )
                self.label_linea4.setText("<b>Estatus:</b> VIGENTE")

                if foto:
                    ruta_img = resolve_project_path(foto)
                    if ruta_img.exists():
                        pixmap = QPixmap(str(ruta_img)).scaled(120, 120, Qt.KeepAspectRatio, Qt.SmoothTransformation)
                        self.label_foto.setPixmap(pixmap)
                    else:
                        self.label_foto.setText("Foto perdida en la inmensidad del universo")
                else:
                    self.label_foto.setText("Sin foto")
            else:
                self.label_linea1.setText("Alumno no existente, fallo en la matrix?")
                self.label_linea2.clear()
                self.label_linea3.clear()
                self.label_linea4.clear()

            cursor.close()
            conn.close()

        except Exception as e:
            self.label_linea1.setText("Se tropezó la conexión, sorry vuelva mañana")
            self.label_linea2.setText(str(e))
            self.label_linea3.clear()
            self.label_linea4.clear()