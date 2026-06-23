# 🛠️ Herramientas y Utilidades (Tools)

Esta carpeta contiene una colección de scripts independientes diseñados para facilitar tareas específicas de administración, redes, virtualización y mantenimiento de tu sistema Linux. 

Aunque algunos módulos pueden integrarse con el script principal de instalación, estas herramientas brillan por su utilidad al usarse de forma individual en el día a día.

## 📜 Catálogo de Scripts

### Mantenimiento y Sistema

#### 1. `mantenimiento.sh` (Limpieza de Disco)
Asistente interactivo para liberar espacio en disco dentro de tu directorio personal (`$HOME`). Enlista los 15 archivos más pesados y busca archivos inactivos. Permite borrar selectivamente.
* **Uso:** `./mantenimiento.sh`

#### 2. `sys_optimizer.sh` (Optimizador de Sistema Profundo)
Script avanzado que automatiza la limpieza del sistema operativo (`sudo` requerido).
* Limpia cachés antiguas de `apt/dnf/zypper`, rota los logs de `journalctl`, desinstala paquetes huérfanos y `flatpaks` no utilizados.
* **Uso:** `sudo ./sys_optimizer.sh`

#### 3. `docker_janitor.sh` (Limpiador de Docker)
Herramienta visual para purgar la basura residual generada por Docker (imágenes *dangling*, volúmenes huérfanos, contenedores apagados).
* **Uso:** `./docker_janitor.sh` o `sudo ./docker_janitor.sh` (dependiendo de tu setup).

#### 4. `monitor_alert.sh` (Alerta Ligera de Recursos)
Un "daemon" minimalista en bash. Revisa cada 60 segundos si la RAM excede el 90% o si la batería baja del 15%. De ser así, lanza una notificación de escritorio nativa (`notify-send`).
* **Uso:** `nohup ./monitor_alert.sh &` (Para dejarlo en segundo plano).

---

### Redes y Privacidad

#### 5. `multi_scanner.sh` (Escáner y Conexión Multiprotocolo)
Un script muy robusto para "Red Teaming". Escanea de forma **paralela y ultra-rápida** un rango de IPs usando `/dev/tcp`, muestra los hosts alcanzables en segundos y automatiza la conexión mediante `ssh`, `sftp`, `scp`, `rsync`, `smb`, `webdav`, o `rdp`.
* **Uso:** `./multi_scanner.sh -b 10.10.11 -s 1 -e 100 -m rdp`

#### 6. `ssh_scanner.sh` (Escáner SSH Rápido)
La versión ligera de `multi_scanner.sh`, enfocado única y exclusivamente en el descubrimiento ultra-rápido de servidores SSH en la red.
* **Uso:** `./ssh_scanner.sh -b 192.168.1 -u root`

#### 7. `wifi_manager.sh` (Gestor Inalámbrico y Privacidad MAC)
Herramienta visual basada en `nmcli` para escanear redes Wi-Fi y asignarles políticas de **MAC Aleatoria** o **MAC Física** según tus necesidades de privacidad.
* **Uso:** `./wifi_manager.sh` (Interactiva) o `sudo ./wifi_manager.sh --global`

#### 8. `lan_share.sh` (Intercambio Rápido con Código QR)
Un mini-servidor web instantáneo. Pásale un archivo o carpeta como argumento y generará un **código QR en la terminal** para que tus compañeros o tú mismo con el celular puedan escanearlo y descargar el archivo inmediatamente.
* **Uso:** `./lan_share.sh /ruta/al/archivo_o_carpeta`

---

### Desarrollo y Virtualización

#### 9. `toggle_kvm.sh` (Gestor de Virtualización para Linux)
Solución para resolver conflictos de kernel entre VirtualBox y KVM/QEMU. Puede alternar entre ambos hipervisores en caliente o de forma permanente, e incluye un diagnosticador avanzado para bloqueos de *UEFI Secure Boot*.
* **Uso:** `./toggle_kvm.sh`

#### 10. `dev_mode_toggle.sh` (Interruptor de Bases de Datos)
Si tienes `mysql`, `postgresql`, `docker` o `redis` siempre corriendo en el fondo consumiendo batería de tu laptop, este menú te permite apagar todos los servicios de desarrollo a la vez (Modo Ahorro) y volverlos a encender solo cuando vayas a programar (Modo Dev).
* **Uso:** `sudo ./dev_mode_toggle.sh`

#### 11. `dotfiles_sync.sh` (Respaldo Automático Git)
Agrupa tus archivos de configuración críticos (`.bashrc`, `.config/bspwm`, `.config/nvim`, etc.), los copia a una carpeta de respaldo y genera automáticamente un *commit* y *push* en Git para que nunca pierdas tu entorno.
* **Uso:** `./dotfiles_sync.sh`
