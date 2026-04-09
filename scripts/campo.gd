extends Node2D

@export var ai_chat: NobodyWhoChat

var estados: Dictionary = {}
var llaves: Dictionary = {}
var propiedades: Dictionary = {}
var funciones: Dictionary = {}


func _ready() -> void:
	estados["global"] = "Hay un cuarto con paredes de metal sin ventanas, detrás de la pared que está al este hay otro cuarto de metal con un dragón escupefuego durmiendo. Afuera de los dos cuartos hay un valle verde con animalitos."
	estados["cuarto_objetos"] = "Es un cuarto con paredes de metal sin ventanas."
	estados["cuarto_dragon"] = "En el cuarto hay un dragón escupefuego durmiendo y roncando suavemente."
	estados["valle"] = "En el valle hay un conejo, una oveja y un ciervo pastando tranquilamente."
	estados["ballesta"] = "Una ballesta. Si hubiera una flecha cargada en ella, se podría disparar con una fuerza descomunal capaz de atravesar acero"
	llaves["objetos"] = ["ballesta"]
	llaves["en_dragon"] = ["dragon"]
	llaves["en_valle"] = ["conejo", "oveja", "ciervo"]
	estados["dragon"] = "Un dragón enorme, con escamas negras y ojos rojos brillantes. Tiene garras afiladas y una cola larga que se enrosca alrededor de su cuerpo. A pesar de su apariencia aterradora, está profundamente dormido."
	estados["conejo"] = "Un conejo blanco con manchas grises, orejas largas y ojos rosados. Está comiendo hierba tranquilamente, sin prestar atención a su entorno."
	estados["oveja"] = "Una oveja de lana blanca y esponjosa. Tiene una cara amable y suelta balidos de vez en cuando mientras pasta el césped."
	estados["ciervo"] = "Un ciervo majestuoso con un pelaje marrón claro y astas ramificadas. Está pastando con elegancia, moviendo su cabeza de vez en cuando para mirar a su alrededor, pero no parece notar nada fuera de lo común."
	propiedades["ballesta_imagen"] = "De lejos se puede ver el largo y la envergadura de la ballesta y aproximar su peso. De cerca se puede percibir la calidad de los materiales."
	propiedades["ballesta_sonido"] = "Si no está en movimiento o siendo usada, no emite ningún sonido."
	propiedades["ballesta_olor"] = "Desde muy cerca, casi pegando la nariz a la ballesta, se puede percibir un olor a metal oxidado. Desde más lejos no se percibe ningún olor."
	propiedades["dragon_imagen"] = "Si estás en el mismo cuarto que el dragón, puedes ver al enorme dragón durmiendo, viendo claramente su respiración. Desde el cuarto de al lado o desde el exterior, no se puede ver nada, pues las paredes son opacas."
	propiedades["dragon_sonido"] = "Si estás en el mismo cuarto que el dragón, puedes escuchar claramente su respiración. Desde el cuarto de al lado, sólo si te acercas mucho a la pared que colinda con el cuarto del dragón, puedes escuchar sus exalaciones suaves. Desde más lejos no se puede escuchar nada."
	propiedades["dragon_olor"] = "Desde cerca, se siente un olor a dióxido de azufre. Desde más lejos no se percibe ningún olor."
	propiedades["conejo_imagen"] = "Desde el exterior, puedes ver al conejo pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas."
	propiedades["conejo_sonido"] = "Desde muy cerca, casi pegando la oreja al suelo, se pueden escuchar los suaves ruidos de masticación del conejo mientras come hierba. Desde más lejos no se puede escuchar nada."
	propiedades["conejo_olor"] = "No presenta ningún olor."
	propiedades["oveja_imagen"] = "Desde el exterior, puedes ver a la oveja pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas."
	propiedades["oveja_sonido"] = "Desde el exterior, si tienes a la oveja de frente, se pueden escuchar sus fuertes ruidos de masticación mientras come hierba. Desde más lejos, incluso dentro de los cuartos, se pueden escuchar sus balidos de vez en cuando."
	propiedades["oveja_olor"] = "Desde cerca, se siente un olor fuerte a lana sucia. Desde más lejos no se percibe ningún olor."
	propiedades["ciervo_imagen"] = "Desde el exterior, puedes ver al ciervo pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas."
	propiedades["ciervo_sonido"] = "Desde muy cerca, casi pegando la oreja al ciervo, se pueden escuchar los suaves ruidos de masticación del ciervo mientras come hierba. Desde más lejos no se puede escuchar nada."
	propiedades["ciervo_olor"] = "Desde cerca, se siente un olor almizclado como de tierra húmeda. Desde más lejos no se percibe ningún olor."
	await lo_que_percibe_el_jugador_al_empezar()

func _process(delta: float) -> void:
	pass


func extraer_percepcion(texto: String) -> String:
	var texto_normalizado = texto.replace("*", "")
	var etiqueta = "PERCEPCION:"
	var indice = texto_normalizado.find(etiqueta)
	var largo_etiqueta = etiqueta.length()

	if indice == -1:
		return texto

	var inicio_contenido = indice + largo_etiqueta
	return texto_normalizado.substr(inicio_contenido).strip_edges()

