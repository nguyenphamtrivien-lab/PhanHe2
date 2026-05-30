using System;
using System.Windows.Forms;

namespace QLBV.UI
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Forms.frmLogin());
        }
    }
}
