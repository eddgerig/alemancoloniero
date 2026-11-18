# Especificación de la API de Lecciones y Módulos (Frontend - Backend)

Documentación técnica de los datos requeridos por el Frontend en Flutter para renderizar dinámicamente las lecciones y actividades de cada módulo.

---

## Endpoint Principal
`GET /api/modulos/{id}/lecciones/`

---

## 1. Estructura General del JSON de Respuesta

```json
{
  "modulo_id": 2,
  "modulo_titulo": "MÓDULO 2 · Z'OOWA KAFFE",
  "total_lecciones": 8,
  "estadisticas_cierre": {
    "palabras_trabajadas": 34,
    "lecciones_completadas": 5,
    "siguiente_modulo": "Módulo 3: Famili"
  },
  "hablante_desbloqueable": {
    "nombre": "Yolanda Fher",
    "foto": "http://77.112.240.202/media/hablantes/yolanda.jpg",
    "relato_id": 101
  },
  "lecciones": [ ... ]
}
```

---

## 2. Tipos de Actividades (`tipo`) para el Array `lecciones`

### Tipo 1: `selectImageGrid` *(Cuadrícula 2x2 de Imágenes)*
El usuario escucha el audio y selecciona 1 de las 4 imágenes.

```json
{
  "id": 1,
  "orden": 1,
  "tipo": "selectImageGrid",
  "pregunta_titulo": "Selecciona la imagen correcta",
  "pregunta_subtitulo": "escucha el audio y selecciona la opción correcta",
  "audio_url": "https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4",
  "voz_hablante": "Yolanda Fehr",
  "respuesta_correcta": "Pan",
  "opciones": [
    { "id": 1, "titulo": "Pan", "imagen_url": "http://77.112.240.202/media/pan.png" },
    { "id": 2, "titulo": "Café", "imagen_url": "http://77.112.240.202/media/cafe.png" },
    { "id": 3, "titulo": "Queso", "imagen_url": "http://77.112.240.202/media/queso.png" },
    { "id": 4, "titulo": "Leche", "imagen_url": "http://77.112.240.202/media/leche.png" }
  ]
}
```

---

### Tipo 2: `swipeCard` *(Mazo de Tarjetas Deslizables)*
El usuario escucha el audio y desliza la tarjeta a la izquierda (✔️) o derecha (❌).

```json
{
  "id": 2,
  "orden": 2,
  "tipo": "swipeCard",
  "pregunta_titulo": "Desliza la imagen hacia el lado correcto",
  "pregunta_subtitulo": "escucha el audio y desliza la imagen",
  "voz_hablante": "Hans Ruh",
  "mazo_tarjetas": [
    { "id": 101, "titulo": "Pan", "imagen_url": "http://77.112.240.202/media/pan.png", "audio_url": "https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4", "es_correcto": true },
    { "id": 102, "titulo": "Café", "imagen_url": "http://77.112.240.202/media/cafe.png", "audio_url": "https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4", "es_correcto": false },
    { "id": 103, "titulo": "Queso", "imagen_url": "http://77.112.240.202/media/queso.png", "audio_url": "https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4", "es_correcto": false },
    { "id": 104, "titulo": "Leche", "imagen_url": "http://77.112.240.202/media/leche.png", "audio_url": "https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4", "es_correcto": true }
  ]
}
```

---

### Tipo 3: `selectTextOption` *(Imagen Prominente + 4 Opciones de Texto)*
Muestra una imagen arriba y 4 botones de texto apilados abajo.

```json
{
  "id": 3,
  "orden": 3,
  "tipo": "selectTextOption",
  "pregunta_titulo": "Selecciona la opción correcta",
  "pregunta_subtitulo": "escucha el audio y selecciona la opción correcta",
  "imagen_url": "http://77.112.240.202/media/pan.png",
  "respuesta_correcta": "Brot",
  "opciones_texto": ["Milich", "Kaffe", "Brot", "Schisili"]
}
```

---

### Tipo 4: `pausaCognitiva` *(Pantalla de Logro Intermedia)*
Pantalla de descanso motivacional.

