// Widget "Próxima clase" de Horario Loyola.
// Lleva su propia copia del horario: si cambia un aula, cámbiala aquí y en www/index.html.

import SwiftUI
import WidgetKit

// MARK: - Datos

struct Asignatura {
    let corto: String
    let color: Color
}

let ASIGNATURAS: [String: Asignatura] = [
    "alg": Asignatura(corto: "Algoritmos", color: Color(red: 0.30, green: 0.45, blue: 0.84)),
    "mat": Asignatura(corto: "Matemáticas I", color: Color(red: 0.56, green: 0.37, blue: 0.80)),
    "fis": Asignatura(corto: "Modelado Físico", color: Color(red: 0.18, green: 0.60, blue: 0.45)),
    "mod": Asignatura(corto: "Modelado 3D", color: Color(red: 0.82, green: 0.50, blue: 0.18)),
    "nar": Asignatura(corto: "Narrativa", color: Color(red: 0.82, green: 0.34, blue: 0.50)),
    "pro": Asignatura(corto: "POO", color: Color(red: 0.18, green: 0.58, blue: 0.71)),
]

struct Clase {
    let dia: Int        // 0 = lunes
    let inicio: Int     // minutos desde medianoche, hora de Madrid
    let fin: Int
    let asig: String
    let aula: String
    let edificio: String
}

let HORARIO: [Clase] = [
    Clase(dia: 0, inicio: 510, fin: 630, asig: "alg", aula: "C1.03", edificio: "Edificio Central"),
    Clase(dia: 0, inicio: 630, fin: 750, asig: "mat", aula: "D1.03", edificio: "Edificio D"),
    Clase(dia: 0, inicio: 750, fin: 870, asig: "fis", aula: "A1.13", edificio: "Edificio Central"),
    Clase(dia: 0, inicio: 1020, fin: 1140, asig: "pro", aula: "Inf. C1.09", edificio: "Edificio Central"),
    Clase(dia: 1, inicio: 900, fin: 1020, asig: "nar", aula: "E1.02", edificio: "Edificio E"),
    Clase(dia: 1, inicio: 1020, fin: 1140, asig: "pro", aula: "Inf. C1.09", edificio: "Edificio Central"),
    Clase(dia: 2, inicio: 750, fin: 870, asig: "mat", aula: "D1.03", edificio: "Edificio D"),
    Clase(dia: 2, inicio: 900, fin: 1020, asig: "fis", aula: "Inf. A-1.02", edificio: "Edificio Central"),
    Clase(dia: 2, inicio: 1020, fin: 1140, asig: "nar", aula: "A1.11", edificio: "Edificio Central"),
    Clase(dia: 3, inicio: 510, fin: 630, asig: "alg", aula: "C1.03", edificio: "Edificio Central"),
    Clase(dia: 3, inicio: 630, fin: 750, asig: "mod", aula: "A1.08", edificio: "Edificio Central"),
    Clase(dia: 3, inicio: 750, fin: 870, asig: "mod", aula: "A1.08", edificio: "Edificio Central"),
    Clase(dia: 4, inicio: 630, fin: 750, asig: "fis", aula: "A1.13", edificio: "Edificio Central"),
]

// Días sin clase (inicio, fin, nombre). Fechas en formato AAAA-MM-DD.
let FESTIVOS: [(String, String, String)] = [
    ("2026-10-12", "2026-10-12", "Fiesta Nacional"),
    ("2026-11-02", "2026-11-02", "Todos los Santos"),
    ("2026-12-07", "2026-12-07", "Día de la Constitución"),
    ("2026-12-08", "2026-12-08", "Inmaculada Concepción"),
    ("2026-12-23", "2027-01-06", "Vacaciones de Navidad"),
    ("2027-03-01", "2027-03-01", "Día de Andalucía"),
    ("2027-03-22", "2027-03-28", "Semana Santa"),
    ("2027-04-15", "2027-04-17", "Feria de Sevilla"),
    ("2027-05-01", "2027-05-01", "Día del Trabajo"),
    ("2027-05-27", "2027-05-27", "Corpus Christi"),
    ("2027-08-16", "2027-08-16", "Festivo"),
]

let DIAS_DE_EXAMEN: Set<String> = [
    "2026-12-11", "2026-12-14", "2026-12-16", "2027-01-12", "2027-01-18", "2027-01-19",
    "2027-01-21", "2027-01-29", "2027-05-17", "2027-05-18", "2027-05-20", "2027-05-28",
    "2027-06-01", "2027-06-04", "2027-06-14", "2027-06-15", "2027-06-16", "2027-06-22",
    "2027-06-24", "2027-06-25",
]

// MARK: - Fechas (siempre en hora de Madrid)

let calendario: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Europe/Madrid") ?? .current
    c.locale = Locale(identifier: "es_ES")
    return c
}()

