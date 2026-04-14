class_name GrafoDirigido
extends RefCounted

# Estructura: { "NodoA": { "NodoB": "EtiquetaArista", "NodoC": "OtraEtiqueta" } }
var estructura = {}

# Añade un nodo al grafo si no existe
func agregar_nodo(nombre: String):
	if not estructura.has(nombre):
		estructura[nombre] = {}

# Añade una arista dirigida con un valor String
func agregar_arista(desde: String, hasta: String, etiqueta: String):
	# Aseguramos que los nodos existan
	agregar_nodo(desde)
	agregar_nodo(hasta)
	# Establecemos la conexión y su valor
	estructura[desde][hasta] = etiqueta
	# Si no existe la conexión opuesta, la creamos con etiqueta vacía
	if not estructura[hasta].has(desde):
		estructura[hasta][desde] = ""

# Añade dos aristas (ida y vuelta) con etiquetas distintas
func agregar_ida_y_vuelta(nodo_a: String, nodo_b: String, etiqueta_a_b: String, etiqueta_b_a: String):
	agregar_arista(nodo_a, nodo_b, etiqueta_a_b)
	agregar_arista(nodo_b, nodo_a, etiqueta_b_a)

# Obtiene el valor de una arista específica
func obtener_etiqueta(desde: String, hasta: String) -> String:
	if estructura.has(desde) and estructura[desde].has(hasta):
		return estructura[desde][hasta]
	return ""

# Imprime el grafo en la consola para depuración
func mostrar_grafo():
	for nodo in estructura:
		var conexiones = estructura[nodo]
		for vecino in conexiones:
			print(nodo, " --(", conexiones[vecino], ")--> ", vecino)