"""Navegación y utilidades comunes de las ventanas del sistema.

Las importaciones de las vistas se hacen dentro de cada función para evitar
importaciones circulares entre las vistas y la lógica.
"""

from PyQt5.QtGui import QPainterPath, QRegion

# Mantiene una referencia a las ventanas abiertas para que Python no las
# recolecte al cerrar la ventana anterior.
_ventanas_abiertas = []


def _mostrar(ventana):
    _ventanas_abiertas.append(ventana)
    ventana.show()
    return ventana


def ir_inicio(ventana_actual, num_control):
    from Logica_Interfaces.Menu import MenuLogic

    ventana_actual.ventana_menu = _mostrar(MenuLogic(num_control))
    ventana_actual.close()


def ir_kardex(ventana_actual, num_control):
    from Diseño_Interfaces.Kardex import Kardex

    ventana_actual.ventana_kardex = _mostrar(Kardex(num_control))
    ventana_actual.close()


def ir_carga(ventana_actual, num_control):
    from Logica_Interfaces.LogicaCargaMaterias import CargaMateriasLogic

    ventana_actual.ventana_carga = _mostrar(CargaMateriasLogic(num_control))
    ventana_actual.close()


def ir_horario(ventana_actual, num_control):
    from Diseño_Interfaces.Horario import Horario

    ventana_actual.ventana_horario = _mostrar(Horario(num_control))
    ventana_actual.close()


def actualizar_mascara(ventana, radio=20):
    """Aplica las esquinas redondeadas, salvo cuando está maximizada."""
    if ventana.isMaximized():
        ventana.clearMask()
        return

    path = QPainterPath()
    path.addRoundedRect(0, 0, ventana.width(), ventana.height(), radio, radio)
    ventana.setMask(QRegion(path.toFillPolygon().toPolygon()))


def alternar_maximizado(ventana, boton):
    """Alterna entre ventana maximizada y tamaño normal."""
    if ventana.isMaximized():
        ventana.showNormal()
        boton.setText("☐")
    else:
        ventana.showMaximized()
        boton.setText("❐")
