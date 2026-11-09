#!/usr/bin/env bash
# Crea el tablero Kanban de SprochKanschtrli en GitHub a partir del Seminario (5.9 Historias de usuario, 5.10 Planificación).
# Requisitos: gh instalado, `gh auth login` y `gh auth refresh -s project`.
# Uso (en Git Bash o terminal Linux/macOS): bash crear_kanban.sh

set -euo pipefail

OWNER="eddgerig"
REPO="eddgerig/alemancoloniero"
TITULO_PROYECTO="SprochKanschtrli — TEG"

# ---------- Etiquetas ----------
echo "Creando etiquetas..."
gh label create "historia-usuario" --repo "$REPO" --color "0E8A16" --description "Historia de usuario (XP)" --force
gh label create "material"         --repo "$REPO" --color "FBCA04" --description "Elaboración de material con la comunidad (Thales, M)" --force
gh label create "prueba-piloto"    --repo "$REPO" --color "D93F0B" --description "Prueba piloto (Thales, P)" --force
gh label create "tecnica"          --repo "$REPO" --color "5319E7" --description "Planificación, arquitectura, integración y despliegue" --force
gh label create "app-movil"        --repo "$REPO" --color "1D76DB" --description "Aplicación móvil (Flutter)" --force
gh label create "cms"              --repo "$REPO" --color "C5DEF5" --description "Módulo de administración (Django Admin)" --force

# ---------- Milestones (iteraciones) ----------
echo "Creando iteraciones..."
crear_milestone () {
  gh api "repos/$REPO/milestones" -f title="$1" -f due_on="$2" -f description="$3" --silent
}
crear_milestone "Iteración 1" "2026-11-20T23:59:59Z" "Semana 1 — Planificación y diseño detallado"
crear_milestone "Iteración 2" "2026-12-11T23:59:59Z" "Semanas 3-4 — Núcleo de acceso y CMS base"
crear_milestone "Iteración 3" "2027-01-15T23:59:59Z" "Semanas 5-6 — Navegación y catálogo de corpus"
crear_milestone "Iteración 4" "2027-01-29T23:59:59Z" "Semanas 7-8 — Motor de lecciones interactivas"
crear_milestone "Iteración 5" "2027-02-12T23:59:59Z" "Semanas 9-10 — Flujo pedagógico y relatos"
crear_milestone "Iteración 6" "2027-02-26T23:59:59Z" "Semanas 11-12 — Patrimonio y sincronización"
crear_milestone "Iteración 7" "2027-03-05T23:59:59Z" "Semana 13 — Auditoría, piloto y ajustes"
crear_milestone "Iteración 8" "2027-03-12T23:59:59Z" "Semana 14 — Despliegue y cierre"

# ---------- Project ----------
echo "Creando el Project..."
PNUM=$(gh project create --owner "$OWNER" --title "$TITULO_PROYECTO" --format json --jq '.number')
gh project link "$PNUM" --owner "$OWNER" --repo "$REPO"
echo "Project #$PNUM creado y vinculado."

# ---------- Issues ----------
# crear "Título" "etiqueta1,etiqueta2" "Iteración N"  <<'EOF' cuerpo EOF
crear () {
  local url
  url=$(gh issue create --repo "$REPO" --title "$1" --label "$2" --milestone "$3" --body-file -)
  gh project item-add "$PNUM" --owner "$OWNER" --url "$url" > /dev/null
  echo "  ✓ $1"
}

echo "Creando issues..."

# ===== Iteración 1 =====
crear "Definición de la arquitectura Flutter + Django REST" "tecnica" "Iteración 1" <<'EOF'
Definir la arquitectura de la solución: app móvil en Flutter, backend en Django REST Framework, PostgreSQL, Firebase Storage para multimedia y Git para control de versiones.

**Entregable:** documento de arquitectura.
EOF

crear "Prototipado UX/UI de pantallas" "tecnica,app-movil" "Iteración 1" <<'EOF'
Prototipos navegables de la interfaz de la aplicación.

**Entregable:** prototipos navegables de interfaz.
EOF

crear "Diseño de la base de datos PostgreSQL" "tecnica" "Iteración 1" <<'EOF'
Modelo entidad-relación de la base de datos.

**Entregable:** modelo entidad-relación de BD (DBML + documentación).
EOF

crear "M-01 — Gestión de consentimiento y definición del corpus base" "material" "Iteración 1" <<'EOF'
**Actividad:** selección de los hablantes nativos participantes, obtención de sus consentimientos informados firmados para el registro y difusión de su voz, y estructuración del corpus léxico de los módulos iniciales (selección de vocabulario por campo semántico, forma escrita, traducción y datos gramaticales). Módulos 1 a 3.

**Validación:** documento de consentimiento firmado por cada hablante y revisión del corpus léxico por hablantes con competencia en el idioma.
EOF

