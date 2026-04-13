extends Node2D

@export var ai_chat: NobodyWhoChat

var estados: Dictionary = {}
var llaves: Dictionary = {}
var propiedades: Dictionary = {}
var funciones: Dictionary = {}
var posicion_jugador: String = "Parado dentro del cuarto de objetos, junto a una pared al este colindante con otro cuarto. Observa sus alrededores, pero no se mueve de su posición."


func _ready() -> void:
	estados["global"] = "Hay un cuarto con paredes de metal sin ventanas, detrás de la pared que está al este hay otro cuarto de metal con un dragón escupefuego durmiendo. Afuera de los dos cuartos hay un valle verde con animalitos."
	estados["cuarto_objetos"] = "Es un cuarto con paredes de metal sin ventanas."
	estados["cuarto_dragon"] = "En el cuarto hay un dragón escupefuego durmiendo y roncando suavemente."
	estados["valle"] = "En el valle hay un conejo, una oveja y un ciervo pastando tranquilamente."
	llaves["objetos"] = ["ballesta"]
	llaves["en_dragon"] = ["dragon"]
	llaves["en_valle"] = ["conejo", "oveja", "ciervo"]
	estados["ballesta"] = "Una ballesta asentada en la pared al norte del cuarto. Si hubiera una flecha cargada en ella, se podría disparar con una fuerza descomunal capaz de atravesar acero"
	estados["dragon"] = "Un dragón enorme, con escamas negras y ojos rojos brillantes. Tiene garras afiladas y una cola larga que se enrosca alrededor de su cuerpo. A pesar de su apariencia aterradora, está profundamente dormido."
	estados["conejo"] = "Un conejo blanco con manchas grises, orejas largas y ojos rosados. Está comiendo hierba tranquilamente, sin prestar atención a su entorno."
	estados["oveja"] = "Una oveja de lana blanca y esponjosa. Tiene una cara amable y suelta balidos de vez en cuando mientras pasta el césped."
	estados["ciervo"] = "Un ciervo majestuoso con un pelaje marrón claro y astas ramificadas. Está pastando con elegancia, moviendo su cabeza de vez en cuando para mirar a su alrededor, pero no parece notar nada fuera de lo común."
	propiedades["ballesta_imagen"] = "De lejos se puede ver que es una ballesta, así como su largo y su envergadura y una aproximación de su peso. De cerca, además de lo anterior, se puede percibir la calidad de los materiales."
	propiedades["ballesta_sonido"] = "Si no está en movimiento o siendo usada, no emite ningún sonido."
	propiedades["ballesta_olor"] = "Desde muy cerca, con tu cara a centímetros de la ballesta, se puede percibir un olor a metal oxidado. Desde más lejos no se percibe ningún olor."
	propiedades["dragon_imagen"] = "Si estás en el mismo cuarto que el dragón, puedes ver al enorme dragón durmiendo, viendo claramente su respiración. Desde el cuarto de al lado o desde el exterior, no se puede ver nada, pues las paredes son opacas."
	propiedades["dragon_sonido"] = "Si estás en el mismo cuarto que el dragón, puedes escuchar claramente sus ronquidos. Desde el cuarto de al lado, sólo si te acercas mucho a la pared que colinda con el cuarto del dragón, puedes escuchar sus exalaciones suaves. Desde más lejos no se puede escuchar nada."
	propiedades["dragon_olor"] = "Si estás en el mismo cuarto que el dragón, se siente un fuerte olor a quemado. Desde el cuarto de al lado, sólo si te acercas mucho a la pared que colinda con el cuarto del dragón, se puede percibir levemente un olor a dióxido de azufre. Desde más lejos no se percibe ningún olor."
	propiedades["conejo_imagen"] = "Desde el exterior, puedes ver al conejo pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas."
	propiedades["conejo_sonido"] = "Desde muy cerca, casi pegando la oreja al suelo, se pueden escuchar los suaves ruidos de masticación del conejo mientras come hierba. Desde más lejos no se puede escuchar nada."
	propiedades["conejo_olor"] = "No presenta ningún olor."
	propiedades["oveja_imagen"] = "Desde el exterior, puedes ver a la oveja pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas."
	propiedades["oveja_sonido"] = "Desde el exterior, si tienes a la oveja frente a ti, se pueden escuchar sus fuertes ruidos de masticación mientras come hierba. Desde más lejos, incluso dentro de los cuartos, se pueden escuchar sus balidos."
	propiedades["oveja_olor"] = "Si estás en la misma zona que la oveja y estás cerca de ella, se siente un olor fuerte a lana sucia. Desde más lejos no se percibe ningún olor."
	propiedades["ciervo_imagen"] = "Desde el exterior, puedes ver al ciervo pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas."
	propiedades["ciervo_sonido"] = "Desde muy cerca, casi tocando al ciervo, se pueden escuchar sus suaves ruidos de masticación mientras come hierba. Desde más lejos no se puede escuchar nada."
	propiedades["ciervo_olor"] = "Si estás en la misma zona que el ciervo y estás cerca de él, se siente un olor almizclado como de tierra húmeda. Desde más lejos no se percibe ningún olor."
	# await lo_que_percibe_el_jugador_al_empezar()
	await accion_jugador_acercarse_y_agarrar_ballesta()

