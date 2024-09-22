import re
import matplotlib.pyplot as plt



def postprocesamiento(texto):
    # Aquí se eliminan todos los \\x00 que aparezcan al final
    texto = re.sub(r'(\\x00)+$', '', texto)


    # Luego se busca la última vez que aparezcan dos \\x00 seguidos, se elimina todo antes de esto
    pos = texto.rfind('\\x00\\x00')
    if pos != -1:
        # Aquí se va a eliminar todo lo que está antes, incluyendo los \\x00
        # Se pone +4 porque son 4 caracteres
        texto = texto[pos+4:]
    # En caso de no encontrar \\x00 seguidos retorna el mismo texto
    texto = texto

    
    # Ya teniendo el texto casi limpio, se eliminan todos los \\x00 que aparezcan en medio de palabras
    texto = texto.replace('\\x00', '')

    # Finalmente, se retorna el texto con los números convertidos del formato \\x02 a un 2 por ejemplo
    return re.sub(r'\\x([0-9a-fA-F]{2})', lambda match: str(int(match.group(1), 16)), texto)


def crear_diccionario(texto):
    # Usamos una expresión regular para encontrar palabras seguidas de números
    patron = r'([a-zA-Z]+)(\d+)'  # Grupo 1: palabra, Grupo 2: número
    matches = re.findall(patron, texto)

    # Creamos el diccionario
    diccionario = {}
    for palabra, contador in matches:
        diccionario[palabra] = int(contador)  # Convertimos el contador a entero
    diccionario_ordenado = dict(sorted(diccionario.items(), key=lambda item: item[1], reverse=True))

    return diccionario_ordenado

def graficar_top_10(diccionario_ordenado):
    # Obtener las 10 primeras palabras del diccionario ordenado
    top_10_palabras = list(diccionario_ordenado.keys())[:10]
    top_10_contadores = list(diccionario_ordenado.values())[:10]
    
    # Crear el histograma
    plt.bar(top_10_palabras, top_10_contadores)
    plt.xlabel('Palabras')
    plt.ylabel('Contador')
    plt.title('Top 10 Palabras por Frecuencia')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()
    
def hex_a_ascii(input_file):
    try:
        # Leer el archivo de texto en modo binario
        with open(input_file, 'rb') as f:
            contenido = f.read()
        
        # Convertir cada byte a ASCII o mantenerlo en hexadecimal si no es imprimible
        ascii_content = ""
        for byte in contenido:
            # Aquí se define el rango de caracteres imprimibles en ascii
            if 32 <= byte <= 126:  
                ascii_content += chr(byte)
            else:
                # En caso de que no sea un ascii, se deja en hexa para ser tratado después
                ascii_content += f'\\x{byte:02x}'

        # Aquí se realiza el limpiamiento del texto, se eliminan \\x00 y se convierten números, además de eliminar el resto de texto basura
        ascii_content = postprocesamiento(ascii_content)
        diccionario = crear_diccionario(ascii_content)

        graficar_top_10(diccionario)
        
    except FileNotFoundError:
        print(f"Error: No se pudo encontrar el archivo {input_file}")


input_file = 'resultado.txt'

hex_a_ascii(input_file)
