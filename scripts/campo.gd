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
	estados["dragon"] = "Un dragón enorme, con escamas negras y ojos rojos brillantes. Tiene garras afiladas y una cola larga que se enrosca alrededor de su cuerpo. A pesar de su apariencia aterradora, está profundamente dormido, haciendo exalaciones que se pueden escuchar desde el cuarto de al lado pero sólo si te acercas mucho a la pared que colinda con el cuarto del dragón, no desde cualquier parte."
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
	propiedades["oveja_sonido"] = "Desde cerca, se pueden escuchar fuertes ruidos de masticación de la oveja mientras come hierba. Desde más lejos, incluso dentro de los cuartos, se pueden escuchar sus balidos de vez en cuando."
	propiedades["oveja_olor"] = "Desde cerca, se siente un olor fuerte a lana sucia. Desde más lejos no se percibe ningún olor."
	propiedades["ciervo_imagen"] = "Desde el exterior, puedes ver al ciervo pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas."
	propiedades["ciervo_sonido"] = "Desde muy cerca, casi pegando la oreja al ciervo, se pueden escuchar los suaves ruidos de masticación del ciervo mientras come hierba. Desde más lejos no se puede escuchar nada."
	propiedades["ciervo_olor"] = "Desde cerca, se siente un incluidaolor almizclado como de tierra húmeda. Desde más lejos no se percibe ningún olor."
	await lo_que_percibe_el_jugador_al_empezar()

func _process(delta: float) -> void:
	pass


func extraer_si_percibes(texto: String) -> String:
	var lineas = texto.split("\n")
	var capturando = false
	var resultado = []
	for linea in lineas:
		var limpia = linea.strip_edges()
		if limpia.begins_with("SI_PERCIBES"):
			capturando = true
			continue
		if limpia.begins_with("NO_PERCIBES"):
			break
		if capturando and not limpia.is_empty():
			resultado.append(limpia)
	if resultado.is_empty():
		return texto
	return "\n".join(resultado)

func extraer_percepcion(texto: String) -> String:
	var etiqueta = "PERCEPCION:"
	var etiqueta_markdown = "**%s**" % etiqueta
	var indice = -1
	var largo_etiqueta = 0

	var indice_markdown = texto.find(etiqueta_markdown)
	if indice_markdown != -1:
		indice = indice_markdown
		largo_etiqueta = etiqueta_markdown.length()

	var indice_plano = texto.find(etiqueta)
	if indice_plano != -1 and (indice == -1 or indice_plano < indice):
		indice = indice_plano
		largo_etiqueta = etiqueta.length()

	if indice == -1:
		return texto

	var inicio_contenido = indice + largo_etiqueta
	return texto.substr(inicio_contenido).strip_edges()