func _process(delta: float) -> void:
	pass


func extraer_percepcion(texto: String) -> String:
	var texto_sin_asteriscos = texto.replace("*", "")
	var texto_busqueda = texto_sin_asteriscos.to_upper().replace("Ó", "O")
	var etiqueta = "PERCEPCION:"
	var indice = texto_busqueda.rfind(etiqueta)
	var largo_etiqueta = etiqueta.length()

	if indice == -1:
		return ""

	var inicio_contenido = indice + largo_etiqueta
	return texto_sin_asteriscos.substr(inicio_contenido).strip_edges()

func extraer_valor_etiqueta(texto: String, etiqueta: String) -> String:
	var texto_sin_asteriscos = texto.replace("*", "")
	var texto_busqueda = texto_sin_asteriscos.to_upper().replace("Ó", "O")
	var etiqueta_busqueda = etiqueta.to_upper().replace("Ó", "O")
	var indice = texto_busqueda.rfind(etiqueta_busqueda)
	if indice == -1:
		return ""
	var inicio_contenido = indice + etiqueta.length()
	return texto_sin_asteriscos.substr(inicio_contenido).strip_edges()

func lo_que_percibe_el_jugador_al_empezar():
	var percepciones = await lo_que_se_percibe_desde_el_cuarto_objetos()
	var prompt = "Esto es lo que el jugador percibe desde su posición: %s\n" % percepciones
	prompt += "Escribe una descripción combinada en segunda persona de todo lo que el jugador percibe."
	ai_chat.start_worker()
	ai_chat.ask(prompt)
	var response = await ai_chat.response_finished
	print("Respuesta de la IA:\n%s" % response)
	return response

func accion_jugador_acercarse_y_agarrar_ballesta():
	var accion = "El jugador camina dentro del cuarto de objetos hasta la ballesta, la toma con ambas manos y la sostiene frente a sí para inspeccionarla."
	var estado_actualizado_ballesta = await actualizar_estado_ballesta(accion)
	if not estado_actualizado_ballesta.is_empty():
		estados["ballesta"] = estado_actualizado_ballesta

	var nueva_posicion_jugador = await actualizar_posicion_jugador(accion)
	if not nueva_posicion_jugador.is_empty():
		posicion_jugador = nueva_posicion_jugador

	var percepcion_ballesta = await lo_que_se_percibe_solo_de_ballesta_en_manos()
	var prompt = "El jugador realizó la siguiente acción: %s\n" % accion
	prompt += "Esto es lo que percibe de la ballesta: %s\n" % percepcion_ballesta
	prompt += "Escribe una descripción combinada en segunda persona de sólo lo que percibes de la ballesta en este momento."
	ai_chat.start_worker()
	ai_chat.ask(prompt)
	var response = await ai_chat.response_finished
	print("Percepción actualizada de la ballesta:\n%s" % response)
	return response

func actualizar_estado_ballesta(accion: String):
	var prompt = "Eres el actualizador de estado de una novela interactiva.\n"
	prompt += "Estado actual de la ballesta: %s\n" % estados["ballesta"]
	prompt += "Acción del jugador: %s\n" % accion
	prompt += "Analiza paso por paso qué cambió de la posición y el estado de la ballesta. Escribe tu análisis en el orden en que lo vas realizando, y después, escribe NUEVO_ESTADO_BALLESTA: seguido de una descripción del nuevo estado de la ballesta después de esa acción. El nuevo estado debe contener toda la información sobre la ballesta después de esa acción, incluyendo información que no haya cambiado del estado anterior. No inventes nada que no se te haya indicado en el estado anterior o en la acción del jugador, pero asegúrate de que el nuevo estado esté completamente actualizado con respecto a toda la información después de esa acción. La descripción del nuevo estado debe estar redactada en presente, sin hablar de cómo era antes, sólo describiendo cómo es la ballesta ahora mismo después de esa acción."
	ai_chat.start_worker()
	ai_chat.ask(prompt)
	var response = await ai_chat.response_finished
	print("Actualización de estado de ballesta:\n%s" % response)
	return extraer_valor_etiqueta(response, "NUEVO_ESTADO_BALLESTA:")

func actualizar_posicion_jugador(accion: String):
	var prompt = "Eres el actualizador de posición de una novela interactiva.\n"
	prompt += "Posición actual del jugador: %s\n" % posicion_jugador
	prompt += "Acción del jugador: %s\n" % accion
	prompt += "Haz un análisis paso a paso de qué cambió de la posición del jugador después de esa acción. Escribe tu análisis en el orden en que lo vas realizando, y después, escribe NUEVA_POSICION_JUGADOR: seguido de una descripción de la nueva posición del jugador después de esa acción. La nueva posición debe contener toda la información sobre la posición del jugador después de esa acción, incluyendo información que no haya cambiado de la posición anterior. Asegúrate de que la nueva posición esté completamente actualizada con respecto a toda la información después de esa acción. La descripción de la nueva posición debe estar redactada en presente, sin hablar de cómo era antes, sólo describiendo cómo es la posición del jugador ahora mismo después de esa acción."
	ai_chat.start_worker()
	ai_chat.ask(prompt)
	var response = await ai_chat.response_finished
	print("Actualización de posición del jugador:\n%s" % response)
	return extraer_valor_etiqueta(response, "NUEVA_POSICION_JUGADOR:")

