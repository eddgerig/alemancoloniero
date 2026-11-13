#!/usr/bin/env bash
# Completa el Kanban: agrega HU-15 al Project y crea los issues restantes.
set -euo pipefail

OWNER="eddgerig"
REPO="eddgerig/alemancoloniero"
PNUM=5

agregar () {
  for i in 1 2 3; do
    gh project item-add "$PNUM" --owner "$OWNER" --url "$1" > /dev/null && return 0
    echo "  reintentando..."; sleep 3
  done
  echo "  ✗ No se pudo agregar al Project: $1"
}

crear () {
  local url
  url=$(gh issue create --repo "$REPO" --title "$1" --label "$2" --milestone "$3" --body-file -)
  agregar "$url"
  echo "  ✓ $1"
}

echo "Agregando HU-15 al Project..."
HU15=$(gh issue list --repo "$REPO" --state all --search "HU-15 in:title" --json url --jq '.[0].url')
agregar "$HU15"
echo "  ✓ HU-15"

echo "Creando issues restantes..."
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