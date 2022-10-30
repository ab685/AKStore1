using System;

namespace AKStore.Entity
{
    public class ProductPurchase
    {
        #region Instance Properties

        public int Id { get; set; }

        public int? ProductId { get; set; }

        public decimal? PurchasePrice { get; set; }

        public int? Quantity { get; set; }

        public string BatchNo { get; set; }

        public int? InsertedByUserId { get; set; }

        public DateTime? InsertedDate { get; set; }

        public int? UpdatedByUserId { get; set; }

        public DateTime? UpdatedDate { get; set; }

        #endregion Instance Properties
    }
}
