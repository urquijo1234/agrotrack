# AgroTrack 🚜📱
**Plataforma Integral para la Gestión, Trazabilidad y Cumplimiento Fitosanitario Agrícola.**

AgroTrack es una solución móvil diseñada para digitalizar las operaciones en campo, facilitando la trazabilidad y el cumplimiento de normativas fitosanitarias (ICA) incluso en zonas sin conectividad.

---

## ✨ Funcionalidades Principales

### 🏗️ Gestión de Estructura Productiva
- **Administración de Predios:** Registro de fincas con datos legales y registro ICA.
- **Inventario de Lotes:** Control de áreas de cultivo, especies y variedades.

### 🚜 Núcleo Operativo (Trazabilidad)
- **Registro de Eventos:** Seguimiento de **Siembra, Aplicación de Insumos y Cosecha**.
- **Soporte Offline-First:** Persistencia local mediante **SQLite** para trabajo en campo sin internet.

### 📄 Módulo Documental
- **Informes ICA:** Checklist digital de cumplimiento trisemestral.
- **Generación de PDF:** Exportación vía Firebase Cloud Functions.
- **Validación QR:** Códigos únicos para verificación rápida.

---

## 🛠️ Stack Tecnológico

- **Frontend:** Flutter (Dart) - Arquitectura Limpia (Clean Architecture).
- **Backend:** Firebase (Auth, Firestore, Cloud Functions, Storage).
- **Base de Datos Local:** SQLite (sqflite).
- **CI/CD:** GitHub Actions (Análisis estático, Testing y Build automático).

---

## 🚀 Instalación y Uso

1. Ve a la sección de [Releases](https://github.com/tu-usuario/agrotrack/releases) y descarga el último APK.
2. Instala el archivo en tu dispositivo Android.
3. ¡Comienza a digitalizar tu producción!

---

## 🧪 Pruebas y Calidad
El proyecto cuenta con una suite de **47 pruebas unitarias y de integración** que garantizan la estabilidad de los flujos de autenticación e informes.