```json
{
  "id": 4,
  "orden": 4,
  "tipo": "pausaCognitiva",
  "palabras_reconocidas_conteo": 5,
  "mensaje_titulo": "¡Ya reconoces 5 palabras nuevas!",
  "mensaje_subtitulo": "Ahora vamos a escribirlas"
}
```

---

### Tipo 5: `fillInBlank` *(Escritura: Completar Espacio en Blanco)*
El usuario selecciona una ficha de palabra para completar la línea en la oración.

```json
{
  "id": 5,
  "orden": 5,
  "tipo": "fillInBlank",
  "pregunta_titulo": "Selecciona la opción correcta",
  "pregunta_subtitulo": "escucha el audio y selecciona la palabra correcta",
  "audio_url": "https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4",
  "voz_hablante": "Yolanda Fehr",
  "oracion_sufijo": "Brot mit kaffe",
  "respuesta_correcta": "Tes",
  "oracion_completa_correcta": "Tes Brot mit kaffe",
  "fichas_opciones": ["Tes", "Tr", "T"]
}
```

---

### Tipo 6: `orderLetters` *(Escritura: Seleccionar y Ordenar Letras)*
Muestra la imagen y casillas superiores sobre la línea. El usuario toca las letras del teclado para formar la palabra.

```json
{
  "id": 6,
  "orden": 6,
  "tipo": "orderLetters",
  "pregunta_titulo": "Seleccione y ordene las letras",
  "pregunta_subtitulo": "Selecciona las letras correctas para formar la palabra",
  "imagen_url": "http://77.112.240.202/media/pan.png",
  "palabra_objetivo": "BROT",
  "letras_disponibles": ["O", "T", "P", "R", "A", "B", "S", "U"]
}
```

---

### Tipo 7: `translateAssembleSentence` *(Escritura: Armar Oración traducida)*
Burbuja de diálogo con audio en Alemán Coloniero y banco de fichas de palabras en Español.

```json
{
  "id": 7,
  "orden": 7,
  "tipo": "translateAssembleSentence",
  "pregunta_titulo": "Selecciona las opciones correctas",
  "pregunta_subtitulo": "escucha el audio y selecciona la opción correcta",
  "burbuja_texto_aleman": "Tes brot mit kaffe",
  "audio_url": "https://res.cloudinary.com/dsefkkkp/video/upload/v1794357254/gct_zoba_kaffe.mp4",
  "voz_hablante": "Yolanda Fehr",
  "respuesta_correcta_espanol": "el pan con café",
  "banco_palabras": ["pan", "café", "con", "el", "azúcar", "la"]
}
```

---

### Tipo 8: `matchAudioImage` *(Emparejar Audios con Imágenes)*
4 reproductores de audio a la izquierda y 4 imágenes a la derecha divididas por la línea punteada.

```json
{
  "id": 8,
  "orden": 8,
  "tipo": "matchAudioImage",
  "pregunta_titulo": "Selecciona la imagen correcta",
  "pregunta_subtitulo": "escucha el audio y selecciona la imagen correcta",
  "parejas": [
    { "audio_id": 1, "audio_url": "...", "voz": "Yolanda Fehr", "imagen_url": "http://77.112.240.202/media/cafe.png", "palabra": "Café" },
    { "audio_id": 2, "audio_url": "...", "voz": "Haidy Collin", "imagen_url": "http://77.112.240.202/media/leche.png", "palabra": "Leche" },
    { "audio_id": 3, "audio_url": "...", "voz": "Simon Rudmann", "imagen_url": "http://77.112.240.202/media/pan.png", "palabra": "Pan" },
    { "audio_id": 4, "audio_url": "...", "voz": "Yolanda Fehr", "imagen_url": "http://77.112.240.202/media/queso.png", "palabra": "Queso" }
  ]
}
```

---

## 3. Puntos Clave para el Backend
1. **`tipo`**: Determina la plantilla/widget interactivo que renderiza el frontend.
2. **URLs Completas**: Todas las URLs de imágenes y audios deben ser completas (`http://...` o `https://...`).
3. **Respuestas Correctas**: El campo `respuesta_correcta` es utilizado por el cliente para validar si la interacción del usuario despliega el panel modal de **Correcto** o **Incorrecto**.
