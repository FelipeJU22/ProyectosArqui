
#Se toman las únicas letras posibles que va a leer para procesar el texto
listaValida = set("abcdefghijklmnopqrstuvwxyz")

#En esta función se va a determinar si la palabra es válida para volverla a reescribir, sino se elimina lo que la altera
def palabraValida(palabra):
    palabraLimpia = ""
    for letra in palabra:
        if letra in listaValida:
            palabraLimpia += letra
    return palabraLimpia

#Aquí se lee el archivo a preprocesar
with open("texto.txt", "r") as file:
    texto = file.read()

#Se pasa el texto a minúsculas para homogenizar todo
texto = texto.lower()

#Se separan las palabras por espacios
palabras = texto.split()

#Aquí se escriben todas las palabras limpias en otro archivo
with open("texto_limpio.txt", "w") as file:
    for palabra in palabras:
        palabra = palabraValida(palabra)
        file.write(f"{palabra}\n")
