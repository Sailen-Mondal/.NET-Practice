using System;
using System.IO;
using System.Web.UI;
using LINQDemo.Demos;

namespace LINQDemo
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Captures Console.WriteLine outputs while running ConsoleDemos.RunAll()
        /// and displays the results inside the terminal output box.
        /// </summary>
        protected void btnRunConsoleDemos_Click(object sender, EventArgs e)
        {
            var originalOut = Console.Out;
            try
            {
                using (StringWriter sw = new StringWriter())
                {
                    Console.SetOut(sw);
                    ConsoleDemos.RunAll();
                    Console.SetOut(originalOut);

                    litConsoleOutput.Text = Server.HtmlEncode(sw.ToString());
                    pnlConsoleOutput.Visible = true;
                }
            }
            finally
            {
                Console.SetOut(originalOut);
            }
        }
    }
}
