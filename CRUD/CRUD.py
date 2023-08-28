import sqlite3 as sq3
from tkinter import *
from tkinter import Tk,ttk, Frame, Button, Entry, Scrollbar, Canvas, Y, END
from tkinter import messagebox
import matplotlib.pyplot as plt


# ENTORNOS VIRTUALES
#1era vez INSTALAR EL virtualenv
#pip install virtualenv

# CREAR ENTORNO VIRTUAL
#virtualenv venv

#CHEQUEAR PIPS
#pip list

#ACTIVAR EL ENTORNO VIRTUAL
#venv\scripts\activate

#INSTALAR LAS LIBREARIAS 
#pip install matplotlib

#DESACTIVAR ENTORNO VIRTUAL
#deactivate


#GRABAR LOS REQUERIMIENTOS DEL ENTORNO
#pip freeze > requirements.txt

#INSTALAR REQUERIMIENTOS en un nuevo entorno virtual
# pip install -r requirements.txt



'''
****************
PARTE FUNCIONAL
****************
'''

# MENU - BBDD

#Conectar
def conectar():
    global con
    global cur
    con = sq3.connect("mi_db.db")
    cur = con.cursor()
    messagebox.showinfo("STATUS","Conectado a la BBDD!")


#LISTAR (Listado de alumnos) 

