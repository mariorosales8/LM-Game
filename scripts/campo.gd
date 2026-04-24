extends Node2D

@export var ai_chat: NobodyWhoChat

var mundo: Mundo = Mundo.new()
var posicion_jugador: String = "Parado dentro del cuarto de objetos, junto a una pared al este colindante con otro cuarto. Observa sus alrededores, pero no se mueve de su posición."
var zona_actual: String = "cuarto_objetos"


func _ready() -> void:
	# await lo_que_percibe_el_jugador_al_empezar()
	await accion_jugador_acercarse_y_agarrar_ballesta()


func get_estado_global() -> String:
	return mundo.estados_de_zonas.get("global", "")


func get_estado_zona(zona: String) -> String:
	return mundo.estados_de_zonas.get(zona, "")


func get_estado_objeto(objeto: String) -> String:
	return mundo.estados_de_objetos.get(objeto, "")


func set_estado_objeto(objeto: String, estado: String) -> void:
	mundo.estados_de_objetos[objeto] = estado


func get_objetos_de_zona(zona: String) -> Array:
	return mundo.objetos_de_zonas.get(zona, [])


func get_condicion_de_cambio(zona_origen: String, zona_destino: String) -> String:
	return mundo.grafica_zonas.get_etiqueta(zona_origen, zona_destino)


func get_propiedad_perceptual(objeto: String, sentido: String) -> String:
	if not mundo.propiedades_perceptuales_de_objetos.has(objeto):
		return ""
	var propiedades_objeto: Dictionary = mundo.propiedades_perceptuales_de_objetos[objeto]
	return propiedades_objeto.get(sentido, "")

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

func afecta_accion_deprecated(accion: String) -> Dictionary:
	var resultados: Dictionary = {}

	# Si la zona actual no existe en la gráfica de condiciones
	if not mundo.grafica_zonas.estructura.has(zona_actual):
		push_warning("La zona actual '%s' no existe en condiciones_de_cambio." % zona_actual)
		return resultados

	# Encontrar zonas conectadas directamente con la zona actual según la gráfica de condiciones de cambio
	var zonas_vecinas: Array = []
	for zona in mundo.grafica_zonas.estructura.keys():
		if zona == zona_actual:
			continue
		if mundo.grafica_zonas.estructura[zona].has(zona_actual):
			zonas_vecinas.append(zona)
	print("Zonas vecinas que podrían afectar la acción en '%s': %s" % [zona_actual, zonas_vecinas])
	# Para cada zona vecina, obtener las condiciones de cambio y consultar a la IA para verificar si afecta la acción
	for zona_origen in zonas_vecinas:
		var condicion_de_cambio = get_condicion_de_cambio(zona_origen, zona_actual)
		var camino: Array = ["%s -> %s: %s" % [zona_origen, zona_actual, condicion_de_cambio]]

		# Si hay caminos registrados, construimos la descripción
		var descripcion_camino = "\n".join(camino)
		var prompt = "Eres el verificador causal de una novela interactiva.\n"
		prompt += "Zona actual objetivo: %s\n" % zona_actual
		prompt += "Zona candidata de origen: %s\n" % zona_origen
		prompt += "Acción del jugador: %s\n" % accion
		prompt += "Estado global: %s\n" % get_estado_global()
		prompt += "Estado de la zona actual (%s): %s\n" % [zona_actual, get_estado_zona(zona_actual)]
		prompt += "Estado de la zona candidata (%s): %s\n" % [zona_origen, get_estado_zona(zona_origen)]
		prompt += "Condiciones de influencia del camino posible:\n%s\n" % descripcion_camino
		prompt += "Decide si, dadas la acción y esas condiciones, la zona candidata afecta de alguna manera la capacidad del jugador de realizar la acción."
		prompt += " Responde con análisis breve y luego con estas etiquetas exactas:\n"
		prompt += "AFECTA_ACCION: SI o NO\n"
		prompt += "JUSTIFICACION: texto corto"

		ai_chat.start_worker()
		ai_chat.ask(prompt)
		var response = await ai_chat.response_finished
		print("Respuesta de verificación de afectación para camino %s -> %s:\n%s" % [zona_origen, zona_actual, response])

		var valor_afecta_accion = extraer_valor_etiqueta(response, "AFECTA_ACCION:").to_upper()
		var afecta_accion = valor_afecta_accion.begins_with("SI")
		var justificacion = extraer_valor_etiqueta(response, "JUSTIFICACION:")

		resultados[zona_origen] = {
			"afecta_accion": afecta_accion,
			"justificacion": justificacion,
			"respuesta_llm": response,
			"camino": camino
		}
		print("Verificación de afectación %s -> %s: %s" % [zona_origen, zona_actual, afecta_accion])

	return resultados

