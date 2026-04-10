namespace EcommerceAPI.Models
{
    public class OrderDto
    {
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
    }
}