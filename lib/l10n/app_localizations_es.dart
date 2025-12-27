// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dashboardTitle => 'Asistente SignBot';

  @override
  String get dashboardSubtitle => 'Tu compañero de firma digital';

  @override
  String get dashboardPoweredBy => 'Potenciado por DocSecure';

  @override
  String get tabDrafting => 'Borradores';

  @override
  String get tabSigning => 'Firmando';

  @override
  String get tabArchiving => 'Archivado';

  @override
  String get cardSelfSignTitle => 'Auto-Firmar Documento';

  @override
  String get cardSelfSignSubtitle => 'Firma un documento para ti mismo';

  @override
  String get cardOneOnOneTitle => 'Firma 1-a-1';

  @override
  String get cardOneOnOneSubtitle => 'Enviar a una persona';

  @override
  String get cardMultiPartyTitle => 'Flujo Multipartes';

  @override
  String get cardMultiPartySubtitle => 'Firma secuencial para equipos';

  @override
  String get promptInputPlaceholder => 'Pídeme que redacte un contrato..';

  @override
  String get menuProfile => 'Perfil';

  @override
  String get menuToggleTheme => 'Cambiar Tema';

  @override
  String get menuLogOut => 'Cerrar Sesión';

  @override
  String get menuLanguage => 'Idioma';

  @override
  String get chatGreeting =>
      '¡Hola! Puedo ayudarte a crear una nueva solicitud de firma.';

  @override
  String get chatWelcomeBack =>
      '¡Bienvenido de nuevo! 👋 ¿Cómo puedo ayudarte hoy con tus documentos?';

  @override
  String chatResumeGreeting(String title) {
    return '¡Bienvenido de nuevo! He cargado el borrador para $title.';
  }

  @override
  String chatRequestType(String type) {
    return 'Necesito $type un nuevo contrato.';
  }

  @override
  String get chatUploadPrompt =>
      'Entendido. Vamos a firmarlo. Por favor sube el documento que quieres usar. Soporta PDF y DOCX.';

  @override
  String chatStartedRequest(String type) {
    return 'He iniciado una solicitud de **$type** para ti. Por favor sube el PDF que te gustaría usar.';
  }

  @override
  String get chatFileUploaded => 'Archivo subido';

  @override
  String get chatRecipientsPrompt =>
      '¡Genial! He preparado el documento. ¿Quién necesita firmarlo? Por favor añade sus detalles abajo.';

  @override
  String get chatManageRecipients =>
      'Por favor gestiona los destinatarios para esta solicitud.';

  @override
  String get chatRecipientsSet => 'Destinatarios listos.';

  @override
  String get chatSummaryPrompt =>
      'Perfecto. Aquí está el resumen de tu solicitud. Si todo se ve bien, puedes enviarla.';

  @override
  String get chatSendRequest => 'Enviar Solicitud';

  @override
  String chatLinkGenerated(String title) {
    return '¡Gran trabajo! He generado el enlace de firma para \'$title\'.';
  }

  @override
  String get chatSendErrorLink =>
      'Tu solicitud ha sido enviada, pero no pude generar un enlace.';

  @override
  String get errorLaunchUrl => 'No se pudo abrir el enlace de firma';

  @override
  String get uploadDocumentTitle => 'SUBIR DOCUMENTO';

  @override
  String get uploadBrowse => 'Tocar para buscar';

  @override
  String get uploadDrag => 'o arrastra aquí';

  @override
  String get btnNextStep => 'Siguiente Paso';

  @override
  String get sourceFiles => 'Archivos';

  @override
  String get sourceScan => 'Escanear';

  @override
  String get sourceDrive => 'Drive';

  @override
  String get recipientsTitle => 'DESTINATARIOS ACTUALES';

  @override
  String get recipientsAdded => 'Añadidos';

  @override
  String get recipientsEmpty => 'Aún no hay destinatarios.';

  @override
  String get recipientsAddNew => 'Añadir Nueva Persona';

  @override
  String get labelFullName => 'Nombre Completo';

  @override
  String get labelEmail => 'Correo Electrónico';

  @override
  String get btnAddToList => 'Añadir a la Lista';

  @override
  String get btnAddMyself => 'Añadirme a mí';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get errorInvalidRecipient => 'Introduce un nombre y correo válidos';

  @override
  String get errorFillAllFields => 'Por favor llena todos los campos';

  @override
  String get errorSelfSignCount =>
      'Auto-firma debe tener exactamente 1 firmante.';

  @override
  String get errorOneOnOneCount => '1-a-1 requiere exactamente 2 firmantes.';

  @override
  String get summaryTitle => 'Resumen del Borrador';

  @override
  String get summaryFile => 'Archivo';

  @override
  String get summaryRecipients => 'Destinatarios';

  @override
  String get summaryStatus => 'Estado';

  @override
  String get summarySignUrl => 'Enlace de Firma';

  @override
  String get btnSendForSigning => 'Enviar para firmar';

  @override
  String get btnEditFields => 'Editar Campos';

  @override
  String get btnAddFields => 'Añadir Campos';

  @override
  String get signingLinkTitle => 'LISTO PARA FIRMAR';

  @override
  String get signingLinkGenerated => 'Enlace de Firma Generado';

  @override
  String get signingLinkShare => 'Compartir este enlace con';

  @override
  String get btnCopyLink => 'Copiar Enlace';

  @override
  String get toastLinkCopied => 'Enlace copiado al portapapeles';

  @override
  String get btnSendEmail => 'Enviar por Email';

  @override
  String get btnCloseStartNew => 'Cerrar y Empezar Nuevo';

  @override
  String get flowCurrent => 'Flujo Actual';

  @override
  String get checkboxAmSigner => 'Soy uno de los firmantes';

  @override
  String get checkboxAutoFill => 'Auto-rellenar mis datos';

  @override
  String get checkboxLoading => 'Cargando perfil...';

  @override
  String get btnAddAnother => 'Añadir Otro Destinatario';

  @override
  String get btnNextPlaceFields => 'Siguiente: Colocar Campos';

  @override
  String get labelYourInfo => 'Tu Información';

  @override
  String labelRecipientN(int n) {
    return 'Destinatario $n';
  }
}
