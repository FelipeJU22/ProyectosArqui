#Librería usada para graficar: matplotlib
import matplotlib.pyplot as plt


#Función para recibir el archivo, y separar por listas las palabras y sus frecuencias
def leerArchivo(archivo):
    palabras = []
    frecuencias = []
    
    with open(archivo, 'r') as file:
        for line in file:
            #Aquí se hace la lógica de que en cada espacio se corta la palabra y su frecuencia y se añade a la lista de palabras
            palabra, frecuencia = line.split()
            palabras.append(palabra)
            frecuencias.append(int(frecuencia))
    
    return palabras, frecuencias

#Se grafican los resultados obtenidos en la función para leer el archivo
def mostrarHistograma(palabras, frecuencias):
    plt.figure(figsize=(10, 5))
    plt.gca().set_facecolor('lightgrey')
    plt.bar(palabras, frecuencias, color = '#4f0000', width = 0.2)
    plt.xlabel('Palabras')
    plt.ylabel('Frecuencia')
    plt.title('Histograma de Palabras')
    plt.show()

archivo = 'histograma.txt'

palabras, frecuencias = leerArchivo(archivo)

mostrarHistograma(palabras, frecuencias)