# ===== Iteración 2 =====
crear "HU-01 — Registro, autenticación y gestión de perfil" "historia-usuario,app-movil" "Iteración 2" <<'EOF'
**Épica 1:** Gestión de cuenta y acceso del aprendiz

Como aprendiz, quiero crear una cuenta, iniciar/cerrar sesión y gestionar mis datos de perfil de forma segura, para conservar y sincronizar mi progreso de aprendizaje de manera personalizada.

**Criterios de aceptación**
- [ ] El sistema valida los datos obligatorios (correo, nombre de usuario, contraseña) y permite el inicio de sesión.
- [ ] Proporciona opción de recuperación de credenciales vía correo.
- [ ] Conserva el progreso del usuario tras cerrar e iniciar sesión en cualquier dispositivo.
EOF

crear "HU-10 — Autenticación y roles en el CMS" "historia-usuario,cms" "Iteración 2" <<'EOF'
**Épica 8:** Control de acceso administrativo

Como administrador, quiero iniciar sesión en el panel de gestión con permisos diferenciados (editor/administrador), para resguardar la seguridad y restringir las acciones según el rol.

**Criterios de aceptación**
- [ ] Autentica credenciales en Django Admin.
- [ ] Habilita funciones específicas según los permisos asignados.
EOF

crear "M-02 (inicio) — Primeras sesiones de grabación" "material" "Iteración 2" <<'EOF'
**Actividad:** primeras sesiones de grabación del vocabulario inicial y del audio de presentación de los hablantes; captura de fotografías de los hablantes nativos.

**Validación:** escucha de los registros por el hablante que los produjo.
EOF

# ===== Iteración 3 =====
crear "HU-02 — Mapa de progreso y acceso a secciones" "historia-usuario,app-movil" "Iteración 3" <<'EOF'
**Épica 2:** Navegación y mapa de módulos

Como aprendiz, quiero visualizar la secuencia de módulos (bloqueados, en curso, completados) y acceder a secciones clave (diccionario, relatos y acervo), para orientar mi recorrido de estudio y repasar contenidos.

**Criterios de aceptación**
- [ ] Presenta el mapa visual distinguiendo el estado de cada módulo.
- [ ] Destaca de forma directa la siguiente lección a continuar.
- [ ] Otorga acceso al diccionario de vocabulario ya estudiado y a las secciones complementarias según los requisitos superados.
EOF

crear "HU-03 — Contextualización cultural y hablantes nativos" "historia-usuario,app-movil" "Iteración 3" <<'EOF'
**Épica 3:** Introducción y contextualización del módulo

Como aprendiz, quiero conocer la temática e ilustración del módulo y escuchar su nombre en Alemán Coloniero con la identificación del hablante, para familiarizarme culturalmente con el ámbito antes de realizar ejercicios.

**Criterios de aceptación**
- [ ] Muestra la ilustración temática y texto explicativo en castellano antes de la primera lección.
- [ ] Muestra una etiqueta clara con el nombre del hablante nativo junto a cada reproductor de sonido.
EOF

crear "HU-11 — Administración de vocabulario y archivos sonoros" "historia-usuario,cms" "Iteración 3" <<'EOF'
**Épica 9:** Gestión del corpus lingüístico y audio

Como administrador, quiero registrar, editar y eliminar unidades léxicas y asociarles sus archivos de audio vinculados al hablante, para mantener estructurado el corpus del idioma.

**Criterios de aceptación**
- [ ] Permite el registro de palabra, categoría, género, traducción y campo semántico.
- [ ] Permite la carga del archivo de audio asignado a su hablante nativo.
EOF

crear "HU-12 — Gestión de fichas de hablantes" "historia-usuario,cms" "Iteración 3" <<'EOF'
**Épica 10:** Directorio de hablantes nativos

Como administrador, quiero registrar y actualizar el perfil de los hablantes nativos (nombre, foto, reseña y audio de presentación), para otorgarles reconocimiento e identificarlos en las lecciones.

**Criterios de aceptación**
- [ ] Permite crear y actualizar la ficha del hablante.
- [ ] Almacena sus recursos multimedia en la nube (Firebase Storage).
EOF

crear "M-02 (cierre) — Edición de audios e ingesta en el CMS" "material" "Iteración 3" <<'EOF'
**Actividad:** edición de los registros sonoros del vocabulario, elaboración de las fichas de los hablantes (datos y fotografía) e ingesta masiva de palabras, audios y fichas en el módulo de administración.

**Validación:** aprobación de la ficha por cada hablante y verificación de la correspondencia entre palabra, audio y hablante en el sistema.

**Entregable:** base de datos alimentada con el vocabulario inicial.
EOF

