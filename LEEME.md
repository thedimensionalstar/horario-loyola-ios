# Horario Loyola · app de iPhone

Proyecto de Capacitor listo para compilar en Codemagic. No necesitas Mac: el proyecto de Xcode (`ios/`) se crea en el Mac de Codemagic en cada compilación.

## Qué hay en la carpeta

| Ruta | Qué es |
|---|---|
| `www/index.html` | La app: horario, semana, calendario, tareas y avisos. |
| `src/native.js` | Conecta la app con el iPhone: avisos, barra de estado y almacenamiento. |
| `scripts/` | Preparan la web, crean el proyecto de Xcode y compilan el `.ipa`. |
| `resources/ios/` | Icono y pantalla de carga. |
| `codemagic.yaml` | Los dos flujos de compilación. |

## 1. Sube el proyecto a GitHub

1. Crea un repositorio nuevo, por ejemplo `horario-loyola-ios`. Puede ser **privado**.
2. Pulsa **uploading an existing file** y arrastra todo lo que hay dentro de esta carpeta.
3. Pulsa **Commit changes**.

## 2. Compila en Codemagic

1. Entra en [codemagic.io](https://codemagic.io) y regístrate con tu cuenta de GitHub.
2. Pulsa **Add application**, elige GitHub y el repositorio. Si te pregunta el tipo de proyecto, elige la opción que usa `codemagic.yaml` (por ejemplo, **Ionic Capacitor App**).
3. Pulsa **Start new build** y elige el flujo **iPhone · IPA sin firmar**.
4. Tarda unos 10–15 minutos. Al terminar, descarga `HorarioLoyola-sin-firmar.ipa` en **Artifacts**.

Si la compilación falla, descarga el registro (`xcodebuild_logs`) y pásaselo a Claude.

## 3. Instálala en tu iPhone gratis

Con **Sideloadly** ([sideloadly.io](https://sideloadly.io)), en Windows:

1. Instala iTunes e iCloud **desde la web de Apple** (no las versiones de Microsoft Store). Sideloadly las necesita.
2. Conecta el iPhone por cable, abre Sideloadly, arrastra el `.ipa`, escribe tu Apple ID y pulsa **Start**.
3. En el iPhone, ve a **Ajustes › General › VPN y gestión de dispositivos** y confía en tu Apple ID.
4. Activa **Ajustes › Privacidad y seguridad › Modo de desarrollador** y reinicia el iPhone.

Con un Apple ID gratuito la app caduca a los 7 días. Para renovarla, repite el paso 2 instalándola encima, sin borrar la anterior, y conservarás tus tareas. **AltStore** ([altstore.io](https://altstore.io)) puede renovarla solo por wifi si tienes AltServer abierto en el PC.

## 4. Con cuenta de desarrollador de Apple (99 $/año)

Así se instala con TestFlight y dura 90 días por versión.

1. En App Store Connect, crea la app con el identificador `com.thedimensionalstar.horarioloyola`.
2. En Codemagic, ve a **Settings › Integrations › Developer Portal** y añade una clave de API de App Store Connect con el nombre **Horario Loyola**.
3. Lanza el flujo **iPhone · TestFlight** e instala la app desde TestFlight en el iPhone.

Si Codemagic se queja de la integración mientras no tengas la cuenta, borra el bloque `ios-testflight` de `codemagic.yaml`.

## Avisos de clase

En la pestaña **Tareas › Avisos de clase** puedes activar un aviso 5, 10, 15 o 30 minutos antes de cada clase, con la hora y el aula. iOS solo deja programar un número limitado de avisos, así que la app programa las próximas 3 semanas cada vez que la abres. Ábrela de vez en cuando para que no se acaben.

## Widget de próxima clase

Mantén pulsada la pantalla de inicio, toca **Editar › Añadir widget**, busca **Horario** y elige el tamaño:

- **Pequeño:** la clase actual o la siguiente, con la hora, el aula y cuánto falta.
- **Mediano:** además, la clase de después.
- **Pantalla de bloqueo:** una versión de una línea o de tres líneas.

El widget no muestra tus tareas, solo las clases. Tiene en cuenta los festivos y los días de examen del calendario.

## Cambiar el horario

El horario está en dos sitios: en `www/index.html` (constante `SCHEDULE`) para la app y en `resources/ios/HorarioWidget/HorarioWidget.swift` (constante `HORARIO`) para el widget. Cambia los dos, súbelos a GitHub y vuelve a compilar.
