namespace AKStore.Models
{
    public class StocksModel
    {
        public int Id { get; set; }
        public int? ProductId { get; set; }
        public string ProductName { get; set; }
        public string FilePath { get; set; }
        public int? Quantity { get; set; }
       
    }
}