# ===== Iteración 4 =====
crear "HU-04 — Actividades de reconocimiento auditivo" "historia-usuario,app-movil" "Iteración 4" <<'EOF'
**Épica 4:** Desarrollo de lecciones e interacción

Como aprendiz, quiero realizar ejercicios de emparejamiento, asociación audio-imagen/texto, para entrenar mi oído en los contrastes fonológicos del dialecto.

**Criterios de aceptación**
- [ ] Las actividades de reconocimiento se presentan antes de las de producción.
- [ ] Evalúa selecciones de audio a imagen, audio a texto e imagen a texto.

**Tipos:** audio_imagen, audio_significado, audio_forma_escrita, imagen_forma_escrita, formacion_pares, verificacion_deslizante, duracion_vocalica.
EOF

crear "HU-05 — Ejercicios de producción y sintaxis" "historia-usuario,app-movil" "Iteración 4" <<'EOF'
**Épica 4:** Desarrollo de lecciones e interacción

Como aprendiz, quiero ordenar fichas de letras, completar palabras faltantes y construir traducciones con apoyo de audio a velocidad reducida, para ejercitar la escritura y estructura sintáctica del idioma.

**Criterios de aceptación**
- [ ] Ofrece letras móviles con distractores para evitar escribir con teclados no adaptados.
- [ ] Permite reproducción ilimitada de audio a velocidad normal y reducida.

**Tipos:** ordenar_letras, componer_piezas, completar_oracion.
EOF

crear "HU-13 — Configuración de módulos, lecciones y actividades" "historia-usuario,cms" "Iteración 4" <<'EOF'
**Épica 11:** Estructuración del curso

Como administrador, quiero crear y ordenar módulos, lecciones y tipos de actividades evaluativas, para diseñar la secuencia pedagógica de la aplicación.

**Criterios de aceptación**
- [ ] Permite definir la introducción del módulo.
- [ ] Permite agregar lecciones en orden.
- [ ] Permite parametrizar los tipos de ejercicio para cada unidad léxica.
EOF

crear "M-03 (inicio) — Formulación de relatos con narradores" "material" "Iteración 4" <<'EOF'
**Actividad:** elaboración de los relatos en castellano y su formulación en Alemán Coloniero junto a los hablantes; construcción de los módulos, lecciones e interacciones mediante el módulo de administración.

**Validación:** revisión de las lecciones y actividades interactivas por hablantes competentes.
EOF

# ===== Iteración 5 =====
crear "HU-06 — Control de lección, avance y pausas" "historia-usuario,app-movil" "Iteración 5" <<'EOF'
**Épica 4:** Desarrollo de lecciones e interacción

Como aprendiz, quiero confirmar conscientemente mis respuestas, visualizar mi barra de avance y pasar por pausas cognitivas, para controlar mi esfuerzo sin perder mi progreso por toques accidentales.

**Criterios de aceptación**
- [ ] La respuesta se evalúa únicamente al pulsar "Comprobar".
- [ ] Intercala la pantalla intermedia con la mascota Frichsli entre momentos de la lección.
- [ ] Advierte al usuario antes de salir de una lección en curso.
EOF

crear "HU-07 — Retroalimentación y cola de reintento" "historia-usuario,app-movil" "Iteración 5" <<'EOF'
**Épica 5:** Retroalimentación y progresión del módulo

Como aprendiz, quiero recibir confirmación inmediata con el audio correcto al responder y reintentar las actividades falladas al final, para aprender de mis errores sin sentir penalización o frustración.

**Criterios de aceptación**
- [ ] Despliega un panel informativo con el resultado y la pronunciación correcta.
- [ ] Agrega los ejercicios fallados a una cola de reintento dentro de la misma lección.
- [ ] Habilita el siguiente módulo al alcanzar un 70 % de aciertos, o permite repetir el módulo sin límite de intentos ni sanción.
EOF

crear "HU-08 — Galería de hablantes y reproductor de relatos" "historia-usuario,app-movil" "Iteración 5" <<'EOF'
**Épica 6:** Fichas de hablantes y relatos

Como aprendiz, quiero desbloquear la ficha con foto y audio de cada hablante al completar un módulo y escuchar sus relatos segmentados, para conectar con las personas de mi comunidad y ejercitar la comprensión en discurso continuo.

**Criterios de aceptación**
- [ ] Revela la ficha del hablante al finalizar el módulo correspondiente.
- [ ] Permite escuchar el relato frase a frase o de forma continua.
- [ ] Presenta entre 2 y 4 preguntas de comprensión al finalizar el relato.
EOF

crear "HU-14a — Carga de relatos y preguntas de comprensión (CMS)" "historia-usuario,cms" "Iteración 5" <<'EOF'
**Épica 12:** Gestión de relatos y acervo documental (parte 1: relatos)

Como administrador, quiero cargar relatos segmentados por frases y sus preguntas de comprensión, para enriquecer el contenido cultural de la plataforma.

