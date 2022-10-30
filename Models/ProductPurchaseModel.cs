using System;
namespace AKStore.Models
{
    public class ProductPurchaseModel
    {
        public int Id { get; set; }
        public int? ProductId { get; set; }
        public string ProductName { get; set; }
        public decimal? PurchasePrice { get; set; }
        public int? Quantity { get; set; }
        public string BatchNo { get; set; }
        public string AddedBy { get; set; }
        public DateTime? AddedDate { get; set; }
        public string UpdatedBy { get; set; }
        public DateTime? UpdatedDate { get; set; }
    }
}
