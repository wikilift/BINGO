# ENGLISH

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/wikilift)

# 🎲 Wikilift Bingo

This project is a **complete Bingo suite** developed from the ground up by [wikilift](https://github.com/wikilift).
The code is available under an open license: you can use, modify, and share it **as long as you credit the author**.
⚠️ **Commercial use is not permitted without the author's explicit permission.**

---

## ✨ Main Features

- 🎤 **Customizable Texts**: Change all the phrases in the game.
- 🗣️ **TTS Voice Selector**: Choose from the voices available on your system.
- 👨‍👩‍👧 **Family Mode**: Add traditional nicknames to numbers and random extra phrases.
- 🎬 **Configurable Events**: Start phrases, end of game, line, bingo, errors, and more.
- 🎨 **Responsive Interface**: Clear controls and clean design.

---

## 🧭 App Menus

The app includes a very simple and intuitive control panel:

- 🎮 **Main Controls**
- `Start Draw`: Start the drum.
- `Pause Draw`: Stop the current rhythm.
- `Draw One`: Manually extract a ball.
- `Restart Game`: Start over with an empty drum.

- 💰 **Prize Management**
- `Call Line`: Mark a valid line and distribute a prize.
- `Call Bingo`: Mark a valid bingo and distribute the jackpot.
- `Line Collected` / `Bingo Collected`: Confirmation after paying.

- 📊 **Game Information**
- `Last Number`: Most recent ball drawn.
- `Number of Players`: Participants in the game.
- `Card Price`: Unit cost.
- `Line Prize` and `Bingo Prize`: Automatic calculation based on the jackpot.
- `Total Jackpot`: Total accumulated revenue.

- ⚙️ **Settings**
- `Save Language Template`: Exports the current JSON.
- `Import`: Upload a JSON with phrases, nicknames, or your own text.
- Confirmation and error messages when saving/loading.

---

## 🚀 How to Customize

1. In the app, open the **Template** menu and save the settings.

2. Edit the JSON file to your liking (you can add phrases, nicknames, text, etc.).

3. Import the JSON back into the app from **Settings → Import**.

4. Your bingo is now customized!

---

## 📂 Configuration File (JSON)

Bingo behavior is customized using a JSON file.

## JSON Structure:

### 1. `chance_phrases`
Percentage (between 0 and 1) indicating the probability that the system will use an alternative phrase instead of the default.

```json
"chance_phrases": 0.20
```

In this example, there is a **20% chance** that a random phrase will be chosen from the list.

---

### 2. `phrases`
Collection of phrases for different moments in the game:

- `start`: Said at the start of the game.
- `end`: Used at the end of the game.
- `line`: What is announced when someone calls a line.
- `bingo`: Celebratory phrases when calling bingo.
- `denied_line`: Messages if someone tries to call a line too early.
- `denied_bingo`: Messages if someone calls bingo too early.
- `plus`: Special phrases when reaching ball 15 (BALL PLUS).

Example:
```json
"phrases": {
"start": [
"Wikilift bingo is starting, be prepared!",
"The game is starting, watch the cards."
],
"line": [
"Line! Let's check the card.",
"We have a line, attention at the table."
]
}
```

---

### 3. `nicknames`
Nicknames for each ball (1 to 90).
These names will be announced next to the number, following the tradition of Spanish bingo.

Example:
```json
"nicknames": {
"1": "the rooster",
"2": "the duckling",
"3": "the sailor",
...
}
```

---

### 4. `strings`
Interface text and fixed messages, such as buttons, errors, or game information.

Example:
```json
"strings": {
"start": "Start draw",
"pause": "Pause draw",
"pay_bingo": "Call bingo",
"paied_bingo": "Bingo paid"
}
```

---

## 🔧 Customization

1. From the app itself, download the configuration JSON file by clicking **Template**.
2. Change the phrases, nicknames, or text to your liking.
3. Save the file and upload it to the app using the **Import template** option.
4. The app will automatically apply the new settings.

---

## 🧩 Tips

- Maintain the JSON structure (braces, quotes, and commas).
- You can add or remove phrases within each list, as long as you respect the format.
- Adjust `chance_phrases` to provide more or less variety in your ads.
- If something fails to load, check that the file is a **valid JSON**.

---

## 🎉 Quick Example

```json
{
"chance_phrases": 0.3,
"phrases": {
"start": ["Let the drum roll!"],
"end": ["Bingo's over, see you soon!"]
},
"nicknames": {
"90": "Grandpa"
},
"strings": {
"start": "Start",
"pause": "Pause"
}
}
```

With this JSON, bingo will use shorter phrases and continue to run smoothly.

---

## 📜 License

This software is **open source with attribution**.
You may:
- Use, share, and modify it freely.
- Include in your own projects **as long as you cite [wikilift](https://github.com/wikilift)**.

You may not:
- Use it for commercial purposes without the author's prior written permission.

---

## 👤 Author

Lovingly created by **wikilift**
🔗 [GitHub](https://github.com/wikilift)

---



# ESPAÑOL

# 🎲 Bingo Wikilift

Este proyecto es una **suite de Bingo completa** desarrollada desde cero por [wikilift](https://github.com/wikilift).  
El código está disponible bajo licencia abierta: puedes usarlo, modificarlo y compartirlo **siempre que cites al autor**.  
⚠️ **No está permitido el uso comercial sin el permiso explícito del autor.**

---

## ✨ Características principales

- 🎤 **Textos personalizables**: cambia todas las frases del juego.  
- 🗣️ **Selector de voz TTS**: elige entre las voces disponibles en tu sistema.  
- 👨‍👩‍👧 **Modo familiar**: añade motes tradicionales a los números y frases extras aleatorias.  
- 🎬 **Eventos configurables**: frases de inicio, fin de partida, línea, bingo, errores y más.  
- 🎨 **Interfaz adaptable**: controles claros y diseño limpio.

---


## 🧭 Menús de la aplicación

La app incluye un panel de control muy sencillo e intuitivo:

- 🎮 **Controles principales**  
  - `Iniciar sorteo`: Comienza el bombo.  
  - `Pausar sorteo`: Detiene el ritmo actual.  
  - `Sacar uno`: Extrae una bola manualmente.  
  - `Reiniciar juego`: Vuelve a empezar con un bombo vacío.

- 💰 **Gestión de premios**  
  - `Cantar línea`: Marca una línea válida y reparte premio.  
  - `Cantar bingo`: Marca un bingo válido y reparte el bote.  
  - `Línea cobrada` / `Bingo cobrado`: Confirmación tras pagar.  

- 📊 **Información de partida**  
  - `Último número`: Bola extraída más reciente.  
  - `Nº de jugadores`: Participantes en la partida.  
  - `Precio del cartón`: Coste unitario.  
  - `Premio Línea` y `Premio Bingo`: Cálculo automático según bote.  
  - `Bote total`: Recaudación total acumulada.

- ⚙️ **Configuración**  
  - `Guardar plantilla idiomas`: Exporta el JSON actual.  
  - `Importar`: Carga un JSON con frases, apodos o textos propios.  
  - Mensajes de confirmación y error al guardar/cargar.

---

## 🚀 Cómo personalizar

1. En la app, abre el menú **Plantilla** y guarda la configuración.  
2. Edita el archivo JSON a tu gusto (puedes añadir frases, apodos, textos...).  
3. Importa de nuevo el JSON en la app desde **Configuración → Importar**.  
4. ¡Tu bingo ya estará personalizado!

---


## 📂 Archivo de configuración (JSON)

El comportamiento del bingo se personaliza mediante un archivo JSON.  


## Estructura del JSON:

### 1. `chance_phrases`
Porcentaje (entre 0 y 1) que indica la probabilidad de que el sistema utilice una frase alternativa en lugar de la predeterminada.

```json
"chance_phrases": 0.20
```

En este ejemplo, hay un **20% de probabilidad** de que se escoja una frase aleatoria de la lista.

---

### 2. `phrases`
Colección de frases para distintos momentos del juego:

- `start`: Se dicen al comenzar la partida.  
- `end`: Se usan al terminar la partida.  
- `line`: Lo que se anuncia cuando alguien canta línea.  
- `bingo`: Frases de celebración al cantar bingo.  
- `denied_line`: Mensajes si alguien intenta cantar línea antes de tiempo.  
- `denied_bingo`: Mensajes si alguien canta bingo demasiado pronto.  
- `plus`: Frases especiales al llegar a la bola 15 (BOLA PLUS).

Ejemplo:
```json
"phrases": {
  "start": [
    "¡Arranca el bingo Wikilift, prevenidos!",
    "Comienza la partida, ojos a los cartones."
  ],
  "line": [
    "¡Línea! Verifiquemos el cartón.",
    "Tenemos línea, atención en mesa."
  ]
}
```

---

### 3. `nicknames`
Apodos para cada bola (1 a 90).  
Estos nombres se anunciarán junto al número, siguiendo la tradición del bingo español.

Ejemplo:
```json
"nicknames": {
  "1": "el gallo",
  "2": "el patito",
  "3": "el marinero",
  ...
}
```

---

### 4. `strings`
Textos de la interfaz y mensajes fijos, como botones, errores o información del juego.

Ejemplo:
```json
"strings": {
  "start": "Iniciar sorteo",
  "pause": "Pausar sorteo",
  "pay_bingo": "Cantar bingo",
  "paied_bingo": "Bingo cobrado"
}
```

---

## 🔧 Personalización

1. Desde la propia app descarga el archivo JSON de configuración apretando en **Plantilla**.
2. Cambia las frases, apodos o textos según tu gusto.
3. Guarda el archivo y cárgalo en la aplicación con la opción **Importar plantilla**.
4. La app aplicará automáticamente la nueva configuración.

---

## 🧩 Consejos

- Mantén la estructura del JSON (llaves, comillas y comas).
- Puedes añadir o quitar frases dentro de cada lista, siempre que respetes el formato.
- Ajusta `chance_phrases` para dar más o menos variedad en los anuncios.
- Si algo falla al cargar, revisa que el archivo sea un **JSON válido**.

---

## 🎉 Ejemplo rápido

```json
{
  "chance_phrases": 0.3,
  "phrases": {
    "start": ["¡Que ruede el bombo!"],
    "end": ["El bingo se despide, ¡hasta pronto!"]
  },
  "nicknames": {
    "90": "el abuelo"
  },
  "strings": {
    "start": "Iniciar",
    "pause": "Pausar"
  }
}
```

Con este JSON, el bingo usará frases más cortas y seguirá funcionando sin problema.


---

## 📜 Licencia

Este software es de **código abierto con atribución**.  
Puedes:  
- Usarlo, compartirlo y modificarlo libremente.  
- Incluirlo en tus propios proyectos **siempre que cites a [wikilift](https://github.com/wikilift)**.  

No puedes:  
- Usarlo con fines comerciales sin el permiso previo y por escrito del autor.  

---

## 👤 Autor

Creado con cariño por **wikilift**  
🔗 [GitHub](https://github.com/wikilift)  

---
