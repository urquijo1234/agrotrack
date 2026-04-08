const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const PDFDocument = require("pdfkit");

admin.initializeApp();

const db = admin.firestore();

// ============================================================
// CLOUD FUNCTION: Se dispara cuando un informe cambia a EMITIDO
// ============================================================
exports.generarInformePdf = onDocumentUpdated(
  {
    document: "informesFitosanitarios/{informeId}",
    region: "us-central1",
    database: "(default)",
  },
  async (event) => {
    const antes = event.data.before.data();
    const despues = event.data.after.data();
    const informeId = event.params.informeId;

    // Solo actuar cuando el estado cambia a EMITIDO
    if (
      antes.estadoInforme === despues.estadoInforme ||
      despues.estadoInforme !== "EMITIDO"
    ) {
      return null;
    }

    console.log(`Generando PDF para informe: ${informeId}`);

    try {
      const bucket = admin.storage().bucket();

      // 1. Cargar subcolecciones
      const [registrosSnap, checklistSnap] = await Promise.all([
        db
          .collection("informesFitosanitarios")
          .doc(informeId)
          .collection("registrosEspecie")
          .get(),
        db
          .collection("informesFitosanitarios")
          .doc(informeId)
          .collection("checklistRespuestas")
          .orderBy("numeroItem")
          .get(),
      ]);

      const registros = registrosSnap.docs.map((d) => d.data());
      const respuestas = checklistSnap.docs.map((d) => d.data());

      // 2. Generar PDF en memoria
      const pdfBuffer = await generarPDF(despues, registros, respuestas);

      // 3. Subir PDF a Firebase Storage
      const filePath = `informes/${informeId}/informe.pdf`;
      const file = bucket.file(filePath);

      await file.save(pdfBuffer, {
        metadata: { contentType: "application/pdf" },
      });

      // 4. Hacer el archivo público
      await file.makePublic();

      // 5. Obtener URL pública
      // 5. Construir las dos URLs
const urlPdfDirecto = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
const urlPdf = `https://agrotrack-a435e.web.app/?id=${informeId}`;

// 6. Actualizar el informe con ambas URLs y estado EXPORTADO
await db
  .collection("informesFitosanitarios")
  .doc(informeId)
  .update({
    urlPdf: urlPdf,
    urlPdfDirecto: urlPdfDirecto,
    estadoInforme: "EXPORTADO",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

      console.log(`PDF generado exitosamente: ${urlPdf}`);
      return null;
    } catch (error) {
      console.error("Error generando PDF:", error);
      return null;
    }
  }
);

// ============================================================
// FUNCIÓN AUXILIAR: Genera el PDF y retorna un Buffer
// ============================================================
function generarPDF(informe, registros, respuestas) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50, size: "A4" });
    const buffers = [];

    doc.on("data", (chunk) => buffers.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(buffers)));
    doc.on("error", reject);

    const PRIMARY = "#2E7D32";
    const DARK = "#1F2937";
    const SOFT = "#6B7280";
    const LIGHT_BG = "#F4F7F2";
    const pageWidth = 515;

    // ==========================================
    // ENCABEZADO
    // ==========================================
    doc.rect(0, 0, 612, 100).fill(PRIMARY);

    doc
      .fillColor("white")
      .fontSize(20)
      .font("Helvetica-Bold")
      .text("INFORME FITOSANITARIO ICA", 50, 28, { align: "center" });

    doc
      .fillColor("white")
      .fontSize(11)
      .font("Helvetica")
      .text("Sistema de Trazabilidad AgroTrack", 50, 54, {
        align: "center",
      });

    doc
      .fillColor("white")
      .fontSize(10)
      .text(
        `Generado el ${new Date().toLocaleDateString("es-CO", {
          year: "numeric",
          month: "long",
          day: "numeric",
        })}`,
        50,
        72,
        { align: "center" }
      );

    doc.moveDown(4);

    // ==========================================
    // DATOS DEL PREDIO
    // ==========================================
    _seccionTitulo(doc, "I. DATOS DEL PREDIO", PRIMARY);

    const datosPredi = [
      ["Predio", informe.nombrePredioReportado],
      ["Titular", informe.nombreTitularReportado],
      [
        "Ubicación",
        `${informe.municipioReportado}, ${informe.departamentoReportado}`,
      ],
      ["Registro ICA", informe.numeroRegistroICA || "No registrado"],
      ["Especie principal", informe.especieVegetalReportada],
    ];

    _tablaSimple(doc, datosPredi, pageWidth, DARK, SOFT, LIGHT_BG);
    doc.moveDown(1);

    // ==========================================
    // PERIODO
    // ==========================================
    _seccionTitulo(doc, "II. PERIODO REPORTADO", PRIMARY);

    const datosperiodo = [
      ["Periodo", _labelPeriodo(informe.periodoReportado)],
      ["Año", `${informe.anioReporte}`],
      [
        "Fecha de emisión",
        informe.fechaEmision
          ? new Date(informe.fechaEmision).toLocaleDateString("es-CO")
          : "N/A",
      ],
    ];

    _tablaSimple(doc, datosperiodo, pageWidth, DARK, SOFT, LIGHT_BG);
    doc.moveDown(1);

    // ==========================================
    // REGISTROS DE ESPECIE
    // ==========================================
    _seccionTitulo(doc, "III. CULTIVOS REPORTADOS", PRIMARY);

    if (registros.length === 0) {
      doc
        .fillColor(SOFT)
        .fontSize(10)
        .font("Helvetica")
        .text("No se registraron cultivos.", { indent: 10 });
    } else {
      registros.forEach((r, index) => {
        if (doc.y > 680) doc.addPage();

        const yHeader = doc.y;
        doc.rect(50, yHeader, pageWidth, 22).fill(LIGHT_BG);

        doc
          .fillColor(PRIMARY)
          .fontSize(11)
          .font("Helvetica-Bold")
          .text(
            `Cultivo ${index + 1}: ${r.especieVegetal}`,
            60,
            yHeader + 4
          );

        doc.moveDown(0.8);

        const datosCultivo = [
          ["Variedad", r.variedad || "No especificada"],
          [
            "N° plantas/árboles",
            r.numeroPlantas ? `${r.numeroPlantas}` : "N/A",
          ],
          ["Fenología", r.fenologia || "N/A"],
          ["Estado fitosanitario", r.estadoFitosanitario || "N/A"],
          [
            "Producción estimada",
            r.produccionEstimada
              ? `${r.produccionEstimada} ${r.unidadProduccion || ""}`
              : "N/A",
          ],
          ["Frecuencia de monitoreo", r.frecuenciaMonitoreo || "N/A"],
          [
            "Fecha de siembra",
            r.fechaSiembra
              ? new Date(r.fechaSiembra).toLocaleDateString("es-CO")
              : "N/A",
          ],
        ];

        _tablaSimple(doc, datosCultivo, pageWidth, DARK, SOFT, LIGHT_BG);
        doc.moveDown(0.5);
      });
    }

    // ==========================================
    // CHECKLIST POR SECCIONES
    // ==========================================
    const secciones = [
      { codigo: "V", titulo: "IV. ÁREAS E INSTALACIONES" },
      { codigo: "VI", titulo: "V. OBLIGACIONES DEL TITULAR (GENERALES)" },
      {
        codigo: "VII",
        titulo: "VI. OBLIGACIONES — CUMPLIMIENTO MANUAL TÉCNICO",
      },
      {
        codigo: "INFO",
        titulo: "VII. INFORMACIÓN DEL INFORME FITOSANITARIO",
      },
    ];

    secciones.forEach((seccion) => {
      const items = respuestas.filter((r) => r.seccion === seccion.codigo);
      if (items.length === 0) return;

      doc.addPage();
      _seccionTitulo(doc, seccion.titulo, PRIMARY);

      items.forEach((item) => {
        if (doc.y > 700) doc.addPage();

        const yInicio = doc.y;

        doc
          .fillColor(PRIMARY)
          .fontSize(9)
          .font("Helvetica-Bold")
          .text(`${item.numeroItem}.`, 50, yInicio, { width: 25 });

        let respuestaTexto = "";

        if (item.cumple !== null && item.cumple !== undefined) {
          respuestaTexto += `CUMPLE: ${item.cumple ? "SÍ" : "NO"}`;
        }
        if (item.estado) {
          respuestaTexto += `  |  ESTADO: ${item.estado}`;
        }
        if (
          item.senalizado !== null &&
          item.senalizado !== undefined
        ) {
          respuestaTexto += `  |  SEÑALIZADO: ${
            item.senalizado ? "SÍ" : "NO"
          }`;
        }
        if (item.observacion) {
          respuestaTexto += `\nObservación: ${item.observacion}`;
        }

        if (!respuestaTexto) respuestaTexto = "Sin respuesta";

        const colorRespuesta =
          item.cumple === true
            ? PRIMARY
            : item.cumple === false
            ? "#DC2626"
            : SOFT;

        doc
          .fillColor(colorRespuesta)
          .fontSize(9)
          .font("Helvetica")
          .text(respuestaTexto, 80, yInicio, {
            width: pageWidth - 30,
          });

        doc.moveDown(0.6);

        doc
          .strokeColor("#E5E7EB")
          .lineWidth(0.5)
          .moveTo(50, doc.y)
          .lineTo(562, doc.y)
          .stroke();

        doc.moveDown(0.3);
      });
    });

    // ==========================================
    // PIE DE PÁGINA
    // ==========================================
    doc.addPage();

    doc.rect(0, 700, 612, 142).fill(PRIMARY);

    doc
      .fillColor("white")
      .fontSize(10)
      .font("Helvetica")
      .text(
        "Este documento fue generado automáticamente por AgroTrack.",
        50,
        715,
        { align: "center" }
      );

    doc
      .fillColor("white")
      .fontSize(9)
      .text(
        `ID del informe: ${informe.informeId || "N/A"}`,
        50,
        732,
        { align: "center" }
      );

    doc
      .fillColor("white")
      .fontSize(9)
      .text(
        "Sistema de Trazabilidad Agrícola — UPB Bucaramanga — Grupo G7",
        50,
        749,
        { align: "center" }
      );

    doc.end();
  });
}

