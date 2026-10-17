# Tarea 3 — Modelo Físico en PostgreSQL (EA3)

Entregables de la tercera fase del proyecto de aula: refinamiento de los modelos conceptual y lógico, e implementación del modelo físico completo (23 tablas) en el SGBD PostgreSQL utilizando pgAdmin4.

## Entregables

| Entregable | Ubicación | Formato | Estado |
|---|---|---|---|
| Informe de la propuesta de solución | [`Informe/`](Informe/) | `.pdf` | Entregado |
| Hoja de cálculo (inventario y diccionario de datos físico) | [`Resultados/`](Resultados/) | `.xlsx` | Entregado |
| Scripts DDL (creación y modificación) | [`Scripts/`](Scripts/) | `.sql` | Entregado |
| Video de sustentación | [`Video/`](Video/) | Enlace YouTube | Entregado |

## Resumen del trabajo realizado

1. **Correcciones al modelo:** Ajuste de referencias circulares, incorporación de la relación recursiva `usuario_sigue_usuario` y entidades asociativas.
2. **Diccionario de datos físico:** Mapeo de las 23 tablas del sistema a tipos de datos nativos de PostgreSQL (`GENERATED ALWAYS AS IDENTITY`, `VARCHAR`, `BOOLEAN`, etc.).
3. **Scripts DDL:** Construcción del código SQL ejecutable para la creación y modificación de esquemas e integridad referencial.
4. **Análisis y conclusiones:** Evaluación de resultados y conclusiones individuales de los integrantes del Equipo A.
