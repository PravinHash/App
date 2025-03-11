import sys
import multiprocessing
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QLabel
from PyQt5.QtCore import QCoreApplication, QObject, pyqtSlot, Q_CLASSINFO
from PyQt5.QtDBus import QDBusConnection, QDBusAbstractAdaptor

# Step 1: Define a Proper D-Bus Adaptor
class DBusAdaptor(QDBusAbstractAdaptor):
    Q_CLASSINFO("D-Bus Interface", "com.guardinger.interface")  # Ensure this is registered properly

    def __init__(self, parent):
        super().__init__(parent)
        self.setAutoRelaySignals(True)

    @pyqtSlot()
    def quitApp(self):
        print("Received quit request via D-Bus. Closing application...")
        QCoreApplication.quit()

# Step 2: Create the Main Application with D-Bus
class DBusServiceApp(QWidget):
    def __init__(self):
        super().__init__()

        # Generate a unique service name using the application's PID
        pid = QCoreApplication.applicationPid()
        self.service_name = f"com.guardinger.service.instance_{pid}"

        # Connect to the session D-Bus
        sessionBus = QDBusConnection.sessionBus()

        # Register the service
        if not sessionBus.registerService(self.service_name):
            print(f"Failed to register D-Bus service: {sessionBus.lastError().message()}")
        else:
            print(f"D-Bus service registered: {self.service_name}")

        # Register the object with the correct interface
        self.adaptor = DBusAdaptor(self)

        if not sessionBus.registerObject("/MainApplication", self.adaptor,
                                         QDBusConnection.ExportAllSlots | 
                                         QDBusConnection.ExportAllInvokables):
            print(f"Failed to register D-Bus object: {sessionBus.lastError().message()}")
        else:
            print("D-Bus object registered: /MainApplication")

        # Step 3: GUI Setup
        self.initUI()

    def initUI(self):
        self.setWindowTitle("D-Bus Service GUI")
        self.setGeometry(100, 100, 300, 150)

        layout = QVBoxLayout()

        self.label = QLabel(f"D-Bus Service Running: {self.service_name}", self)
        layout.addWidget(self.label)

        self.quit_button = QPushButton("Quit App", self)
        self.quit_button.clicked.connect(self.quitApp)
        layout.addWidget(self.quit_button)

        self.setLayout(layout)

    @pyqtSlot()
    def quitApp(self):
        print("Quit button clicked. Exiting application...")
        QCoreApplication.quit()

if __name__ == "__main__":
    multiprocessing.freeze_support()  # Prevents multiple instances
    multiprocessing.set_start_method("spawn", force=True)  # ✅ Ensure correct process handling

    app = QApplication(sys.argv)
    service = DBusServiceApp()
    service.show()
    sys.exit(app.exec_())

