import 'package:flutter/material.dart';
import 'nutri_calculator_service.dart';
import 'dart:math';

void main() {
  runApp(const NutriApp());
}

//Nueva paleta de colores
class AppColors {
  static const navy = Color(0xFF0E1A30);
  static const green = Color(0xFF34C77B);
  static const greenDark = Color(0xFF1FA866);
  static const yellowBg = Color(0xFFFCEEB5);
  static const purpleBg = Color(0xFFE6DDF7);
  static const purpleText = Color(0xFF8B5CF6);
  static const mintBg = Color(0xFFCFF3DD);
  static const blue = Color(0xFF3B82F6);
  static const textDark = Color(0xFF14171F);
  static const textGrey = Color(0xFF8A8F98);

  // La nueva paleta no trae fondo; conservo el anterior (casi blanco).
  static const background = Color(0xFFFCFBFF);
}

class NutriApp extends StatelessWidget {
  const NutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Healthy - Asistente de Nutrición', //Cambiar lo de "title"
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
          surface: AppColors.background,
          onSurface: AppColors.textDark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const NutriChatPage(),
    );
  }
}

/////////////////////////////////
///

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class NutriChatPage extends StatefulWidget {
  const NutriChatPage({super.key});

  @override
  State<NutriChatPage> createState() => _NutriChatPageState();
}

