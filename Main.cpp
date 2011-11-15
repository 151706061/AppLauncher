
// Qt includes
#include <QApplication>
#include <QTimer>
#include <QDebug>

#include "ctkAppLauncher.h"
#include "ctkCommandLineParser.h"

// STD includes
#include <cstdlib>

#if defined (_WIN32)
#include <windows.h>
#endif

int appLauncherMain(int argc, char** argv)
{
  #ifdef QT_MAC_USE_COCOA
  // See http://doc.trolltech.com/4.7/qt.html#ApplicationAttribute-enum
  // Setting the application to be a plugin will avoid the loading of qt_menu.nib files
  QCoreApplication::setAttribute(Qt::AA_MacPluginApplication, true);
  #endif
  QApplication app(argc, argv);
  
  // Initialize resources in static libs
  Q_INIT_RESOURCE(CTKAppLauncherBase);
  
  ctkAppLauncher appLauncher(app);
  
  QTimer::singleShot(0, &appLauncher, SLOT(startLauncher()));

  return app.exec();
}

#if defined (_WIN32)
int __stdcall WinMain(HINSTANCE hInstance,
                      HINSTANCE hPrevInstance,
                      LPSTR lpCmdLine, int nShowCmd)
{
  Q_UNUSED(hInstance);
  Q_UNUSED(hPrevInstance);
  Q_UNUSED(nShowCmd);

  int argc;
  char **argv;
  ctkCommandLineParser::convertWindowsCommandLineToUnixArguments(
    lpCmdLine, &argc, &argv);

  int ret = appLauncherMain(argc, argv);

  for (int i = 0; i < argc; i++)
    {
    delete [] argv[i];
    }
  delete [] argv;

  return ret;
}
#else
int main(int argc, char *argv[])
{
  return appLauncherMain(argc, argv);
}
#endif
