using System;

namespace AKStore.Entity
{
    public class TransactionMaster
    {
        public int Id { get; set; }
        public int RetailerDetailsId { get; set; }
        public int CustomerId { get; set; }
        public decimal Amount { get; set; }
        public string Notes { get; set; }
        public DateTime TransactionDate { get; set; }
        public int InsertedByUserId { get; set; }
        public int UpdatedByUserId { get; set; }
        public DateTime InsertedDate { get; set; }
        public DateTime UpdatedDate { get; set; }
    }
}