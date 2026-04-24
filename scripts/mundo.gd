class_name Mundo
extends RefCounted

var grafica_zonas: GrafoDirigido = GrafoDirigido.new()
var objetos_de_zonas: Dictionary = {}
var estados_de_zonas: Dictionary = {}
var estados_de_objetos: Dictionary = {}
var condiciones_de_cambio_de_objetos: Dictionary = {}
var propiedades_perceptuales_de_objetos: Dictionary = {}


func _init() -> void:
	inicializar_grafica_de_zonas()
	inicializar_objetos_por_zona()
	inicializar_estados()
	inicializar_condiciones_de_cambio_de_objetos()
	inicializar_propiedades_perceptuales()


func inicializar_grafica_de_zonas() -> void:
	grafica_zonas = GrafoDirigido.new()

	var zonas = ["cuarto_objetos", "cuarto_dragon", "valle"]
	for zona in zonas:
		grafica_zonas.agregar_nodo(zona)

	grafica_zonas.agregar_ida_y_vuelta(
		"cuarto_objetos",
		"cuarto_dragon",
		"Que algo del cuarto de objetos aumente ruido/olor, se mueva al cuarto del dragón o proyecte estímulos al cuarto del dragón.",
		"Que algo del cuarto del dragón aumente ruido/olor, se mueva al cuarto de objetos o proyecte estímulos al cuarto de objetos."
	)

	grafica_zonas.agregar_ida_y_vuelta(
		"cuarto_objetos",
		"valle",
		"Que algo del cuarto de objetos aumente ruido/olor, se mueva al valle o proyecte estímulos al valle.",
		"Que algo del valle aumente ruido/olor, se mueva al cuarto de objetos o proyecte estímulos al cuarto de objetos."
	)

	grafica_zonas.agregar_ida_y_vuelta(
		"cuarto_dragon",
		"valle",
		"Que algo del cuarto del dragón aumente ruido/olor, se mueva al valle o proyecte estímulos al valle.",
		"Que algo del valle aumente ruido/olor, se mueva al cuarto del dragón o proyecte estímulos al cuarto del dragón."
	)


func inicializar_objetos_por_zona() -> void:
	objetos_de_zonas = {
		"cuarto_objetos": ["ballesta"],
		"cuarto_dragon": ["dragon"],
		"valle": ["conejo", "oveja", "ciervo"]
	}


func inicializar_estados() -> void:
	estados_de_zonas = {
		"global": "Hay un cuarto con paredes de metal sin ventanas, detrás de la pared que está al este hay otro cuarto de metal con un dragón escupefuego durmiendo. Afuera de los dos cuartos hay un valle verde.",
		"cuarto_objetos": "Es un cuarto con paredes de metal sin ventanas.",
		"cuarto_dragon": "Es un cuarto con paredes de metal sin ventanas. En él hay un dragón escupefuego durmiendo y roncando suavemente.",
		"valle": "En el valle hay un conejo, una oveja y un ciervo pastando tranquilamente."
	}

	estados_de_objetos = {
		"ballesta": "Una ballesta asentada en la pared al norte del cuarto. Si tuviera una flecha cargada, podría dispararse con fuerza descomunal capaz de atravesar acero.",
		"dragon": "Un dragón enorme de escamas negras y ojos rojos, profundamente dormido.",
		"conejo": "Un conejo blanco con manchas grises que come hierba tranquilamente.",
		"oveja": "Una oveja de lana blanca y esponjosa que pasta y balida ocasionalmente.",
		"ciervo": "Un ciervo de pelaje marrón claro y astas ramificadas que pasta con elegancia."
	}


func inicializar_condiciones_de_cambio_de_objetos() -> void:
	condiciones_de_cambio_de_objetos = {
		"ballesta": "Si alguien la toma, la mueve, la manipula o la usa (por ejemplo, cargarla/dispararla).",
		"dragon": "Si recibe estímulos suficientes (ruido, olor o impacto directo) que lo despierten.",
		"conejo": "Si percibe amenaza cercana.",
		"oveja": "Si se altera por estímulos del entorno, incrementando su actividad y su emisión sonora (balidos).",
		"ciervo": "Si detecta amenaza o perturbación, entrando en alerta y cambiando postura o ubicación local."
	}


func inicializar_propiedades_perceptuales() -> void:
	propiedades_perceptuales_de_objetos = {
		"ballesta": {
			"imagen": "De lejos se puede ver que es una ballesta, así como su largo y su envergadura y una aproximación de su peso. De cerca, además de lo anterior, se puede percibir la calidad de los materiales.",
			"sonido": "Si no está en movimiento o siendo usada, no emite ningún sonido.",
			"olor": "Desde muy cerca, con tu cara a centímetros de la ballesta, se puede percibir un olor a metal oxidado. Desde más lejos no se percibe ningún olor."
		},
		"dragon": {
			"imagen": "Si estás en el mismo cuarto que el dragón, puedes ver al enorme dragón durmiendo, viendo claramente su respiración. Desde el cuarto de al lado o desde el exterior, no se puede ver nada, pues las paredes son opacas.",
			"sonido": "Si estás en el mismo cuarto que el dragón, puedes escuchar claramente sus ronquidos. Desde el cuarto de al lado, sólo si te acercas mucho a la pared que colinda con el cuarto del dragón, puedes escuchar sus exalaciones suaves. Desde más lejos no se puede escuchar nada.",
			"olor": "Si estás en el mismo cuarto que el dragón, se siente un fuerte olor a quemado. Desde el cuarto de al lado, sólo si te acercas mucho a la pared que colinda con el cuarto del dragón, se puede percibir levemente un olor a dióxido de azufre. Desde más lejos no se percibe ningún olor."
		},
		"conejo": {
			"imagen": "Desde el exterior, puedes ver al conejo pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas.",
			"sonido": "Desde muy cerca, casi pegando la oreja al suelo, se pueden escuchar los suaves ruidos de masticación del conejo mientras come hierba. Desde más lejos no se puede escuchar nada.",
			"olor": "No perceptible."
		},
		"oveja": {
			"imagen": "Desde el exterior, puedes ver a la oveja pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas.",
			"sonido": "Desde el exterior, si tienes a la oveja frente a ti, se pueden escuchar sus fuertes ruidos de masticación mientras come hierba. Desde más lejos, incluso dentro de los cuartos, se pueden escuchar sus balidos.",
			"olor": "Si estás en la misma zona que la oveja y estás cerca de ella, se siente un olor fuerte a lana sucia. Desde más lejos no se percibe ningún olor."
		},
		"ciervo": {
			"imagen": "Desde el exterior, puedes ver al ciervo pastando tranquilamente. Desde el interior de los cuartos no se puede ver nada, pues las paredes son opacas.",
			"sonido": "Desde muy cerca, casi tocando al ciervo, se pueden escuchar sus suaves ruidos de masticación mientras come hierba. Desde más lejos no se puede escuchar nada.",
			"olor": "Si estás en la misma zona que el ciervo y estás cerca de él, se siente un olor almizclado como de tierra húmeda. Desde más lejos no se percibe ningún olor."
		}
	}