class _NutriChatPageState extends State<NutriChatPage> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  final NutriCalculatorService _calculatorService = NutriCalculatorService();
  bool isTyping = false;

  final List<ChatMessage> messages = [
    ChatMessage(
      text: '¡Hola! Soy Mr.Healthy, soy tu asistente personalizado. '
          'Puedo ayudarte con dudas sobre habitos saludables, ideas de '
          'comidas, hidratación. '
          '¿Sobre qué te gustaría saber?',
      isUser: false,
    ),
  ];

  final List<String> quickOptions = [
    '¿Cuánta agua debo tomar al día?',
    '¿Es mejor comer antes o después de entrenar?',
    'Ideas de snacks saludables para la tarde',
    'Calcular mi IMC',
  ];

  void sendMessage([String? predefinedText]) {
    final text = (predefinedText ?? messageController.text).trim();

    if (text.isEmpty || isTyping) return;

    messageController.clear();

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      isTyping = true;
    });

    scrollToBottom();
    final respuesta = _calculatorService.procesarMensaje(text);
    final response = respuesta.isNotEmpty ? respuesta : getNutriResponse(text);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      setState(() {
        messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
        isTyping = false;
      });

      scrollToBottom();
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
  // Servicio para cálculos de nutrición (IMC y GET)

  String getNutriResponse(String input) {
    final text = input.toLowerCase();
    const List<String> consejosHabitos = [
      '1. Bebe un vaso de agua al despertar y mantén una botella a la mano durante el día.',
      '2. Añade una porción de verdura o fruta a cada comida.',
      '3. Camina al menos 20-30 minutos al día; empieza con 10 si te cuesta.',
      '4. Duerme entre 7 y 9 horas y trata de acostarte a la misma hora.',
      '5. Come despacio y sin pantallas para notar cuándo ya estás satisfecho.',
      '6. Planea tus comidas de la semana y haz tu lista de compras con tiempo.',
      '7. Cambia un refresco o jugo azucarado al día por agua o agua con limón.',
      '8. Ten a la vista snacks saludables: fruta, nueces o yogur natural.',
      '9. Reduce poco a poco la sal y los ultraprocesados; lee las etiquetas.',
      '10. Cambia un solo hábito a la vez y repítelo 3-4 semanas hasta que sea automático.',
    ];

    if (_containsAny(text, [
      'mas habitos',
      'mas habito',
      //IA
      'mas habitos por favor',
      'dame mas habitos',
      'dame otra idea de habito',
      'dame otro habito saludable',
      'quiero mas ideas de habitos',
      'puedes recomendarme otro habito',
      'muestrame mas sugerencias de habitos',
      'que otro habito puedo probar',
    ])) {
      final consejo = consejosHabitos[Random().nextInt(consejosHabitos.length)];
      return '¡Claro! Aquí tienes otro hábito saludable:\n\n'
          '$consejo\n\n'
          'Si quieres, escribe nuevamente "más hábitos" para ver otro consejo.';
    }

    if (_containsAny(text, [
      'nuevo habito',
      'sugiere un habito',
      'sugerencia de un habito',
      'ejemplo de habito',
      'recomendacion de habito',
      'recomiendame un habito',
      'sugiereme un habito',
      'dame un habito saludable',
      'dame una idea de habito saludable',
      'recomiendame un habito saludable',
      'que habito saludable puedo empezar',
      'que habito me recomiendas',
      'sugiereme un habito para mejorar mi salud',
      'quiero comenzar un habito saludable',
      'proponme un habito saludable',
      'necesito una idea para un habito saludable',
      'dime un habito saludable', //Giovanni
      'sugiereme un habito saludable', //Giovanni
    ])) {
      final consejo = consejosHabitos[Random().nextInt(consejosHabitos.length)];
      return '¡Claro! Aquí tienes un hábito saludable para empezar:\n\n'
          '$consejo\n\n'
          'Escribe "más hábitos" si quieres ver los diez consejos.';
    }

    //mijo
    if (_containsAny(text, [
      'que pasa si no cumplo un habito diario',
      'que pasa si no completo los habitos diarios',
      'que pasa si no cumplo un habito diario?',
      'si no cumplo un habito diario que pasa??',
      'si no cumplo un habito diario que pasa?',
      'si no cumplo un habito diario que pasa',
      'si no cumplo los habitos diarios que pasa',
      'si no cumplo los habitos diarios que sucede?',
      'si no cumplo los habitos diarios que sucede??',
      'que pasa si no realizo un habito diario?',
      'que pasa si no realizo un habito diario??',
      'que pasa si no realizo un habito diario',
      //IA
      'que ocurre si no cumplo mis habitos',
      'que pasa si fallo un dia mi habito',
      'pierdo mi progreso si no hago un habito',
      'que sucede si no completo mi objetivo diario',
      'si hoy no hago mis habitos que pasa',
      'afecta si un dia no cumplo mi habito',
      'que pasa si dejo de hacer un habito por un dia',
    ])) {
      return 'Puedes pasar al siguiente objetivo diario  . '
          'solo pierdes XP que acumulas en totaldel habito o de los  . '
          'habitos que fallaste.';
    }

    // Respuesta de apoyo antes de la coincidencia general de desafíos.
    if (_containsAny(text, [
      'no puedo con el desafio',
      'no puedo con el reto',
      'no lo logro',
      'no puedo hacerlo',
      'es demasiado para mi',
      'me cuesta mucho',
      'me cuesta demasiado',
      'es muy pesado',
      'es muy complicado',
      'muy complicado',
      //IA
      'muy exigente',
      'quiero rendirme',
      'me quiero rendir',
      'no puedo terminar el desafio',
      'no logro completar el reto',
      'me resulta dificil el desafio',
      'el desafio es muy dificil',
      'quiero abandonar el reto',
      'no puedo seguir con este desafio',
      'me siento abrumado por el desafio',
    ])) {
      return 'Te sugiero ir a ajustes para cambiar la dificultad de tus '
          'desafíos. También puedes retirarte o cancelar el desafío.';
    }

    //mijo
    if (_containsAny(text, [
      '¿que son los desafios?',
      'que son los desafios?',
      'que son los desafios',
      'Qué son los desafios??',
      //IA
      'que significa un desafio en la aplicacion',
      'para que sirven los desafios',
      'como funcionan los desafios',
      'cual es el objetivo de los desafios',
      'que gano al completar un desafio',
      'desafios',
      'desafio',
    ])) {
      return 'Los desafíos son metas temporales que la aplicación te propone. '
          'Al completarlos, obtienes experiencia (XP) adicional.';
    }
    //mijo

    //mijo
    if (_containsAny(text, [
      '¿Dónde puedo registrar un habito?',
      'registrar un habito',
      'donde puedo registrar un habito?',
      'donde puedo registrar un habito??'
          'Donde puedo registrar un habito??',
      'como registro mis habitos',
       "donde registro un habito", //Giovanni
      "como registro un habito", //Giovanni
      "como se registra un habito", //Giovanni
      "donde se registra un habito", //Giovanni
      //IA
      'en que parte registro un habito',
      'donde marco que cumpli un habito',
      'como puedo completar mi habito diario',
      'donde agrego un nuevo habito',
      'como registro el cumplimiento de un habito',
    ])) {
      return 'En la parte de Tu mision de hoy. '
          'o en la seccion de habitos donde puedes. '
          'registrarlas.';
    }
    //mijo

    //mijo
    if (_containsAny(text, [
      '¿Donde cambio la contraseña y el correo electronico?',
      '¿donde cambio la contraseña y el correo electronico de mi cuenta?',
      '¿donde cambio la contraseña de mi cuenta?',
      '¿Donde cambio el correo electronico de mi cuenta?',
      'cambiar contraseña y correo electronico',
      'cambiar contraseña y correo electronico de mi cuenta',
      'cambiar contraseña de mi cuenta',
      'cambiar correo electronico de mi cuenta',
      'cambiar contraseña'
          'Cambiar contraseña',
      'cambiar correo electronico',
      'donde cambio la contraseña y el correo electronico??',
      'donde cambio la contraseña y el correo electronico de mi cuenta?',
      '¿Donde cambio la contraseña?',
      '¿Donde cambio el correo electronico?',
      'cambiar email y contraseña',
      'cambiar email y contraseña de mi cuenta',
      'cambiar email de mi cuenta',
      'Cambiar correo',
      '¿Donde cambio el correo de mi cuenta?',
      'cambiar el correo de mi cuenta',
      '¿donde cambio el email de mi cuenta?',
      'cambiar el email de mi cuenta',
      'cambiar la contraseña',
      'cambiar email',
       'como cambiar la contraseña', //giovanni
      'como cambiar el correo y la contraseña', //Giovanni
      'como cambiar la contraseña de mi cuenta', //Giovanni
      'como puedo cambiar el correo,' // Giovanni
          'donde cambio el correo', //Giovanni
      'donde cambiar el correo', //Giovanni
      'donde se cambia el correo', //Giovanni
      'como se cambia el correo', //Giovanni
      //IA
      'como actualizo mi correo y contrasena',
      'donde edito mis datos de perfil',
      'como modifico el correo de mi cuenta',
      'donde puedo actualizar mi contrasena',
      'quiero cambiar mis datos personales',
      'como cambio mi email desde el perfil',
    ])) {
      return 'En la parte de perfil en la parte. '
          'inferior derecha entra a configuracion. '
          'hay podras editar tus datos personales.';
    }
    //mijo

    if (_containsAny(text, [
      'explicar un habito',
      'Habito',
      'explica un habito',
      'explicar habito',
      'explica habito',
      'explicar un hábito saludable',
      'explica un hábito saludable',
      'explicar el habito',
      'explica el hábito',
      //IA
      'que significa tener un habito',
      'que es un habito saludable',
      'como se forma un habito saludable',
      'por que es importante crear habitos saludables',
      'explicame que es un habito',
      'como puedo entender mejor los habitos saludables',
      'que quiere decir habito',
    ])) {
      return 'Un hábito es una conducta que se repite casi sin pensarlo y que se vuelve automática con el tiempo. '
          'Por ejemplo, caminar 20 minutos al día o beber agua al despertar. '
          'Los hábitos saludables se fortalecen cuando los repites de forma constante, con una rutina clara y poco a poco. '
          'Eso hace que sea más fácil mantenerlos y que se conviertan en parte de tu estilo de vida.';
    }

    if (_containsAny(text, [
      'Experiencia',
      'xp',
      'Nivel',
      'subir de nivel',
      'como consigo experiencia',
      //IA
      'como acumulo xp',
      'como aumento mi experiencia',
      'que tengo que hacer para subir de nivel',
      'como desbloqueo el siguiente nivel',
      'como avanzo de nivel en la aplicacion',
      'como gano puntos de experiencia',
    ])) {
      return 'Ganas experiencia (XP) al registrar tus evidencias. '
          'fotograficas, al cumplir los desafios, . '
          'y para pasar el siguiente nivel necesitas'
          'completar el nivel al 100% y asi poder desbloquear el siguiente nivel, ';
    }

    if (_containsAny(text, [
      'Fotografía de alimentos',
      'fotografia',
      'Evidencias',
      'Fotografias',
      'Foto',
       'evidencia fotográfica', //Giovanni
      'evidencia fotografica', //Giovanni
      'evidencias fotograficas', //Giovanni
      'evidencias fotográficas', //Giovanni
      'como subo una evidencia fotografica',
      'para que sirven las evidencias',
      //IA
      'como envio evidencia de mis habitos',
      'cuando tengo que tomar una foto de evidencia',
      'las fotos de los desafios son obligatorias',
      'como se comprueba que complete un desafio',
      'donde agrego una foto de mi progreso',
    ])) {
      return 'La evidencias fotograficas funcionan por medio, '
          'de que avance la dificultad de los desafios, '
          'a apartir de la dificultad media hasta la alta,'
          'son de manera opcional que permite que se verifiquen'
          'si se estan cumpliendo los desafios, y que se pueda ver el progreso de la persona, ';
    }

    if (_containsAny(text, [
      'calorías',
      'cuántas calorías',
      'cuantas calorias necesito al dia',
      'calorías necesarias', //Giovanni
      'calorias necesarias', //Giovanni
      //IA
      'como calculo mis calorias diarias',
      'cual es mi requerimiento calorico',
      'cuanta energia necesito cada dia',
      'necesito saber cuantas calorias consumir',
      'como saber cuantas calorias debo comer',
    ])) {
      return 'Las calorías que necesitas varían según tu edad, sexo, '
          'peso y nivel de actividad. En lugar de contar cada '
          'caloría, enfócate en comer variado: verduras, frutas, '
          'proteínas, granos integrales y grasas saludables. Si '
          'quieres un cálculo personalizado, lo mejor es consultar '
          'con un nutriólogo.';
    }

    if (_containsAny(text, [
      'proteína',
      'alimentos con proteína',
      'alimentos proteicos', //Modificación. Añadir línea
      'comidas con proteina', //Modificación. Añadir línea
      'comidas proteicas', //Modificación. Añadir línea
      //IA
      'que puedo comer para obtener proteina',
      'cuales son buenas fuentes de proteina',
      'que alimentos tienen mucha proteina',
      'ideas de comidas altas en proteina',
      'como agrego mas proteina a mis comidas',
      'recomiendame alimentos con proteina',
    ])) {
      return 'Buenas fuentes de proteína: huevo, pollo, pescado, '
          'carne magra, frijoles, lentejas, garbanzos, tofu, yogur '
          'griego, queso, leche y frutos secos. Intenta incluir una '
          'porción en cada comida principal para sentirte '
          'satisfecho por más tiempo.';
    }

    if (_containsAny(text, [
      'Agua',
      '¿Cuanta agua debo tomar al día?',
      'Cuánta agua debo tomar al dia',
       'agua debo beber al día', //Giovanni
      'agua necesito tomar al día', // Giovanni
      'agua tengo que tomar día', // Giovanni
      'agua hay que tomar al día', //Giovanni
      'agua necesito beber al día', // Giovanni
      'agua tengo que beber al día', // Giovanni
      'agua hay que beber al día', //Giovanni

      'agua debo beber al dia', //Giovanni
      'agua necesito tomar al dia', // Giovanni
      'agua tengo que tomar al dia', // Giovanni
      'agua hay que tomar al dia', //Giovanni
      'agua necesito beber al dia', // Giovanni
      'agua tengo que beber al dia', // Giovanni
      'agua hay que beber al dia', //Giovanni
      'cual es la cantidad de agua recomendada',
      'como se cuanta agua debo beber',
      //IA
      'cuantos litros de agua debo tomar',
      'cuanta agua necesito diariamente',
      'recomiendame cuanta agua tomar al dia',
      'como mantenerme hidratado durante el dia',
    ])) {
      return 'Multiplica tu peso corporal por 35 mililitros. Por  '
          'ejemplo, si pesas 70 kg, necesitas unos 2.45 litros al día. ';
    }

    if (_containsAny(text, [
      'snack',
      'snacks',
      'colación',
      'entre comidas',
      'Botanas',
      'Antojos',
      'Antojitos',
      //IA
      'que puedo comer entre comidas',
      'dame ideas de colaciones saludables',
      'recomiendame algo saludable para picar',
      'que snack saludable puedo preparar',
      'opciones de botanas nutritivas',
      'ideas para una merienda saludable',
      'que comer cuando tengo antojo',
    ])) {
      return 'Ideas de snacks saludables: fruta fresca, yogur '
          'natural, un puñado de nueces o almendras, zanahoria o '
          'apio con hummus, palomitas caseras, huevo duro o un '
          'sándwich pequeño de pan integral. Lo importante es que '
          'combinen fibra y proteína para que te llenen.';
    }

    if (_containsAny(text, [
      'frutas',
      'Verduras',
      'Frutas y verduras',
      'Frutas y vegetables',
      'Vegetables',
      'porciones de fruta',
      'vegetales', //Modificación. Añadir línea
      'porcion de fruta', //Modificación. Añadir línea
      'frutas y vegetales', //Modificación. Añadir línea
      'porcion de verduras',
      'Porciones de frutas',
      'Porcion de frutas',
      'porciones de verduras',
      'Porciones de verdura',
      //IA
      'cuantas frutas y verduras debo comer',
      'como incluir mas verduras en mi alimentacion',
      'que frutas son buenas para comer',
      'ideas para comer mas vegetales',
      'cuantas porciones de vegetales se recomiendan',
      'como agregar frutas a mis comidas',
      'recomiendame frutas y verduras saludables',
    ])) {
      return 'Se recomienda comer al menos 5 porciones de frutas y '
          'verduras al día. Varía los colores: verde, rojo, naranja '
          'y morado. Puedes agregarlas al desayuno, como snack, en '
          'la comida o la cena. No tienen que ser aburridas, prueba '
          'nuevas preparaciones.';
    }

    if (_containsAny(text, [
      'retroalimentacion',
      'feedback', //Giovanni
      'Feedback' //Giovanni
      //IA
      'como recibo comentarios sobre mi progreso',
      'para que sirve la retroalimentacion de la aplicacion',
      'como funciona el seguimiento de mi progreso',
      'la aplicacion me da recomendaciones de habitos',
      'como obtengo sugerencias segun mis resultados',
      'donde veo comentarios sobre mis avances',
    ])) {
      return 'Permite analizar el progreso registrado, '
          'y generar sugerencias de habitos acordes, '
          'con los objetivos del usuario, ';
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Consultar la fecha desde el "bot"
    //giovanni
    if (_containsAny(text, [
      'que dia es',
      'qué día es',
      'que día es hoy',
      'qué dia es hoy',
      'que fecha es hoy',
      'qué fecha es hoy',
      'fecha de hoy',
      'fecha actual',
      'que hora es',
      'qué hora es',
      'hora actual',
      'dime la hora',
      'dime la fecha',
      'en que dia estamos',
      'en qué día estamos',
      'a cuanto estamos',
      'a cuánto estamos',
      'que dia de la semana',
      'qué día de la semana',
       'a qué estamos', //Giovanni
    ])) {
      final now = DateTime.now();

      const dias = [
        'lunes',
        'martes',
        'miércoles',
        'jueves',
        'viernes',
        'sábado',
        'domingo',
      ];
      const meses = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];

      final diaSemana =
          dias[now.weekday - 1]; // weekday: 1 = lunes ... 7 = domingo
      final mes = meses[now.month - 1];
      final hora = now.hour.toString().padLeft(2, '0');
      final minuto = now.minute.toString().padLeft(2, '0');

      return 'Hoy es $diaSemana ${now.day} de $mes de ${now.year}, '
          'y son las $hora:$minuto.';
    }

    // 1. Comidas pesadas

    if (_containsAny(text, [
      'comer antes de entrenar',
      'comida pesada antes de hacer ejercicio',
      'que no comer antes de entrenar',
      'alimentos a evitar antes del gym',
      'comida grasosa antes de ejercicio',
      'comer mucho antes de entrenar',
      'evitar fritos antes de entrenar',
      'comer antes de correr',
      'que no debo comer antes del ejercicio',
      'comida antes del gimnasio',
       'evitar comer antes de entrenar', //Giovanni
      'no debo comer antes de entrenar', //Giovanni
      'debo de evitar comer antes de entrenar', //Giovanni
      'debo dejar de comer antes de hacer ejercicio' //Giovanni
          'debo dejar de comer antes de entrenar' //Giovanni
    ])) {
      return 'Evita comidas pesadas, grasosas, fritas o muy abundantes 2 a 3 horas antes de entrenar. Pueden causar pesadez, náuseas y calambres. Mejor una comida ligera con carbohidratos y algo de proteína.';
    }

    if (text.contains('entren') &&
        _containsAny(text, ['antes', 'después', 'despues'])) {
      return 'Depende de la duración e intensidad del ejercicio y de '
          'cómo te sientas. Si vas a comer una comida completa antes '
          'de entrenar, intenta hacerlo entre 1 y 3 horas antes; si '
          'falta poco, elige algo ligero que te siente bien. Después '
          'de entrenar, procura incluir proteína y carbohidratos en '
          'tu siguiente comida; no es necesario comer '
          'inmediatamente. Mantente bien hidratado.';
    }

    //Nueva pregunta para alternativas sin aceite
    if (_containsAny(text, [
      'cocina sin aceite',
      'recetas sin aceite',
      'cocinar sin aceite',
      'alternativas al aceite para cocinar',
      'reemplazar el aceite',
      'sin aceite',
      'evitar aceite',
      'evitar el aceite',
      'alimentos sin aceite',
      'comidas sin aceite',
      'Cocina sin aceite',
      'Recetas sin aceite',
      'Cocinar sin aceite',
      'Alternativas al aceite para cocinar',
      'Remplazar el aceite',
      'Sin aceite',
      'Evitar aceite',
      'Evitar el aceite',
      'Alimentos sin aceite',
      'Comidas sin aceite',
    ])) {
      return 'Las técnicas de cocina sin aceite permiten preparar '
          'alimentos de forma más saludable, reduciendo el uso de grasas '
          'añadidas sin perder su sabor. Una de ellas es cocinar al vapor, '
          'ideal para verduras y pescado; otra es hornear, por ejemplo, '
          'papas o pollo. También se puede utilizar una freidora de aire, '
          'que cocina alimentos como papas fritas o alitas con poco o nada '
          'de aceite. Finalmente, está la cocción a la plancha antiadherente, '
          'que permite preparar huevos, carnes y verduras sin necesidad de '
          'añadir grasa.';
    }
    /////////////////////

    //Explicar un habito
    if (_containsAny(text, [
      'habito',
      'hábito',
      'Habito',
      'Hábito',
      'como funciona un habito',
      'como funciona un hábito',
      'como funciona un habito saludable',
      'como funciona un hábito saludable',
      'explica un habito',
      'explica un hábito',
      'de los hábitos',
      'sobre los hábitos',
      'de los habitos',
      'sobre los habitos',
      'Como funciona un habito',
      'Como funciona un hábito',
      'Como funciona un habito saludable',
      'Como funciona un hábito saludable',
      'Explica un habito',
      'Explica un hábito',
      'De los hábitos',
      'Sobre los hábitos',
      'sobre los habitos',
      'Como funciona un habito',
      'como funciona un hábito',
      'como funciona un habito saludable',
      'como funciona un hábito saludable',
      'explicar un habito',
      'explicar un hábito',
      'Explicar un hábito',
      'Explicar un habito',
    ])) {
      return 'Los hábitos saludables de alimentación y actividad física '
          'son fundamentales para mantener una buena salud y prevenir '
          'enfermedades. Una alimentación equilibrada incluye frutas, verduras, '
          'cereales, proteínas y suficiente agua, evitando el consumo excesivo '
          'de azúcar, grasas y comida chatarra. Además, realizar actividad física '
          'regularmente, como caminar, correr, bailar o practicar algún deporte, '
          'ayuda a fortalecer los músculos, mejorar la condición física y reducir '
          'el estrés';
    }

    //giovanni

    //Sugerencia en caso de que al usuario se le haga dificil
    //un desafío
    if (_containsAny(text, [
      'no puedo con el desafio',
      'no puedo con el desafío',
      'no puedo con el reto',
      'no lo logro',
      'no puedo hacerlo',
      'es demasiado para mi',
      'es demasiado para mí',
      'me cuesta mucho',
      'me cuesta demasiado',
      'es muy pesado',
      'es muy complicado',
      'muy complicado',
      'muy exigente',
      'quiero rendirme',
      'me quiero rendir',
    ])) {
      return 'Te sugiero ir a ajustes para cambiar la dificultad de tus '
          'desafíos, también puedes retirarte o cancelar el desafío.';
    }

    //Fuentes de Grasas Saludables
    if (_containsAny(text, [
      'grasas saludables',
      'grasa saludable',
      'grasas buenas',
      'grasa buena',
      'fuentes de grasa',
      'fuentes de grasas',
      'alimentos con grasa saludable',
      'alimentos con grasas saludables',
      'que grasas puedo comer',
      'qué grasas puedo comer',
      'grasas sanas',
      'aceite saludable',
      'aceites saludables',
       'grasas sanas', //Giovanni
      'aceites buenos', //Giovanni
      'aceites sanos', //Giovanni
      'grasa sana', //Giovanni
      'aceite sano', //Giovanni
      'aceite bueno', //Giovanni
    ])) {
      return 'Algunas fuentes de grasas saludables son:\n\n'
          '• Aguacate\n'
          '• Aceite de oliva extra virgen\n'
          '• Nueces, almendras, cacahuates y pistaches\n'
          '• Semillas de chía, linaza y calabaza\n'
          '• Pescados grasos: salmón, sardina, atún y caballa\n'
          '• Aceitunas\n'
          '• Huevo\n\n'
          'Consúmelas con moderación: aunque son saludables, aportan '
          'muchas calorías. Una porción pequeña al día es suficiente.';
    }

// 2. Alcohol
    if (_containsAny(text, [
      'alcohol antes de entrenar',
      'beber antes de hacer ejercicio',
      'cerveza antes del gym',
      'tomar alcohol y entrenar',
      'resaca y ejercicio',
      'entrenar con resaca',
      'alcohol y rendimiento',
      'evitar alcohol antes de ejercicio',
      'bebidas alcoholicas y deporte',
      'puedo entrenar despues de tomar',
      'tomar antes del ejercicio', //Giovanni
      'tomar antes de hacer ejercicio' //Giovanni
          'beber antes de hacer ejercicio' //Giovanni
          'beber antes del ejercicio' //Giovanni

          'tomar antes del entrenamiento', //Giovanni
      'tomar antes de entrenar' //Giovanni
          'beber antes de entrenar' //Giovanni
          'beber antes del entrenamiento' //Giovanni
    ])) {
      return 'Evita el alcohol antes de entrenar (y la noche anterior). Deshidrata, reduce la coordinación, la fuerza y los reflejos, y aumenta el riesgo de lesiones.';
    }

// 3. Exceso de cafeína
    if (_containsAny(text, [
      'cafe antes de entrenar',
      'cafeina antes del ejercicio',
      'bebidas energeticas antes de entrenar',
      'exceso de cafeina gym',
      'pre entreno demasiado',
      'preworkout riesgos',
      'energizantes y ejercicio',
      'cuanta cafeina antes de entrenar',
      'taquicardia por pre entreno',
      'redbull antes de entrenar',
       'exceso de preentreno', //Giovanni
      'demasiado preentreno', //Giovanni
      'cafe antes de hacer ejercicio', //Giovanni
      'demasiada cafeina antes de entrenar', //Giovanni
      'mucha cafeina antes de entrenar', //Giovanni
    ])) {
      return 'Evita el exceso de cafeína y las bebidas energéticas. Demasiada puede causar taquicardia, temblores, ansiedad y malestar estomacal. Si la usas, que sea en dosis moderadas.';
    }

// 4. Llegar deshidratado
    if (_containsAny(text, [
      'agua antes de entrenar',
      'deshidratacion y ejercicio',
      'no beber agua antes del gym',
      'hidratarse antes de hacer ejercicio',
      'cuanta agua tomar antes de entrenar',
      'entrenar sin tomar agua',
      'sed durante el ejercicio',
      'calambres por falta de agua',
      'beber mucha agua antes de correr',
      'hidratacion antes del entrenamiento',
      'hago ejercicio sin tomar agua', //Giovanni
      'hacer ejercicio sin haber tomado agua', //Giovanni
      'hacer ejercicio sin tomar agua', //Giovanni
      'hago ejercicio sin haber tomado agua', //Giovanni

      'entreno sin tomar agua', //Giovanni
      'entrenar sin haber tomado agua', //Giovanni
      'entrenar sin tomar agua', //Giovanni
      'entreno sin haber tomado agua', //Giovanni

      'hago ejercicio sin beber agua', //Giovanni
      'hacer ejercicio sin haber bebido agua', //Giovanni
      'hacer ejercicio sin beber agua', //Giovanni
      'hago ejercicio sin bebido tomado agua', //Giovanni

      'sin haber tomado agua', //Giovanni
      'sin tomar agua', //Giovanni
      'sin beber agua', //Giovanni
      'sin haber bebido agua' //Giovanni
    ])) {
      return 'No llegues deshidratado ni tampoco tomes grandes cantidades de golpe. Bebe agua de forma gradual durante el día y un poco (250-500 ml) antes de entrenar.';
    }

// 5. Saltarse el calentamiento
    if (_containsAny(text, [
      'entrenar sin calentar',
      'no calentar antes de ejercicio',
      'calentamiento antes del gym',
      'es necesario calentar',
      'lesiones por no calentar',
      'calentamiento previo',
      'empezar directo con pesas',
      'saltarse el calentamiento',
      'como calentar antes de entrenar',
      'evitar lesiones al empezar',
      'salto el calentamiento antes de', //Giovanni
      'no hago el calentamiento antes de', //Giovanni
      'no hago calentamiento previo', // Giovanni
      'hago ejercicio sin calentar', //Giovanni
      'entreno sin calentar', //Giovanni
    ])) {
      return 'No te saltes el calentamiento. De 5 a 10 minutos de movilidad y cardio suave preparan músculos y articulaciones y reducen el riesgo de lesiones.';
    }

// 6. Estiramientos estáticos largos
    if (_containsAny(text, [
      'estirar antes de entrenar',
      'estiramientos antes del ejercicio',
      'estiramiento estatico antes de pesas',
      'estirar en frio',
      'estiramientos largos antes de correr',
      'estirar antes o despues',
      'estiramiento dinamico',
      'estirar antes del gym',
      'perder fuerza por estirar',
      'estiramientos previos al entrenamiento',
    ])) {
      return 'Evita los estiramientos estáticos largos (más de 30-60 s) antes de entrenar: pueden reducir temporalmente la fuerza y la potencia. Prefiere estiramientos dinámicos y deja los estáticos para el final.';
    }

// 7. Entrenar sin dormir bien
    if (_containsAny(text, [
      'entrenar sin dormir',
      'poco sueno y ejercicio',
      'dormir antes de entrenar',
      'cansancio y gym',
      'falta de descanso entrenamiento',
      'entrenar con sueno',
      'desvelado y ejercicio',
      'dormir mal rendimiento',
      'insomnio y entrenar',
      'horas de sueno para entrenar',
       'ejercicio sin dormir bien', //Giovanni
      'ejercito sin dormir bien', //Giovanni
      'entreno sin dormir bien', //Giovanni
      'voy al gym sin dormir bien', //Giovanni

      'ejercicio sin haber dormido bien', //Giovanni
      'ejercito sin haber dormido bien', //Giovanni
      'entreno sin haber dormido bien', //Giovanni
      'voy al gym sin haber dormido bien', //Giovanni
    ])) {
      return 'Evita entrenar intenso con muy poco sueño. Baja el rendimiento, aumenta el riesgo de lesión y afecta la recuperación. Si dormiste mal, baja la intensidad o descansa.';
    }

// 8. Analgésicos preventivos
    if (_containsAny(text, [
      'ibuprofeno antes de entrenar',
      'pastillas para el dolor y ejercicio',
      'antiinflamatorios antes del gym',
      'tomar analgesicos antes de correr',
      'paracetamol antes de entrenar',
      'medicamentos antes de hacer ejercicio',
      'tomar pastilla para no sentir dolor',
      'aines y deporte',
      'naproxeno y ejercicio',
      'analgesico preventivo deporte',
    ])) {
      return 'Evita tomar analgésicos o antiinflamatorios "preventivamente" antes de entrenar. Pueden enmascarar el dolor, afectar estómago y riñones, y hacerte ignorar una lesión. Consulta a un médico si los necesitas.';
    }

// 9. Entrenar lesionado o enfermo
    if (_containsAny(text, [
      'entrenar con fiebre',
      'hacer ejercicio enfermo',
      'entrenar con dolor',
      'entrenar lesionado',
      'ejercicio con gripe',
      'entrenar con mareo',
      'hacer ejercicio con resfriado',
      'dolor de pecho al entrenar',
      'cuando no debo entrenar',
      'entrenar con malestar',
    ])) {
      return 'Evita entrenar con fiebre, mareos, dolor de pecho, vómito o dolor articular agudo. Descansa y consulta a un médico si los síntomas persisten.';
    }

// 10. Ropa y calzado inadecuados
    if (_containsAny(text, [
      'ropa para entrenar',
      'zapatos para hacer ejercicio',
      'calzado inadecuado gym',
      'que no usar para entrenar',
      'ropa incomoda ejercicio',
      'tenis para correr',
      'ropa de algodon sudor',
      'evitar ampollas al entrenar',
      'ropa y lesiones deportivas',
      'que ponerme para entrenar',
      'pongo para entrenar', //Giovanni
      'debo usar para entrenar', //Giovanni
      'debo ponerme para entrenar', //Giovanni
      'no me debo poner para hacer ejercicio', //Giovanni
    ])) {
      return 'Evita ropa muy ajustada, que no transpire o calzado gastado o inadecuado. Pueden causar rozaduras, ampollas, sobrecalentamiento y lesiones en rodillas y tobillos.';
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////giovanni

    if (_containsAny(text, [
      'hola',
      'buenos dias',
      'buenos días',
      'buenas tardes',
      'buenas noches',
      'Buenos dias',
      'Buenos días',
      'Buenas tardes',
      'Buenas noches',
      'Ola',
      'ola',
      'Hola',
      'Buenas',
      'buenas',
    ])) {
      return '¡Hola! Estoy aquí para ayudarte con tus dudas de '
          'nutrición. Puedes preguntarme sobre alimentos, comidas, '
          'hidratación o hábitos saludables.';
    }

    if (_containsAny(text, [
      'gracias',
      'te agradezco',
      'muchas gracias',
      'gracias por tu ayuda',
      'Muchas gracias',
      'Gracias por tu ayuda',
      'Gracias',
      'Te agradezco',
      'Te agradezco mucho',
      'Te agradezco por tu ayuda',
      'Gracias por tu ayuda',
      'te agradesco mucho',
      'te agradesco por tu ayuda',
      'gracias por tu ayuda',
    ])) {
      return '¡Con gusto! Recuerda que una alimentación variada y '
          'equilibrada es la mejor base para sentirte bien. Si '
          'tienes otra duda, aquí estoy.';
    }

    return 'Lo siento, no puedo responder esa pregunta por el momento. '
        'Puedes elegir una de las cuatro opciones que aparecen debajo '
        'del chat para recibir ayuda.';
  }

  bool _containsAny(String text, List<String> keywords) {
    final normalized = _normalizeText(text);

    return keywords.any((keyword) {
      final key = _normalizeText(keyword);
      if (key.isEmpty) return false;

      final pattern = RegExp(
        r'(^|[^a-z0-9])' + RegExp.escape(key) + r'($|[^a-z0-9])',
      );

      return pattern.hasMatch(normalized);
    });
  }

  String _normalizeText(String value) {
    final normalized = value.toLowerCase();
    final withoutAccents = normalized
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r"[\u2018\u2019]"), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return withoutAccents;
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final visibleOptions =
        isMobile ? quickOptions.take(5).toList() : quickOptions;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mintBg,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              '- M R.  H E A L T H Y -', //Cambiar el título a Mr. Healthy
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Tu asistente de nutrición',
              style: TextStyle(color: AppColors.textDark, fontSize: 12),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(9),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.yellowBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: AppColors.green),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.mintBg.withValues(alpha: 0.55),
            child: const Text(
              'La información que doy es orientativa. Para un plan '
              'personalizado, consulta a un nutriólogo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDark, fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return const TypingIndicator();
                }

                return MessageBubble(
                  message: messages[index],
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: Color(0xFFE3EAD9))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    '¿Sobre qué quieres saber?',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: visibleOptions.map((option) {
                    // <- antes: quickOptions.map
                    return OutlinedButton(
                      onPressed: isTyping ? null : () => sendMessage(option),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        backgroundColor: AppColors.mintBg.withValues(
                          alpha: 0.45,
                        ),
                        side: const BorderSide(color: Color(0xFFC9DDB4)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              color: AppColors.background,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5EC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton.filled(
                      onPressed: isTyping ? null : () => sendMessage(),
                      tooltip: 'Enviar mensaje',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.yellowBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.green,
                size: 18,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.mintBg : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFFC9DDB4)
                      : const Color(0xFFE6EDDD),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 42, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Nutri está escribiendo...',
          style: TextStyle(
            color: AppColors.green,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
