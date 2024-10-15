using System;
using System.Runtime.InteropServices;
using Microsoft.Windows.AppNotifications;
using Microsoft.Windows.AppNotifications.Builder;
using System.Windows.Forms;

public class BadgeManager
{
    [DllImport("user32.dll")]
    private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    public static void UpdateBadge(int count)
    {
        // Actualiza el badge en la barra de tareas
        var hwnd = FindWindow(null, "Your Application Title");

        if (hwnd != IntPtr.Zero)
        {
            // Aquí se establece el texto del badge
            // Utiliza el método adecuado para mostrar el badge
            AppNotificationManager.CreateToastNotification(CreateBadgeNotification(count));
        }
    }

    private static AppNotificationContent CreateBadgeNotification(int count)
    {
        var badgeContent = new AppNotificationContent
        {
            Badge = new AppNotificationBadge($"badge/{count}")
        };

        return badgeContent;
    }
}