func clave(_ fecha: Date) -> String {
    let c = calendario.dateComponents([.year, .month, .day], from: fecha)
    return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
}

func diaSemana(_ fecha: Date) -> Int {
    (calendario.component(.weekday, from: fecha) + 5) % 7
}

func hora(_ minutos: Int) -> String {
    String(format: "%02d:%02d", minutos / 60, minutos % 60)
}

/// Devuelve por qué no hay clase ese día, o nil si es un día lectivo.
func motivoSinClase(_ k: String, _ ds: Int) -> String? {
    if DIAS_DE_EXAMEN.contains(k) { return "Día de examen" }
    if let f = FESTIVOS.first(where: { k >= $0.0 && k <= $0.1 }) { return f.2 }
    if k < "2026-09-07" || k > "2027-06-26" { return "Sin clases" }
    if (k > "2026-12-04" && k < "2027-02-01") || k > "2027-05-14" { return "Sin clases" }
    if ds > 4 { return "Fin de semana" }
    if k >= "2027-02-01" { return "Segundo cuatrimestre" }
    return nil
}

struct Sesion {
    let clase: Clase
    let inicio: Date
    let fin: Date
    var asignatura: Asignatura {
        ASIGNATURAS[clase.asig] ?? Asignatura(corto: clase.asig, color: .gray)
    }
}

/// Las próximas clases que aún no han terminado a partir de `ahora`.
func sesiones(desde ahora: Date, maximo: Int) -> [Sesion] {
    var resultado: [Sesion] = []
    let hoy = calendario.startOfDay(for: ahora)
    for desplazamiento in 0..<220 {
        guard let dia = calendario.date(byAdding: .day, value: desplazamiento, to: hoy) else { continue }
        let ds = diaSemana(dia)
        if motivoSinClase(clave(dia), ds) != nil { continue }
        for c in HORARIO where c.dia == ds {
            guard let inicio = calendario.date(byAdding: .minute, value: c.inicio, to: dia),
                  let fin = calendario.date(byAdding: .minute, value: c.fin, to: dia) else { continue }
            if fin > ahora {
                resultado.append(Sesion(clase: c, inicio: inicio, fin: fin))
                if resultado.count >= maximo { return resultado }
            }
        }
    }
    return resultado
}

func etiquetaDia(_ fecha: Date, desde ahora: Date) -> String {
    let n = calendario.dateComponents([.day], from: calendario.startOfDay(for: ahora), to: calendario.startOfDay(for: fecha)).day ?? 0
    if n == 0 { return "Hoy" }
    if n == 1 { return "Mañana" }
    let dias = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    return "\(dias[diaSemana(fecha)]) \(calendario.component(.day, from: fecha))"
}

// MARK: - Línea de tiempo

struct Entrada: TimelineEntry {
    let date: Date
    let sesiones: [Sesion]
    let hoySinClase: String?
}

func entrada(para fecha: Date) -> Entrada {
    Entrada(date: fecha, sesiones: sesiones(desde: fecha, maximo: 2), hoySinClase: motivoSinClase(clave(fecha), diaSemana(fecha)))
}

struct Proveedor: TimelineProvider {
    func placeholder(in context: Context) -> Entrada {
        entrada(para: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (Entrada) -> Void) {
        completion(entrada(para: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entrada>) -> Void) {
        let ahora = Date()
        var fechas: [Date] = [ahora]
        // Cambia al empezar y al terminar cada clase, y a medianoche (para "Hoy" / "Mañana").
        for s in sesiones(desde: ahora, maximo: 10) {
            if s.inicio > ahora { fechas.append(s.inicio) }
            fechas.append(s.fin)
        }
        let hoy = calendario.startOfDay(for: ahora)
        for n in 1...7 {
            if let medianoche = calendario.date(byAdding: .day, value: n, to: hoy) { fechas.append(medianoche) }
        }
        let ordenadas = Array(Set(fechas)).filter { $0 >= ahora }.sorted()
        completion(Timeline(entries: ordenadas.map { entrada(para: $0) }, policy: .atEnd))
    }
}

// MARK: - Vistas

let fondo = LinearGradient(
    colors: [Color(red: 0.17, green: 0.24, blue: 0.40), Color(red: 0.08, green: 0.11, blue: 0.20)],
    startPoint: .topLeading, endPoint: .bottomTrailing
)
let tenue = Color(red: 0.68, green: 0.73, blue: 0.82)
let rojo = Color(red: 0.93, green: 0.25, blue: 0.26)

struct Cuenta: View {
    let sesion: Sesion
    let ahora: Date

    var body: some View {
        if sesion.inicio <= ahora {
            Text("Termina en ") + Text(sesion.fin, style: .relative)
        } else if calendario.isDate(sesion.inicio, inSameDayAs: ahora) {
            Text("Empieza en ") + Text(sesion.inicio, style: .relative)
        } else {
            Text("\(etiquetaDia(sesion.inicio, desde: ahora)) · \(hora(sesion.clase.inicio))")
        }
    }
}

struct Etiqueta: View {
    let texto: String
    let punto: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(punto).frame(width: 7, height: 7)
            Text(texto).font(.system(size: 11, weight: .heavy)).tracking(0.8).foregroundStyle(tenue)
        }
    }
}

