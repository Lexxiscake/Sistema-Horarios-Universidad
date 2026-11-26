"""Ventana de solo lectura con el horario inscrito por el alumno."""

from PyQt5.QtWidgets import (
    QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout,
    QTableWidget, QTableWidgetItem, QHeaderView,
)
from PyQt5.QtGui import QFont, QPainter, QLinearGradient, QColor, QBrush
from PyQt5.QtCore import Qt

from db_config import parse_time
from Diseño_Interfaces import navegacion
from Logica_Interfaces.Horario import obtener_horario_alumno


DIAS = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]


class Horario(QWidget):
    def __init__(self, num_control):
        super().__init__()
        self.num_control = num_control
        self.setWindowTitle("Horario")
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.resize(1100, 700)
        self.setMinimumSize(900, 600)
        self.drag_position = None

        self.cerrar_btn = QPushButton("✕", self)
        self.cerrar_btn.setGeometry(self.width() - 35, 10, 25, 25)
        self.cerrar_btn.setStyleSheet(
            "background: transparent; color: black; font-size: 18px; border: none;"
        )
        self.cerrar_btn.clicked.connect(self.close)

        self.max_btn = QPushButton("☐", self)
        self.max_btn.setGeometry(self.width() - 70, 10, 25, 25)
        self.max_btn.setStyleSheet(self.cerrar_btn.styleSheet())
        self.max_btn.clicked.connect(
            lambda: navegacion.alternar_maximizado(self, self.max_btn)
        )

        self.init_ui()

    # ---------- Diseño ----------
    def paintEvent(self, event):
        painter = QPainter(self)
        gradient = QLinearGradient(0, 0, self.width(), self.height())
        gradient.setColorAt(0.0, QColor("#ffffff"))
        gradient.setColorAt(0.4, QColor("#a3d5ff"))
        gradient.setColorAt(1.0, QColor("#3399ff"))
        painter.fillRect(self.rect(), QBrush(gradient))

    def resizeEvent(self, event):
        navegacion.actualizar_mascara(self, 20)
        self.cerrar_btn.setGeometry(self.width() - 35, 10, 25, 25)
        self.max_btn.setGeometry(self.width() - 70, 10, 25, 25)
        super().resizeEvent(event)

    # Movimiento de ventana
    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton and not self.isMaximized():
            self.drag_position = event.globalPos() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if (
            event.buttons() == Qt.LeftButton
            and self.drag_position is not None
            and not self.isMaximized()
        ):
            self.move(event.globalPos() - self.drag_position)
            event.accept()

    def mouseReleaseEvent(self, event):
        self.drag_position = None

    def init_ui(self):
        fuente_general = QFont("Segoe UI", 10)
        layout_principal = QHBoxLayout(self)

        # ---------- Panel lateral ----------
        panel_lateral = QVBoxLayout()
        panel_lateral.setSpacing(20)
        panel_lateral.addStretch()

        self.btn_inicio = QPushButton("Inicio")
        self.btn_kardex = QPushButton("Kárdex")
        self.btn_carga = QPushButton("Carga de Materias")
        self.btn_horario = QPushButton("Horario")

        estilo_boton = """
            QPushButton {
                background-color: #ffffff;
                color: #003366;
                font-weight: bold;
                border: 1px solid #99ccff;
                border-radius: 8px;
                padding: 8px;
            }
            QPushButton:hover {
                background-color: #cce6ff;
            }
        """
        for btn in (self.btn_inicio, self.btn_kardex, self.btn_carga, self.btn_horario):
            btn.setFont(fuente_general)
            btn.setFixedWidth(180)
            btn.setStyleSheet(estilo_boton)
            panel_lateral.addWidget(btn, alignment=Qt.AlignHCenter)
        panel_lateral.addStretch()

        self.btn_inicio.clicked.connect(
            lambda: navegacion.ir_inicio(self, self.num_control)
        )
        self.btn_kardex.clicked.connect(
            lambda: navegacion.ir_kardex(self, self.num_control)
        )
        self.btn_carga.clicked.connect(
            lambda: navegacion.ir_carga(self, self.num_control)
        )

        # ---------- Panel central ----------
        panel_central = QVBoxLayout()
        panel_central.setSpacing(15)
        panel_central.addSpacing(40)

        nombre_alumno, filas = obtener_horario_alumno(self.num_control)

        titulo = QLabel(f"<b>TU HORARIO</b>")
        titulo.setStyleSheet("color: #003366; font-size: 18px;")
        panel_central.addWidget(titulo)

        subtitulo = QLabel(f"Alumno: {nombre_alumno} · Número de control: {self.num_control}")
        subtitulo.setStyleSheet("color: #003366; font-size: 12px;")
        panel_central.addWidget(subtitulo)

        self.tabla_horario = QTableWidget(15, 6)
        self.tabla_horario.setHorizontalHeaderLabels(
            ["HORA"] + [d.upper() for d in DIAS]
        )
        self.tabla_horario.verticalHeader().setVisible(False)
        self.tabla_horario.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.tabla_horario.setEditTriggers(QTableWidget.NoEditTriggers)
        self.tabla_horario.setSelectionMode(QTableWidget.NoSelection)
        self.tabla_horario.setStyleSheet("background: white; gridline-color: #ddd;")

        horas = [f"{h:02d}:00 - {h + 1:02d}:00" for h in range(7, 22)]
        for i, hora in enumerate(horas):
            item = QTableWidgetItem(hora)
            item.setBackground(QColor("#e3f2fd"))
            item.setFlags(Qt.ItemIsEnabled)
            self.tabla_horario.setItem(i, 0, item)

        # celdas vacías por defecto
        for f in range(15):
            for c in range(1, 6):
                vacia = QTableWidgetItem("")
                vacia.setFlags(Qt.ItemIsEnabled)
                self.tabla_horario.setItem(f, c, vacia)

        for dia, inicio, fin, nombre, letra, aula in filas:
            try:
                ini = parse_time(inicio)
            except (TypeError, ValueError):
                continue
            if dia not in DIAS:
                continue
            fila = ini.hour - 7
            if fila < 0 or fila >= 15:
                continue
            col = DIAS.index(dia) + 1
            texto = nombre + (f" ({letra})" if letra else "")
            if aula:
                texto += f"\n{aula}"
            celda = QTableWidgetItem(texto)
            celda.setBackground(QColor("#90caf9"))
            celda.setTextAlignment(Qt.AlignCenter)
            celda.setFlags(Qt.ItemIsEnabled)
            self.tabla_horario.setItem(fila, col, celda)

        panel_central.addWidget(self.tabla_horario)

        if not filas:
            aviso = QLabel(
                "Aún no tienes materias inscritas. Ve a 'Carga de Materias' "
                "para armar tu horario."
            )
            aviso.setStyleSheet("color: #003366; font-size: 13px;")
            panel_central.addWidget(aviso)

        layout_principal.addLayout(panel_lateral)
        layout_principal.addLayout(panel_central, stretch=1)