func lo_que_percibe_el_jugador_al_empezar():
	var del_propio_cuarto = await lo_que_se_percibe_del_propio_cuarto_desde_el_centro_del_cuarto_objetos()
	var de_otros_cuartos = await lo_que_se_percibe_de_otros_cuartos_desde_el_centro_del_cuarto_objetos()
	var prompt = "Esto es lo que el jugador percibe del propio cuarto en el que se encuentra: %s\n" % del_propio_cuarto
	prompt += "Esto es lo que el jugador percibe de fuera del cuarto en el que se encuentra: %s\n" % de_otros_cuartos
	prompt += "Escribe una descripción combinada en segunda persona de todo lo que el jugador percibe. Debe ser una descripción literaria pero objetiva."
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

	# var descripcion_base_dragon = "Descripción del cuarto actual: %s\n" % estados["cuarto_objetos"]
	# descripcion_base_dragon += "Descripción del cuarto de al lado: %s\n" % estados["cuarto_dragon"]
	for elemento in llaves["en_dragon"]:
		var descripcion_elemento_dragon = "En un cuarto se encuentra: %s\n" % estados[elemento]
		descripcion_elemento_dragon += "Propiedades perceptuales de este elemento:\n"
		for sentido in sentidos:
			var llave_propiedad = "%s_%s" % [elemento, sentido]
			if propiedades.has(llave_propiedad):
				descripcion_elemento_dragon += "- %s: %s\n" % [sentido, propiedades[llave_propiedad]]
			# QUE LA COMPROBACIÓN SE HAGA AQUÍ DENTRO POR CADA PROPIEDAD
		descripcion_elemento_dragon += "Posición del jugador: Parado en el centro del cuarto de al lado, a bastante distancia de todas las paredes.\n"
		var prompt_separador_dragon = descripcion_elemento_dragon
		prompt_separador_dragon += "Analiza qué información de este elemento puede percibir el jugador desde la posición en la que se encuentra, y qué información no se puede percibir desde allí. Escribe tu análisis, y después, escribe PERCEPCION: seguido de una descripción en segunda persona de sólo lo que el jugador puede percibir desde su posición, sin mencionar de qué elemento se trata. Asegúrate de que la descripción no revele nada de información que no se percibe directamente desde la posición del jugador."
		ai_chat.start_worker()
		ai_chat.ask(prompt_separador_dragon)
		var response_separador_dragon = await ai_chat.response_finished
		print("Respuesta de separación de la IA:\n%s" % response_separador_dragon)
		var percepcion_dragon = extraer_percepcion(response_separador_dragon)
		print("Percepción extraída de la respuesta de separación:\n%s" % percepcion_dragon)

		var system_prompt_comprobador_dragon = "Eres un sistema de una novela interactiva que se asegura de que las descripciones generadas automáticamente sean aptas para mostrarse al jugador sin arruinar la experiencia de exploración y descubrimiento.\n"
		system_prompt_comprobador_dragon += descripcion_elemento_dragon
		system_prompt_comprobador_dragon += "Resultado de percepción generado automáticamente:\n%s\n" % percepcion_dragon
		#var prompt_comprobador_equisciente_dragon = system_prompt_comprobador_dragon + "El resultado generado automáticamente debería ser ."
		var prompt_comprobador_factual_dragon = system_prompt_comprobador_dragon +"Analiza si el resultado generado automáticamente revela alguna información que no se debería percibir directamente desde la posición del jugador. Escribe tu análisis en el orden en que lo vas realizando, y después, responde con una lista de cualquier información incluida en el resultado que no se pueda percibir, o responde 'NINGUNA' (después de escribir tu análisis) si toda la información incluida en el resultado se puede percibir directamente desde la posición del jugador."
		ai_chat.start_worker()
		ai_chat.ask(prompt_comprobador_factual_dragon)
		var response_comprobador_dragon = await ai_chat.response_finished
		print("Respuesta del comprobador de la IA:\n%s" % response_comprobador_dragon)

		# var prompt_descripcion_dragon = "Una persona en el centro del cuarto actual percibe lo siguiente:\n%s\n" % percepcion_dragon
		# prompt_descripcion_dragon += "Escribe una descripción breve en segunda persona de sólo lo que sí se percibe desde el centro del cuarto actual sobre este elemento del cuarto de al lado. No menciones nada que no se perciba."
		# ai_chat.start_worker()
		# ai_chat.ask(prompt_descripcion_dragon)
		# var response_dragon = await ai_chat.response_finished
		# print("Respuesta de la IA:\n%s" % response_dragon)
		# respuestas.append(response_dragon)
		respuestas.append(percepcion_dragon)

	var descripcion_base_valle = "Descripción del cuarto actual: %s\n" % estados["cuarto_objetos"]
	descripcion_base_valle += "Descripción del exterior: %s\n" % estados["valle"]
	for elemento in llaves["en_valle"]:
		var prompt_separador_valle = descripcion_base_valle + "En el exterior se encuentra: %s\n" % estados[elemento]
		prompt_separador_valle += "Propiedades perceptuales de este elemento:\n"
		for sentido in sentidos:
			var llave_propiedad = "%s_%s" % [elemento, sentido]
			if propiedades.has(llave_propiedad):
				prompt_separador_valle += "- %s: %s\n" % [sentido, propiedades[llave_propiedad]]
		prompt_separador_valle += "Desde el centro del cuarto actual, separa en dos listas lo que sí se percibe y lo que no se percibe de este elemento. Responde con este formato exacto:\nSI_PERCIBES:\n- ...\nNO_PERCIBES:\n- ..."
		ai_chat.start_worker()
		ai_chat.ask(prompt_separador_valle)
		var response_separador_valle = await ai_chat.response_finished
		print("Respuesta de separación de la IA:\n%s" % response_separador_valle)
		var percepcion_valle = extraer_si_percibes(response_separador_valle)
		print("Percepción extraída de la respuesta de separación:\n%s" % percepcion_valle)

		# var prompt_descripcion_valle = descripcion_base_valle + "En el exterior se encuentra: %s\n" % estados[elemento]
		# prompt_descripcion_valle += "Resultado de separación perceptual:\n%s\n" % response_separador_valle
		# prompt_descripcion_valle += "Escribe una descripción breve en segunda persona de sólo lo que sí se percibe desde el centro del cuarto actual sobre este elemento del exterior. No describas lo que no se percibe."
		# ai_chat.start_worker()
		# ai_chat.ask(prompt_descripcion_valle)
		# var response_valle = await ai_chat.response_finished
		# print("Respuesta de la IA:\n%s" % response_valle)
		# respuestas.append(response_valle)
		respuestas.append(percepcion_valle)

	var respuesta_combinada = ""
	for r in respuestas:
		respuesta_combinada += r + "\n"
	return respuesta_combinada
