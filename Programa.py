from PyQt5.QtWidgets import QMessageBox

from db_config import get_connection
from Diseño_Interfaces.login import LoginWindow
from Logica_Interfaces.Menu import MenuLogic


class LoginLogic(LoginWindow):
    def __init__(self):
        super().__init__()
        self.login_btn.clicked.connect(self.validar_login)

    def conectar_sql(self):
        return get_connection()
    
    def validar_login(self):
        numero_control = self.numero_control_input.text().strip()
        contraseña = self.contra_input.text().strip()

        if not numero_control or not contraseña:
            QMessageBox.warning(self, "Campos vacíos", "Coloca algo no seas huevón")
            return

        try:
            conn = self.conectar_sql()
            cursor = conn.cursor()
            query = "SELECT * FROM Alumnos WHERE Num_control = ? AND Contraseña_hash = ?"
            cursor.execute(query, (numero_control, contraseña))
            resultado = cursor.fetchone()

            if resultado:
                QMessageBox.information(self, "Acceso", f"Bienvenido, {resultado.Nombre}")
                self.close()
                self.dashboard = MenuLogic(numero_control)
                self.dashboard.show()
                
            else:
                QMessageBox.critical(self, "Sujeto no identificado", "Invasor!!!!")

            cursor.close()
            conn.close()

        except Exception as e:
            QMessageBox.critical(
                self,
                "Error de conexión",
                f"{e}\n\n"
                "Si es la primera vez que ejecutas el proyecto, inicializa la "
                "base de datos con:\n"
                "    python scripts/init_db.py",
            )

if __name__ == "__main__":
    from PyQt5.QtWidgets import QApplication
    import sys

    app = QApplication(sys.argv)
    ventana = LoginLogic()
    ventana.show()
    sys.exit(app.exec_())


    