**Criterios de aceptación**
- [ ] Permite ingresar el audio segmentado por frases con su texto y traducción.
- [ ] Permite crear las preguntas de evaluación del relato.
EOF

crear "M-03 (cierre) — Grabación de relatos y preguntas" "material" "Iteración 5" <<'EOF'
**Actividad:** grabación y edición de los relatos (discurso continuo), redacción de las preguntas de comprensión e ingreso al CMS.

**Validación:** aprobación del texto y escucha del relato por el narrador.
EOF

# ===== Iteración 6 =====
crear "HU-09 — Consulta de testimonios y patrimonio oral" "historia-usuario,app-movil" "Iteración 6" <<'EOF'
**Épica 7:** Acervo documental

Como aprendiz, quiero escuchar piezas del acervo documental con transcripción sincronizada y traducción opcional, para valorar los testimonios históricos y expresiones orales de los mayores.

**Criterios de aceptación**
- [ ] Lista los testimonios con título e identificación del hablante.
- [ ] Destaca el texto en transcripción a medida que avanza la reproducción de audio.
- [ ] Permite mostrar u ocultar la traducción al castellano.
EOF

crear "HU-14b — Carga de piezas del acervo (CMS)" "historia-usuario,cms" "Iteración 6" <<'EOF'
**Épica 12:** Gestión de relatos y acervo documental (parte 2: acervo)

Como administrador, quiero cargar las piezas del acervo con transcripción y traducción, para enriquecer el contenido cultural de la plataforma.

**Criterios de aceptación**
- [ ] Permite ingresar la transcripción línea por línea con su segmentación temporal.
- [ ] Permite ingresar la traducción.
- [ ] Permite indicar el tipo de soporte de cada pieza.
EOF

crear "HU-15 — Configuración de reglas de habilitación" "historia-usuario,cms" "Iteración 6" <<'EOF'
**Épica 12:** Gestión de relatos y acervo documental

Como administrador, quiero establecer qué módulos se requieren para habilitar cada relato o pieza del acervo, para garantizar que el aprendiz avance según su nivel.

**Criterios de aceptación**
- [ ] Permite vincular las condiciones de desbloqueo entre módulos, relatos y acervo.
EOF

crear "M-04 — Recolección y sincronización del acervo documental" "material" "Iteración 6" <<'EOF'
**Actividad:** recolección de testimonios orales para el acervo documental con su transcripción y traducción, y carga en el módulo de administración configurando la segmentación y sincronía temporal entre audio y texto.

**Validación:** revisión de transcripciones y traducciones por hablantes competentes, y comprobación de la sincronía entre la voz y el texto en la aplicación.
EOF

# ===== Iteración 7 =====
crear "Integración y congelamiento de código (Release Candidate)" "tecnica" "Iteración 7" <<'EOF'
Integración de todos los componentes y congelamiento del código para la prueba piloto.
EOF

crear "M-05 — Auditoría integral de contenido y preparación del piloto" "material" "Iteración 7" <<'EOF'
**Actividad:** revisión integral de extremo a extremo de todo el contenido cargado en el sistema, y preparación logística del piloto (selección del grupo de prueba y diseño de los instrumentos de observación).

**Validación:** aprobación del contenido lingüístico por hablantes competentes y visto bueno de los instrumentos de observación por la tutora.
EOF

crear "P-01 — Prueba piloto doble (usabilidad y validación lingüística)" "prueba-piloto" "Iteración 7" <<'EOF'
**Actividad:** aplicación de la app a un grupo reducido de aprendices de la comunidad para evaluar usabilidad, navegación y comprensión de los ejercicios, con revisión en paralelo de hablantes nativos para certificar la corrección de los contenidos.

**Validación:** instrumentos de observación diligenciados y lista consolidada de hallazgos técnicos y lingüísticos.
EOF

crear "P-02 — Ciclo de ajuste e incorporación de correcciones" "prueba-piloto" "Iteración 7" <<'EOF'
**Actividad:** resolución de fallos del software identificados en la prueba e incorporación de correcciones de contenido a través del módulo de administración (Django Admin).

**Validación:** verificación del sistema corregido e informe de cierre de la prueba piloto.
EOF

# ===== Iteración 8 =====
crear "Generación del paquete ejecutable" "tecnica" "Iteración 8" <<'EOF'
Generación del paquete de la aplicación lista para distribución local.
EOF

crear "Cierre del repositorio y consolidación de resultados" "tecnica" "Iteración 8" <<'EOF'
- [ ] Cierre del repositorio de código fuente.
- [ ] Consolidación de resultados y actas de validación.
- [ ] Redacción final del informe del Trabajo Especial de Grado.
EOF

echo ""
echo "Listo. Project: https://github.com/users/$OWNER/projects/$PNUM"