from tkinter import *

#FRAMECAMPOS
color_fondo = "purple"
color_letra = "black"

#FRAMEBOTONES
fondo_framebotones = "plum"
color_fondo_boton = "black"
color_textboton = "plum"

# Raiz 
raiz = Tk()
raiz.title("Python CRUD...")

# # Barramenu
barramenu = Menu(raiz) # Contenedor de todos los menus de la ventana o raíz.
raiz.config(menu=barramenu) # Con esto colocamos el Menu dentro de la raíz o ventana ppal

# # Menu BBDD
bbddmenu = Menu(barramenu, tearoff=0) # Contenedor de los command de bbdd
bbddmenu.add_command(label = "Conectar a la BBDD")
bbddmenu.add_command(label = "Listado de alumnos")
bbddmenu.add_command(label = "Salir")

# Menu Graficos 
statsmenu = Menu(barramenu,tearoff=0)
statsmenu.add_command(label="Alumnos por escuela")
statsmenu.add_command(label="Calificaciones")

#Menu Limpiar
limpiarmenu = Menu(barramenu,tearoff=0)
limpiarmenu.add_command(label="Limpiar")

#Menu Acerca de ...
ayudamenu = Menu(barramenu,tearoff=0)
ayudamenu.add_command(label="Licencia")
ayudamenu.add_command(label="Acerca de...")


barramenu.add_cascade(label="BBDD", menu=bbddmenu ) # Con add_cascade agregamos los menus a la barra de menúes
barramenu.add_cascade(label= "Graficas", menu=statsmenu)
barramenu.add_cascade(label="Limpiar", menu=limpiarmenu)
barramenu.add_cascade(label="Acerca de...", menu=ayudamenu)

# ----FRAMECAMPOS----

framecampos = Frame(raiz)
framecampos.config(bg=color_fondo)
framecampos.pack(fill="both") # Con esta linea hacemos que se expanda junto con el contenedor padre,

#Labels
#Se pueden configurar todos los elementos en funciones

def config_label(mi_label,fila):
    espaciado_labels = {"column":0, "sticky":"e", "padx":10, "pady":12}
    color_labels = {"bg":color_fondo,"fg":color_letra}
    mi_label.grid(row=fila, **espaciado_labels)
    mi_label.config(**color_labels)


legajo_label = Label(framecampos, text="N° de legajo")
config_label(legajo_label,0)

apellido_label = Label(framecampos, text="Apellido")
config_label(apellido_label,1)

nombre_label = Label(framecampos, text="Nombre")
config_label(nombre_label,2)

email_label = Label(framecampos, text="Email")
config_label(email_label,3)

promedio_label = Label(framecampos, text="Promedio")
config_label(promedio_label,4)

escuela_label = Label(framecampos, text="Escuela")
config_label(escuela_label,5)

localidad_label = Label(framecampos, text="Localidad")
config_label(localidad_label,6)

provincia_label = Label(framecampos, text="Provincia")
config_label(provincia_label,7)


# legajo_label.grid(row=0,column=0, padx= 10, pady=10, sticky="e") #Sticky usa los puntos cardinales, e = este
# legajo_label.config(bg=color_fondo, fg=color_letra)

# CAMPOS DEL FORMULARIO
# Creo las variables de control para los campos de entrada
'''
IntVar()
DoubleVar()
StringVar()
BooleanVar()

'''

legajo = StringVar()
apellido = StringVar()
nombre = StringVar()
email = StringVar()
promedio = DoubleVar()
escuela = StringVar()
localidad = StringVar()
provincia = StringVar()


def config_input(mi_input, fila):
    espaciado_inputs = {"column":1,"padx":10,"pady":10,"ipadx":50}
    mi_input.grid(row=fila,**espaciado_inputs)

legajo_input = Entry(framecampos, textvariable=legajo)
config_input(legajo_input,0)

apellido_input = Entry(framecampos, textvariable=apellido)
config_input(apellido_input,1)

nombre_input = Entry(framecampos, textvariable=nombre)
config_input(nombre_input,2)

email_input = Entry(framecampos, textvariable=email)
config_input(email_input,3)

promedio_input = Entry(framecampos, textvariable=promedio)
config_input(promedio_input,4)

escuela_input = Entry(framecampos, textvariable=legajo)
config_input(escuela_input,5)

localidad_input = Entry(framecampos, textvariable=localidad)
config_input(localidad_input,6)
localidad_input.config(state="disabled")

provincia_input = Entry(framecampos, textvariable=provincia)
config_input(provincia_input,7)
provincia_input.config(state="disabled")


#----FRAMEBOTONES----
# Botones de la funcion CRUD (create,read,update,delete)

framebotones = Frame(raiz)
framebotones.config(bg=fondo_framebotones)
framebotones.pack(fill="both")

def config_buttons(mi_button,columna):
    espaciado_buttons = {"row":0,"padx":5,"pady":10, "ipadx":12}
    mi_button.config(bg=color_fondo_boton, fg=color_textboton)
    mi_button.grid(column=columna, **espaciado_buttons)

boton_crear = Button(framebotones, text="Crear")
config_buttons(boton_crear,0)

boton_buscar = Button(framebotones, text="Buscar")
config_buttons(boton_buscar,1)

boton_actualizar = Button(framebotones, text="Actualizar")
config_buttons(boton_actualizar,2)

boton_borrar = Button(framebotones, text="Borrar")
config_buttons(boton_borrar,3)

# FRAME DEL PIE

framecopy = Frame(raiz)
framecopy.config(bg="black")
framecopy.pack(fill="both")

copylabel = Label(framecopy, text="2023  CaC 4.0 - Big Data")
copylabel.config(bg="black",fg="white")
copylabel.grid(row=0, column=0, padx=10,pady=10)


# Lo que hace el mainloop, la ventana queda abierta hasta q yo la cierre
raiz.mainloop()