func get_zonas_con_cambio_tras_accion(accion: String) -> Array:
	var zonas_con_cambio: Array = []

	if not mundo.grafica_zonas.estructura.has(zona_actual):
		push_warning("La zona actual '%s' no existe en condiciones_de_cambio." % zona_actual)
		return zonas_con_cambio

	var conexiones_salida: Dictionary = mundo.grafica_zonas.estructura[zona_actual]
	var vecinos_influenciables: Array = []
	for zona_vecina in conexiones_salida.keys():
		var condicion = get_condicion_de_cambio(zona_actual, zona_vecina)
		if not condicion.strip_edges().is_empty():
			vecinos_influenciables.append(zona_vecina)

	print("Zonas vecinas que pueden ser influidas desde '%s': %s" % [zona_actual, vecinos_influenciables])

	var resultados: Dictionary = {}
	for zona_destino in vecinos_influenciables:
		var condicion_de_cambio = get_condicion_de_cambio(zona_actual, zona_destino)
		var prompt = "Eres el verificador causal de una novela interactiva.\n"
		prompt += "Zona de origen (zona actual): %s\n" % zona_actual
		prompt += "Zona vecina influenciable (destino): %s\n" % zona_destino
		prompt += "Acción del jugador: %s\n" % accion
		prompt += "Estado global: %s\n" % get_estado_global()
		prompt += "Estado de la zona origen (%s): %s\n" % [zona_actual, get_estado_zona(zona_actual)]
		prompt += "Estado de la zona vecina destino (%s): %s\n" % [zona_destino, get_estado_zona(zona_destino)]
		prompt += "Condición para que haya influencia de %s a %s:\n%s\n" % [zona_actual, zona_destino, condicion_de_cambio]
		prompt += "Decide si, dada la acción del jugador, se produce un cambio en la zona vecina destino según esa condición. "
		prompt += "Escribe tu análisis en el orden en que lo vas realizando, y después, escribe PRODUCE_CAMBIO: seguido de SI o NO según si se produce o no el cambio."

		ai_chat.start_worker()
		ai_chat.ask(prompt)
		var response = await ai_chat.response_finished
		print("Respuesta de verificación de cambio para camino %s -> %s:\n%s" % [zona_actual, zona_destino, response])

		var valor_produce_cambio = extraer_valor_etiqueta(response, "PRODUCE_CAMBIO:").to_upper()
		var produce_cambio = valor_produce_cambio.begins_with("SI")

		resultados[zona_destino] = produce_cambio
		print("Verificación de cambio %s -> %s: %s" % [zona_actual, zona_destino, produce_cambio])

	for zona in resultados.keys():
		if resultados[zona]:
			zonas_con_cambio.append(zona)

	print("La acción produce cambio en las zonas: %s" % zonas_con_cambio)
	return zonas_con_cambio

func construir_contexto_zona_para_accion(zona: String) -> String:
	var contexto = "Zona: %s\n" % zona
	contexto += "Estado de la zona: %s\n" % get_estado_zona(zona)

	var elementos = get_objetos_de_zona(zona)
	if elementos.is_empty():
		contexto += "Elementos en zona: (ninguno registrado)\n"
		return contexto

	contexto += "Elementos en zona:\n"
	for elemento in elementos:
		contexto += "- %s: %s\n" % [elemento, get_estado_objeto(elemento)]

	return contexto

