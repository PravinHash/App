import dbus

pid = 18856  # Replace with actual PID
service_name = f"com.guardinger.service.instance_{pid}"
object_path = "/MainApplication"
interface_name = "com.guardinger.interface"

bus = dbus.SessionBus()
app_object = bus.get_object(service_name, object_path)
app_interface = dbus.Interface(app_object, dbus_interface=interface_name)
app_interface.quitApp()
