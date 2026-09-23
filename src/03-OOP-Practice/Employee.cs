namespace ConsoleApp2
{
    public class Employee
    {
        ~Employee()
        {

            Console.WriteLine("Destractor invoked");
            Console.ReadLine();
        }
        public Employee(int n)
        {
            Console.WriteLine("Constractor invoked!");
        }

    }
}