struct SinClases: View {
    let motivo: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Etiqueta(texto: "HORARIO", punto: tenue)
            Text(motivo ?? "Sin clases").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            Text("No quedan clases programadas.").font(.system(size: 12)).foregroundStyle(tenue)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct Pequeno: View {
    let sesion: Sesion
    let ahora: Date

    var body: some View {
        let enCurso = sesion.inicio <= ahora
        VStack(alignment: .leading, spacing: 3) {
            Etiqueta(texto: enCurso ? "AHORA" : "PRÓXIMA", punto: enCurso ? rojo : sesion.asignatura.color)
            Text(sesion.asignatura.corto)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text("\(hora(sesion.clase.inicio))–\(hora(sesion.clase.fin))")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
            Text("Aula \(sesion.clase.aula)")
                .font(.system(size: 12))
                .foregroundStyle(tenue)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 0)
            Cuenta(sesion: sesion, ahora: ahora)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(enCurso ? rojo : sesion.asignatura.color)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct Mediano: View {
    let entrada: Entrada

    var body: some View {
        if let actual = entrada.sesiones.first {
            HStack(alignment: .top, spacing: 14) {
                Pequeno(sesion: actual, ahora: entrada.date)
                Rectangle().fill(Color.white.opacity(0.14)).frame(width: 1)
                VStack(alignment: .leading, spacing: 3) {
                    Etiqueta(texto: "DESPUÉS", punto: entrada.sesiones.count > 1 ? entrada.sesiones[1].asignatura.color : tenue)
                    if entrada.sesiones.count > 1 {
                        let siguiente = entrada.sesiones[1]
                        Text(siguiente.asignatura.corto)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text("\(etiquetaDia(siguiente.inicio, desde: entrada.date)) · \(hora(siguiente.clase.inicio))")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white)
                        Text("Aula \(siguiente.clase.aula)")
                            .font(.system(size: 12))
                            .foregroundStyle(tenue)
                            .lineLimit(1)
                        Text(siguiente.clase.edificio)
                            .font(.system(size: 11))
                            .foregroundStyle(tenue)
                            .lineLimit(1)
                    } else {
                        Text("Sin más clases").font(.system(size: 13)).foregroundStyle(tenue)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        } else {
            SinClases(motivo: entrada.hoySinClase)
        }
    }
}

struct Rectangular: View {
    let entrada: Entrada

    var body: some View {
        if let s = entrada.sesiones.first {
            let cuando: String = s.inicio <= entrada.date
                ? "Ahora · hasta \(hora(s.clase.fin))"
                : "\(etiquetaDia(s.inicio, desde: entrada.date)) · \(hora(s.clase.inicio))"
            VStack(alignment: .leading, spacing: 1) {
                Text(cuando)
                    .font(.system(size: 13, weight: .semibold))
                    .widgetAccentable()
                Text(s.asignatura.corto).font(.system(size: 15, weight: .bold)).lineLimit(1)
                Text("Aula \(s.clase.aula)").font(.system(size: 13)).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(entrada.hoySinClase ?? "Sin clases")
        }
    }
}

struct EnLinea: View {
    let entrada: Entrada

    var body: some View {
        if let s = entrada.sesiones.first {
            Text("\(hora(s.clase.inicio)) \(s.asignatura.corto) · \(s.clase.aula)")
        } else {
            Text("Sin clases")
        }
    }
}

struct VistaWidget: View {
    @Environment(\.widgetFamily) var familia
    let entrada: Entrada

    var esPantallaBloqueo: Bool {
        familia == .accessoryRectangular || familia == .accessoryInline
    }

    var body: some View {
        Group {
            switch familia {
            case .systemMedium:
                Mediano(entrada: entrada)
            case .accessoryRectangular:
                Rectangular(entrada: entrada)
            case .accessoryInline:
                EnLinea(entrada: entrada)
            default:
                if let s = entrada.sesiones.first {
                    Pequeno(sesion: s, ahora: entrada.date)
                } else {
                    SinClases(motivo: entrada.hoySinClase)
                }
            }
        }
        .containerBackground(for: .widget) {
            if esPantallaBloqueo { Color.clear } else { fondo }
        }
    }
}

// MARK: - Widget

struct ProximaClaseWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ProximaClase", provider: Proveedor()) { entrada in
            VistaWidget(entrada: entrada)
        }
        .configurationDisplayName("Próxima clase")
        .description("Tu próxima clase con la hora y el aula.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct HorarioWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProximaClaseWidget()
    }
}
