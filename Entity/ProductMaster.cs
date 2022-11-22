using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace AKStore.Entity
{
    public class ProductMaster
    {
        public int Id { get; set; }
        public int DistributorId { get; set; }
        [NotMapped]
        public string CompanyName { get; set; }
        [NotMapped]
        public string CategoryName { get; set; }
        public int? CategoryId { get; set; }
        public int? CompanyId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal SellPrice { get; set; }
        public int DiscountType { get; set; }
        public decimal DiscountInNumbers { get; set; }
        public int MinQuantityForDiscount { get; set; }
        [NotMapped]
        public int? OrderedQuantity { get; set; }
        public string FilePath { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? InsertedByUserId { get; set; }
        public int? UpdatedByUserId { get; set; }
        public bool? HasDiscount { get; set; }
    }
}
