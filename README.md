# script_linux

### ¿Qué es `script_linux`?
Este proyecto es un script de Bash diseñado para simplificar la instalación de paquetes en diversas distribuciones de Linux. Nació de la necesidad de automatizar la configuración de mis sistemas, especialmente después de reinstalar mi sistema operativo o en nuevas máquinas.

El script se ha probado y funciona mejor en:
* **Debian y distros derivadas:** Ubuntu, Linux Mint, Zorin OS, Pop!_OS.
* **Otras distros:** OpenSUSE y Fedora.

Espero que esta herramienta te sea tan útil como lo ha sido para mí, ahorrándote tiempo y esfuerzo en la configuración inicial de tu entorno de desarrollo.

### Funcionalidades principales
`script_linux` es un asistente de gestión e instalación de paquetes con las siguientes funciones:

* **Actualización** de paquetes del sistema.
* **Instalación** de paquetes específicos.
* **Eliminación** de paquetes.
* **Búsqueda** de paquetes en los repositorios.

---

### Paquetes pre-configurados
El script incluye opciones para instalar rápidamente tus herramientas de desarrollo favoritas:

* **Lenguajes de programación:** C/C++, Java 17, Python.
* **Herramientas de contenedores:** Docker.
* **Sistemas de paquetes alternativos:** Flatpak.
* **Compatibilidad:** Wine.
* **Entornos de desarrollo:** Varios IDEs populares.
* **Otros extras:** Herramientas y utilidades adicionales.

---

### Requisitos Previos
Para poder utilizar el script, asegúrate de tener `git` y `make` instalados en tu sistema.

### ¿Cómo usarlo?
Para empezar a usar el script, abre tu terminal y ejecuta los siguientes comandos:

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/script_linux.git

# Entrar al directorio
cd script_linux

# Ejecutar el script
make run
```

---

![preview](inicio.png)

### Roadmap
Aunque este miniproyecto nació como una práctica personal para aplicar conocimientos de Bash, estoy considerando añadir en el futuro:
* Integración de herramientas CLI modernas escritas en Rust (como `bat`, `eza`, `fd`, etc.).
* Automatización y configuración de Dotfiles.

### Licencia
Este proyecto es de uso libre. Eres libre de usarlo, modificarlo y distribuirlo según tus necesidades.