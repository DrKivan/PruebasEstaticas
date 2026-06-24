using System;

namespace DemoAuditApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Ingrese su edad:");
            int edad = int.Parse(Console.ReadLine());
            if (edad > 18)
                Console.WriteLine("Acceso permitido");
            else
                Console.WriteLine("Acceso denegado");
        }
    }
}