func lo_que_percibe_el_jugador_al_empezar():
	var del_propio_cuarto = await lo_que_se_percibe_del_propio_cuarto_desde_el_centro_del_cuarto_objetos()
	var de_otros_cuartos = await lo_que_se_percibe_de_otros_cuartos_desde_el_centro_del_cuarto_objetos()
	var prompt = "Esto es lo que el jugador percibe del propio cuarto en el que se encuentra: %s\n" % del_propio_cuarto
	prompt += "Esto es lo que el jugador percibe de fuera del cuarto en el que se encuentra: %s\n" % de_otros_cuartos
	prompt += "Escribe una descripción combinada en segunda persona de todo lo que el jugador percibe."
	ai_chat.start_worker()
	ai_chat.ask(prompt)
	var response = await ai_chat.response_finished
	print("Respuesta de la IA:\n%s" % response)
	return response

func lo_que_se_percibe_del_propio_cuarto_desde_el_centro_del_cuarto_objetos():
	var descripcion_cuarto = "Descripción del cuarto: %s\n" % estados["cuarto_objetos"]
	var respuestas = []
	for objeto in llaves["objetos"]:
		var prompt = descripcion_cuarto + "En el cuarto se encuentra el siguiente objeto: %s\n" % estados[objeto]
		prompt += "Escribe una descripción en segunda persona de lo que una persona parada en el centro del cuarto puede observar del objeto. No describas nada más del cuarto, sólo el objeto."
		ai_chat.start_worker()
		ai_chat.ask(prompt)
		var response = await ai_chat.response_finished
		print("Respuesta de la IA:\n%s" % response)
		respuestas.append(response)
	var respuesta_combinada = ""
	for r in respuestas:
		respuesta_combinada += r + "\n"
	return respuesta_combinada

func lo_que_se_percibe_de_otros_cuartos_desde_el_centro_del_cuarto_objetos():
	var respuestas = []
	var sentidos = ["imagen", "sonido", "olor"]

	for elemento in llaves["en_dragon"]:
		var descripcion_elemento = "Contexto omnisciente: En un cuarto se encuentra: %s\n" % estados[elemento]
		descripcion_elemento += "Posición del jugador: Parado en el cuarto de al lado junto a la pared colindante.\n"
		for sentido in sentidos:
			var llave_propiedad = "%s_%s" % [elemento, sentido]
			if propiedades.has(llave_propiedad):
				var prompt_percepcion_propiedad = "Eres un sistema de una novela interactiva que determina lo que el jugador puede percibir según la información del mundo.\n"
				prompt_percepcion_propiedad += descripcion_elemento
				prompt_percepcion_propiedad += "Propiedad perceptible (%s): %s\n" % [sentido, propiedades[llave_propiedad]]
				prompt_percepcion_propiedad += "Analiza si esta propiedad específica se puede percibir directamente desde la posición del jugador. Escribe tu análisis en el orden en que lo vas realizando, y después, si se puede percibir algo, escribe PERCEPCION: seguido de una descripción de sólo lo que el jugador puede percibir desde su posición, sin mencionar de dónde proviene. Asegúrate de que la descripción no revele nada de información que no se percibe directamente desde la posición del jugador. Si el jugador no puede percibir nada de esta propiedad, escribe PERCEPCION: NADA"
				ai_chat.start_worker()
				ai_chat.ask(prompt_percepcion_propiedad)
				var response_percepcion_propiedad_dragon = await ai_chat.response_finished
				print("Percepción de propiedad (%s) de la IA:\n%s" % [llave_propiedad, response_percepcion_propiedad_dragon])
				var percepcion_propiedad_dragon = extraer_percepcion(response_percepcion_propiedad_dragon)
				if not percepcion_propiedad_dragon.is_empty() and percepcion_propiedad_dragon.to_upper() != "NADA":
					respuestas.append(percepcion_propiedad_dragon)

	for elemento in llaves["en_valle"]:
		var descripcion_elemento_valle = "Contexto omnisciente: En el exterior se encuentra: %s\n" % estados[elemento]
		descripcion_elemento_valle += "Posición del jugador: Parado dentro de un cuarto, junto a una pared colindante con otro cuarto.\n"
		for sentido in sentidos:
			var llave_propiedad = "%s_%s" % [elemento, sentido]
			if propiedades.has(llave_propiedad):
				var prompt_percepcion_propiedad_valle = "Eres un sistema de una novela interactiva que determina lo que el jugador puede percibir según la información del mundo.\n"
				prompt_percepcion_propiedad_valle += descripcion_elemento_valle
				prompt_percepcion_propiedad_valle += "Propiedad perceptible (%s): %s\n" % [sentido, propiedades[llave_propiedad]]
				prompt_percepcion_propiedad_valle += "Analiza si esta propiedad específica se puede percibir directamente desde la posición del jugador. Escribe tu análisis en el orden en que lo vas realizando, y después, si se puede percibir algo, escribe PERCEPCION: seguido de una descripción de sólo lo que el jugador puede percibir desde su posición, sin mencionar de dónde proviene. Asegúrate de que la descripción no revele nada de información que no se percibe directamente desde la posición del jugador. Si el jugador no puede percibir nada de esta propiedad, escribe PERCEPCION: NADA"
				ai_chat.start_worker()
				ai_chat.ask(prompt_percepcion_propiedad_valle)
				var response_percepcion_propiedad_valle = await ai_chat.response_finished
				print("Percepción de propiedad (%s) de la IA:\n%s" % [llave_propiedad, response_percepcion_propiedad_valle])
				var percepcion_propiedad_valle = extraer_percepcion(response_percepcion_propiedad_valle)
				if not percepcion_propiedad_valle.is_empty() and percepcion_propiedad_valle.to_upper() != "NADA":
					respuestas.append(percepcion_propiedad_valle)

	var respuesta_combinada = ""
	for r in respuestas:
		respuesta_combinada += r + "\n"
	return respuesta_combinada
