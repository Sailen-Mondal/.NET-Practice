using ConsoleAppForPractice;

Console.WriteLine("Hello, World!");
Animal a = new Animal();
a.Eat();

Box<int> intBox = new Box<int>(100);
intBox.Display();

Box<string> stringBox = new Box<string>("Hello C#");
stringBox.Display();