func lo_que_se_percibe_solo_de_ballesta_en_manos():
	var respuestas = []
	var sentidos = ["imagen", "sonido", "olor"]
	for sentido in sentidos:
		var llave_propiedad = "ballesta_%s" % sentido
		if propiedades.has(llave_propiedad):
			var descripcion_elemento = "Contexto omnisciente: %s\n" % estados["ballesta"]
			descripcion_elemento += "Posición del jugador: %s\n" % posicion_jugador
			var prompt_percepcion_propiedad = "Eres un sistema de una novela interactiva que determina lo que el jugador puede percibir según la información del mundo.\n"
			prompt_percepcion_propiedad += descripcion_elemento
			prompt_percepcion_propiedad += "Propiedad perceptible (%s): %s\n" % [sentido, propiedades[llave_propiedad]]
			prompt_percepcion_propiedad += "Analiza qué es lo que se puede percibir de esta propiedad desde la posición del jugador. Escribe tu análisis en el orden en que lo vas realizando, y después, si se puede percibir algo, escribe PERCEPCION: seguido de una descripción de sólo lo que el jugador puede percibir desde su posición. Si el jugador no puede percibir nada de esta propiedad, escribe PERCEPCION: NADA"
			ai_chat.start_worker()
			ai_chat.ask(prompt_percepcion_propiedad)
			var response_percepcion_propiedad = await ai_chat.response_finished
			print("Percepción de ballesta (%s):\n%s" % [llave_propiedad, response_percepcion_propiedad])
			var percepcion_propiedad = extraer_percepcion(response_percepcion_propiedad)
			if not percepcion_propiedad.is_empty() and percepcion_propiedad.to_upper() != "NADA":
				respuestas.append(percepcion_propiedad)

	var respuesta_combinada = ""
	for r in respuestas:
		respuesta_combinada += r + "\n"
	return respuesta_combinada

func lo_que_se_percibe_desde_el_cuarto_objetos():
	var respuestas = []
	var sentidos = ["imagen", "sonido", "olor"]
	var contextos = [
		{
			"llave": "objetos",
			"contexto": "Contexto omnisciente: En el cuarto de objetos se encuentra: %s\n",
		},
		{
			"llave": "en_dragon",
			"contexto": "Contexto omnisciente: El cuarto del dragón se encuentra al este del cuarto objetos.\n El cuarto del dragón se encuentra: %s\n",
		},
		{
			"llave": "en_valle",
			"contexto": "Contexto omnisciente: En el exterior se encuentra: %s\n",
		}
	]

	for contexto in contextos:
		for elemento in llaves[contexto["llave"]]:
			var descripcion_elemento = contexto["contexto"] % estados[elemento]
			descripcion_elemento += "Posición del jugador: %s\n" % posicion_jugador
			for sentido in sentidos:
				var llave_propiedad = "%s_%s" % [elemento, sentido]
				if propiedades.has(llave_propiedad):
					var prompt_percepcion_propiedad = "Eres un sistema de una novela interactiva que determina lo que el jugador puede percibir según la información del mundo.\n"
					prompt_percepcion_propiedad += descripcion_elemento
					prompt_percepcion_propiedad += "Propiedad perceptible (%s): %s\n" % [sentido, propiedades[llave_propiedad]]
					prompt_percepcion_propiedad += "Analiza qué es lo que se puede percibir de esta propiedad desde la posición del jugador. Escribe tu análisis en el orden en que lo vas realizando, y después, si se puede percibir algo, escribe PERCEPCION: seguido de una descripción de sólo lo que el jugador puede percibir desde su posición, sin mencionar de dónde proviene. Asegúrate de que la descripción no revele nada de información que no se percibe directamente desde la posición del jugador. Si el jugador no puede percibir nada de esta propiedad, escribe PERCEPCION: NADA"
					ai_chat.start_worker()
					ai_chat.ask(prompt_percepcion_propiedad)
					var response_percepcion_propiedad = await ai_chat.response_finished
					print("Percepción de propiedad (%s) de la IA:\n%s" % [llave_propiedad, response_percepcion_propiedad])
					var percepcion_propiedad = extraer_percepcion(response_percepcion_propiedad)
					if not percepcion_propiedad.is_empty() and percepcion_propiedad.to_upper() != "NADA":
						respuestas.append(percepcion_propiedad)

	var respuesta_combinada = ""
	for r in respuestas:
		respuesta_combinada += r + "\n"
	return respuesta_combinada