func procesar_accion(accion: String) -> bool:
	var zonas_con_cambio = await get_zonas_con_cambio_tras_accion(accion)
	var zonas_relevantes = [zona_actual] + zonas_con_cambio

	var contexto_relevante = ""
	for zona in zonas_relevantes:
		contexto_relevante += construir_contexto_zona_para_accion(zona) + "\n"

	var prompt = "Eres el verificador de viabilidad de acciones de una novela interactiva.\n"
	prompt += "Acción del jugador: %s\n" % accion
	prompt += "Zona actual del jugador: %s\n" % zona_actual
	prompt += "Posición del jugador: %s\n" % posicion_jugador
	prompt += "Estado global: %s\n\n" % get_estado_global()
	prompt += "Debes basarte exclusivamente en la información de estas zonas:\n"
	prompt += "%s\n" % contexto_relevante
	prompt += "No inventes información externa. Decide si la acción es posible o no dadas las condiciones descritas.\n"
	prompt += "Escribe tu análisis en el orden en que lo vas realizando, y después, escribe ACCION_POSIBLE: seguido de SI o NO según corresponda."

	ai_chat.start_worker()
	ai_chat.ask(prompt)
	var response = await ai_chat.response_finished
	print("Verificación de posibilidad de acción:\n%s" % response)

	var valor_accion_posible = extraer_valor_etiqueta(response, "ACCION_POSIBLE:").to_upper()
	var accion_posible = valor_accion_posible.begins_with("SI")

	if accion_posible:
		print("ACCIÓN POSIBLE: SI.")
	else:
		print("ACCIÓN POSIBLE: NO.")

	return accion_posible

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
	var accion_posible = await procesar_accion(accion)
	if not accion_posible:
		print("La acción no se ejecuta porque no es posible en el estado actual.")
		return "No puedes realizar esa acción ahora."
	var estado_actualizado_ballesta = await actualizar_estado_ballesta(accion)
	if not estado_actualizado_ballesta.is_empty():
		set_estado_objeto("ballesta", estado_actualizado_ballesta)

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
	prompt += "Estado actual de la ballesta: %s\n" % get_estado_objeto("ballesta")
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
		var propiedad = get_propiedad_perceptual("ballesta", sentido)
		if not propiedad.is_empty():
			var descripcion_elemento = "Contexto omnisciente: %s\n" % get_estado_objeto("ballesta")
			descripcion_elemento += "Posición del jugador: %s\n" % posicion_jugador
			var prompt_percepcion_propiedad = "Eres un sistema de una novela interactiva que determina lo que el jugador puede percibir según la información del mundo.\n"
			prompt_percepcion_propiedad += descripcion_elemento
			prompt_percepcion_propiedad += "Propiedad perceptible (%s): %s\n" % [sentido, propiedad]
			prompt_percepcion_propiedad += "Analiza qué es lo que se puede percibir de esta propiedad desde la posición del jugador. Escribe tu análisis en el orden en que lo vas realizando, y después, si se puede percibir algo, escribe PERCEPCION: seguido de una descripción de sólo lo que el jugador puede percibir desde su posición. Si el jugador no puede percibir nada de esta propiedad, escribe PERCEPCION: NADA"
			ai_chat.start_worker()
			ai_chat.ask(prompt_percepcion_propiedad)
			var response_percepcion_propiedad = await ai_chat.response_finished
			print("Percepción de ballesta (%s):\n%s" % [sentido, response_percepcion_propiedad])
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
			"zona": "cuarto_objetos",
			"contexto": "Contexto omnisciente: En el cuarto de objetos se encuentra: %s\n",
		},
		{
			"zona": "cuarto_dragon",
			"contexto": "Contexto omnisciente: El cuarto del dragón se encuentra al este del cuarto objetos.\n El cuarto del dragón se encuentra: %s\n",
		},
		{
			"zona": "valle",
			"contexto": "Contexto omnisciente: En el exterior se encuentra: %s\n",
		}
	]

	for contexto in contextos:
		for elemento in get_objetos_de_zona(contexto["zona"]):
			var descripcion_elemento = contexto["contexto"] % get_estado_objeto(elemento)
			descripcion_elemento += "Posición del jugador: %s\n" % posicion_jugador
			for sentido in sentidos:
				var propiedad = get_propiedad_perceptual(elemento, sentido)
				if not propiedad.is_empty():
					var prompt_percepcion_propiedad = "Eres un sistema de una novela interactiva que determina lo que el jugador puede percibir según la información del mundo.\n"
					prompt_percepcion_propiedad += descripcion_elemento
					prompt_percepcion_propiedad += "Propiedad perceptible (%s): %s\n" % [sentido, propiedad]
					prompt_percepcion_propiedad += "Analiza qué es lo que se puede percibir de esta propiedad desde la posición del jugador. Escribe tu análisis en el orden en que lo vas realizando, y después, si se puede percibir algo, escribe PERCEPCION: seguido de una descripción de sólo lo que el jugador puede percibir desde su posición, sin mencionar de dónde proviene. Asegúrate de que la descripción no revele nada de información que no se percibe directamente desde la posición del jugador. Si el jugador no puede percibir nada de esta propiedad, escribe PERCEPCION: NADA"
					ai_chat.start_worker()
					ai_chat.ask(prompt_percepcion_propiedad)
					var response_percepcion_propiedad = await ai_chat.response_finished
					print("Percepción de propiedad (%s_%s) de la IA:\n%s" % [elemento, sentido, response_percepcion_propiedad])
					var percepcion_propiedad = extraer_percepcion(response_percepcion_propiedad)
					if not percepcion_propiedad.is_empty() and percepcion_propiedad.to_upper() != "NADA":
						respuestas.append(percepcion_propiedad)

	var respuesta_combinada = ""
	for r in respuestas:
		respuesta_combinada += r + "\n"
	return respuesta_combinada
