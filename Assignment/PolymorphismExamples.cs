namespace Assignment;

// Question 6: Compile-time and runtime polymorphism.
public class AreaCalculator
{
    // Compile-time polymorphism: same method name, different parameters.
    public double CalculateArea(double radius)
    {
        return Math.PI * radius * radius;
    }

    public double CalculateArea(double length, double width)
    {
        return length * width;
    }
}

public class Shape
{
    public virtual void Draw()
    {
        Console.WriteLine("Drawing a shape.");
    }
}

public class Circle : Shape
{
    public override void Draw()
    {
        Console.WriteLine("Drawing a circle.");
    }
}

public class Polygon : Shape
{
    public override void Draw()
    {
        Console.WriteLine("Drawing a polygon.");
    }
}