def listar():
    class Table():
        def __init__(self, raiz2, page_size): 
            self.nombre_cols = ["Legajo", "Apellido", "Nombre", "Promedio", "Email", "Escuela", "Localidad", "Provincia"]
            self.frameppal = Frame(raiz2)
            self.frameppal.pack(fill="both", expand=True)
            self.canvas = Canvas(self.frameppal)
            self.canvas.pack(side=LEFT, fill="both", expand=True)
            self.scrollbar = ttk.Scrollbar(self.frameppal, orient=VERTICAL, command=self.canvas.yview)
            self.scrollbar.pack(side=RIGHT, fill=Y)
            self.canvas.configure(yscrollcommand=self.scrollbar.set)            
            self.canvas.bind('<Configure>', lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all")))
            self.canvas.config(width=1000)
            self.frame = Frame(self.canvas)
            self.canvas.create_window((0, 0), window=self.frame, anchor="nw")
            for i in range(cant_cols):
                self.e = Entry(self.frame)
                self.e.config(bg="black", fg="white")
                self.e.grid(row=0, column=i)
                self.e.insert(END, self.nombre_cols[i])
            self.page_size = page_size
            self.current_page = 0
            self.total_pages = (cant_filas + self.page_size - 1) // self.page_size            
            self.update_table()            



        def update_table(self):
            start = self.current_page * self.page_size
            end = min(start + self.page_size, cant_filas)
            for widget in self.frame.winfo_children():
                widget.destroy()
            for i in range(cant_cols):
                self.e = Entry(self.frame)
                self.e.config(bg="black", fg="white")
                self.e.grid(row=0, column=i)
                self.e.insert(END, self.nombre_cols[i])
            for fila in range(start, end):
                for col in range(cant_cols):
                    self.e = Entry(self.frame)
                    self.e.grid(row=fila - start + 1, column=col)
                    self.e.insert(END, resultado[fila][col])
                    self.e.config(state="readonly")
            self.frame.update_idletasks()
            self.canvas.configure(scrollregion=self.canvas.bbox("all"))

        def next_page(self):
            if self.current_page < self.total_pages - 1:
                self.current_page += 1
                self.update_table()

        def prev_page(self):
            if self.current_page > 0:
                self.current_page -= 1
                self.update_table()

    # INTERFAZ 
    raiz2 = Tk()
    raiz2.title("Listado de alumnos")
    framecerrar = Frame(raiz2)
    framecerrar.pack(fill="both")
    boton_cerrar = Button(framecerrar, text="Cerrar", command=raiz2.destroy)
    boton_cerrar.pack(fill="both")

    # obtener los datos
    con = sq3.connect("mi_db.db")
    cur = con.cursor()
    query1 = '''
            SELECT alumnos.legajo, alumnos.apellido,alumnos.nombre,alumnos.nota,alumnos.email, escuelas.nombre,
            escuelas.localidad,escuelas.provincia FROM alumnos INNER JOIN escuelas ON alumnos.id_escuela = escuelas._id
               '''
    cur.execute(query1)
    resultado = cur.fetchall()
    cant_filas = len(resultado)  # Obtengo la cant de registros para saber cuantas filas
    cant_cols = len(resultado[0])  # Obtengo la cantidad de columnas

    page_size = 100
    tabla = Table(raiz2, page_size)

    con.close()

    framebotones = Frame(raiz2)
    framebotones.pack(fill="both")
    boton_prev = Button(framebotones, text="Anterior", command=tabla.prev_page)
    boton_prev.pack(side=LEFT, fill="both")
    boton_next = Button(framebotones, text="Siguiente", command=tabla.next_page)
    boton_next.pack(side=RIGHT, fill="both")

    raiz2.mainloop()

# Salir
def salir():
    resp = messagebox.askquestion("CONFIRME","Desea abandonar la aplicacion?")
    if resp == "yes":        
        raiz.destroy()
        con.close()

# MENU - GRAFICAS

## Por escuelas

def alumnos_en_escuelas():
    con = sq3.connect("mi_db.db")
    cur = con.cursor()    

    query_buscar = '''SELECT COUNT(alumnos.legajo) AS "total" , escuelas.nombre FROM alumnos INNER JOIN 
    escuelas ON alumnos.id_escuela = escuelas._id GROUP BY escuelas.nombre ORDER BY total DESC
    '''
    cur.execute(query_buscar)
    resultado = cur.fetchall()
    # prueba
    #print(resultado)
    cuenta = []
    escuela = []
    for i in resultado:
        cuenta.append(i[0])
        escuela.append(i[1])
    # print(resultado)
    plt.bar(escuela,cuenta)
    plt.xticks(rotation=90)
    plt.show()

## Por calificaciones
def alumnos_con_notas():
    con = sq3.connect("mi_db.db")
    cur = con.cursor()
    
    query_buscar = ''' SELECT COUNT(legajo) AS "total", nota FROM alumnos GROUP BY nota ORDER BY total 
    DESC    '''
    cur.execute(query_buscar)
    resultado = cur.fetchall()
    # prueba
    #print(resultado)
    cuenta = []
    nota = []
    for i in resultado:
        cuenta.append(i[0])
        nota.append(i[1])
    plt.bar(nota,cuenta)
    plt.xticks(rotation=0)
    plt.show()





# MENU - LIMPIAR
#Tomamos las var de control y llamamos al metodo set

def limpiar():
    legajo.set("")    
    apellido.set("")
    nombre.set("")
    email.set("")
    promedio.set("")
    escuela.set("Seleccione")
    localidad.set("") 
    provincia.set("")
    legajo_input.config(state="normal")


# MENU Acerca de ...

def mostrar_licencia():
    msg = '''
    Sistema CRUD en Python
    Copyright (C) 2023 - xxxxx xxxx
    Email: xxxx@xxx.xx\n=======================================
    This program is free software: you can redistribute it 
    and/or modify it under the terms of the GNU General Public 
    License as published by the Free Software Foundation, 
    either version 3 of the License, or (at your option) any 
    later version.
    This program is distributed in the hope that it will be 
    useful, but WITHOUT ANY WARRANTY; without even the 
    implied warranty of MERCHANTABILITY or FITNESS FOR A 
    PARTICULAR PURPOSE.  See the GNU General Public License 
    for more details.
    You should have received a copy of the GNU General Public 
    License along with this program.  
    If not, see <https://www.gnu.org/licenses/>.'''
    messagebox.showinfo("LICENCIA",msg)

def mostrar_acercade():
    messagebox.showinfo("ACERCA DE","Creado por Javier A. Rivasseau\npara Codo a Codo 4.0 - Big Data\nJunio, 2023\nEmail: ing.javier.rivasseau@gmail.com")
    

'''
****************
funciones VARIAS (Esta funcion es para poder usar El boton Crear y el boton Actualizar)
****************
'''
# Esta funcion se ejecuta sola cuando corremos el codigo porque actualiza = False.
# y nos devuelve el nombre de las escuelas 

def buscar_escuelas(actualiza): 
    con = sq3.connect("mi_db.db")
    cur = con.cursor()
    if actualiza:
        cur.execute("SELECT _id,localidad,provincia FROM escuelas WHERE nombre = ?", (escuela.get(),)) #escuela.get() con elemento fantasma
    else: #Esta opcion llena la lista de escuelas para el desplegable
        cur.execute("SELECT nombre FROM escuelas")
    # Lista de tuplas
    #[(nom,),(nom,),(nom,),(nom,)] #elemento fantasma de la tupla
    resultado = cur.fetchall()
    retorno = []
    print("print resultado",resultado)    
    for e in resultado:
        if actualiza:
            localidad.set(e[1])
            provincia.set(e[2])
        esc = e[0]
        retorno.append(esc)
    print("print retorno",retorno)
    con.close()
    return retorno   
# print resultado [('Carlos Guido y Spano',), ('Paula Albarracín de Sarmiento',), ('Escuela Nro.392',), ('General Las Heras',), ('Gdor. Valentín Virasoro',), ('E.E.P. Nro.852',), ('Tutú Maramba',), ('Justo José de Urquiza',), ('Sor Clotilde León',), ('Escuela Nro.264',)]
# print retorno ['Carlos Guido y Spano', 'Paula Albarracín de Sarmiento', 'Escuela Nro.392', 'General Las Heras', 'Gdor. Valentín Virasoro', 'E.E.P. Nro.852', 'Tutú Maramba', 'Justo José de Urquiza', 'Sor Clotilde León', 'Escuela Nro.264']

'''
****************
Seccion CRUD
****************
'''
#CREAR
def crear():
    cur.execute("SELECT legajo FROM alumnos")
    resultado = cur.fetchall()
    existe = False
    # print("Print legajo",resultado)
    for i in resultado:
        if i[0] == int(legajo.get()[0]):
            existe = True
            break
    # print("Legajo get",(legajo.get(),))
    if existe:
        messagebox.showerror("ERROR","El N° de Legajo ya existe en la BBDD")               
    else:
        id_escuela = int(buscar_escuelas(True)[0])
        datos = id_escuela, legajo.get(), apellido.get(), nombre.get(), promedio.get(), email.get()
        cur.execute("INSERT INTO alumnos (id_escuela, legajo, apellido, nombre, nota, email) VALUES (?,?,?,?,?,?)", datos)
        con.commit()
        messagebox.showinfo("STATUS","Registro Agregado")
        limpiar()


def buscar_legajo():
    query_buscar = '''SELECT alumnos.legajo, alumnos.apellido, alumnos.nombre, alumnos.nota, 
    alumnos.email, escuelas.nombre, escuelas.localidad, escuelas.provincia FROM alumnos INNER JOIN
    escuelas ON alumnos.id_escuela=escuelas._id WHERE legajo = ? OR alumnos.apellido = ?'''
    cur.execute(query_buscar,(legajo.get(),apellido.get()))
    resultado = cur.fetchall()

    if resultado == []:
        messagebox.showerror("ERROR!", "Ese numero de legajo no existe")
        legajo.set("")
    else:
        for campo in resultado:
            legajo.set(campo[0])
            apellido.set(campo[1])
            nombre.set(campo[2])
            promedio.set(campo[3])
            email.set(campo[4])
            escuela.set(campo[5])
            localidad.set(campo[6])
            provincia.set(campo[7])
            legajo_input.config(state="disabled")

#ACTUALIZAR
def actualizar():
    id_escuela = int(buscar_escuelas(True)[0])
    datos = id_escuela,  apellido.get(), nombre.get(), promedio.get(), email.get()
    cur.execute("UPDATE alumnos SET id_escuela=?,apellido=?,nombre=?,nota=?,email=? WHERE legajo="+legajo.get(),datos)
    con.commit()
    messagebox.showinfo("STATUS","Registro Actualizado")
    limpiar()

#BORRAR

def borrar():
    resp = messagebox.askquestion("BORRAR","Desea eliminar el registro?")
    if resp == "yes":
        cur.execute("DELETE FROM alumnos WHERE legajo=" + legajo.get())
        con.commit()
        messagebox.showinfo("STATUS","Registro eliminado")
        limpiar()



'''
****************
INTERFAZ GRAFICA
****************
'''


#FRAMECAMPOS
color_fondo = "purple"
color_letra = "white"

#FRAMEBOTONES
fondo_framebotones = "plum"
color_fondo_boton = "black"
color_textboton = "plum"

# Raiz 
raiz = Tk()
raiz.title("Python CRUD...")

# # Barramenu
barramenu = Menu(raiz)
raiz.config(menu=barramenu)

# # Menu BBDD
bbddmenu = Menu(barramenu, tearoff=0)
bbddmenu.add_command(label = "Conectar a la BBDD",command=conectar )
bbddmenu.add_command(label = "Listado de alumnos",command=listar)
bbddmenu.add_command(label = "Salir",command = salir )

# Menu Graficos 
statsmenu = Menu(barramenu,tearoff=0)
statsmenu.add_command(label="Alumnos por escuela",command = alumnos_en_escuelas)
statsmenu.add_command(label="Calificaciones",command = alumnos_con_notas)

#Menu Limpiar
limpiarmenu = Menu(barramenu,tearoff=0)
limpiarmenu.add_command(label="Limpiar",command=limpiar)

#Menu Acerca de ...
ayudamenu = Menu(barramenu,tearoff=0)
ayudamenu.add_command(label="Licencia",command = mostrar_licencia)
ayudamenu.add_command(label="Acerca de...",command= mostrar_acercade)


barramenu.add_cascade(label="BBDD", menu=bbddmenu )
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
    espaciado_labels = {"column":0, "sticky":"e", "padx":10, "pady":10}
    color_labels = {"bg":color_fondo,"fg":color_letra}
    mi_label.grid(row=fila, **espaciado_labels)
    mi_label.config(**color_labels)


'''Esta primera vez con legajo_label, sin usar la función config_label(mi_label,fila)'''

legajo_label = Label(framecampos, text="N° de legajo")
legajo_label.grid(row=0,column=0,sticky="e",padx=10,pady=10)
legajo_label.config(bg=color_fondo,fg=color_letra)
# config_label(legajo_label,0)

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

# Campos del formulario
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

#Convertir escuela en un desplegable ----------------------------------------
# escuela_input = Entry(framecampos, textvariable=legajo)
# config_input(escuela_input,5)
escuelas = buscar_escuelas(False)
escuela.set("Seleccione")

escuela_option = OptionMenu(framecampos, escuela, *escuelas) #OptionMenu(master,variable,*opciones)
escuela_option.config(width=30)
escuela_option.grid(row=5, column=1, padx=10,sticky="w") # escuela_option.grid(row=5, column=1, padx=10,pady=10,ipadx=10,sticky="w")


localidad_input = Entry(framecampos, textvariable=localidad)
config_input(localidad_input,6)
localidad_input.config(state="readonly")

provincia_input = Entry(framecampos, textvariable=provincia)
config_input(provincia_input,7)
provincia_input.config(state="readonly")


#----FRAMEBOTONES----
# Botones de la funcion CRUD (create,read,update,delete)

framebotones = Frame(raiz)
framebotones.config(bg=fondo_framebotones)
framebotones.pack(fill="both")

def config_buttons(mi_button,columna):
    espaciado_buttons = {"row":0,"padx":5,"pady":10, "ipadx":12}
    mi_button.config(bg=color_fondo_boton, fg=color_textboton)
    mi_button.grid(column=columna, **espaciado_buttons)

boton_crear = Button(framebotones, text="Crear", command=crear)
config_buttons(boton_crear,0)

boton_buscar = Button(framebotones, text="Buscar",command=buscar_legajo)
config_buttons(boton_buscar,1)

boton_actualizar = Button(framebotones, text="Actualizar",command=actualizar)
config_buttons(boton_actualizar,2)

boton_borrar = Button(framebotones, text="Borrar",command=borrar)
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
