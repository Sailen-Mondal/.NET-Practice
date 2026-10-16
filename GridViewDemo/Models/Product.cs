using System;

namespace Demo
{
    public class Product
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public int Price { get; set; }
    }

    public class ProductDetailViewModel
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public int Price { get; set; }
        public string Color { get; set; }
        public string Size { get; set; }
        public decimal Weight { get; set; }
        public int QuantityInStock { get; set; }
        public bool Discontinued { get; set; }
        public string Supplier { get; set; }
    }
}
