namespace ConsoleApp2
{
    internal class Program
    {

        static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");
            Employee employee=new Employee(9);
            Employee employee1 = new Employee(9);
            Employee employee2 = new Employee(9);
            Employee employee3 = new Employee(9);
            Employee employee4 = new Employee(9);
            Employee employee5 = new Employee(9);
            //Program obj2 = new Program();

            IShape[] shapes = { new Circle(), new Square() };

            foreach (var shape in shapes)
            {
                shape.Draw();
            }
            PartialClass obj = new PartialClass(69);
            obj.myMethod();

        }
    }
}