// ============================================================
// HELPERS
// ============================================================
function _seccionTitulo(doc, titulo, color) {
  if (doc.y > 700) doc.addPage();

  doc
    .fillColor(color)
    .fontSize(12)
    .font("Helvetica-Bold")
    .text(titulo);

  doc
    .strokeColor(color)
    .lineWidth(1.5)
    .moveTo(50, doc.y + 2)
    .lineTo(562, doc.y + 2)
    .stroke();

  doc.moveDown(0.8);
}

function _tablaSimple(doc, filas, pageWidth, dark, soft, lightBg) {
  filas.forEach((fila, i) => {
    if (doc.y > 700) doc.addPage();

    const y = doc.y;
    const bgColor = i % 2 === 0 ? "white" : lightBg;

    doc.rect(50, y, pageWidth, 18).fill(bgColor);

    doc
      .fillColor(soft)
      .fontSize(9)
      .font("Helvetica-Bold")
      .text(fila[0], 55, y + 4, { width: 140 });

    doc
      .fillColor(dark)
      .fontSize(9)
      .font("Helvetica")
      .text(fila[1] || "N/A", 200, y + 4, {
        width: pageWidth - 155,
      });

    doc.moveDown(0.55);
  });
}

function _labelPeriodo(periodo) {
  const map = {
    FEB_MAR_ABR: "Febrero - Marzo - Abril",
    MAY_JUN_JUL: "Mayo - Junio - Julio",
    AGO_SEP_OCT: "Agosto - Septiembre - Octubre",
    NOV_DIC_ENE: "Noviembre - Diciembre - Enero",
  };
  return map[periodo] || periodo;
}